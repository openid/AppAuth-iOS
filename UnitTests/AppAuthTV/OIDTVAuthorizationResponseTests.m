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


//TODO move these imports down below into the macro
#import "OIDTVAuthorizationRequest.h"
#import "OIDTVAuthorizationResponse.h"
#import "OIDTVServiceConfiguration.h"
#import "OIDTVTokenRequest.h"

#if SWIFT_PACKAGE
@import AppAuthTV;
#else
#import "Source/AppAuthCore/OIDScopeUtilities.h"
#import "Source/AppAuthCore/OIDURLQueryComponent.h"
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

/*! @brief The key for the @c verificationURL property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kVerificationURLKey = @"verification_url";

/*! @brief The value for the @c verificationURL property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kVerificationURLValue = @"ttps://www.example.com/device";

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
static NSString *const kIntervalValue = @"5"; //TODO: need to later test if it handles 0 appropriately, with the new logic

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
      [[OIDTVServiceConfiguration alloc] initWithAuthorizationEndpoint:[[NSURL alloc] init]
                                               TVAuthorizationEndpoint:TVAuthorizationEndpoint
                                                         tokenEndpoint:tokenEndpoint];
  return configuration;
}

- (OIDTVAuthorizationRequest *)testAuthorizationRequest {
  NSArray<NSString *> *testScopes = @[ kTestScope, kTestScopeA ];
  NSDictionary<NSString *, NSString *> *testAdditionalParameters =
      @{kTestAdditionalParameterKey : kTestAdditionalParameterValue};
  return [[OIDTVAuthorizationRequest alloc] initWithConfiguration:[self testServiceConfiguration]
                                                         clientId:kTestClientID
                                                     clientSecret:kTestClientSecret
                                                           scopes:testScopes
                                             additionalParameters:testAdditionalParameters];
}

- (OIDTVAuthorizationResponse *)testAuthorizationResponse {
  return 
      [[OIDTVAuthorizationResponse alloc] initWithRequest:[self testAuthorizationRequest]
                                               parameters:@{
                                                 kVerificationURLKey : kVerificationURLValue,
                                                 kUserCodeKey : kUserCodeValue,
                                                 kDeviceCodeKey : kDeviceCodeValue,
                                                 kExpiresInKey : @(kExpiresInValue),
                                                 kIntervalKey : kIntervalValue,
                                                 kTestAdditionalParameterKey :kTestAdditionalParameterValue
                                               }];
}

-(void)testInitializer {
  OIDTVAuthorizationResponse *response = [self testAuthorizationResponse];

  XCTAssertEqualObjects(response.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(response.interval, kIntervalValue);
  XCTAssertEqualObjects(response.userCode, kUserCodeValue);
  XCTAssertEqualObjects(response.verificationURI, kVerificationURIValue);

  // Should be ~ kTestExpirationSeconds seconds. Avoiding swizzling NSDate here for certainty
  // to keep dependencies down, and simply making an assumption that this check will be executed
  // relatively quickly after the initialization above (less than 5 seconds.)
  NSTimeInterval expiration = [response.accessTokenExpirationDate timeIntervalSinceNow];
  XCTAssert(expiration > kExpiresInValue - 5 && expiration <= kExpiresInValue, @"");
}

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
 * process and checking to make sure the source and destination both contain the
 * @c TODO
 */
- (void)testCopying {
  OIDTVAuthorizationResponse *response = [self testAuthorizationResponse];
  
  OIDTVAuthorizationResponse *responseCopy = [response copy];

  XCTAssertEqualObjects(response, responseCopy);
  
}

/*! @brief Tests the @c NSSecureCoding implementation by round-tripping an instance through the
 * coding process and checking to make sure the source and destination both contain the
 * @c TODO
 */
- (void)testSecureCoding {
//  OIDTVAuthorizationResponse *response = [self testAuthorizationResponse];
//
//  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:response];
//  OIDTVAuthorizationRequest *responseCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//
//  NSURL *authRequestCopyTVAuthorizationEndpoint =
//      ((OIDTVServiceConfiguration *)authRequestCopy.configuration).TVAuthorizationEndpoint;
//
//  XCTAssertEqualObjects(authRequestCopyTVAuthorizationEndpoint,
//                        serviceConfiguration.TVAuthorizationEndpoint);
}

-(void) testTokenPollRequest {
  OIDTVAuthorizationResponse *testResponse = [self testAuthorizationResponse];
  OIDTVTokenRequest *pollRequestA = [testResponse tokenPollRequest];
  OIDTVTokenRequest *pollRequestB = [testResponse tokenPollRequestWithAdditionalParameters:nil];
  XCTAssertEqualObjects(pollRequestA, pollRequestB);
}

-(void) testTokenPollRequestWithAdditionalParameters {
  OIDTVAuthorizationResponse *testResponse = [self testAuthorizationResponse];
  NSDictionary *dict = @{kAdditionalParametersKey: kTestAdditionalParameterValue};
  OIDTVTokenRequest *pollRequest = [testResponse tokenPollRequestWithAdditionalParameters:dict];
  XCTAssertEqualObjects(pollRequest.deviceCode, kDeviceCodeValue);
  XCTAssertEqualObjects(pollRequest.clientID, kTestClientID);
  XCTAssertEqualObjects(pollRequest.clientSecret, kTestClientSecret);
  XCTAssertEqualObjects(pollRequest.additionalParameters, dict);
}

@end

#pragma GCC diagnostic pop
