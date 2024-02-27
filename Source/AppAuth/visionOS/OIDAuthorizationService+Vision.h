/*! @file OIDAuthorizationService+Vision.h
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2016 Google Inc. All Rights Reserved.
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

#if TARGET_OS_VISION

#import <UIKit/UIKit.h>

#import "OIDAuthorizationService.h"
#import "OIDExternalUserAgentSession.h"

NS_ASSUME_NONNULL_BEGIN

/*! @brief Provides visionOS specific authorization request handling.
 */
@interface OIDAuthorizationService (Vision)

/*! @brief Perform an authorization flow, presenting an appropriate browser for the user to
 authenticate.
    @param request The authorization request.
    @param presentingWindow The window to present the authentication flow.
    @param callback The method called when the request has completed or failed.
    @return A @c OIDExternalUserAgentSession instance which will terminate when it
        receives a @c OIDExternalUserAgentSession.cancel message, or after processing a
        @c OIDExternalUserAgentSession.resumeExternalUserAgentFlowWithURL: message.
 */
+ (id<OIDExternalUserAgentSession>) presentAuthorizationRequest:(OIDAuthorizationRequest *)request
                                               presentingWindow:(UIWindow *)presentingWindow
                                                       callback:(OIDAuthorizationCallback)callback;

/*! @brief Perform an authorization flow using the @c ASWebAuthenticationSession optionally using an
        emphemeral browser session that shares no cookies or data with the normal browser session.
    @param request The authorization request.
    @param presentingWindow The window to present the authentication flow.
    @param prefersEphemeralSession Whether the caller prefers to use a private authentication
        session. See @c ASWebAuthenticationSession.prefersEphemeralWebBrowserSession for more.
    @param callback The method called when the request has completed or failed.
    @return A @c OIDExternalUserAgentSession instance which will terminate when it
        receives a @c OIDExternalUserAgentSession.cancel message, or after processing a
        @c OIDExternalUserAgentSession.resumeExternalUserAgentFlowWithURL: message.
 */
+ (id<OIDExternalUserAgentSession>) presentAuthorizationRequest:(OIDAuthorizationRequest *)request
                                               presentingWindow:(UIWindow *)presentingWindow
                                        prefersEphemeralSession:(BOOL)prefersEphemeralSession
                                                       callback:(OIDAuthorizationCallback)callback;

/*! @brief Perform an authorization flow using the default browser.
    @param request The authorization request.
    @param callback The method called when the request has completed or failed.
    @return A @c OIDExternalUserAgentSession instance which will terminate when it
        receives a @c OIDExternalUserAgentSession.cancel message, or after processing a
        @c OIDExternalUserAgentSession.resumeExternalUserAgentFlowWithURL: message.
 */
+ (id<OIDExternalUserAgentSession>)presentAuthorizationRequest:(OIDAuthorizationRequest *)request
                                                      callback:(OIDAuthorizationCallback)callback
    __deprecated_msg("For visionOS 1.15 and above please use presentAuthorizationRequest:presentingWindow:callback:");

@end

NS_ASSUME_NONNULL_END

#endif // TARGET_OS_VISION
