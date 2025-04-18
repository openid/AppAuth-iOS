/*! @file OIDTVAuthorizationService.h
    @brief AppAuth iOS SDK
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

@class OIDAuthState;
@class OIDTVAuthorizationRequest;
@class OIDTVAuthorizationResponse;
@class OIDTVServiceConfiguration;

/*! @brief Represents the type of block used as a callback for creating a TV service configuration from
        a remote OpenID Connect Discovery document.
    @param configuration The TV service configuration, if available.
    @param error The error if an error occurred.
 */
typedef void (^OIDTVDiscoveryCallback)(OIDTVServiceConfiguration *_Nullable configuration,
                                     NSError *_Nullable error);

/*! @brief The block that is called when the TV authorization has initialized.
    @param response The authorization response, or nil if there was an error. Display
        @c OIDTVAuthorizationResponse.userCode and @c OIDTVAuthorizationResponse.verificationURI to
        the user so they can action the request.
    @param error The error if an error occurred.
 */
typedef void (^OIDTVAuthorizationInitialization)(OIDTVAuthorizationResponse *_Nullable response,
                                                 NSError *_Nullable error);

/*! @brief The block that is called when the TV authorization has completed.
    @param authorization The @c OIDAuthState which you can use to authorize
        API calls, or nil if there was an error.
    @param error The error if an error occurred.
 */
typedef void (^OIDTVAuthorizationCompletion)
    (OIDAuthState *_Nullable authorization,
     NSError *_Nullable error);

/*! @brief Block returned when authorization is initialized that will cancel the pending
        authorization when executed. Has no effect if called twice or after the authorization
        concluded.
 */
typedef void (^OIDTVAuthorizationCancelBlock)(void);

/*! @brief Performs authorization flows designed for TVs and other limited input devices.
 */
@interface OIDTVAuthorizationService : NSObject
/*! @internal
    @brief Unavailable. This class should not be initialized.
 */
- (instancetype)init NS_UNAVAILABLE;

/*! @brief Convenience method for creating a TV authorization service configuration from an OpenID
        Connect compliant issuer URL. This method validates the presence of a device authorization
        endpoint in the retrieved discovery document and instantiates an
        @c OIDTVServiceConfiguration.
    @param issuerURL The service provider's OpenID Connect issuer.
    @param completion A block which will be invoked when the authorization service configuration has
        been created, or when an error has occurred.
    @see https://openid.net/specs/openid-connect-discovery-1_0.html
 */
+ (void)discoverServiceConfigurationForIssuer:(NSURL *)issuerURL
                                   completion:(OIDTVDiscoveryCallback)completion;

/*! @brief Convenience method for creating a TV authorization service configuration from an OpenID
        Connect compliant identity provider's discovery document. This method validates the presence
        of a device authorization endpoint in the retrieved discovery document and instantiates an
        @c OIDTVServiceConfiguration.
    @param discoveryURL The URL of the service provider's OpenID Connect discovery document.
    @param completion A block which will be invoked when the authorization service configuration has
        been created, or when an error has occurred.
    @see https://openid.net/specs/openid-connect-discovery-1_0.html
 */
+ (void)discoverServiceConfigurationForDiscoveryURL:(NSURL *)discoveryURL
                                         completion:(OIDTVDiscoveryCallback)completion;

/*! @brief Starts a TV authorization flow with the given request and polls for a response.
    @param request The TV authorization request to initiate.
    @param initialization Block that is called with the initial authorization response. Unlike other
        OAuth authorization responses, the TV authorization response doesn't contain the
        authorization as the user has yet to grant it. Rather, it contains the information that you
        show to the user in order for them to authorize the request on another device.
    @param completion Block that is called on the success or failure of the authorization. If the
        user approves the request, you will get a @c OIDAuthState that you can use
        to authenticate API calls, otherwis eyou will get an error.
    @return A block which you can execute if you need to cancel the ongoing authorization. Has no
        effect if called twice, or called after the authorization concludes.
    @see https://tools.ietf.org/html/rfc8628
 */
+ (OIDTVAuthorizationCancelBlock)authorizeTVRequest:(OIDTVAuthorizationRequest *)request
                                     initialization:(OIDTVAuthorizationInitialization)initialization
                                         completion:(OIDTVAuthorizationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
