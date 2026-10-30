/*! @file OIDFakeAuthorizationServiceTests.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2026 The AppAuth Authors. All Rights Reserved.
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
@import AppAuthCore;
@import AppAuthTestHelpers;
#else
#import "Sources/AppAuthCore.h"
#import "Sources/AppAuthTestHelpers/AppAuthTestHelpers.h"
#endif
#import "OIDAuthorizationRequestTests.h"
#import "OIDAuthorizationResponseTests.h"
#import "OIDTokenRequestTests.h"

/*! @brief An external user agent that never presents anything.
 */
@interface OIDNoOpExternalUserAgent : NSObject <OIDExternalUserAgent>
@end

@implementation OIDNoOpExternalUserAgent

- (BOOL)presentExternalUserAgentRequest:(id<OIDExternalUserAgentRequest>)request
                                session:(id<OIDExternalUserAgentSession>)session {
  return NO;
}

- (void)dismissExternalUserAgentAnimated:(BOOL)animated completion:(void (^)(void))completion {
  if (completion) {
    completion();
  }
}

@end

/*! @brief Unit tests for @c OIDFakeAuthorizationService.
 */
@interface OIDFakeAuthorizationServiceTests : XCTestCase
@end

@implementation OIDFakeAuthorizationServiceTests

/*! @brief A token request is recorded, and invoking the kept callback reaches the caller. */
- (void)testPerformTokenRequestIsRecordedAndCallbackIsReturned {
  OIDFakeAuthorizationService *service = [[OIDFakeAuthorizationService alloc] init];
  OIDTokenRequest *request = [OIDTokenRequestTests testInstance];
  OIDAuthorizationResponse *authorizationResponse = [OIDAuthorizationResponseTests testInstance];
  __block OIDTokenResponse *receivedResponse = nil;
  __block NSError *receivedError = nil;

  [service performTokenRequest:request
      originalAuthorizationResponse:authorizationResponse
                           callback:^(OIDTokenResponse *_Nullable tokenResponse,
                                      NSError *_Nullable error) {
                             receivedResponse = tokenResponse;
                             receivedError = error;
                           }];

  XCTAssertEqual(service.tokenRequestCount, 1u);
  XCTAssertEqual(service.lastTokenRequest, request);
  XCTAssertEqual(service.lastOriginalAuthorizationResponse, authorizationResponse);
  XCTAssertNotNil(service.lastTokenCallback);

  NSError *someError = [NSError errorWithDomain:@"com.example" code:42 userInfo:nil];
  service.lastTokenCallback(nil, someError);
  XCTAssertNil(receivedResponse);
  XCTAssertEqual(receivedError, someError);
}

/*! @brief The two-argument token request is recorded with no authorization response. */
- (void)testTwoArgumentPerformTokenRequestRoutesToThreeArgument {
  OIDFakeAuthorizationService *service = [[OIDFakeAuthorizationService alloc] init];
  OIDTokenRequest *request = [OIDTokenRequestTests testInstance];

  [service performTokenRequest:request
                      callback:^(OIDTokenResponse *_Nullable tokenResponse,
                                 NSError *_Nullable error) {
                      }];

  XCTAssertEqual(service.tokenRequestCount, 1u);
  XCTAssertEqual(service.lastTokenRequest, request);
  XCTAssertNil(service.lastOriginalAuthorizationResponse);
}

/*! @brief An authorization request is recorded and returns a fake session, which counts a cancel
        without calling back.
 */
- (void)testPresentAuthorizationRequestReturnsFakeSession {
  OIDFakeAuthorizationService *service = [[OIDFakeAuthorizationService alloc] init];
  OIDAuthorizationRequest *request = [OIDAuthorizationRequestTests testInstance];
  OIDNoOpExternalUserAgent *userAgent = [[OIDNoOpExternalUserAgent alloc] init];
  __block BOOL callbackInvoked = NO;

  id<OIDExternalUserAgentSession> session =
      [service presentAuthorizationRequest:request
                         externalUserAgent:userAgent
                                  callback:^(OIDAuthorizationResponse *_Nullable response,
                                             NSError *_Nullable error) {
                                    callbackInvoked = YES;
                                  }];

  XCTAssertEqual(session, service.lastAuthorizationSession);
  XCTAssertTrue([session isKindOfClass:[OIDFakeExternalUserAgentSession class]]);
  XCTAssertEqual(service.lastAuthorizationRequest, request);
  XCTAssertEqual(service.lastExternalUserAgent, userAgent);

  [session cancel];
  XCTAssertEqual(service.lastAuthorizationSession.cancelCount, 1u);
  XCTAssertFalse(callbackInvoked);
}

@end
