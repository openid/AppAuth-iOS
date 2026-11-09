/*! @file OIDAuthorizationServiceTests.m
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

#import "OIDAuthorizationRequestTests.h"
#import "OIDRegistrationRequestTests.h"
#import "OIDServiceConfigurationTests.h"
#import "OIDTokenRequestTests.h"

#if SWIFT_PACKAGE
@import AppAuthCore;
#else
#import "Sources/AppAuthCore/OIDAuthState.h"
#import "Sources/AppAuthCore/OIDAuthorizationRequest.h"
#import "Sources/AppAuthCore/OIDAuthorizationResponse.h"
#import "Sources/AppAuthCore/OIDAuthorizationService.h"
#import "Sources/AppAuthCore/OIDError.h"
#import "Sources/AppAuthCore/OIDExternalUserAgent.h"
#import "Sources/AppAuthCore/OIDExternalUserAgentSession.h"
#import "Sources/AppAuthCore/OIDRegistrationRequest.h"
#import "Sources/AppAuthCore/OIDRegistrationResponse.h"
#import "Sources/AppAuthCore/OIDTokenRequest.h"
#import "Sources/AppAuthCore/OIDTokenResponse.h"
#import "Sources/AppAuthCore/OIDURLSessionProvider.h"
#endif

/*! @brief The time allowed for a stubbed request to reach its callback.
 */
static const NSTimeInterval kCallbackTimeout = 5;

/*! @brief The HTTP status code the stub answers with.
 */
static NSInteger gStubbedStatusCode;

/*! @brief The body the stub answers with.
 */
static NSData *gStubbedBody;

/*! @brief A URL protocol that answers every request with a canned status code and body, so the
        token and registration endpoints can be driven without a network.
 */
@interface OIDStubbedResponseURLProtocol : NSURLProtocol

/*! @brief Sets the status code and body that every request receives until the next call.
 */
+ (void)stubStatusCode:(NSInteger)statusCode body:(NSString *)body;

@end

@implementation OIDStubbedResponseURLProtocol

+ (void)stubStatusCode:(NSInteger)statusCode body:(NSString *)body {
  gStubbedStatusCode = statusCode;
  gStubbedBody = [body dataUsingEncoding:NSUTF8StringEncoding];
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
                                  statusCode:gStubbedStatusCode
                                 HTTPVersion:@"HTTP/1.1"
                                headerFields:@{ @"Content-Type" : @"application/json" }];
  [self.client URLProtocol:self
        didReceiveResponse:response
        cacheStoragePolicy:NSURLCacheStorageNotAllowed];
  [self.client URLProtocol:self didLoadData:gStubbedBody];
  [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

@end

/*! @brief Unit tests for the response handling in @c OIDAuthorizationService.
 */
// An external user agent that "presents" immediately and dismisses synchronously, so a test can
// drive an authorization session by resuming it with a redirect URL itself.
@interface OIDImmediateExternalUserAgent : NSObject <OIDExternalUserAgent>
@end

@implementation OIDImmediateExternalUserAgent

- (BOOL)presentExternalUserAgentRequest:(id<OIDExternalUserAgentRequest>)request
                                session:(id<OIDExternalUserAgentSession>)session {
  return YES;
}

- (void)dismissExternalUserAgentAnimated:(BOOL)animated completion:(void (^)(void))completion {
  if (completion) {
    completion();
  }
}

@end

@interface OIDAuthorizationServiceTests : XCTestCase
@end

@implementation OIDAuthorizationServiceTests

- (void)setUp {
  [super setUp];
  NSURLSessionConfiguration *configuration =
      [NSURLSessionConfiguration ephemeralSessionConfiguration];
  configuration.protocolClasses = @[ [OIDStubbedResponseURLProtocol class] ];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
  [OIDURLSessionProvider setSession:session];
}

- (void)tearDown {
  [OIDURLSessionProvider setSession:[NSURLSession sharedSession]];
  [super tearDown];
}

/*! @brief Performs @c [OIDTokenRequestTests testInstance] against the stub and returns the
        callback's error, passing the callback's response out through @c response.
 */
- (NSError *)errorFromTokenRequestWithStatusCode:(NSInteger)statusCode
                                            body:(NSString *)body
                                        response:(OIDTokenResponse **)response {
  [OIDStubbedResponseURLProtocol stubStatusCode:statusCode body:body];
  OIDTokenRequest *request = [OIDTokenRequestTests testInstance];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Token callback"];
  __block OIDTokenResponse *returnedResponse = nil;
  __block NSError *returnedError = nil;
  [OIDAuthorizationService performTokenRequest:request
                                      callback:^(OIDTokenResponse *_Nullable tokenResponse,
                                                 NSError *_Nullable error) {
    returnedResponse = tokenResponse;
    returnedError = error;
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:kCallbackTimeout handler:nil];
  if (response) {
    *response = returnedResponse;
  }
  return returnedError;
}

/*! @brief Performs @c [OIDRegistrationRequestTests testInstance] against the stub and returns the
        callback's error, passing the callback's response out through @c response.
 */
- (NSError *)errorFromRegistrationRequestWithStatusCode:(NSInteger)statusCode
                                                   body:(NSString *)body
                                               response:(OIDRegistrationResponse **)response {
  [OIDStubbedResponseURLProtocol stubStatusCode:statusCode body:body];
  OIDRegistrationRequest *request = [OIDRegistrationRequestTests testInstance];
  XCTestExpectation *expectation = [self expectationWithDescription:@"Registration completion"];
  __block OIDRegistrationResponse *returnedResponse = nil;
  __block NSError *returnedError = nil;
  [OIDAuthorizationService
      performRegistrationRequest:request
                      completion:^(OIDRegistrationResponse *_Nullable registrationResponse,
                                   NSError *_Nullable error) {
    returnedResponse = registrationResponse;
    returnedError = error;
    [expectation fulfill];
  }];
  [self waitForExpectationsWithTimeout:kCallbackTimeout handler:nil];
  if (response) {
    *response = returnedResponse;
  }
  return returnedError;
}

/*! @brief Tests that a 4xx token response whose JSON body is an empty array returns a server error
        rather than crashing.
 */
- (void)testTokenRequestWith4xxEmptyArrayBodyReturnsServerError {
  OIDTokenResponse *response = nil;
  NSError *error = [self errorFromTokenRequestWithStatusCode:400
                                                        body:@"[]"
                                                    response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeServerError);
}

/*! @brief Tests that a 4xx token response whose JSON body is a non-empty array returns a server
        error rather than crashing.
 */
- (void)testTokenRequestWith4xxArrayBodyReturnsServerError {
  OIDTokenResponse *response = nil;
  NSError *error = [self errorFromTokenRequestWithStatusCode:400
                                                        body:@"[\"proxy error\"]"
                                                    response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeServerError);
}

/*! @brief Tests that a 4xx token response with a well-formed OAuth error object returns the
        corresponding OAuth token error.
 */
- (void)testTokenRequestWith4xxOAuthErrorBodyReturnsOAuthError {
  OIDTokenResponse *response = nil;
  NSError *error = [self errorFromTokenRequestWithStatusCode:400
                                                        body:@"{\"error\":\"invalid_grant\"}"
                                                    response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDOAuthTokenErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeOAuthInvalidGrant);
}

/*! @brief Tests that a 200 token response whose JSON body is a non-empty array returns a JSON
        deserialization error rather than crashing.
 */
- (void)testTokenRequestWith200ArrayBodyReturnsDeserializationError {
  OIDTokenResponse *response = nil;
  NSError *error = [self errorFromTokenRequestWithStatusCode:200
                                                        body:@"[\"x\"]"
                                                    response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeJSONDeserializationError);
}

/*! @brief Tests that a 200 token response whose JSON body is an empty array returns a JSON
        deserialization error rather than crashing.
 */
- (void)testTokenRequestWith200EmptyArrayBodyReturnsDeserializationError {
  OIDTokenResponse *response = nil;
  NSError *error = [self errorFromTokenRequestWithStatusCode:200
                                                        body:@"[]"
                                                    response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeJSONDeserializationError);
}

/*! @brief Tests that a 400 registration response whose JSON body is an array returns a server error
        rather than crashing.
 */
- (void)testRegistrationRequestWith400ArrayBodyReturnsServerError {
  OIDRegistrationResponse *response = nil;
  NSError *error = [self errorFromRegistrationRequestWithStatusCode:400
                                                               body:@"[]"
                                                           response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeServerError);
}

/*! @brief Tests that a 400 registration response with a well-formed OAuth error object returns the
        corresponding OAuth registration error.
 */
- (void)testRegistrationRequestWith400OAuthErrorBodyReturnsOAuthError {
  OIDRegistrationResponse *response = nil;
  NSError *error =
      [self errorFromRegistrationRequestWithStatusCode:400
                                                  body:@"{\"error\":\"invalid_request\"}"
                                              response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDOAuthRegistrationErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeOAuthRegistrationInvalidRequest);
}

/*! @brief Tests that a 201 registration response whose JSON body is an array returns a JSON
        deserialization error rather than crashing.
 */
- (void)testRegistrationRequestWith201ArrayBodyReturnsDeserializationError {
  OIDRegistrationResponse *response = nil;
  NSError *error = [self errorFromRegistrationRequestWithStatusCode:201
                                                               body:@"[]"
                                                           response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeJSONDeserializationError);
}

#pragma mark - Authorization responses

/*! @brief Presents @c request with an immediate user agent, resumes the session with
        @c redirectURL and returns the callback's error, passing the response out through
        @c response.
 */
- (NSError *)errorFromAuthorizationRequest:(OIDAuthorizationRequest *)request
                               redirectURL:(NSURL *)redirectURL
                                  response:(OIDAuthorizationResponse **)response {
  __block OIDAuthorizationResponse *returnedResponse = nil;
  __block NSError *returnedError = nil;
  __block BOOL called = NO;
  id<OIDExternalUserAgentSession> session = [OIDAuthorizationService
      presentAuthorizationRequest:request
                externalUserAgent:[[OIDImmediateExternalUserAgent alloc] init]
                         callback:^(OIDAuthorizationResponse *_Nullable authorizationResponse,
                                    NSError *_Nullable error) {
    returnedResponse = authorizationResponse;
    returnedError = error;
    called = YES;
  }];
  NSError *resumeError = nil;
  XCTAssertTrue([session resumeExternalUserAgentFlowWithURL:redirectURL error:&resumeError]);
  XCTAssertNil(resumeError);
  XCTAssertTrue(called);
  if (response) {
    *response = returnedResponse;
  }
  return returnedError;
}

/*! @brief Tests that a code flow redirect without a @c code parameter fails the flow with an error
        instead of delivering a response that has no authorization code. Addresses issue #813.
 */
- (void)testCodeFlowResponseWithoutCodeReturnsError {
  OIDAuthorizationRequest *request = [OIDAuthorizationRequestTests testInstanceCodeFlow];
  NSURL *redirect = [NSURL URLWithString:@"http://www.google.com/?state=State"];
  OIDAuthorizationResponse *response = nil;
  NSError *error = [self errorFromAuthorizationRequest:request
                                           redirectURL:redirect
                                              response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDOAuthAuthorizationErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeOAuthAuthorizationClientError);
  XCTAssertTrue([error.localizedDescription containsString:@"missing the code parameter"]);
}

/*! @brief Tests that a hybrid flow (@c "code id_token") redirect without a @c code parameter also
        fails the flow.
 */
- (void)testHybridFlowResponseWithoutCodeReturnsError {
  OIDAuthorizationRequest *request =
      [self requestWithResponseType:[NSString stringWithFormat:@"%@ %@", OIDResponseTypeCode,
                                                               OIDResponseTypeIDToken]];
  NSURL *redirect = [NSURL URLWithString:@"http://www.google.com/?state=State&id_token=abc"];
  OIDAuthorizationResponse *response = nil;
  NSError *error = [self errorFromAuthorizationRequest:request
                                           redirectURL:redirect
                                              response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDOAuthAuthorizationErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeOAuthAuthorizationClientError);
}

/*! @brief Tests that a code flow redirect with a @c code parameter is still delivered.
 */
- (void)testCodeFlowResponseWithCodeSucceeds {
  OIDAuthorizationRequest *request = [OIDAuthorizationRequestTests testInstanceCodeFlow];
  NSURL *redirect = [NSURL URLWithString:@"http://www.google.com/?code=AuthCode&state=State"];
  OIDAuthorizationResponse *response = nil;
  NSError *error = [self errorFromAuthorizationRequest:request
                                           redirectURL:redirect
                                              response:&response];
  XCTAssertNil(error);
  XCTAssertEqualObjects(response.authorizationCode, @"AuthCode");
}

/*! @brief Tests that an OAuth error redirect is reported as the server's error, not as a missing
        code.
 */
- (void)testCodeFlowErrorResponseKeepsOAuthError {
  OIDAuthorizationRequest *request = [OIDAuthorizationRequestTests testInstanceCodeFlow];
  NSURL *redirect =
      [NSURL URLWithString:@"http://www.google.com/?error=access_denied&state=State"];
  OIDAuthorizationResponse *response = nil;
  NSError *error = [self errorFromAuthorizationRequest:request
                                           redirectURL:redirect
                                              response:&response];
  XCTAssertNil(response);
  XCTAssertEqualObjects(error.domain, OIDOAuthAuthorizationErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeOAuthAuthorizationAccessDenied);
}

/*! @brief Tests that a state mismatch is still reported as such when the code is also missing.
 */
- (void)testStateMismatchTakesPrecedenceOverMissingCode {
  OIDAuthorizationRequest *request = [OIDAuthorizationRequestTests testInstanceCodeFlow];
  NSURL *redirect = [NSURL URLWithString:@"http://www.google.com/?state=Other"];
  OIDAuthorizationResponse *response = nil;
  NSError *error = [self errorFromAuthorizationRequest:request
                                           redirectURL:redirect
                                              response:&response];
  XCTAssertNil(response);
  XCTAssertTrue([error.localizedDescription containsString:@"State mismatch"]);
}

/*! @brief Tests that the @c OIDAuthState convenience flow reports a missing code through its
        callback. It used to call @c tokenExchangeRequest on a response without a code, which
        raises @c kTokenExchangeRequestException and crashes the app.
 */
- (void)testAuthStateCodeFlowWithoutCodeReturnsErrorInsteadOfRaising {
  OIDAuthorizationRequest *request = [OIDAuthorizationRequestTests testInstanceCodeFlow];
  __block OIDAuthState *returnedState = nil;
  __block NSError *returnedError = nil;
  __block BOOL called = NO;
  OIDImmediateExternalUserAgent *userAgent = [[OIDImmediateExternalUserAgent alloc] init];
  id<OIDExternalUserAgentSession> session =
      [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                            externalUserAgent:userAgent
                                                     callback:^(OIDAuthState *_Nullable authState,
                                                                NSError *_Nullable error) {
    returnedState = authState;
    returnedError = error;
    called = YES;
  }];
  NSURL *redirect = [NSURL URLWithString:@"http://www.google.com/?state=State"];
  XCTAssertNoThrow([session resumeExternalUserAgentFlowWithURL:redirect error:NULL]);
  XCTAssertTrue(called);
  XCTAssertNil(returnedState);
  XCTAssertEqualObjects(returnedError.domain, OIDOAuthAuthorizationErrorDomain);
  XCTAssertEqual(returnedError.code, OIDErrorCodeOAuthAuthorizationClientError);
}

/*! @brief Returns a request like @c [OIDAuthorizationRequestTests testInstanceCodeFlow] with the
        given response type and state @c "State".
 */
- (OIDAuthorizationRequest *)requestWithResponseType:(NSString *)responseType {
  return [[OIDAuthorizationRequest alloc]
      initWithConfiguration:[OIDServiceConfigurationTests testInstance]
                   clientId:@"ClientID"
               clientSecret:nil
                      scope:@"openid"
                redirectURL:[NSURL URLWithString:@"http://www.google.com/"]
               responseType:responseType
                      state:@"State"
                      nonce:@"Nonce"
               codeVerifier:nil
              codeChallenge:nil
        codeChallengeMethod:nil
       additionalParameters:nil];
}

@end
