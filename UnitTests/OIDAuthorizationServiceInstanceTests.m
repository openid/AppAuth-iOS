/*! @file OIDAuthorizationServiceInstanceTests.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2026 The AppAuth Authors. All Rights Reserved.
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

#import <XCTest/XCTest.h>

#import "OIDAuthorizationRequestTests.h"
#import "OIDEndSessionRequestTests.h"
#import "OIDTokenRequestTests.h"

#if SWIFT_PACKAGE
@import AppAuthCore;
#else
#import "Sources/AppAuthCore/OIDAuthorizationResponse.h"
#import "Sources/AppAuthCore/OIDAuthorizationService.h"
#import "Sources/AppAuthCore/OIDEndSessionResponse.h"
#import "Sources/AppAuthCore/OIDError.h"
#import "Sources/AppAuthCore/OIDExternalUserAgent.h"
#import "Sources/AppAuthCore/OIDExternalUserAgentSession.h"
#import "Sources/AppAuthCore/OIDTokenRequest.h"
#import "Sources/AppAuthCore/OIDTokenResponse.h"
#endif

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

NS_ASSUME_NONNULL_BEGIN

/*! @brief An external user agent that refuses to present anything.
 */
@interface OIDRefusingExternalUserAgent : NSObject <OIDExternalUserAgent>
@end

@implementation OIDRefusingExternalUserAgent

- (BOOL)presentExternalUserAgentRequest:(id<OIDExternalUserAgentRequest>)request
                                session:(id<OIDExternalUserAgentSession>)session {
  return NO;
}

- (void)dismissExternalUserAgentAnimated:(BOOL)animated completion:(void (^)(void))completion {
  if (completion) {
    completion();
  }
}

@end

/*! @brief Records the three-argument token request instead of performing it.
 */
@interface OIDTokenRecordingAuthorizationService : OIDAuthorizationService

/*! @brief How many three-argument token requests were made. */
@property(nonatomic, readonly) NSUInteger tokenRequestCount;

/*! @brief The request passed to the most recent three-argument token request. */
@property(nonatomic, readonly, nullable) OIDTokenRequest *lastTokenRequest;

/*! @brief The authorization response passed to the most recent three-argument token request. */
@property(nonatomic, readonly, nullable)
    OIDAuthorizationResponse *lastOriginalAuthorizationResponse;

@end

@implementation OIDTokenRecordingAuthorizationService

- (void)performTokenRequest:(OIDTokenRequest *)request
    originalAuthorizationResponse:(nullable OIDAuthorizationResponse *)authorizationResponse
                         callback:(OIDTokenCallback)callback {
  _tokenRequestCount++;
  _lastTokenRequest = request;
  _lastOriginalAuthorizationResponse = authorizationResponse;
}

@end

/*! @brief Unit tests for the instance methods of @c OIDAuthorizationService.
 */
@interface OIDAuthorizationServiceInstanceTests : XCTestCase
@end

@implementation OIDAuthorizationServiceInstanceTests

/*! @brief A refused authorization request fails with @c OIDErrorCodeSafariOpenError. */
- (void)testPresentAuthorizationRequestFailsWhenUserAgentRefuses {
  OIDAuthorizationService *service = [[OIDAuthorizationService alloc] init];
  OIDRefusingExternalUserAgent *userAgent = [[OIDRefusingExternalUserAgent alloc] init];
  __block OIDAuthorizationResponse *receivedResponse;
  __block NSError *receivedError;
  id<OIDExternalUserAgentSession> session =
      [service presentAuthorizationRequest:[OIDAuthorizationRequestTests testInstance]
                         externalUserAgent:userAgent
                                  callback:^(OIDAuthorizationResponse *_Nullable response,
                                             NSError *_Nullable error) {
        receivedResponse = response;
        receivedError = error;
      }];
  XCTAssertNotNil(session);
  XCTAssertNil(receivedResponse);
  XCTAssertEqualObjects(receivedError.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(receivedError.code, OIDErrorCodeSafariOpenError);
}

/*! @brief A refused end session request fails with @c OIDErrorCodeSafariOpenError. */
- (void)testPresentEndSessionRequestFailsWhenUserAgentRefuses {
  OIDAuthorizationService *service = [[OIDAuthorizationService alloc] init];
  OIDRefusingExternalUserAgent *userAgent = [[OIDRefusingExternalUserAgent alloc] init];
  __block OIDEndSessionResponse *receivedResponse;
  __block NSError *receivedError;
  id<OIDExternalUserAgentSession> session =
      [service presentEndSessionRequest:[OIDEndSessionRequestTests testInstance]
                      externalUserAgent:userAgent
                               callback:^(OIDEndSessionResponse *_Nullable response,
                                          NSError *_Nullable error) {
        receivedResponse = response;
        receivedError = error;
      }];
  XCTAssertNotNil(session);
  XCTAssertNil(receivedResponse);
  XCTAssertEqualObjects(receivedError.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(receivedError.code, OIDErrorCodeSafariOpenError);
}

/*! @brief The two-argument token request goes through the three-argument one, with no
        authorization response.
 */
- (void)testTwoArgumentTokenRequestCallsThreeArgumentTokenRequest {
  OIDTokenRecordingAuthorizationService *service =
      [[OIDTokenRecordingAuthorizationService alloc] init];
  OIDTokenRequest *request = [OIDTokenRequestTests testInstance];
  [service performTokenRequest:request
                      callback:^(OIDTokenResponse *_Nullable response,
                                 NSError *_Nullable error) {}];
  XCTAssertEqual(service.tokenRequestCount, 1u);
  XCTAssertEqual(service.lastTokenRequest, request);
  XCTAssertNil(service.lastOriginalAuthorizationResponse);
}

@end

NS_ASSUME_NONNULL_END

#pragma GCC diagnostic pop
