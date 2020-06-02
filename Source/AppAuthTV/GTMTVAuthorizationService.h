/*! @file GTMTVAuthorizationService.h
    @brief GTMAppAuth SDK
    @copyright
        Copyright 2016 Google Inc.
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

NS_ASSUME_NONNULL_BEGIN

@class GTMAppAuthFetcherAuthorization;
@class GTMTVAuthorizationRequest;
@class GTMTVAuthorizationResponse;
@class GTMTVServiceConfiguration;

/*! @brief The block that is called when the TV authorization has initialized.
    @param response The authorization response, or nil if there was an error. Display
        @c GTMTVAuthorizationResponse.userCode and @c GTMTVAuthorizationResponse.verificationURL to
        the user so they can action the request.
    @param error The error if an error occurred.
 */
typedef void (^GTMTVAuthorizationInitialization)(GTMTVAuthorizationResponse *_Nullable response,
                                                 NSError *_Nullable error);

/*! @brief The block that is called when the TV authorization has completed.
    @param authorization The @c GTMAppAuthFetcherAuthorization which you can use to authorize
        API calls, or nil if there was an error.
    @param error The error if an error occurred.
 */
typedef void (^GTMTVAuthorizationCompletion)
    (GTMAppAuthFetcherAuthorization *_Nullable authorization,
     NSError *_Nullable error);

/*! @brief Block returned when authorization is initialized to that will cancel the pending
        authorization when executed. Has no effect if called twice or after the authorization
        concluded.
 */
typedef void (^GTMTVAuthorizationCancelBlock)(void);

/*! @brief Performs authorization flows designed for TVs and other limited input devices.
 */
@interface GTMTVAuthorizationService : NSObject

#if !GTM_APPAUTH_SKIP_GOOGLE_SUPPORT
/*! @brief Convenience method to return the TV authorization URL for Google.
    @return TV authorization URL for Google.
 */
+ (GTMTVServiceConfiguration *)TVConfigurationForGoogle;
#endif // !GTM_APPAUTH_SKIP_GOOGLE_SUPPORT

/*! @brief Starts a TV authorization flow with the given request and polls for a response.
    @param request The TV authorization request to initiate.
    @param initialization Block that is called with the initial authorization response. Unlike other
        OAuth authorization responses, the TV authorization response doesn't contain the
        authorization as the user has yet to grant it. Rather, it contains the information that you
        show to the user in order for them to authorize the request on another device.
    @param completion Block that is called on the success or failure of the authorization. If the
        user approves the request, you will get a @c GTMAppAuthFetherAuthorization that you can use
        to authenticate API calls, otherwis eyou will get an error.
    @return A block which you can execute if you need to cancel the ongoing authorization. Has no
        effect if called twice, or called after the authorization concludes.
    @see https://developers.google.com/identity/protocols/OAuth2ForDevices
 */
+ (GTMTVAuthorizationCancelBlock)authorizeTVRequest:(GTMTVAuthorizationRequest *)request
                                     initializaiton:(GTMTVAuthorizationInitialization)initialization
                                         completion:(GTMTVAuthorizationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
