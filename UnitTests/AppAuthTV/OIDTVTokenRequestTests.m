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
#import "Sources/AppAuthCore/OIDScopeUtilities.h"
#import "Sources/AppAuthTV/OIDTVAuthorizationRequest.h"
#import "Sources/AppAuthTV/OIDTVAuthorizationResponse.h"
#import "Sources/AppAuthTV/OIDTVServiceConfiguration.h"
#import "Sources/AppAuthTV/OIDTVTokenRequest.h"
#endif

// Ignore warnings about "Use of GNU statement expression extension" which is
// raised by our use of the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

/*! @brief Test value for the @c deviceAuthorizationEndpoint property.
 */
static NSString *const kTestDeviceAuthorizationEndpoint =
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

/*! @brief Test key for the @c additionalHeaders property.
 */
static NSString *const kTestAdditionalHeaderKey = @"B";

/*! @brief Test value for the @c additionalHeaders property.
 */
static NSString *const kTestAdditionalHeaderValue = @"2";

/*! @brief Test key for the @c clientID parameter in the HTTP request.
 */
static NSString *const kTestClientIDKey = @"client_id";

/*! @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientID = @"ClientID";

/*! @brief Test value for the @c clientSecret property.
 */
static NSString *const kTestClientSecret = @"ClientSecret";

/*! @brief Key for the @c deviceCode property for @c NSSecureCoding and the HTTP request body.
 */
static NSString *const kDeviceCodeKey = @"device_code";

/*! @brief Value for the @c deviceCode key in the HTTP request body.
 */
static NSString *const kDeviceCodeValue = @"DeviceCode";

/*! @brief Key for the @c grantType property for @c NSSecureCoding and the HTTP request body.
 */
static NSString *const kGrantTypeKey = @"grant_type";

/*! @brief Value for the @c grant_type key in the HTTP request body
 *  @see https://tools.ietf.org/html/rfc8628#section-3.4
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
  NSURL *deviceAuthorizationEndpoint = [NSURL URLWithString:kTestDeviceAuthorizationEndpoint];

  OIDTVServiceConfiguration *configuration = [[OIDTVServiceConfiguration alloc]
      initWithDeviceAuthorizationEndpoint:deviceAuthorizationEndpoint
                            tokenEndpoint:tokenEndpoint];
  return configuration;
}

- (OIDTVTokenRequest *)testTokenRequest {
  OIDTVServiceConfiguration *service = [self testServiceConfiguration];
  return [[OIDTVTokenRequest alloc]
      initWithConfiguration:service
                 deviceCode:kDeviceCodeValue
                   clientID:kTestClientID
               clientSecret:kTestClientSecret
       additionalParameters:@{kTestAdditionalParameterKey : kTestAdditionalParameterValue}
          additionalHeaders:@{kTestAdditionalHeaderKey : kTestAdditionalHeaderValue}];
}

/*! @brief Tests the initializer
*/
- (void)testInitializer {
  OIDTVTokenRequest *request = [self testTokenRequest];
  NSURL *requestDeviceAuthorizationEndpoint =
      ((OIDTVServiceConfiguration *)request.configuration).deviceAuthorizationEndpoint;

  XCTAssertEqualObjects(requestDeviceAuthorizationEndpoint,
                        [self testServiceConfiguration].deviceAuthorizationEndpoint);
  XCTAssertEqualObjects(request.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(request.grantType, kOIDTVDeviceTokenGrantType);
  XCTAssertEqualObjects(request.clientID, kTestClientID);
  XCTAssertEqualObjects(request.clientSecret, kTestClientSecret);
  XCTAssertEqualObjects(request.additionalParameters,
                        @{kTestAdditionalParameterKey:kTestAdditionalParameterValue});
  XCTAssertEqualObjects(request.additionalHeaders,
                        @{kTestAdditionalHeaderKey:kTestAdditionalHeaderValue});
}

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
 *      process and checking to make sure the source and destination both contain the @c deviceCode.
 */
- (void)testCopying {
  OIDTVTokenRequest *request = [self testTokenRequest];
  OIDTVTokenRequest *requestCopy = [request copy];

  XCTAssertEqualObjects(requestCopy.deviceCode, request.deviceCode);
}

/*! @brief Tests the @c NSSecureCoding implementation by round-tripping an instance through the
 *      coding process and checking to make sure the source and destination both contain the
 *      @c deviceCode
 */
- (void)testSecureCoding {
  OIDTVTokenRequest *request = [self testTokenRequest];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
  OIDTVTokenRequest *requestDecoded = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  XCTAssertEqualObjects(requestDecoded.deviceCode, request.deviceCode);
}

/*! @brief Tests the @c URLRequest method to verify that the body parameters include the correct
 *      grant type, device code and additional parameters.
 */
- (void)testURLRequest {
  OIDTVTokenRequest *request = [self testTokenRequest];

  NSURLRequest *URLRequest = [request URLRequest];

  NSDictionary<NSString *, NSString *> *bodyParameters =
      [self bodyParametersFromURLRequest:URLRequest];
  
  // Since clientSecret is present, we will not need to check for client_id
  // as that will be passed in using HTTP Basic Authentication
  
  NSDictionary<NSString *, NSString *> *expectedParameters = @{
    kGrantTypeKey : kOIDTVDeviceTokenGrantType,
    kDeviceCodeKey : kDeviceCodeValue,
    kTestAdditionalParameterKey : kTestAdditionalParameterValue
  };

  XCTAssertEqualObjects(bodyParameters, expectedParameters);
}

@end

#pragma GCC diagnostic pop
