/*! @file OIDExternalUserAgentIOSTests.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2026 Google Inc. All Rights Reserved.
    @copydetails
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
 */

#import <TargetConditionals.h>

// These tests exercise iOS-only code. They are excluded from the Swift package's test targets,
// which only depend on AppAuthCore.
#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST && !SWIFT_PACKAGE

#import <XCTest/XCTest.h>

#import <AuthenticationServices/AuthenticationServices.h>

#import "Sources/AppAuth/iOS/OIDExternalUserAgentIOS.h"
#import "Sources/AppAuthCore/OIDAuthorizationRequest.h"
#import "Sources/AppAuthCore/OIDEndSessionRequest.h"
#import "Sources/AppAuthCore/OIDExternalUserAgentRequest.h"
#import "Sources/AppAuthCore/OIDResponseTypes.h"
#import "Sources/AppAuthCore/OIDScopes.h"
#import "Sources/AppAuthCore/OIDServiceConfiguration.h"

@interface OIDExternalUserAgentIOS (Testing)
  // expose private method for simple testing
+ (nullable ASWebAuthenticationSessionCallback *)HTTPSCallbackForRequest:
    (nonnull id<OIDExternalUserAgentRequest>)request API_AVAILABLE(ios(17.4));
@end

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

/*! @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientID = @"ClientID";

/*! @brief Test value for the @c authorizationEndpoint property.
 */
static NSString *const kTestAuthorizationEndpoint = @"https://accounts.example.com/authorize";

/*! @brief Test value for the @c tokenEndpoint property.
 */
static NSString *const kTestTokenEndpoint = @"https://accounts.example.com/token";

/*! @brief Test value for the @c idTokenHint parameter.
 */
static NSString *const kTestIDTokenHint = @"id-token-hint";

/*! @brief A request of a type unknown to @c OIDExternalUserAgentIOS.HTTPSCallbackForRequest:.
 */
@interface OIDUnsupportedExternalUserAgentRequest : NSObject <OIDExternalUserAgentRequest>
@end

@implementation OIDUnsupportedExternalUserAgentRequest

- (NSURL *)externalUserAgentRequestURL {
  return [NSURL URLWithString:kTestAuthorizationEndpoint];
}

- (NSString *)redirectScheme {
  return @"https";
}

@end

/*! @brief Unit tests for the iOS external user agent's HTTPS (universal link) callback support.
 */
@interface OIDExternalUserAgentIOSTests : XCTestCase
@end

@implementation OIDExternalUserAgentIOSTests

- (OIDAuthorizationRequest *)authorizationRequestWithRedirectURL:(NSURL *)redirectURL {
  OIDServiceConfiguration *configuration = [[OIDServiceConfiguration alloc]
      initWithAuthorizationEndpoint:[NSURL URLWithString:kTestAuthorizationEndpoint]
                      tokenEndpoint:[NSURL URLWithString:kTestTokenEndpoint]];
  return [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                       clientId:kTestClientID
                                                         scopes:@[ OIDScopeOpenID ]
                                                    redirectURL:redirectURL
                                                   responseType:OIDResponseTypeCode
                                           additionalParameters:nil];
}

/*! @brief An authorization request with an HTTPS redirect gets a callback matching that redirect.
 */
- (void)testHTTPSCallbackForAuthorizationRequest {
  if (@available(iOS 17.4, *)) {
    OIDAuthorizationRequest *request = [self authorizationRequestWithRedirectURL:
        [NSURL URLWithString:@"https://client.example.com/oauth2redirect"]];
    ASWebAuthenticationSessionCallback *callback = [OIDExternalUserAgentIOS HTTPSCallbackForRequest:request];
    XCTAssertNotNil(callback);
    XCTAssertTrue([callback matchesURL:
        [NSURL URLWithString:@"https://client.example.com/oauth2redirect?code=1234"]]);
    XCTAssertFalse([callback matchesURL:
        [NSURL URLWithString:@"https://other.example.com/oauth2redirect?code=1234"]]);
  } else {
    XCTSkip(@"ASWebAuthenticationSessionCallback requires iOS 17.4.");
  }
}

/*! @brief An end session request with an HTTPS post-logout redirect gets a callback rather than
        crashing on an unchecked cast.
 */
- (void)testHTTPSCallbackForEndSessionRequest {
  if (@available(iOS 17.4, *)) {
    OIDServiceConfiguration *configuration = [[OIDServiceConfiguration alloc]
        initWithAuthorizationEndpoint:[NSURL URLWithString:kTestAuthorizationEndpoint]
                        tokenEndpoint:[NSURL URLWithString:kTestTokenEndpoint]];
    OIDEndSessionRequest *request = [[OIDEndSessionRequest alloc]
        initWithConfiguration:configuration
                  idTokenHint:kTestIDTokenHint
        postLogoutRedirectURL:[NSURL URLWithString:@"https://client.example.com/signout"]
         additionalParameters:nil];
    ASWebAuthenticationSessionCallback *callback = [OIDExternalUserAgentIOS HTTPSCallbackForRequest:request];
    XCTAssertNotNil(callback);
    XCTAssertTrue([callback matchesURL:
        [NSURL URLWithString:@"https://client.example.com/signout?state=1234"]]);
  } else {
    XCTSkip(@"ASWebAuthenticationSessionCallback requires iOS 17.4.");
  }
}

/*! @brief A custom scheme redirect is not a universal link, so no callback is created.
 */
- (void)testNoHTTPSCallbackForCustomSchemeRedirect {
  if (@available(iOS 17.4, *)) {
    OIDAuthorizationRequest *request = [self authorizationRequestWithRedirectURL:
        [NSURL URLWithString:@"com.example.app:/oauth2redirect"]];
    XCTAssertNil([OIDExternalUserAgentIOS HTTPSCallbackForRequest:request]);
  } else {
    XCTSkip(@"ASWebAuthenticationSessionCallback requires iOS 17.4.");
  }
}

/*! @brief An HTTPS redirect without a host can never be matched, so no callback is created.
 */
- (void)testNoHTTPSCallbackForRedirectWithoutHost {
  if (@available(iOS 17.4, *)) {
    OIDAuthorizationRequest *request = [self authorizationRequestWithRedirectURL:
        [NSURL URLWithString:@"https:///oauth2redirect"]];
    XCTAssertNil([OIDExternalUserAgentIOS HTTPSCallbackForRequest:request]);
  } else {
    XCTSkip(@"ASWebAuthenticationSessionCallback requires iOS 17.4.");
  }
}

/*! @brief An HTTPS redirect without a path matches on the root path.
 */
- (void)testHTTPSCallbackForRedirectWithoutPath {
  if (@available(iOS 17.4, *)) {
    OIDAuthorizationRequest *request = [self authorizationRequestWithRedirectURL:
        [NSURL URLWithString:@"https://client.example.com"]];
    ASWebAuthenticationSessionCallback *callback = [OIDExternalUserAgentIOS HTTPSCallbackForRequest:request];
    XCTAssertNotNil(callback);
    XCTAssertTrue([callback matchesURL:
        [NSURL URLWithString:@"https://client.example.com/?code=1234"]]);
    XCTAssertFalse([callback matchesURL:
        [NSURL URLWithString:@"https://client.example.com/oauth2redirect?code=1234"]]);
  } else {
    XCTSkip(@"ASWebAuthenticationSessionCallback requires iOS 17.4.");
  }
}

/*! @brief Request types without a known redirect URL get no callback rather than crashing.
 */
- (void)testNoHTTPSCallbackForUnsupportedRequestType {
  if (@available(iOS 17.4, *)) {
    id<OIDExternalUserAgentRequest> request =
        [[OIDUnsupportedExternalUserAgentRequest alloc] init];
    XCTAssertNil([OIDExternalUserAgentIOS HTTPSCallbackForRequest:request]);
  } else {
    XCTSkip(@"ASWebAuthenticationSessionCallback requires iOS 17.4.");
  }
}

@end

#pragma GCC diagnostic pop

#endif // TARGET_OS_IOS && !TARGET_OS_MACCATALYST && !SWIFT_PACKAGE
