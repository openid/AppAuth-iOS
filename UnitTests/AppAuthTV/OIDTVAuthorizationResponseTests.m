/*! @file OIDTVAuthorizationRequestTests.m
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
#import "Source/AppAuthCore/OIDScopeUtilities.h"
#import "Source/AppAuthCore/OIDURLQueryComponent.h"
#import "Source/AppAuthTV/OIDTVAuthorizationRequest.h"
#import "Source/AppAuthTV/OIDTVAuthorizationResponse.h"
#import "Source/AppAuthTV/OIDTVServiceConfiguration.h"
#import "Source/AppAuthTV/OIDTVTokenRequest.h"
#endif

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

/*! @brief The key for the @c verificationURI property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kVerificationURIKey = @"verification_uri";

/*! @brief An alternative key for the @c verificationURI property in the incoming parameters and for
        @c NSSecureCoding. If "verification_uri" is not found in the response, a "verification_url"
        key is considered equivalent. TODO: Update these comments..
 */
static NSString *const kVerificationURIAlternativeKey = @"verification_url";

/*! @brief The test value for the @c verificationURL and @c verificationURI property in the incoming parameters and for @c NSSecureCoding.
 */
static NSString *const kVerificationTestURL = @"https://www.example.com/device";

/*! @brief The key for the @c verificationURIComplete property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kVerificationURICompleteKey = @"verification_uri_complete";

/*! @brief The key for the @c verificationURIComplete property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kVerificationTestURIComplete = @"https://www.example.com/device/UserCode";

/*! @brief The key for the @c userCode property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kUserCodeKey = @"user_code";

/*! @brief The value for the @c userCode property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kUserCodeValue = @"UserCode";

/*! @brief The key for the @c deviceCode property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kDeviceCodeKey = @"device_code";

/*! @brief The value for the @c deviceCode property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kDeviceCodeValue = @"DeviceCode";

/*! @brief The key for the @c expirationDate property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kExpiresInKey = @"expires_in";

/*! @brief The value for the @c expirationDate property in the incoming parameters and for
        @c NSSecureCoding.
 */
static long long const kExpiresInValue = 1800;

/*! @brief The key for the @c interval property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kIntervalKey = @"interval";

/*! @brief The value for the @c interval property in the incoming parameters and for
        @c NSSecureCoding.
 */
static int const kIntervalValue = 5;

/*! @brief Key used to encode the @c additionalParameters property for @c NSSecureCoding
 */
static NSString *const kAdditionalParametersKey = @"additionalParameters";

/*! @brief Key used to encode the @c request property for @c NSSecureCoding
 */
static NSString *const kRequestKey = @"request";

@implementation OIDTVAuthorizationResponseTests

- (OIDTVServiceConfiguration *)testServiceConfiguration {
  NSURL *tokenEndpoint = [NSURL URLWithString:kTestTokenEndpoint];
  NSURL *TVAuthorizationEndpoint = [NSURL URLWithString:kTestTVAuthorizationEndpoint];

  // Pass in an empty authorizationEndpoint since only the TVAuthorizationEndpoint and tokenEndpoint
  // are used for the TV authentication flow.
  OIDTVServiceConfiguration *configuration =
      [[OIDTVServiceConfiguration alloc] initWithTVAuthorizationEndpoint:TVAuthorizationEndpoint
                                                         tokenEndpoint:tokenEndpoint];
  return configuration;
}

- (OIDTVAuthorizationRequest *)testAuthorizationRequest {
  return [[OIDTVAuthorizationRequest alloc] initWithConfiguration:[self testServiceConfiguration]
                                                         clientId:kTestClientID
                                                     clientSecret:kTestClientSecret
                                                           scopes:nil
                                             additionalParameters:nil];
}

- (OIDTVAuthorizationResponse *)testAuthorizationResponse {
  return 
      [[OIDTVAuthorizationResponse alloc] initWithRequest:[self testAuthorizationRequest]
                                               parameters:@{
                                                 kVerificationURIKey : kVerificationTestURL,
                                                 kVerificationURICompleteKey :kVerificationTestURIComplete,
                                                 kUserCodeKey : kUserCodeValue,
                                                 kDeviceCodeKey : kDeviceCodeValue,
                                                 kExpiresInKey : @(kExpiresInValue),
                                                 kIntervalKey : @(kIntervalValue),
                                                 kTestAdditionalParameterKey :kTestAdditionalParameterValue
                                               }];
}

-(void)testInitializerAlternativeKey {
  OIDTVAuthorizationResponse *response = [[OIDTVAuthorizationResponse alloc] initWithRequest:[self testAuthorizationRequest]
    parameters:@{
      kVerificationURIAlternativeKey : kVerificationTestURL,
      kVerificationURICompleteKey :kVerificationTestURIComplete,
      kUserCodeKey : kUserCodeValue,
      kDeviceCodeKey : kDeviceCodeValue,
      kExpiresInKey : @(kExpiresInValue),
      kIntervalKey : @(kIntervalValue),
      kTestAdditionalParameterKey :kTestAdditionalParameterValue
    }];

  XCTAssertEqualObjects(response.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(response.interval, @(kIntervalValue));
  XCTAssertEqualObjects(response.userCode, kUserCodeValue);
  XCTAssertEqualObjects(response.verificationURIComplete, kVerificationTestURIComplete);

  // This test confirms that "verification_url" maps to the "verificationURI" instance
  // variable, so subsequent tests can simply test on a reponse with "verification_uri"
  XCTAssertEqualObjects(response.verificationURI, kVerificationTestURL);

  // Should be ~ kExpiresInValue seconds. Avoiding swizzling NSDate here for certainty
  // to keep dependencies down, and simply making an assumption that this check will be executed
  // relatively quickly after the initialization above (less than 5 seconds.)
  NSTimeInterval expiration = [response.expirationDate timeIntervalSinceNow];
  XCTAssert(expiration > kExpiresInValue - 5 && expiration <= kExpiresInValue, @"");
}

-(void)testInitializer { //TODO: Test both variants, with the verification_uri and url...
  OIDTVAuthorizationResponse *response = [self testAuthorizationResponse];

  XCTAssertEqualObjects(response.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(response.interval, @(kIntervalValue));
  XCTAssertEqualObjects(response.userCode, kUserCodeValue);
  XCTAssertEqualObjects(response.verificationURIComplete, kVerificationTestURIComplete);
  XCTAssertEqualObjects(response.verificationURI, kVerificationTestURL);

  // Should be ~ kExpiresInValue seconds. Avoiding swizzling NSDate here for certainty
  // to keep dependencies down, and simply making an assumption that this check will be executed
  // relatively quickly after the initialization above (less than 5 seconds.)
  NSTimeInterval expiration = [response.expirationDate timeIntervalSinceNow];
  XCTAssert(expiration > kExpiresInValue - 5 && expiration <= kExpiresInValue, @"");
}

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
 * process and checking to make sure the source and destination both contain the
 */
- (void)testCopying {
  OIDTVAuthorizationResponse *response = [self testAuthorizationResponse];
  
  OIDTVAuthorizationResponse *responseCopy = [response copy];

  XCTAssertEqualObjects(responseCopy.request, response.request);
  XCTAssertEqualObjects(responseCopy.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(responseCopy.interval, @(kIntervalValue));
  XCTAssertEqualObjects(responseCopy.userCode, kUserCodeValue);
  XCTAssertEqualObjects(responseCopy.verificationURIComplete, kVerificationTestURIComplete);
  XCTAssertEqualObjects(responseCopy.verificationURI, kVerificationTestURL);
}

/*! @brief Tests the @c NSSecureCoding implementation by round-tripping an instance through the
 * coding process and checking to make sure the source and destination both contain the
 */
- (void)testSecureCoding {
  OIDTVAuthorizationResponse *response = [self testAuthorizationResponse];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:response];
  OIDTVAuthorizationResponse *responseCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  // Not a full test of the request deserialization, but should be sufficient as a smoke test
  // to make sure the request IS actually getting serialized and deserialized in the
  // NSSecureCoding implementation. We'll leave it up to the OIDAuthorizationRequest tests to make
  // sure the NSSecureCoding implementation of that class is correct.
  XCTAssertNotNil(responseCopy.request);

  XCTAssertEqualObjects(responseCopy.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(responseCopy.interval, @(kIntervalValue));
  XCTAssertEqualObjects(responseCopy.userCode, kUserCodeValue);
  XCTAssertEqualObjects(responseCopy.verificationURIComplete, kVerificationTestURIComplete);
  XCTAssertEqualObjects(responseCopy.verificationURI, kVerificationTestURL);
}

-(void) testTokenPollRequest {
  OIDTVAuthorizationResponse *testResponse = [self testAuthorizationResponse];
  OIDTVTokenRequest *pollRequest = [testResponse tokenPollRequest];
  XCTAssertEqualObjects(pollRequest.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(pollRequest.clientID, kTestClientID);
  XCTAssertEqualObjects(pollRequest.clientSecret, kTestClientSecret);
  XCTAssertEqualObjects(pollRequest.additionalParameters, @{});
}

-(void) testTokenPollRequestWithAdditionalParameters {
  OIDTVAuthorizationResponse *testResponse = [self testAuthorizationResponse];
  NSDictionary *testParams = @{kAdditionalParametersKey: kTestAdditionalParameterValue};
  OIDTVTokenRequest *pollRequest = [testResponse tokenPollRequestWithAdditionalParameters:testParams];
  XCTAssertEqualObjects(pollRequest.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(pollRequest.clientID, kTestClientID);
  XCTAssertEqualObjects(pollRequest.clientSecret, kTestClientSecret);
  XCTAssertEqualObjects(pollRequest.additionalParameters, testParams);
}

@end

#pragma GCC diagnostic pop
