/*! @file OIDFakeAuthorizationService.h
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

#import "OIDAuthorizationService.h"
#import "OIDFakeExternalUserAgentSession.h"

NS_ASSUME_NONNULL_BEGIN

/*! @brief An @c OIDAuthorizationService whose instance methods record their arguments and keep the
        callbacks for the test to invoke, instead of presenting UI or making network requests.
    @discussion Inject an instance where production code would otherwise call the class methods of
        @c OIDAuthorizationService. The class methods of this fake are inherited unchanged and still
        perform real work; only the instance methods are faked.
 */
@interface OIDFakeAuthorizationService : OIDAuthorizationService

/*! @brief The request passed to the most recent
        @c -presentAuthorizationRequest:externalUserAgent:callback:.
 */
@property(nonatomic, readonly, nullable) OIDAuthorizationRequest *lastAuthorizationRequest;

/*! @brief The external user agent passed to the most recent authorization request. For the
        platform convenience methods, this is the agent AppAuth built for the caller's view
        controller or window.
 */
@property(nonatomic, readonly, nullable) id<OIDExternalUserAgent> lastExternalUserAgent;

/*! @brief The callback of the most recent authorization request. Invoke it to complete the flow.
 */
@property(nonatomic, readonly, copy, nullable) OIDAuthorizationCallback lastAuthorizationCallback;

/*! @brief The session returned from the most recent authorization request.
 */
@property(nonatomic, readonly, nullable) OIDFakeExternalUserAgentSession *lastAuthorizationSession;

/*! @brief The request passed to the most recent
        @c -presentEndSessionRequest:externalUserAgent:callback:.
 */
@property(nonatomic, readonly, nullable) OIDEndSessionRequest *lastEndSessionRequest;

/*! @brief The callback of the most recent end-session request.
 */
@property(nonatomic, readonly, copy, nullable) OIDEndSessionCallback lastEndSessionCallback;

/*! @brief How many token requests have been performed.
 */
@property(nonatomic, readonly) NSUInteger tokenRequestCount;

/*! @brief The request passed to the most recent
        @c -performTokenRequest:originalAuthorizationResponse:callback:.
 */
@property(nonatomic, readonly, nullable) OIDTokenRequest *lastTokenRequest;

/*! @brief The authorization response passed alongside the most recent token request, if any.
 */
@property(nonatomic, readonly, nullable)
    OIDAuthorizationResponse *lastOriginalAuthorizationResponse;

/*! @brief The callback of the most recent token request. Invoke it to complete the request.
 */
@property(nonatomic, readonly, copy, nullable) OIDTokenCallback lastTokenCallback;

/*! @brief The request passed to the most recent @c -performRegistrationRequest:completion:.
 */
@property(nonatomic, readonly, nullable) OIDRegistrationRequest *lastRegistrationRequest;

/*! @brief The completion of the most recent registration request.
 */
@property(nonatomic, readonly, copy, nullable) OIDRegistrationCompletion lastRegistrationCompletion;

@end

NS_ASSUME_NONNULL_END
