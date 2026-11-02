/*! @file OIDTVAuthorizationServiceTests.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2026 Google LLC
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

#if SWIFT_PACKAGE
@import AppAuthTV;
#else
#import "Sources/AppAuthCore/OIDError.h"
#import "Sources/AppAuthTV/OIDTVAuthorizationRequest.h"
#import "Sources/AppAuthTV/OIDTVAuthorizationResponse.h"
#import "Sources/AppAuthTV/OIDTVAuthorizationService.h"
#import "Sources/AppAuthTV/OIDTVServiceConfiguration.h"
#endif

/*! @brief Test value for the @c deviceAuthorizationEndpoint property.
 */
static NSString *const kTestDeviceAuthorizationEndpoint = @"https://www.example.com/device/code";

/*! @brief Test value for the @c tokenEndpoint property.
 */
static NSString *const kTestTokenEndpoint = @"https://www.example.com/token";

/*! @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientID = @"ClientID";

/*! @brief Test value for the @c clientSecret property.
 */
static NSString *const kTestClientSecret = @"ClientSecret";

/*! @brief The time allowed for a stubbed request to reach its callback.
 */
static const NSTimeInterval kCallbackTimeout = 5;

/*! @brief The HTTP status code the stub answers with.
 */
static NSInteger gTVStubbedStatusCode;

/*! @brief The body the stub answers with.
 */
static NSData *gTVStubbedBody;

/*! @brief A URL protocol that answers every request with a canned status code and body, so the
        device authorization endpoint can be driven without a network. A copy of the one in
        OIDAuthorizationServiceTests.m, which the AppAuthTV package target cannot see.
 */
@interface OIDTVStubbedResponseURLProtocol : NSURLProtocol

/*! @brief Sets the status code and body that every request receives until the next call.
 */
+ (void)stubStatusCode:(NSInteger)statusCode body:(NSString *)body;

@end

@implementation OIDTVStubbedResponseURLProtocol

+ (void)stubStatusCode:(NSInteger)statusCode body:(NSString *)body {
  gTVStubbedStatusCode = statusCode;
  gTVStubbedBody = [body dataUsingEncoding:NSUTF8StringEncoding];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
  return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
  return request;
}

- (void)startLoading {
  NSHTTPURLResponse *response =
      [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                  statusCode:gTVStubbedStatusCode
                                 HTTPVersion:@"HTTP/1.1"
                                headerFields:@{ @"Content-Type" : @"application/json" }];
  [self.client URLProtocol:self
        didReceiveResponse:response
        cacheStoragePolicy:NSURLCacheStorageNotAllowed];
  [self.client URLProtocol:self didLoadData:gTVStubbedBody];
  [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

@end

/*! @brief Unit tests for the response handling in @c OIDTVAuthorizationService.
 */
@interface OIDTVAuthorizationServiceTests : XCTestCase
@end

@implementation OIDTVAuthorizationServiceTests

- (void)setUp {
  [super setUp];
  [NSURLProtocol registerClass:[OIDTVStubbedResponseURLProtocol class]];
}

- (void)tearDown {
  [NSURLProtocol unregisterClass:[OIDTVStubbedResponseURLProtocol class]];
  [super tearDown];
}

/*! @brief Returns an @c OIDTVAuthorizationRequest configured with the test endpoints and client
        credentials.
 */
- (OIDTVAuthorizationRequest *)testAuthorizationRequest {
  NSURL *deviceAuthorizationEndpoint = [NSURL URLWithString:kTestDeviceAuthorizationEndpoint];
  NSURL *tokenEndpoint = [NSURL URLWithString:kTestTokenEndpoint];
  OIDTVServiceConfiguration *configuration = [[OIDTVServiceConfiguration alloc]
      initWithDeviceAuthorizationEndpoint:deviceAuthorizationEndpoint
                            tokenEndpoint:tokenEndpoint];
  return [[OIDTVAuthorizationRequest alloc] initWithConfiguration:configuration
                                                         clientId:kTestClientID
                                                     clientSecret:kTestClientSecret
                                                           scopes:nil
                                             additionalParameters:nil];
}

/*! @brief Performs @c [self testAuthorizationRequest] against the stub and returns the
        initialization callback's error, passing the callback's response out through @c response.
 */
- (NSError *)errorFromAuthorizationRequestWithStatusCode:(NSInteger)statusCode
                                                    body:(NSString *)body
                                                response:(OIDTVAuthorizationResponse **)response {
  [OIDTVStubbedResponseURLProtocol stubStatusCode:statusCode body:body];
  OIDTVAuthorizationRequest *request = [self testAuthorizationRequest];
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Device authorization initialization"];
  __block OIDTVAuthorizationResponse *returnedResponse = nil;
  __block NSError *returnedError = nil;
  [OIDTVAuthorizationService
      authorizeTVRequest:request
          initialization:^(OIDTVAuthorizationResponse *_Nullable authorizationResponse,
                           NSError *_Nullable error) {
    returnedResponse = authorizationResponse;
    returnedError = error;
    [expectation fulfill];
  }
              completion:^(OIDAuthState *_Nullable authorization, NSError *_Nullable error) {
    XCTFail(@"Completion must not run for a failed initialization.");
  }];
  [self waitForExpectationsWithTimeout:kCallbackTimeout handler:nil];
  if (response) {
    *response = returnedResponse;
  }
  return returnedError;
}

/*! @brief Tests that a 400 device authorization response whose JSON body is an empty array returns
        a server error rather than crashing.
 */
- (void)testAuthorizationRequestWith400EmptyArrayBodyReturnsServerError {
  OIDTVAuthorizationResponse *response = nil;
  NSError *error = [self errorFromAuthorizationRequestWithStatusCode:400
                                                                body:@"[]"
                                                            response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeServerError);
}

/*! @brief Tests that a 400 device authorization response whose JSON body is a non-empty array
        returns a server error rather than crashing.
 */
- (void)testAuthorizationRequestWith400ArrayBodyReturnsServerError {
  OIDTVAuthorizationResponse *response = nil;
  NSError *error =
      [self errorFromAuthorizationRequestWithStatusCode:400
                                                   body:@"[{\"error\":\"invalid_request\"}]"
                                               response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeServerError);
}

/*! @brief Tests that a 400 device authorization response with a well-formed OAuth error object
        returns the corresponding OAuth token error.
 */
- (void)testAuthorizationRequestWith400OAuthErrorBodyReturnsOAuthError {
  OIDTVAuthorizationResponse *response = nil;
  NSError *error =
      [self errorFromAuthorizationRequestWithStatusCode:400
                                                   body:@"{\"error\":\"invalid_request\"}"
                                               response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDOAuthTokenErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeOAuthInvalidRequest);
}

/*! @brief Tests that a 200 device authorization response whose JSON body is a non-empty array
        returns a JSON deserialization error rather than crashing.
 */
- (void)testAuthorizationRequestWith200ArrayBodyReturnsDeserializationError {
  OIDTVAuthorizationResponse *response = nil;
  NSError *error = [self errorFromAuthorizationRequestWithStatusCode:200
                                                                body:@"[{\"device_code\":\"x\"}]"
                                                            response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeJSONDeserializationError);
}

/*! @brief Tests that a 200 device authorization response whose JSON body is an empty array returns
        a JSON deserialization error rather than crashing.
 */
- (void)testAuthorizationRequestWith200EmptyArrayBodyReturnsDeserializationError {
  OIDTVAuthorizationResponse *response = nil;
  NSError *error = [self errorFromAuthorizationRequestWithStatusCode:200
                                                                body:@"[]"
                                                            response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeJSONDeserializationError);
}

@end
