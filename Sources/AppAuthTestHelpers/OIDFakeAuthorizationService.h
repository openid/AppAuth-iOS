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
#import <TargetConditionals.h>

#import "OIDAuthorizationService.h"
#import "OIDFakeExternalUserAgentSession.h"

// Apps that use the Swift package don't define SWIFT_PACKAGE. Check for the header instead.
// AppAuth.xcodeproj finds these headers by name, and the package finds them by directory.
#if __has_include("OIDAuthorizationService+IOS.h")
#import "OIDAuthorizationService+IOS.h"
#import "OIDAuthorizationService+Mac.h"
#else
#import "iOS/OIDAuthorizationService+IOS.h"
#import "macOS/OIDAuthorizationService+Mac.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/*! @brief An @c OIDAuthorizationServiceProtocol whose methods record their arguments and keep the
        callbacks for the test to invoke, instead of presenting UI or making network requests.
    @discussion Inject an instance where production code takes an
        @c id<OIDAuthorizationServiceProtocol>.
        A kept callback clears itself once invoked. Callbacks usually capture the caller, and the
        caller often holds this fake. Keeping the callback would leak both.
 */
@interface OIDFakeAuthorizationService : NSObject <OIDAuthorizationServiceProtocol>

/*! @brief The request passed to the most recent
        @c -presentAuthorizationRequest:externalUserAgent:callback:.
 */
@property(nonatomic, readonly, nullable) OIDAuthorizationRequest *lastAuthorizationRequest;

/*! @brief The external user agent passed to the most recent authorization request. For the
        platform convenience methods, this is the agent AppAuth would build for the caller's view
        controller or window.
 */
@property(nonatomic, readonly, nullable) id<OIDExternalUserAgent> lastExternalUserAgent;

/*! @brief The callback of the most recent authorization request. Invoke it to complete the flow.
        Becomes nil once invoked.
 */
@property(nonatomic, readonly, copy, nullable) OIDAuthorizationCallback lastAuthorizationCallback;

/*! @brief The session returned from the most recent authorization request.
 */
@property(nonatomic, readonly, nullable) OIDFakeExternalUserAgentSession *lastAuthorizationSession;

/*! @brief The request passed to the most recent
        @c -presentEndSessionRequest:externalUserAgent:callback:.
 */
@property(nonatomic, readonly, nullable) OIDEndSessionRequest *lastEndSessionRequest;

/*! @brief The callback of the most recent end-session request. Becomes nil once invoked.
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
        Becomes nil once invoked.
 */
@property(nonatomic, readonly, copy, nullable) OIDTokenCallback lastTokenCallback;

/*! @brief The request passed to the most recent @c -performRegistrationRequest:completion:.
 */
@property(nonatomic, readonly, nullable) OIDRegistrationRequest *lastRegistrationRequest;

/*! @brief The completion of the most recent registration request. Becomes nil once invoked.
 */
@property(nonatomic, readonly, copy, nullable) OIDRegistrationCompletion lastRegistrationCompletion;

@end

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

/*! @brief The iOS convenience methods. Each builds the external user agent AppAuth would build
        for the view controller, then records the request like
        @c -presentAuthorizationRequest:externalUserAgent:callback:.
 */
@interface OIDFakeAuthorizationService (IOS) <OIDAuthorizationServiceIOSProtocol>
@end

#endif // TARGET_OS_IOS || TARGET_OS_MACCATALYST

#if TARGET_OS_OSX

/*! @brief The macOS convenience methods. Each builds the external user agent AppAuth would build
        for the window, then records the request like
        @c -presentAuthorizationRequest:externalUserAgent:callback:.
 */
@interface OIDFakeAuthorizationService (Mac) <OIDAuthorizationServiceMacProtocol>
@end

#endif // TARGET_OS_OSX

NS_ASSUME_NONNULL_END
