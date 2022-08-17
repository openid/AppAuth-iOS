/*! @file OIDExternalUserAgentMac.h
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

#if TARGET_OS_OSX

#import <AppKit/AppKit.h>
#import "OIDExternalUserAgent.h"

NS_ASSUME_NONNULL_BEGIN

/*! @brief A Mac-specific external user-agent UI Coordinator that uses the default browser to
        present an external user-agent request.
 */
@interface OIDExternalUserAgentMac : NSObject <OIDExternalUserAgent>

/*! @brief The designated initializer.
    @param presentingWindow The window from which to present the @c ASWebAuthenticationSession on
        macOS 10.15 and above.  Older macOS versions use the system browser.
 */
- (instancetype)initWithPresentingWindow:(NSWindow *)presentingWindow NS_DESIGNATED_INITIALIZER;

/*! @brief Create an external user-agent which optionally uses a private authentication session.
 @param presentingWindow The window from which to present the @c ASWebAuthenticationSession.
 @param prefersEphemeralSession Whether the caller prefers to use a private authentication
 session. See @c ASWebAuthenticationSession.prefersEphemeralWebBrowserSession for more.
 */
- (nullable instancetype)initWithPresentingWindow:(NSWindow *)presentingWindow
                          prefersEphemeralSession:(BOOL)prefersEphemeralSession
    API_AVAILABLE(macos(10.15));

- (instancetype)init __deprecated_msg("Use initWithPresentingWindow for macOS 10.15 and above.");

@end

NS_ASSUME_NONNULL_END

#endif // TARGET_OS_OSX
