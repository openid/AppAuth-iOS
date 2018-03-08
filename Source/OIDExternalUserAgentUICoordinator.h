/*! @file OIDExternalUserAgentUICoordinator.h
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

#import <Foundation/Foundation.h>

@protocol OIDExternalUserAgentFlowSession;
@protocol OIDExternalUserAgentRequest;

NS_ASSUME_NONNULL_BEGIN

/*! @protocol OIDExternalUserAgentUICoordinator
    @brief An external user-agent UI coordinator that presents a request. Clients may provide custom
        implementations of an external UI coordinator to customize the way the requests are
        presented to the end user.
 */
@protocol OIDExternalUserAgentUICoordinator<NSObject>

/*! @brief Presents the external user-agent request in the UI coordinator.
    @param request The request to be presented in the UI.
    @param session The @c OIDExternalUserAgentFlowSession instance that initiates presenting the UI.
        Concrete implementations of a @c OIDExternalUserAgentUICoordinator may call
        resumeExternalUserAgentFlowWithURL or failExternalUserAgentFlowWithError on session to either
        resume or fail the request.
    @return YES If the request UI was successfully presented to the user.
 */
- (BOOL)presentExternalUserAgentRequest:(id<OIDExternalUserAgentRequest> )request
                                session:(id<OIDExternalUserAgentFlowSession>)session;

/*! @brief Dimisses the external user-agent UI and calls completion when the dismiss operation ends.
    @param animated Wheter or not the dismiss operation should be animated.
    @remarks Has no effect if no UI is presented.
    @param completion The block to be called when the dismiss operations ends
 */
- (void)dismissExternalUserAgentUIAnimated:(BOOL)animated completion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
