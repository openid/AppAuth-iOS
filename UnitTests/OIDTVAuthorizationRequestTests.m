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

#import "OIDTVAuthorizationRequestTests.h"
#import "OIDURLQueryComponent.h"

#import "OIDTVAuthorizationRequest.h"
#import "OIDTVServiceConfiguration.h"

#import "Source/AppAuthCore/OIDScopeUtilities.h"

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

/*! @brief Test value for the @c authorizationEndpoint property.
 */
static NSString *const kInitializerTestTVAuthEndpoint = @"https://www.example.com/device/code";

/*! @brief Test value for the @c tokenEndpoint property.
 */
static NSString *const kInitializerTestTokenEndpoint = @"https://www.example.com/token";

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

/*! @brief Expected HTTP Method for the authorization URLRequest
 */
static NSString *const kHTTPPost = @"POST";

/*! @brief Expected ContentType header key for the authorization URLRequest
 */
static NSString *const kHTTPContentTypeHeaderKey = @"Content-Type";

/*! @brief Expected ContentType header key for the authorization URLRequest
 */
static NSString *const kHTTPContentTypeHeaderValue =
    @"application/x-www-form-urlencoded; charset=UTF-8";

@implementation OIDTVAuthorizationRequestTests

- (OIDTVServiceConfiguration *)testServiceConfiguration {
  NSURL *tokenEndpoint = [NSURL URLWithString:kInitializerTestTokenEndpoint];
  NSURL *TVAuthorizationEndpoint = [NSURL URLWithString:kInitializerTestTVAuthEndpoint];

  OIDTVServiceConfiguration *configuration =
  [[OIDTVServiceConfiguration alloc] initWithAuthorizationEndpoint:TVAuthorizationEndpoint
                                           TVAuthorizationEndpoint:TVAuthorizationEndpoint
                                                     tokenEndpoint:tokenEndpoint];
  return configuration;
}

- (NSDictionary<NSString *, NSString *> *)bodyParametersFromURLRequest:(NSURLRequest *)urlRequest {
  NSString *bodyString = [[NSString alloc] initWithData:urlRequest.HTTPBody
                                               encoding:NSUTF8StringEncoding];
  NSArray *bodyParameterStrings = [bodyString componentsSeparatedByString:@"&"];
  

  NSMutableDictionary<NSString *, NSString *> *bodyParameters = [[NSMutableDictionary alloc] init];

  for (NSString *paramString in bodyParameterStrings) {
    NSArray *components = [paramString componentsSeparatedByString:@"="];
    NSLog(@"%@:%@", components[0], components[1]);
    
    [bodyParameters setObject:components[1] forKey:components[0]];
  }

  return bodyParameters;
}

- (void)testInitializer {
  OIDTVAuthorizationRequest *authRequest =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:[self testServiceConfiguration]
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:nil
                                          additionalParameters:nil];

  XCTAssertEqualObjects(authRequest.responseType, OIDResponseTypeCode);
  XCTAssertEqualObjects(authRequest.redirectURL, [[NSURL alloc] init]);
}

- (void)testURLRequestBasicClientAuth {
  OIDTVAuthorizationRequest *authRequest =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:[self testServiceConfiguration]
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:nil
                                          additionalParameters:nil];

  NSURLRequest *urlRequest = [authRequest URLRequest];

  XCTAssertEqualObjects([urlRequest HTTPMethod], kHTTPPost);
  XCTAssertEqualObjects([urlRequest valueForHTTPHeaderField:kHTTPContentTypeHeaderKey],
                        kHTTPContentTypeHeaderValue);
  XCTAssertEqualObjects(urlRequest.URL.absoluteString, kInitializerTestTVAuthEndpoint);

  NSDictionary<NSString *, NSString *> *bodyParameters =
      [self bodyParametersFromURLRequest:urlRequest];
  NSDictionary<NSString *, NSString *> *expectedParameters = @{@"client_id" : kTestClientID};

  XCTAssertEqualObjects(bodyParameters, expectedParameters);
}

- (void)testURLRequestScopes {
  OIDTVAuthorizationRequest *authRequest =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:[self testServiceConfiguration]
                                                      clientId:kTestClientID
                                                  clientSecret:kTestClientSecret
                                                        scopes:@[ kTestScope, kTestScopeA ]
                                          additionalParameters:nil];

  NSURLRequest *urlRequest = [authRequest URLRequest];

  XCTAssertEqualObjects([urlRequest HTTPMethod], kHTTPPost);
  XCTAssertEqualObjects([urlRequest valueForHTTPHeaderField:kHTTPContentTypeHeaderKey],
                        kHTTPContentTypeHeaderValue);
  XCTAssertEqualObjects(urlRequest.URL.absoluteString, kInitializerTestTVAuthEndpoint);

  NSDictionary<NSString *, NSString *> *bodyParameters =
      [self bodyParametersFromURLRequest:urlRequest];
  NSDictionary<NSString *, NSString *> *expectedParameters = @{
    @"client_id" : kTestClientID,
    @"scope" : [[NSString stringWithFormat:@"%@ %@", kTestScope, kTestScopeA]
    stringByAddingPercentEncodingWithAllowedCharacters:[OIDURLQueryComponent
                                                           URLParamValueAllowedCharacters]]
  };

  XCTAssertEqualObjects(bodyParameters, expectedParameters);
}

- (void)testURLRequestAdditionalParams {
  OIDTVAuthorizationRequest *authRequest = [[OIDTVAuthorizationRequest alloc]
      initWithConfiguration:[self testServiceConfiguration]
                   clientId:kTestClientID
               clientSecret:kTestClientSecret
                     scopes:@[ kTestScope, kTestScopeA ]
       additionalParameters:@{kTestAdditionalParameterKey : kTestAdditionalParameterValue}];

  NSURLRequest *urlRequest = [authRequest URLRequest];

  XCTAssertEqualObjects([urlRequest HTTPMethod], kHTTPPost);
  XCTAssertEqualObjects([urlRequest valueForHTTPHeaderField:kHTTPContentTypeHeaderKey],
                        kHTTPContentTypeHeaderValue);
  XCTAssertEqualObjects(urlRequest.URL.absoluteString, kInitializerTestTVAuthEndpoint);

  NSDictionary<NSString *, NSString *> *bodyParameters =
      [self bodyParametersFromURLRequest:urlRequest];
  NSDictionary<NSString *, NSString *> *expectedParameters = @{
    @"client_id" : kTestClientID,
    @"scope" : [[NSString stringWithFormat:@"%@ %@", kTestScope, kTestScopeA]
        stringByAddingPercentEncodingWithAllowedCharacters:[OIDURLQueryComponent
                                                               URLParamValueAllowedCharacters]],
    kTestAdditionalParameterKey : kTestAdditionalParameterValue
  };

  XCTAssertEqualObjects(bodyParameters, expectedParameters);
}

@end

#pragma GCC diagnostic pop
