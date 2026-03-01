/*! @file OIDTVAuthorizationResponseTests.m
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

#import "OIDTVAuthorizationResponseTests.h"

#if SWIFT_PACKAGE
@import AppAuthTV;
#else
#import "Sources/AppAuthCore/OIDScopeUtilities.h"
#import "Sources/AppAuthCore/OIDURLQueryComponent.h"
#import "Sources/AppAuthTV/OIDTVAuthorizationRequest.h"
#import "Sources/AppAuthTV/OIDTVAuthorizationResponse.h"
#import "Sources/AppAuthTV/OIDTVServiceConfiguration.h"
#import "Sources/AppAuthTV/OIDTVTokenRequest.h"
#endif

/*! @brief Test value for the @c deviceAuthorizationEndpoint property.
 */
static NSString *const kTestDeviceAuthorizationEndpoint = @"https://www.example.com/device/code";

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

/*! @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientID = @"ClientID";

/*! @brief Test value for the @c clientSecret property.
 */
static NSString *const kTestClientSecret = @"ClientSecret";

/*! @brief Key for the @c verificationURI property.
 */
static NSString *const kVerificationURIKey = @"verification_uri";

/*! @brief Alternative key for the @c verificationURI property. If "verification_uri" is not found
        in the response, a "verification_url" key is considered equivalent.
 */
static NSString *const kVerificationURIAlternativeKey = @"verification_url";

/*! @brief Test value for the @c verificationURI property.
 */
static NSString *const kTestVerificationURI = @"https://www.example.com/device";

/*! @brief Key for the @c verificationURIComplete property.
 */
static NSString *const kVerificationURICompleteKey = @"verification_uri_complete";

/*! @brief Test value for the @c verificationURIComplete property.
 */
static NSString *const kTestVerificationURIComplete = @"https://www.example.com/device/UserCode";

/*! @brief Key for the @c userCode property.
 */
static NSString *const kUserCodeKey = @"user_code";

/*! @brief Test value for the @c userCode property.
 */
static NSString *const kTestUserCode = @"UserCode";

/*! @brief Key for the @c deviceCode property.
 */
static NSString *const kDeviceCodeKey = @"device_code";

/*! @brief Test value for the @c deviceCode property.
 */
static NSString *const kTestDeviceCode = @"DeviceCode";

/*! @brief Key for the @c expirationDate property.
 */
static NSString *const kExpiresInKey = @"expires_in";

/*! @brief Test lifetime value used for the @c expirationDate property.
 */
static long long const kTestExpiresIn = 1800;

/*! @brief Key for the @c interval property.
 */
static NSString *const kIntervalKey = @"interval";

/*! @brief Test value for the @c interval property.
 */
static int const kTestInterval = 5;

@implementation OIDTVAuthorizationResponseTests

- (OIDTVServiceConfiguration *)testServiceConfiguration {
  NSURL *tokenEndpoint = [NSURL URLWithString:kTestTokenEndpoint];
  NSURL *deviceAuthorizationEndpoint = [NSURL URLWithString:kTestDeviceAuthorizationEndpoint];

  OIDTVServiceConfiguration *configuration =
      [[OIDTVServiceConfiguration alloc] initWithDeviceAuthorizationEndpoint:deviceAuthorizationEndpoint
                                                           tokenEndpoint:tokenEndpoint];
  return configuration;
}

- (OIDTVAuthorizationRequest *)testAuthorizationRequest {
  OIDTVAuthorizationRequest *request =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:[self testServiceConfiguration]
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:nil
                                          additionalParameters:nil];
  return request;
}

/*! @brief Returns an @c OIDTVAuthorizationResponse instance using the standard key for
        @c verificationURI, with a @c verificationURIComplete value and additional parameter.
    @returns an @c OIDTVAuthorizationResponse instance
*/
- (OIDTVAuthorizationResponse *)testAuthorizationResponse {
  OIDTVAuthorizationResponse *response = [[OIDTVAuthorizationResponse alloc]
      initWithRequest:[self testAuthorizationRequest]
           parameters:@{
             kVerificationURIKey : kTestVerificationURI,
             kVerificationURICompleteKey : kTestVerificationURIComplete,
             kUserCodeKey : kTestUserCode,
             kDeviceCodeKey : kTestDeviceCode,
             kExpiresInKey : @(kTestExpiresIn),
             kIntervalKey : @(kTestInterval),
             kTestAdditionalParameterKey : kTestAdditionalParameterValue
           }];
  return response;
}

/*! @brief Tests the initializer using the standard key for @c verificationURI.
 */
- (void)testInitializer {
  OIDTVAuthorizationResponse *response = [self testAuthorizationResponse];

  NSDictionary<NSString *, NSString *> *testAdditionalParameters =
      @{kTestAdditionalParameterKey : kTestAdditionalParameterValue};

  XCTAssertEqualObjects(response.verificationURI, kTestVerificationURI);
  XCTAssertEqualObjects(response.verificationURIComplete, kTestVerificationURIComplete);
  XCTAssertEqualObjects(response.userCode, kTestUserCode);
  XCTAssertEqualObjects(response.deviceCode, kTestDeviceCode);
  XCTAssertEqualObjects(response.interval, @(kTestInterval));
  XCTAssertEqualObjects(response.additionalParameters, testAdditionalParameters);

  // Should be ~ kExpiresInValue seconds. Avoiding swizzling NSDate here for certainty
  // to keep dependencies down, and simply making an assumption that this check will be executed
  // relatively quickly after the initialization above (less than 5 seconds.)
  NSTimeInterval expiration = [response.expirationDate timeIntervalSinceNow];
  XCTAssert(expiration > kTestExpiresIn - 5 && expiration <= kTestExpiresIn);
}

/*! @brief Tests the initializer using the alternative key for @c verificationURI.
 */
- (void)testInitializerAlternativeKey {
  OIDTVAuthorizationResponse *response = [[OIDTVAuthorizationResponse alloc]
      initWithRequest:[self testAuthorizationRequest]
           parameters:@{
             kVerificationURIAlternativeKey : kTestVerificationURI,
             kVerificationURICompleteKey : kTestVerificationURIComplete,
             kUserCodeKey : kTestUserCode,
             kDeviceCodeKey : kTestDeviceCode,
             kExpiresInKey : @(kTestExpiresIn),
             kIntervalKey : @(kTestInterval),
             kTestAdditionalParameterKey : kTestAdditionalParameterValue
           }];

  NSDictionary<NSString *, NSString *> *testAdditionalParameters =
      @{kTestAdditionalParameterKey : kTestAdditionalParameterValue};

  // Tests that the alternative key used above maps to the verificationURI property, so
  // subsequent tests can simply test using [self testAuthorizationResponse] which uses
  // the standard key.
  XCTAssertEqualObjects(response.verificationURI, kTestVerificationURI);

  XCTAssertEqualObjects(response.verificationURIComplete, kTestVerificationURIComplete);
  XCTAssertEqualObjects(response.userCode, kTestUserCode);
  XCTAssertEqualObjects(response.deviceCode, kTestDeviceCode);
  XCTAssertEqualObjects(response.interval, @(kTestInterval));
  XCTAssertEqualObjects(response.additionalParameters, testAdditionalParameters);

  // Should be ~ kExpiresInValue seconds. Avoiding swizzling NSDate here for certainty
  // to keep dependencies down, and simply making an assumption that this check will be executed
  // relatively quickly after the initialization above (less than 5 seconds.)
  NSTimeInterval expiration = [response.expirationDate timeIntervalSinceNow];
  XCTAssert(expiration > kTestExpiresIn - 5 && expiration <= kTestExpiresIn);
}

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
 *      process and checking to make sure the source and destination are equivalent.
 */
- (void)testCopying {
  OIDTVAuthorizationResponse *response = [self testAuthorizationResponse];
  OIDTVAuthorizationResponse *responseCopy = [response copy];

  NSDictionary<NSString *, NSString *> *testAdditionalParameters =
      @{kTestAdditionalParameterKey : kTestAdditionalParameterValue};

  XCTAssertEqualObjects(responseCopy.request, response.request);
  XCTAssertEqualObjects(responseCopy.deviceCode, kTestDeviceCode);
  XCTAssertEqualObjects(responseCopy.interval, @(kTestInterval));
  XCTAssertEqualObjects(responseCopy.userCode, kTestUserCode);
  XCTAssertEqualObjects(responseCopy.verificationURIComplete, kTestVerificationURIComplete);
  XCTAssertEqualObjects(responseCopy.verificationURI, kTestVerificationURI);
  XCTAssertEqualObjects(responseCopy.additionalParameters, testAdditionalParameters);
}

/*! @brief Tests the @c NSSecureCoding implementation by round-tripping an instance through the
 *      coding process and checking to make sure the source and destination are equivalent.
 */
- (void)testSecureCoding {
  OIDTVAuthorizationResponse *response = [self testAuthorizationResponse];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:response];
  OIDTVAuthorizationResponse *responseCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  NSDictionary<NSString *, NSString *> *testAdditionalParameters =
      @{kTestAdditionalParameterKey : kTestAdditionalParameterValue};

  // Not a full test of the request deserialization, but should be sufficient as a smoke test
  // to make sure the request IS actually getting serialized and deserialized in the
  // NSSecureCoding implementation. We'll leave it up to the OIDTVAuthorizationRequest tests to make
  // sure the NSSecureCoding implementation of that class is correct.
  XCTAssertNotNil(responseCopy.request);

  XCTAssertEqualObjects(responseCopy.deviceCode, kTestDeviceCode);
  XCTAssertEqualObjects(responseCopy.interval, @(kTestInterval));
  XCTAssertEqualObjects(responseCopy.userCode, kTestUserCode);
  XCTAssertEqualObjects(responseCopy.verificationURIComplete, kTestVerificationURIComplete);
  XCTAssertEqualObjects(responseCopy.verificationURI, kTestVerificationURI);
  XCTAssertEqualObjects(responseCopy.additionalParameters, testAdditionalParameters);
}

/*! @brief Tests the @c tokenPollRequest method that takes no additional parameters.
 */
- (void)testTokenPollRequest {
  OIDTVAuthorizationResponse *testResponse = [self testAuthorizationResponse];

  OIDTVTokenRequest *pollRequest = [testResponse tokenPollRequest];

  XCTAssertEqualObjects(pollRequest.deviceCode, kTestDeviceCode);
  XCTAssertEqualObjects(pollRequest.clientID, kTestClientID);
  XCTAssertEqualObjects(pollRequest.clientSecret, kTestClientSecret);
  XCTAssertEqualObjects(pollRequest.additionalParameters, @{});
}

/*! @brief Tests the @c testTokenPollRequestWithAdditionalParametersAdditionalHeaders method with one additional
         parameter and one additional header.
 */
- (void)testTokenPollRequestWithAdditionalParametersAdditionalHeaders {
  OIDTVAuthorizationResponse *testResponse = [self testAuthorizationResponse];

  NSDictionary<NSString *, NSString *> *testAdditionalParameters =
      @{kTestAdditionalParameterKey : kTestAdditionalParameterValue};
  
  NSDictionary<NSString *, NSString *> *testAdditionalHeaders =
      @{kTestAdditionalHeaderKey : kTestAdditionalHeaderValue};

  OIDTVTokenRequest *pollRequest =
      [testResponse tokenPollRequestWithAdditionalParameters:testAdditionalParameters additionalHeaders:testAdditionalHeaders];

  XCTAssertEqualObjects(pollRequest.deviceCode, kTestDeviceCode);
  XCTAssertEqualObjects(pollRequest.clientID, kTestClientID);
  XCTAssertEqualObjects(pollRequest.clientSecret, kTestClientSecret);
  XCTAssertEqualObjects(pollRequest.additionalParameters, testAdditionalParameters);
  XCTAssertEqualObjects(pollRequest.additionalHeaders, testAdditionalHeaders);
}

@end
