/*! @file OIDExternalUserAgentIOSCustomBrowserTests.m
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

#import <TargetConditionals.h>

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST && !SWIFT_PACKAGE

#import <XCTest/XCTest.h>

#import "OIDAuthorizationRequestTests.h"
#import "Sources/AppAuth/iOS/OIDExternalUserAgentIOSCustomBrowser.h"
#import "Sources/AppAuthCore/OIDAuthorizationRequest.h"
#import "Sources/AppAuthCore/OIDAuthorizationService.h"
#import "Sources/AppAuthCore/OIDError.h"
#import "Sources/AppAuthCore/OIDExternalUserAgent.h"
#import "Sources/AppAuthCore/OIDExternalUserAgentRequest.h"
#import "Sources/AppAuthCore/OIDExternalUserAgentSession.h"

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

NS_ASSUME_NONNULL_BEGIN

/*! @brief Fake @c OIDExternalUserAgentIOSCustomBrowserURLOpener that records calls and lets tests
        drive the open completion handler.
 */
@interface OIDTestCustomBrowserURLOpener : NSObject <OIDExternalUserAgentIOSCustomBrowserURLOpener>

@property(nonatomic) BOOL canOpenURLResult;
@property(nonatomic, readonly) NSMutableArray<NSURL *> *canOpenURLQueries;
@property(nonatomic, readonly) NSMutableArray<NSURL *> *openedURLs;
@property(nonatomic, copy, nullable) void (^lastCompletionHandler)(BOOL success);

@end

@implementation OIDTestCustomBrowserURLOpener

- (instancetype)init {
  self = [super init];
  if (self) {
    _canOpenURLResult = YES;
    _canOpenURLQueries = [NSMutableArray array];
    _openedURLs = [NSMutableArray array];
  }
  return self;
}

- (BOOL)canOpenURL:(NSURL *)URL {
  [_canOpenURLQueries addObject:URL];
  return _canOpenURLResult;
}

- (void)openURL:(NSURL *)URL completionHandler:(nullable void (^)(BOOL success))completionHandler {
  [_openedURLs addObject:URL];
  _lastCompletionHandler = [completionHandler copy];
}

@end

/*! @brief Fake @c OIDExternalUserAgentSession that records failures reported to it.
 */
@interface OIDTestExternalUserAgentSession : NSObject <OIDExternalUserAgentSession>

@property(nonatomic, readonly) NSMutableArray<NSError *> *failureErrors;

@end

@implementation OIDTestExternalUserAgentSession

- (instancetype)init {
  self = [super init];
  if (self) {
    _failureErrors = [NSMutableArray array];
  }
  return self;
}

- (void)cancel {
}

- (void)cancelWithCompletion:(nullable void (^)(void))completion {
  if (completion) {
    completion();
  }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (BOOL)resumeExternalUserAgentFlowWithURL:(NSURL *)URL {
  return NO;
}
#pragma clang diagnostic pop

- (BOOL)resumeExternalUserAgentFlowWithURL:(NSURL *)URL
                                     error:(NSError *_Nullable *_Nullable)error {
  return NO;
}

- (void)failExternalUserAgentFlowWithError:(NSError *)error {
  [_failureErrors addObject:error];
}

@end

/*! @brief Fake @c OIDExternalUserAgent that captures the session passed to it.
 */
@interface OIDTestCapturingExternalUserAgent : NSObject <OIDExternalUserAgent>

@property(nonatomic, nullable) id<OIDExternalUserAgentSession> session;

@end

@implementation OIDTestCapturingExternalUserAgent

- (BOOL)presentExternalUserAgentRequest:(id<OIDExternalUserAgentRequest>)request
                                session:(id<OIDExternalUserAgentSession>)session {
  _session = session;
  return YES;
}

- (void)dismissExternalUserAgentAnimated:(BOOL)animated completion:(void (^)(void))completion {
  completion();
}

@end

/*! @brief Unit tests covering @c presentExternalUserAgentRequest:session: of
        @c OIDExternalUserAgentIOSCustomBrowser through an injected URL opener, and the session's
        failure idempotency.
 */
@interface OIDExternalUserAgentIOSCustomBrowserTests : XCTestCase
@end

@implementation OIDExternalUserAgentIOSCustomBrowserTests

- (OIDExternalUserAgentIOSCustomBrowser *)customBrowserWithOpener:
    (id<OIDExternalUserAgentIOSCustomBrowserURLOpener>)opener {
  OIDCustomBrowserURLTransformation transform = [OIDExternalUserAgentIOSCustomBrowser
      URLTransformationSchemeSubstitutionHTTPS:@"testbrowser"
                                          HTTP:@"testbrowser-http"];
  return [[OIDExternalUserAgentIOSCustomBrowser alloc] initWithURLTransformation:transform
                                                                canOpenURLScheme:nil
                                                                     appStoreURL:nil
                                                                       URLOpener:opener];
}

- (void)testPresentOpensTransformedURLAndReturnsYES {
  OIDTestCustomBrowserURLOpener *opener = [[OIDTestCustomBrowserURLOpener alloc] init];
  OIDTestExternalUserAgentSession *session = [[OIDTestExternalUserAgentSession alloc] init];
  OIDExternalUserAgentIOSCustomBrowser *browser = [self customBrowserWithOpener:opener];

  BOOL presented =
      [browser presentExternalUserAgentRequest:[OIDAuthorizationRequestTests testInstance]
                                       session:session];

  XCTAssertTrue(presented);
  XCTAssertEqual(opener.openedURLs.count, 1u);
  XCTAssertEqualObjects(opener.openedURLs.firstObject.scheme, @"testbrowser");
  XCTAssertEqual(session.failureErrors.count, 0u);
  XCTAssertEqual(opener.canOpenURLQueries.count, 0u);
}

// Pins the fix for issue #980: canOpenURL: can answer NO for a URL that openURL: opens.
- (void)testPresentIgnoresCanOpenURLForRequestURL {
  OIDTestCustomBrowserURLOpener *opener = [[OIDTestCustomBrowserURLOpener alloc] init];
  opener.canOpenURLResult = NO;
  OIDTestExternalUserAgentSession *session = [[OIDTestExternalUserAgentSession alloc] init];
  OIDExternalUserAgentIOSCustomBrowser *browser = [self customBrowserWithOpener:opener];

  BOOL presented =
      [browser presentExternalUserAgentRequest:[OIDAuthorizationRequestTests testInstance]
                                       session:session];

  XCTAssertTrue(presented);
  XCTAssertEqual(opener.openedURLs.count, 1u);
  XCTAssertEqual(session.failureErrors.count, 0u);
}

- (void)testOpenFailureFailsSessionExactlyOnce {
  OIDTestCustomBrowserURLOpener *opener = [[OIDTestCustomBrowserURLOpener alloc] init];
  OIDTestExternalUserAgentSession *session = [[OIDTestExternalUserAgentSession alloc] init];
  OIDExternalUserAgentIOSCustomBrowser *browser = [self customBrowserWithOpener:opener];

  [browser presentExternalUserAgentRequest:[OIDAuthorizationRequestTests testInstance]
                                   session:session];
  XCTAssertNotNil(opener.lastCompletionHandler);
  opener.lastCompletionHandler(NO);

  XCTAssertEqual(session.failureErrors.count, 1u);
  XCTAssertEqualObjects(session.failureErrors.firstObject.domain, OIDGeneralErrorDomain);
  XCTAssertEqual(session.failureErrors.firstObject.code, OIDErrorCodeSafariOpenError);
}

- (void)testOpenSuccessDoesNotFailSession {
  OIDTestCustomBrowserURLOpener *opener = [[OIDTestCustomBrowserURLOpener alloc] init];
  OIDTestExternalUserAgentSession *session = [[OIDTestExternalUserAgentSession alloc] init];
  OIDExternalUserAgentIOSCustomBrowser *browser = [self customBrowserWithOpener:opener];

  [browser presentExternalUserAgentRequest:[OIDAuthorizationRequestTests testInstance]
                                   session:session];
  XCTAssertNotNil(opener.lastCompletionHandler);
  opener.lastCompletionHandler(YES);

  XCTAssertEqual(session.failureErrors.count, 0u);
}

- (void)testNilTransformedURLReturnsNOWithoutOpening {
  OIDTestCustomBrowserURLOpener *opener = [[OIDTestCustomBrowserURLOpener alloc] init];
  OIDTestExternalUserAgentSession *session = [[OIDTestExternalUserAgentSession alloc] init];
  OIDCustomBrowserURLTransformation nilTransform = ^NSURL *_Nullable(NSURL *_Nullable requestURL) {
    return nil;
  };
  OIDExternalUserAgentIOSCustomBrowser *browser =
      [[OIDExternalUserAgentIOSCustomBrowser alloc] initWithURLTransformation:nilTransform
                                                             canOpenURLScheme:nil
                                                                  appStoreURL:nil
                                                                    URLOpener:opener];

  BOOL presented =
      [browser presentExternalUserAgentRequest:[OIDAuthorizationRequestTests testInstance]
                                       session:session];

  XCTAssertFalse(presented);
  XCTAssertEqual(opener.openedURLs.count, 0u);
  XCTAssertEqual(session.failureErrors.count, 0u);
}

// OIDExternalUserAgentIOSCustomBrowser fails the session from an asynchronous completion handler,
// so a session that has already finished (cancelled, or failed another way) must ignore a second
// failure.
- (void)testSessionReportsFailureOnlyOnce {
  OIDTestCapturingExternalUserAgent *agent = [[OIDTestCapturingExternalUserAgent alloc] init];
  __block NSUInteger callbackCount = 0;
  __block NSError *receivedError = nil;

  id<OIDExternalUserAgentSession> session = [OIDAuthorizationService
      presentAuthorizationRequest:[OIDAuthorizationRequestTests testInstance]
                externalUserAgent:agent
                         callback:^(OIDAuthorizationResponse *_Nullable response,
                                    NSError *_Nullable error) {
                           callbackCount++;
                           receivedError = error;
                         }];
  XCTAssertNotNil(session);
  XCTAssertEqual(callbackCount, 0u);

  NSError *first = [NSError errorWithDomain:OIDGeneralErrorDomain
                                       code:OIDErrorCodeSafariOpenError
                                   userInfo:@{NSLocalizedDescriptionKey : @"first"}];
  NSError *second = [NSError errorWithDomain:OIDGeneralErrorDomain
                                        code:OIDErrorCodeSafariOpenError
                                    userInfo:@{NSLocalizedDescriptionKey : @"second"}];

  [session failExternalUserAgentFlowWithError:first];
  [session failExternalUserAgentFlowWithError:second];

  XCTAssertEqual(callbackCount, 1u);
  XCTAssertEqualObjects(receivedError.localizedDescription, @"first");
}

@end

NS_ASSUME_NONNULL_END

#pragma GCC diagnostic pop

#endif // TARGET_OS_IOS && !TARGET_OS_MACCATALYST && !SWIFT_PACKAGE
