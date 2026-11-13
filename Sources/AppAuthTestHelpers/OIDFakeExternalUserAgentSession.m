/*! @file OIDFakeExternalUserAgentSession.m
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

#import "OIDFakeExternalUserAgentSession.h"

#import "OIDError.h"
#import "OIDErrorUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@implementation OIDFakeExternalUserAgentSession

- (instancetype)init {
  self = [super init];
  if (self) {
    _resumeResult = YES;
  }
  return self;
}

- (void)cancel {
  _cancelCount++;
}

- (void)cancelWithCompletion:(nullable void (^)(void))completion {
  _cancelCount++;
  if (completion) {
    completion();
  }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (BOOL)resumeExternalUserAgentFlowWithURL:(NSURL *)URL {
  return [self resumeExternalUserAgentFlowWithURL:URL error:nil];
}
#pragma clang diagnostic pop

- (BOOL)resumeExternalUserAgentFlowWithURL:(NSURL *)URL
                                     error:(NSError *_Nullable *_Nullable)error {
  _lastResumedURL = URL;
  if (!_resumeResult && error) {
    *error = [OIDErrorUtilities errorWithCode:OIDErrorCodeURLMismatch
                              underlyingError:nil
                                  description:@"Fake session was told not to handle the URL."];
  }
  return _resumeResult;
}

- (void)failExternalUserAgentFlowWithError:(NSError *)error {
  _lastFailureError = error;
}

@end

NS_ASSUME_NONNULL_END
