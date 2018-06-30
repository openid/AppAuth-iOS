/*! @file OIDAuthState+IOS.h
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

#import <UIKit/UIKit.h>

#import "OIDAuthState.h"

NS_ASSUME_NONNULL_BEGIN

/*! @brief iOS specific convenience methods for @c OIDAuthState.
 */
@interface OIDAuthState (IOS)

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

/*! @brief Convenience method to create a @c OIDAuthState by presenting an authorization request
        and performing the authorization code exchange in the case of code flow requests.
    @param authorizationRequest The authorization request to present.
    @param presentingViewController The view controller from which to present the
        @c SFSafariViewController.
    @param callback The method called when the request has completed or failed.
    @return A @c OIDExternalUserAgentSession instance which will terminate when it
        receives a @c OIDExternalUserAgentSession.cancel message, or after processing a
        @c OIDExternalUserAgentSession.resumeExternalUserAgentFlowWithURL: message.
 */
+ (id<OIDExternalUserAgentSession, OIDAuthorizationFlowSession>)
    authStateByPresentingAuthorizationRequest:(OIDAuthorizationRequest *)authorizationRequest
                     presentingViewController:(UIViewController *)presentingViewController
                                     callback:(OIDAuthStateAuthorizationCallback)callback;

/*! @brief Performs an incremental authorization request.
    @param incrementalAuthorizationRequest the incremental authorization request. Must use the same
        OAuth client as the original request.
    @param presentingViewController The view controller which is presenting this request.
    @return A @c OIDExternalUserAgentSession instance which will terminate when it receives a
        @c OIDExternalUserAgentSession.cancel message, or after processing a
    @discussion This method will automatically do an incremental authorization code exchange. If
        any part of this fails, the last error is provided in the callback, and the @c OIDAuthState
        object is not updated. You must ensure that the authorization server supports public client
        incremental authorization otherwise, the OIDAuthState will just be overwritten with the
        new authorization grant (and the previous grant will be lost).
 */
- (id<OIDExternalUserAgentSession, OIDAuthorizationFlowSession>)
    presentIncrementalAuthorizationRequest:(OIDAuthorizationRequest *)incrementalAuthorizationRequest
                  presentingViewController:(UIViewController *)presentingViewController
                                  callback:(OIDAuthStateIncrementalAuthorizationCallback)callback;

#pragma GCC diagnostic pop

@end

NS_ASSUME_NONNULL_END
