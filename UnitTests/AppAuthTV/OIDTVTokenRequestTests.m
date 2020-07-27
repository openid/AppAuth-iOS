/*! @file OIDTVTokenRequestTests.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2020 Google Inc. All Rights Reserved.
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

#import "OIDTVTokenRequestTests.h"

#import "OIDTVTokenRequest.h"

#if SWIFT_PACKAGE
@import AppAuthTV;
#else
#import "Source/AppAuthCore/OIDScopeUtils.h"
#import "Source/AppAuthTV/OIDTVAuthorizationResponse.h"
#import "Source/AppAuthTV/OIDTVServiceConfiguration.h"
#import "Source/AppAuthTV/OIDTVTokenRequest.h"
#endif

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

/*! @brief Test value for the @c TVAuthorizationEndpoint property.
 */
static NSString *const kTestTVAuthorizationEndpoint = @"https://www.example.com/device/code";

/*! @brief Test value for the @c tokenEndpoint property.
 */
static NSString *const kTestTokenEndpoint = @"https://www.example.com/token";

/*! @brief Test key for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterKey = @"A";

/*! @brief Test value for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterValue = @"1";

/*! @brief Test key for the @c clientID parameter in the HTTP request.
 */
static NSString *const kTestClientIDKey = @"client_id";

/*! @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientID = @"ClientID";

/*! @brief Test value for the @c clientSecret property.
 */
static NSString *const kTestClientSecret = @"ClientSecret";

/*! @brief Test key for the @c scope parameter in the HTTP request.
 */
static NSString *const kTestScopeKey = @"scope";

/*! @brief Test value for the @c scope property.
 */
static NSString *const kTestScope = @"Scope";

/*! @brief Test value for the @c scope property.
 */
static NSString *const kTestScopeA = @"ScopeA";

/*! @brief Expected HTTP Method for the authorization @c URLRequest
 */
static NSString *const kHTTPPost = @"POST";

/*! @brief Expected @c ContentType header key for the authorization @c URLRequest
 */
static NSString *const kHTTPContentTypeHeaderKey = @"Content-Type";

/*! @brief Expected @c ContentType header value for the authorization @c URLRequest
 */
static NSString *const kHTTPContentTypeHeaderValue =
    @"application/x-www-form-urlencoded; charset=UTF-8";
@implementation OIDTVTokenRequestTests

- (OIDTVServiceConfiguration *)testServiceConfiguration {
  NSURL *tokenEndpoint = [NSURL URLWithString:kTestTokenEndpoint];
  NSURL *TVAuthorizationEndpoint = [NSURL URLWithString:kTestTVAuthorizationEndpoint];

  // Pass in an empty authorizationEndpoint since only the TVAuthorizationEndpoint and tokenEndpoint
  // are used for the TV authentication flow.
  OIDTVServiceConfiguration *configuration = [[OIDTVServiceConfiguration alloc]
      initWithAuthorizationEndpoint:[[NSURL alloc] initWithString:@""]
            TVAuthorizationEndpoint:TVAuthorizationEndpoint
                      tokenEndpoint:tokenEndpoint];
  return configuration;
}



- (OIDTVAuthorizationResponse *)testAuthResponse {
  OIDTVServiceConfiguration *serviceConfiguration = [self testServiceConfiguration];
  NSArray<NSString *> *testScopes = @[ kTestScope, kTestScopeA ];
  NSString *testScopeString = [OIDScopeUtilities scopesWithArray:testScopes];
  NSDictionary<NSString *, NSString *> *testAdditionalParameters =
      @{kTestAdditionalParameterKey : kTestAdditionalParameterValue};

  return [[OIDTVAuthorizationRequest alloc] initWithConfiguration:serviceConfiguration
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:testScopes
                                          additionalParameters:testAdditionalParameters];
}

-(instancetype) testInstance {
  
}

@end

#pragma GCC diagnostic pop
