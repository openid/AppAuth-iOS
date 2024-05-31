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

#import "OIDTVAuthorizationRequestTests.h"

#if SWIFT_PACKAGE
@import AppAuthTV;
#else
#import "Sources/AppAuthCore/OIDScopeUtilities.h"
#import "Sources/AppAuthCore/OIDURLQueryComponent.h"
#import "Sources/AppAuthTV/OIDTVAuthorizationRequest.h"
#import "Sources/AppAuthTV/OIDTVServiceConfiguration.h"
#endif

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

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

@implementation OIDTVAuthorizationRequestTests

- (OIDTVServiceConfiguration *)testServiceConfiguration {
  NSURL *tokenEndpoint = [NSURL URLWithString:kTestTokenEndpoint];
  NSURL *deviceAuthorizationEndpoint = [NSURL URLWithString:kTestDeviceAuthorizationEndpoint];

  OIDTVServiceConfiguration *configuration =
      [[OIDTVServiceConfiguration alloc] initWithDeviceAuthorizationEndpoint:deviceAuthorizationEndpoint
                                                           tokenEndpoint:tokenEndpoint];
  return configuration;
}

- (NSDictionary<NSString *, NSString *> *)bodyParametersFromURLRequest:(NSURLRequest *)URLRequest {
  NSString *bodyString = [[NSString alloc] initWithData:URLRequest.HTTPBody
                                               encoding:NSUTF8StringEncoding];
  NSArray<NSString *> *bodyParameterStrings = [bodyString componentsSeparatedByString:@"&"];

  NSMutableDictionary<NSString *, NSString *> *bodyParameters = [[NSMutableDictionary alloc] init];

  for (NSString *paramString in bodyParameterStrings) {
    NSArray<NSString *> *components = [paramString componentsSeparatedByString:@"="];

    if (components.count == 2) {
      bodyParameters[components[0]] = components[1];
    }
  }

  return bodyParameters;
}

/*! @brief Tests the initializer
 */
- (void)testInitializer {
  OIDTVServiceConfiguration *serviceConfiguration = [self testServiceConfiguration];
  NSArray<NSString *> *testScopes = @[ kTestScope, kTestScopeA ];
  NSString *testScopeString = [OIDScopeUtilities scopesWithArray:testScopes];
  NSDictionary<NSString *, NSString *> *testAdditionalParameters =
      @{kTestAdditionalParameterKey : kTestAdditionalParameterValue};

  OIDTVAuthorizationRequest *authRequest =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:serviceConfiguration
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:testScopes
                                          additionalParameters:testAdditionalParameters];

  NSURL *authRequestDeviceAuthorizationEndpoint =
      ((OIDTVServiceConfiguration *)authRequest.configuration).deviceAuthorizationEndpoint;

  XCTAssertEqualObjects(authRequest.clientID, kTestClientID);
  XCTAssertEqualObjects(authRequest.clientSecret, kTestClientSecret);
  XCTAssertEqualObjects(authRequest.scope, testScopeString);
  XCTAssertEqualObjects(authRequest.additionalParameters, testAdditionalParameters);
  XCTAssertEqualObjects(authRequest.responseType, OIDResponseTypeCode);
  XCTAssertEqualObjects(authRequest.redirectURL, [[NSURL alloc] initWithString:@""]);
  XCTAssertEqualObjects(authRequestDeviceAuthorizationEndpoint,
                        serviceConfiguration.deviceAuthorizationEndpoint);
}

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
 *      process and checking to make sure the source and destination both contain the
 *      @c deviceAuthorizationEndpoint
 */
- (void)testCopying {
  OIDTVServiceConfiguration *serviceConfiguration = [self testServiceConfiguration];

  OIDTVAuthorizationRequest *authRequest =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:serviceConfiguration
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:nil
                                          additionalParameters:nil];

  OIDTVAuthorizationRequest *authRequestCopy = [authRequest copy];
  NSURL *authRequestCopyDeviceAuthorizationEndpoint =
      ((OIDTVServiceConfiguration *)authRequestCopy.configuration).deviceAuthorizationEndpoint;

  XCTAssertEqualObjects(authRequestCopyDeviceAuthorizationEndpoint,
                        serviceConfiguration.deviceAuthorizationEndpoint);
}

/*! @brief Tests the @c NSSecureCoding implementation by round-tripping an instance through the
 *      coding process and checking to make sure the source and destination both contain the
 *      @c deviceAuthorizationEndpoint
 */
- (void)testSecureCoding {
  OIDTVServiceConfiguration *serviceConfiguration = [self testServiceConfiguration];

  OIDTVAuthorizationRequest *authRequest =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:serviceConfiguration
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:nil
                                          additionalParameters:nil];

  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:authRequest];
  OIDTVAuthorizationRequest *authRequestCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  NSURL *authRequestCopyDeviceAuthorizationEndpoint =
      ((OIDTVServiceConfiguration *)authRequestCopy.configuration).deviceAuthorizationEndpoint;

  XCTAssertEqualObjects(authRequestCopyDeviceAuthorizationEndpoint,
                        serviceConfiguration.deviceAuthorizationEndpoint);
}

/*! @brief Tests the @c URLRequest method on a request with no scopes or additional parameters
 */
- (void)testURLRequestBasicClientAuth {
  OIDTVServiceConfiguration *serviceConfiguration = [self testServiceConfiguration];

  OIDTVAuthorizationRequest *authRequest =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:serviceConfiguration
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:nil
                                          additionalParameters:nil];

  NSURLRequest *URLRequest = [authRequest URLRequest];

  XCTAssertEqualObjects(URLRequest.HTTPMethod, kHTTPPost);
  XCTAssertEqualObjects([URLRequest valueForHTTPHeaderField:kHTTPContentTypeHeaderKey],
                        kHTTPContentTypeHeaderValue);
  XCTAssertEqualObjects(URLRequest.URL, serviceConfiguration.deviceAuthorizationEndpoint);

  NSDictionary<NSString *, NSString *> *bodyParameters =
      [self bodyParametersFromURLRequest:URLRequest];
  NSDictionary<NSString *, NSString *> *expectedParameters = @{@"client_id" : kTestClientID};

  XCTAssertEqualObjects(bodyParameters, expectedParameters);
}

/*! @brief Tests the @c URLRequest method on a request with two scopes and no additional parameters
 */
- (void)testURLRequestScopes {
  OIDTVServiceConfiguration *serviceConfiguration = [self testServiceConfiguration];
  NSArray<NSString *> *testScopes = @[ kTestScope, kTestScopeA ];
  NSString *testScopeString = [OIDScopeUtilities scopesWithArray:testScopes];
  NSString *testScopeStringPercentEncoded = [testScopeString
      stringByAddingPercentEncodingWithAllowedCharacters:[OIDURLQueryComponent
                                                             URLParamValueAllowedCharacters]];

  OIDTVAuthorizationRequest *authRequest =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:serviceConfiguration
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:@[ kTestScope, kTestScopeA ]
                                          additionalParameters:nil];

  NSURLRequest *URLRequest = [authRequest URLRequest];

  XCTAssertEqualObjects([URLRequest HTTPMethod], kHTTPPost);
  XCTAssertEqualObjects([URLRequest valueForHTTPHeaderField:kHTTPContentTypeHeaderKey],
                        kHTTPContentTypeHeaderValue);
  XCTAssertEqualObjects(URLRequest.URL, serviceConfiguration.deviceAuthorizationEndpoint);

  NSDictionary<NSString *, NSString *> *bodyParameters =
      [self bodyParametersFromURLRequest:URLRequest];
  NSDictionary<NSString *, NSString *> *expectedParameters =
      @{kTestClientIDKey : kTestClientID, kTestScopeKey : testScopeStringPercentEncoded};

  XCTAssertEqualObjects(bodyParameters, expectedParameters);
}

/*! @brief Tests the @c URLRequest method on a request with two scopes and one additional parameter
 */
- (void)testURLRequestAdditionalParams {
  OIDTVServiceConfiguration *serviceConfiguration = [self testServiceConfiguration];
  NSArray<NSString *> *testScopes = @[ kTestScope, kTestScopeA ];
  NSString *testScopeString = [OIDScopeUtilities scopesWithArray:testScopes];
  NSString *testScopeStringPercentEncoded = [testScopeString
      stringByAddingPercentEncodingWithAllowedCharacters:[OIDURLQueryComponent
                                                             URLParamValueAllowedCharacters]];
  OIDTVAuthorizationRequest *authRequest = [[OIDTVAuthorizationRequest alloc]
      initWithConfiguration:serviceConfiguration
                   clientId:kTestClientID
               clientSecret:kTestClientSecret
                     scopes:@[ kTestScope, kTestScopeA ]
       additionalParameters:@{kTestAdditionalParameterKey : kTestAdditionalParameterValue}];

  NSURLRequest *URLRequest = [authRequest URLRequest];

  XCTAssertEqualObjects([URLRequest HTTPMethod], kHTTPPost);
  XCTAssertEqualObjects([URLRequest valueForHTTPHeaderField:kHTTPContentTypeHeaderKey],
                        kHTTPContentTypeHeaderValue);
  XCTAssertEqualObjects(URLRequest.URL, serviceConfiguration.deviceAuthorizationEndpoint);

  NSDictionary<NSString *, NSString *> *bodyParameters =
      [self bodyParametersFromURLRequest:URLRequest];
  NSDictionary<NSString *, NSString *> *expectedParameters = @{
    kTestClientIDKey : kTestClientID,
    kTestScopeKey : testScopeStringPercentEncoded,
    kTestAdditionalParameterKey : kTestAdditionalParameterValue
  };

  XCTAssertEqualObjects(bodyParameters, expectedParameters);
}

@end

#pragma GCC diagnostic pop
