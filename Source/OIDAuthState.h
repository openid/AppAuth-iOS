/*! @file OIDAuthState.h
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2015 Google Inc. All Rights Reserved.
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

@class OIDAuthorizationRequest;
@class OIDAuthorizationResponse;
@class OIDAuthState;
@class OIDTokenResponse;
@class OIDTokenRequest;
@protocol OIDAuthorizationFlowSession;
@protocol OIDAuthorizationUICoordinator;
@protocol OIDAuthStateChangeDelegate;
@protocol OIDAuthStateErrorDelegate;

NS_ASSUME_NONNULL_BEGIN

/*! @typedef OIDAuthStateAction
    @brief Represents a block used to call an action with a fresh access token.
    @param accessToken A valid access token if available.
    @param idToken A valid ID token if available.
    @param error The error if an error occurred.
 */
typedef void (^OIDAuthStateAction)(NSString *_Nullable accessToken,
                                   NSString *_Nullable idToken,
                                   NSError *_Nullable error);

/*! @typedef OIDAuthStateAuthorizationCallback
    @brief The method called when the @c
        OIDAuthState.authStateByPresentingAuthorizationRequest:presentingViewController:callback:
        method has completed or failed.
    @param authState The auth state, if the authorization request succeeded.
    @param error The error if an error occurred.
 */
typedef void (^OIDAuthStateAuthorizationCallback)(OIDAuthState *_Nullable authState,
                                                  NSError *_Nullable error);

/*! @class OIDAuthState
    @brief A convenience class that retains the auth state between @c OIDAuthorizationResponse%s
        and @c OIDTokenResponse%s.
 */
@interface OIDAuthState : NSObject <NSSecureCoding>

/*! @property refreshToken
    @brief The most recent refresh token received from the server.
    @discussion Rather than using this property directly, you should call
        @c OIDAuthState.withFreshTokensPerformAction:.
    @remarks refresh_token
    @see https://tools.ietf.org/html/rfc6749#section-5.1
 */
@property(nonatomic, readonly, nullable) NSString *refreshToken;

/*! @property scope
    @brief The scope of the current authorization grant.
    @discussion This represents the latest scope returned by the server and may be a subset of the
        scope that was initially granted.
    @remarks scope
 */
@property(nonatomic, readonly, nullable) NSString *scope;

/*! @property lastAuthorizationResponse
    @brief The most recent authorization response used to update the authorization state. For the
        implicit flow, this will contain the latest access token.
 */
@property(nonatomic, readonly) OIDAuthorizationResponse *lastAuthorizationResponse;

/*! @property lastTokenResponse
    @brief The most recent token response used to update this authorization state. This will
        contain the latest access token.
 */
@property(nonatomic, readonly, nullable) OIDTokenResponse *lastTokenResponse;

/*! @property authorizationError
    @brief The authorization error that invalidated this @c OIDAuthState.
    @discussion The authorization error encountered by @c OIDAuthState or set by the user via
        @c OIDAuthState.updateWithAuthorizationError: that invalidated this @c OIDAuthState.
        Authorization errors from @c OIDAuthState will always have a domain of
        @c ::OIDOAuthAuthorizationErrorDomain or @c ::OIDOAuthTokenErrorDomain. Note: that after
        unarchiving the @c OIDAuthState object, the @ NSError.userInfo property of this error will
        be nil.
 */
@property(nonatomic, readonly, nullable) NSError *authorizationError;

/*! @property isAuthorized
    @brief Returns YES if the authorization state is not known to be invalid.
    @discussion Returns YES if no OAuth errors have been received, and the last call resulted in a
        successful access token or id token. This does not mean that the access is fresh - just
        that it was valid the last time it was used. Note that network and other transient errors
        do not invalidate the authorized state.  If NO, you should authenticate the user again,
        using a fresh authorization request. Invalid @c OIDAuthState objects may still be useful in
        that case, to hint at the previously authorized user and streamline the re-authentication
        experience.
 */
@property(nonatomic, readonly) BOOL isAuthorized;

/*! @property stateChangeDelegate
    @brief The @c OIDAuthStateChangeDelegate delegate.
    @discussion Use the delegate to observe state changes (and update storage) as well as error
        states.
 */
@property(nonatomic, weak, nullable) id<OIDAuthStateChangeDelegate> stateChangeDelegate;

/*! @property errorDelegate
    @brief The @c OIDAuthStateErrorDelegate delegate.
    @discussion Use the delegate to observe state changes (and update storage) as well as error
        states.
 */
@property(nonatomic, weak, nullable) id<OIDAuthStateErrorDelegate> errorDelegate;

/*! @fn authStateByPresentingAuthorizationRequest:UICoordinator:callback:
    @brief Convenience method to create a @c OIDAuthState by presenting an authorization request
        and performing the authorization code exchange in the case of code flow requests.
    @param authorizationRequest The authorization request to present.
    @param UICoordinator Generic authorization UI coordinator that can present an authorization
        request.
    @param callback The method called when the request has completed or failed.
    @return A @c OIDAuthorizationFlowSession instance which will terminate when it
        receives a @c OIDAuthorizationFlowSession.cancel message, or after processing a
        @c OIDAuthorizationFlowSession.resumeAuthorizationFlowWithURL: message.
 */
+ (id<OIDAuthorizationFlowSession>)
    authStateByPresentingAuthorizationRequest:(OIDAuthorizationRequest *)authorizationRequest
                                UICoordinator:(id<OIDAuthorizationUICoordinator>)UICoordinator
                                     callback:(OIDAuthStateAuthorizationCallback)callback;

/*! @fn init
    @internal
    @brief Unavailable. Please use @c initWithAuthorizationResponse:.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/*! @fn initWithAuthorizationResponse:
    @brief Creates an auth state from an authorization response.
    @param response The authorization response.
 */
- (nullable instancetype)initWithAuthorizationResponse:
    (OIDAuthorizationResponse *)authorizationResponse;

/*! @fn initWithAuthorizationResponse:tokenResponse:
    @brief Creates an auth state from an authorization response.
    @param response The authorization response.
 */
- (nullable instancetype)initWithAuthorizationResponse:
    (OIDAuthorizationResponse *)authorizationResponse
                                         tokenResponse:(nullable OIDTokenResponse *)tokenResponse;

/*! @fn updateWithAuthorizationResponse:error:
    @brief Updates the authorization state based on a new authorization response.
    @param authorizationResponse The new authorization response to update the state with.
    @param error Any error encountered when performing the authorization request. Errors in the
        domain @c ::OIDOAuthAuthorizationErrorDomain are reflected in the auth state, other errors
        are assumed to be transient, and ignored.
    @discussion Typically called with the response from an incremental authorization request,
        or if using the implicit flow. Will clear the @c #lastTokenResponse property.
 */
- (void)updateWithAuthorizationResponse:(nullable OIDAuthorizationResponse *)authorizationResponse
                                  error:(nullable NSError *)error;

/*! @fn updateWithTokenResponse:error:
    @brief Updates the authorization state based on a new token response.
    @param tokenResponse The new token response to update the state from.
    @param error Any error encountered when performing the authorization request. Errors in the
        domain @c ::OIDOAuthTokenErrorDomain are reflected in the auth state, other errors
        are assumed to be transient, and ignored.
    @discussion Typically called with the response from an authorization code exchange, or a token
        refresh.
 */
- (void)updateWithTokenResponse:(nullable OIDTokenResponse *)tokenResponse
                          error:(nullable NSError *)error;

/*! @fn updateWithAuthorizationError:
    @brief Updates the authorization state based on an authorization error.
    @param authorizationError The authorization error.
    @discussion Call this method if you receive an authorization error during an API call to
        invalidate the authentication state of this @c OIDAuthState. Don't call with errors
        unrelated to authorization, such as transient network errors.
        The OIDAuthStateErrorDelegate.authState:didEncounterAuthorizationError: method of
        @c #errorDelegate will be called with the error.
        You may optionally use the convenience method
        OIDErrorUtilities.resourceServerAuthorizationErrorWithCode:errorResponse:underlyingError:
        to create @c NSError objects for use here.
        The latest error received is stored in @c #authorizationError. Note: that after unarchiving
        this object, the @c NSError.userInfo property of this error will be nil.
 */
- (void)updateWithAuthorizationError:(NSError *)authorizationError;

/*! @fn withFreshTokensPerformAction:
    @brief Calls the block with a valid access token (refreshing it first, if needed), or if a
        refresh was needed and failed, with the error that caused it to fail.
    @param action The block to execute with a fresh token. This block will be executed on the main
        thread.
 */
- (void)withFreshTokensPerformAction:(OIDAuthStateAction)action;

/*! @fn setNeedsTokenRefresh
    @brief Forces a token refresh the next time @c OIDAuthState.withFreshTokensPerformAction: is
        called, even if the current tokens are considered valid.
 */
- (void)setNeedsTokenRefresh;

/*! @fn tokenRefreshRequest
    @brief Creates a token request suitable for refreshing an access token.
    @return A @c OIDTokenRequest suitable for using a refresh token to obtain a new access token.
    @discussion After performing the refresh, call @c OIDAuthState.updateWithTokenResponse:error:
        to update the authorization state based on the response. Rather than doing the token refresh
        yourself, you should use @c OIDAuthState.withFreshTokensPerformAction:.
    @see https://tools.ietf.org/html/rfc6749#section-1.5
 */
- (nullable OIDTokenRequest *)tokenRefreshRequest;

/*! @fn tokenRefreshRequestWithAdditionalParameters:
    @brief Creates a token request suitable for refreshing an access token.
    @param additionalParameters Additional parameters for the token request.
    @return A @c OIDTokenRequest suitable for using a refresh token to obtain a new access token.
    @discussion After performing the refresh, call @c OIDAuthState.updateWithTokenResponse:error:
        to update the authorization state based on the response. Rather than doing the token refresh
        yourself, you should use @c OIDAuthState.withFreshTokensPerformAction:.
    @see https://tools.ietf.org/html/rfc6749#section-1.5
 */
- (nullable OIDTokenRequest *)tokenRefreshRequestWithAdditionalParameters:
    (nullable NSDictionary<NSString *, NSString *> *)additionalParameters;

@end

NS_ASSUME_NONNULL_END
