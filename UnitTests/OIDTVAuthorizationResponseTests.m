/*! @file OIDTVAuthorizationRequestTests.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2015 Google Inc. All Rights Reserved.
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

#import "OIDTVAuthorizationResponseTests.h"

#import "OIDAuthorizationResponseTests.h"
#import "OIDServiceConfigurationTests.h"
#import "OIDURLQueryComponent.h"

#import "OIDTVAuthorizationRequest.h"
#import "OIDTVServiceConfiguration.h"

#import "OIDTVAuthorizationResponse.h"

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

/*! @brief Test value for the @c refreshToken property.
 */
static NSString *const kRefreshTokenTestValue = @"refresh_token";

/*! @brief Test key for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterKey = @"A";

/*! @brief Test value for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterValue = @"1";


/*! @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientID = @"ClientID";

/*! @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientSecret = @"ClientSecret";

/*! @brief Test value for the @c scope property.
 */
static NSString *const kTestScope = @"Scope";

/*! @brief Test value for the @c scope property.
 */
static NSString *const kTestScopeA = @"ScopeA";

/*! @brief Test value for the @c authorizationEndpoint property.
 */
static NSString *const kInitializerTestTVAuthEndpoint = @"https://www.example.com/device/code";

/*! @brief Test value for the @c tokenEndpoint property.
 */
static NSString *const kInitializerTestTokenEndpoint = @"https://www.example.com/token";

static NSString *const testjson = @"";

@implementation OIDTVAuthorizationResponseTests

- (OIDTVServiceConfiguration *)testServiceConfiguration {
  NSURL *tokenEndpoint =
      [NSURL URLWithString:kInitializerTestTokenEndpoint];
  NSURL *TVAuthorizationEndpoint =
      [NSURL URLWithString:kInitializerTestTVAuthEndpoint];

  OIDTVServiceConfiguration *configuration =
      [[OIDTVServiceConfiguration alloc] initWithAuthorizationEndpoint:TVAuthorizationEndpoint
                                               TVAuthorizationEndpoint:TVAuthorizationEndpoint
                                                         tokenEndpoint:tokenEndpoint];
  return configuration;
}

- (OIDTVAuthorizationRequest *) authRequest {
  return [[OIDTVAuthorizationRequest alloc] initWithConfiguration:[self testServiceConfiguration]
                                                  clientId:kTestClientID
                                              clientSecret:kTestClientSecret
                                                    scopes:@[ kTestScope, kTestScopeA ]
                                      additionalParameters:nil];

}


- (void)testURLRequestBasicClientAuth {
  //OIDTVAuthorizationRequest *ar = [self authRequest];
  //NSURLRequest* urlRequest = [ar URLRequest];

}


@end

#pragma GCC diagnostic pop
