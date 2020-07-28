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
#if SWIFT_PACKAGE
@import AppAuthTV;
#else
#import "Source/AppAuthCore/OIDScopeUtilities.h"
#import "Source/AppAuthTV/OIDTVAuthorizationRequest.h"
#import "Source/AppAuthTV/OIDTVAuthorizationResponse.h"
#import "Source/AppAuthTV/OIDTVServiceConfiguration.h"
#import "Source/AppAuthTV/OIDTVTokenRequest.h"
#endif

// Ignore warnings about "Use of GNU statement expression extension" which is
// raised by our use of the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

/*! @brief Test value for the @c TVAuthorizationEndpoint property.
 */
static NSString *const kTestTVAuthorizationEndpoint =
    @"https://www.example.com/device/code";

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

/*! @brief The key for the @c deviceCode property for @c NSSecureCoding and
 * request body.
 */
static NSString *const kDeviceCodeKey = @"device_code";

/*! @brief The value for the @c deviceCode property for @c NSSecureCoding and
 * request body.
 */
static NSString *const kDeviceCodeValue = @"DEVICECODEEEE";

/*! @brief Key used to encode the @c grantType property for @c NSSecureCoding
 * and request body.
 */
static NSString *const kGrantTypeKey = @"grant_type";

/*! @brief Value for @c grant_type key in the request body
    @see https://tools.ietf.org/html/rfc8628#section-3.4
 */
static NSString *const kOIDTVDeviceTokenGrantType =
    @"urn:ietf:params:oauth:grant-type:device_code";

@implementation OIDTVTokenRequestTests

- (NSDictionary<NSString *, NSString *> *)bodyParametersFromURLRequest:
    (NSURLRequest *)URLRequest {
  NSString *bodyString = [[NSString alloc] initWithData:URLRequest.HTTPBody
                                               encoding:NSUTF8StringEncoding];
  NSArray<NSString *> *bodyParameterStrings =
      [bodyString componentsSeparatedByString:@"&"];

  NSMutableDictionary<NSString *, NSString *> *bodyParameters =
      [[NSMutableDictionary alloc] init];

  for (NSString *paramString in bodyParameterStrings) {
    NSArray<NSString *> *components =
        [paramString componentsSeparatedByString:@"="];

    if (components.count == 2) {
      bodyParameters[components[0]] = components[1];
    }
  }

  return bodyParameters;
}

- (OIDTVServiceConfiguration *)testServiceConfiguration {
  NSURL *tokenEndpoint = [NSURL URLWithString:kTestTokenEndpoint];
  NSURL *TVAuthorizationEndpoint =
      [NSURL URLWithString:kTestTVAuthorizationEndpoint];

  // Pass in an empty authorizationEndpoint since only the
  // TVAuthorizationEndpoint and tokenEndpoint are used for the TV
  // authentication flow.
  OIDTVServiceConfiguration *configuration = [[OIDTVServiceConfiguration alloc]
      initWithAuthorizationEndpoint:[[NSURL alloc] initWithString:@""]
            TVAuthorizationEndpoint:TVAuthorizationEndpoint
                      tokenEndpoint:tokenEndpoint];
  return configuration;
}

- (OIDTVTokenRequest *)testInstance {
  OIDTVServiceConfiguration *service = [self testServiceConfiguration];
  return [[OIDTVTokenRequest alloc]
      initWithConfiguration:service
                 deviceCode:kDeviceCodeValue
                   clientID:kTestClientID
               clientSecret:kTestClientSecret
       additionalParameters:@{
         kTestAdditionalParameterKey : kTestAdditionalParameterValue
       }];
}

- (void)testInitializer {
  OIDTVTokenRequest *request = [self testInstance];
  NSURL *requestTVAuthorizationEndpoint =
  ((OIDTVServiceConfiguration *)request.configuration).TVAuthorizationEndpoint;
  
  XCTAssertEqualObjects(requestTVAuthorizationEndpoint, [self testServiceConfiguration].TVAuthorizationEndpoint);
  XCTAssertEqualObjects(request.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(request.grantType, kOIDTVDeviceTokenGrantType);
  XCTAssertEqualObjects(request.clientID, kTestClientID);
  XCTAssertEqualObjects(request.clientSecret, kTestClientSecret);
  XCTAssertEqualObjects(request.additionalParameters, @{kTestAdditionalParameterKey:kTestAdditionalParameterValue});
}

// todo test the copy

- (void)testCopying {
  OIDTVTokenRequest *request = [self testInstance];
  OIDTVTokenRequest *requestCopy = [request copy];

  XCTAssertEqualObjects(requestCopy.deviceCode, request.deviceCode);
}
// todo test URLRequest includes the thing

- (void)testSecureCoding {
  OIDTVTokenRequest *request = [self testInstance];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
  OIDTVTokenRequest *requestDecoded =
      [NSKeyedUnarchiver unarchiveObjectWithData:data];
  XCTAssertEqualObjects(requestDecoded.deviceCode, request.deviceCode);
}

- (void)testURLRequest {
  OIDTVTokenRequest *request = [self testInstance];

  NSURLRequest *URLRequest =
      [request URLRequest];

  NSDictionary<NSString *, NSString *> *bodyParameters =
      [self bodyParametersFromURLRequest:URLRequest];
  NSDictionary<NSString *, NSString *> *expectedParameters = @{
    kGrantTypeKey : kOIDTVDeviceTokenGrantType,
    kDeviceCodeKey : kDeviceCodeValue,
    kTestAdditionalParameterKey : kTestAdditionalParameterValue
  };

  XCTAssertEqualObjects(bodyParameters, expectedParameters);
}

@end

#pragma GCC diagnostic pop
