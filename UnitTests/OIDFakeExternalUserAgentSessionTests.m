/*! @file OIDFakeExternalUserAgentSessionTests.m
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
#import "Sources/AppAuthCore/OIDError.h"
#import "Sources/AppAuthTestHelpers/AppAuthTestHelpers.h"
#endif

/*! @brief Unit tests for @c OIDFakeExternalUserAgentSession.
 */
@interface OIDFakeExternalUserAgentSessionTests : XCTestCase
@end

@implementation OIDFakeExternalUserAgentSessionTests

/*! @brief Resuming records the URL and returns @c resumeResult, with an error when it is NO. */
- (void)testResumeRecordsURLAndReturnsResumeResult {
  OIDFakeExternalUserAgentSession *session = [[OIDFakeExternalUserAgentSession alloc] init];
  session.resumeResult = NO;
  NSURL *firstURL = [NSURL URLWithString:@"https://example.com/callback?code=1"];
  NSError *error = nil;
  XCTAssertFalse([session resumeExternalUserAgentFlowWithURL:firstURL error:&error]);
  XCTAssertEqualObjects(session.lastResumedURL, firstURL);
  XCTAssertEqualObjects(error.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(error.code, OIDErrorCodeURLMismatch);

  session.resumeResult = YES;
  error = nil;
  NSURL *secondURL = [NSURL URLWithString:@"https://example.com/callback?code=2"];
  XCTAssertTrue([session resumeExternalUserAgentFlowWithURL:secondURL error:&error]);
  XCTAssertEqualObjects(session.lastResumedURL, secondURL);
  XCTAssertNil(error);
}

/*! @brief A new session handles every URL. */
- (void)testResumeResultDefaultsToYES {
  OIDFakeExternalUserAgentSession *session = [[OIDFakeExternalUserAgentSession alloc] init];
  XCTAssertTrue(session.resumeResult);
}

/*! @brief Both cancel methods are counted, and the completion runs. */
- (void)testCancelIsCounted {
  OIDFakeExternalUserAgentSession *session = [[OIDFakeExternalUserAgentSession alloc] init];
  [session cancel];
  __block BOOL completionCalled = NO;
  [session cancelWithCompletion:^{
    completionCalled = YES;
  }];
  XCTAssertEqual(session.cancelCount, 2u);
  XCTAssertTrue(completionCalled);
}

/*! @brief Failing the flow records the error. */
- (void)testFailRecordsError {
  OIDFakeExternalUserAgentSession *session = [[OIDFakeExternalUserAgentSession alloc] init];
  NSError *error = [NSError errorWithDomain:@"com.example" code:42 userInfo:nil];
  [session failExternalUserAgentFlowWithError:error];
  XCTAssertEqualObjects(session.lastFailureError, error);
}

@end
