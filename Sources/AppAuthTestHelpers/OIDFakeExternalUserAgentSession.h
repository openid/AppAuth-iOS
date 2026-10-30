/*! @file OIDFakeExternalUserAgentSession.h
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

#import <Foundation/Foundation.h>

#import "OIDExternalUserAgentSession.h"

NS_ASSUME_NONNULL_BEGIN

/*! @brief An @c OIDExternalUserAgentSession that records the messages it receives instead of
        driving a user agent. Returned by @c OIDFakeAuthorizationService.
 */
@interface OIDFakeExternalUserAgentSession : NSObject <OIDExternalUserAgentSession>

/*! @brief How many times @c -cancel or @c -cancelWithCompletion: was called. */
@property(nonatomic, readonly) NSUInteger cancelCount;

/*! @brief The URL passed to the most recent @c -resumeExternalUserAgentFlowWithURL:error:, if any. */
@property(nonatomic, readonly, nullable) NSURL *lastResumedURL;

/*! @brief What @c -resumeExternalUserAgentFlowWithURL:error: returns. Defaults to YES. */
@property(nonatomic) BOOL resumeResult;

/*! @brief The error passed to the most recent @c -failExternalUserAgentFlowWithError:, if any. */
@property(nonatomic, readonly, nullable) NSError *lastFailureError;

@end

NS_ASSUME_NONNULL_END
