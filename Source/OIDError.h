/*! @file OIDError.h
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

NS_ASSUME_NONNULL_BEGIN

/*! @var OIDGeneralErrorDomain
    @brief The error domain for all NSErrors returned from the AppAuth library.
 */
extern NSString *const OIDGeneralErrorDomain;

/*! @var OIDOAuthAuthorizationErrorDomain
    @brief The error domain for OAuth specific errors on the authorization endpoint.
    @discussion This error domain is used when the server responds to an authorization request
        with an explicit OAuth error, as defined by RFC6749 Section 4.1.2.1. If the authorization
        response is invalid and not explicitly an error response, another error domain will be used.
        The error response parameter dictionary is available in the
        @c NSError.userInfo dictionary using the @c OIDOAuthErrorResponseErrorKey key.
        The @c NSError.code will be one of the @c OIDErrorCodeOAuthAuthorization enum values.
    @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
 */
extern NSString *const OIDOAuthAuthorizationErrorDomain;

/*! @var OIDOAuthTokenErrorDomain
    @brief The error domain for OAuth specific errors on the token endpoint.
    @discussion This error domain is used when the server responds with HTTP 400 and an OAuth error,
        as defined RFC6749 Section 5.2. If an HTTP 400 response does not parse as an OAuth error
        (i.e. no 'error' field is present or the JSON is invalid), another error domain will be
        used. The entire OAuth error response dictionary is available in the @c NSError.userInfo
        dictionary using the @c OIDOAuthErrorResponseErrorKey key. Unlike transient network errors,
        errors in this domain invalidate the authentication state, and either indicate a client
        error or require user interaction (i.e. reauthentication) to resolve.
        The @c NSError.code will be one of the @c OIDErrorCodeOAuthToken enum values.
    @see https://tools.ietf.org/html/rfc6749#section-5.2
 */
extern NSString *const OIDOAuthTokenErrorDomain;

/*! @var OIDResourceServerAuthorizationErrorDomain
    @brief The error domain for authorization errors encountered out of band on the resource server.
 */
extern NSString *const OIDResourceServerAuthorizationErrorDomain;

/*! @var OIDHTTPErrorDomain
    @brief An error domain representing received HTTP errors.
 */
extern NSString *const OIDHTTPErrorDomain;

/*! @var OIDOAuthErrorResponseErrorKey
    @brief An error key for the original OAuth error response (if any).
 */
extern NSString *const OIDOAuthErrorResponseErrorKey;

/*! @var kOAuthErrorResponseErrorField
    @brief The key of the 'error' response field in a RFC6749 Section 5.2 response.
    @remark error
    @see https://tools.ietf.org/html/rfc6749#section-5.2
 */
extern NSString *const OIDOAuthErrorFieldError;

/*! @var kOAuthErrorResponseErrorDescriptionField
    @brief The key of the 'error_description' response field in a RFC6749 Section 5.2 response.
    @remark error_description
    @see https://tools.ietf.org/html/rfc6749#section-5.2
 */
extern NSString *const OIDOAuthErrorFieldErrorDescription;

/*! @var kOAuthErrorResponseErrorURIField
    @brief The key of the 'error_uri' response field in a RFC6749 Section 5.2 response.
    @remark error_uri
    @see https://tools.ietf.org/html/rfc6749#section-5.2
 */
extern NSString *const OIDOAuthErrorFieldErrorURI;

/*! @enum OIDErrorCode
    @brief The various error codes returned from the AppAuth library.
 */
typedef NS_ENUM(NSInteger, OIDErrorCode) {
  /*! @var OIDErrorCodeInvalidDiscoveryDocument
      @brief Indicates a problem parsing an OpenID Connect Service Discovery document.
   */
  OIDErrorCodeInvalidDiscoveryDocument = -2,

  /*! @var OIDErrorCodeUserCanceledAuthorizationFlow
      @brief Indicates the user manually canceled the OAuth authorization code flow.
   */
  OIDErrorCodeUserCanceledAuthorizationFlow = -3,

  /*! @var OIDErrorCodeProgramCanceledAuthorizationFlow
      @brief Indicates an OAuth authorization flow was programmatically cancelled.
   */
  OIDErrorCodeProgramCanceledAuthorizationFlow = -4,

  /*! @var OIDErrorCodeNetworkError
      @brief Indicates a network error or server error occurred.
   */
  OIDErrorCodeNetworkError = -5,

  /*! @var OIDErrorCodeServerError
      @brief Indicates a server error occurred.
   */
  OIDErrorCodeServerError = -6,

  /*! @var OIDErrorCodeJSONDeserializationError
      @brief Indicates a problem occurred deserializing the response/JSON.
   */
  OIDErrorCodeJSONDeserializationError = -7,

  /*! @var OIDErrorCodeTokenResponseConstructionError
      @brief Indicates a problem occurred constructing the token response from the JSON.
   */
  OIDErrorCodeTokenResponseConstructionError = -8,

  /*! @var OIDErrorCodeSafariOpenError
      @brief @c UIApplication.openURL: returned NO when attempting to open the authorization
          request in mobile Safari.
   */
  OIDErrorCodeSafariOpenError = -9,
};

/*! @enum OIDErrorCodeOAuth
    @brief Enum of all possible OAuth error codes as defined by RFC6749
    @discussion Used by @c OIDErrorCodeOAuthAuthorization and @c OIDErrorCodeOAuthToken
        which define endpoint-specific subsets of OAuth codes. Those enum types are down-castable
        to this one.
    @see https://tools.ietf.org/html/rfc6749#section-11.4
    @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
    @see https://tools.ietf.org/html/rfc6749#section-5.2
 */
typedef NS_ENUM(NSInteger, OIDErrorCodeOAuth) {

  /*! @var OIDErrorCodeOAuthInvalidRequest
      @remarks invalid_request
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthInvalidRequest = -2,

  /*! @var OIDErrorCodeOAuthUnauthorizedClient
      @remarks unauthorized_client
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthUnauthorizedClient = -3,

  /*! @var OIDErrorCodeOAuthAccessDenied
      @remarks access_denied
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthAccessDenied = -4,

  /*! @var OIDErrorCodeOAuthUnsupportedResponseType
      @remarks unsupported_response_type
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthUnsupportedResponseType = -5,

  /*! @var OIDErrorCodeOAuthInvalidScope
      @remarks invalid_scope
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthInvalidScope = -6,

  /*! @var OIDErrorCodeOAuthServerError
      @remarks server_error
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthServerError = -7,

  /*! @var OIDErrorCodeOAuthTemporarilyUnavailable
      @remarks temporarily_unavailable
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthTemporarilyUnavailable = -8,

  /*! @var OIDErrorCodeOAuthInvalidClient
      @remarks invalid_client
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthInvalidClient = -9,

  /*! @var OIDErrorCodeOAuthInvalidGrant
      @remarks invalid_grant
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthInvalidGrant = -10,

  /*! @var OIDErrorCodeOAuthUnsupportedGrantType
      @remarks unsupported_grant_type
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthUnsupportedGrantType = -11,

  /*! @var OIDErrorCodeOAuthClientError
      @brief An authorization error occurring on the client rather than the server. For example,
        due to a state mismatch or misconfiguration. Should be treated as an unrecoverable
        authorization error.
   */
  OIDErrorCodeOAuthClientError = -0xEFFF,

  /*! @var OIDErrorCodeOAuthOther
      @brief An OAuth error not known to this library
      @discussion Indicates an OAuth error as per RFC6749, but the error code was not in our
          list. It could be a custom error code, or one from an OAuth extension. See the "error" key
          of the @c NSError:userInfo property. Such errors are assumed to invalidate the
          authentication state
   */
  OIDErrorCodeOAuthOther = -0xF000,
};

/*! @enum OIDErrorCodeOAuthAuthorization
    @brief The error codes for the @c OIDOAuthAuthorizationErrorDomain error domain
    @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
 */
typedef NS_ENUM(NSInteger, OIDErrorCodeOAuthAuthorization) {
  /*! @var OIDErrorCodeOAuthAuthorizationInvalidRequest
      @remarks invalid_request
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthAuthorizationInvalidRequest = OIDErrorCodeOAuthInvalidRequest,

  /*! @var OIDErrorCodeOAuthAuthorizationUnauthorizedClient
      @remarks unauthorized_client
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthAuthorizationUnauthorizedClient = OIDErrorCodeOAuthUnauthorizedClient,

  /*! @var OIDErrorCodeOAuthAuthorizationAccessDenied
      @remarks access_denied
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthAuthorizationAccessDenied =
      OIDErrorCodeOAuthAccessDenied,

  /*! @var OIDErrorCodeOAuthAuthorizationUnsupportedResponseType
      @remarks unsupported_response_type
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthAuthorizationUnsupportedResponseType =
      OIDErrorCodeOAuthUnsupportedResponseType,

  /*! @var OIDErrorCodeOAuthAuthorizationAuthorizationInvalidScope
      @brief Indicates a network error or server error occurred.
      @remarks invalid_scope
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthAuthorizationAuthorizationInvalidScope = OIDErrorCodeOAuthInvalidScope,

  /*! @var OIDErrorCodeOAuthAuthorizationServerError
      @brief Indicates a server error occurred.
      @remarks server_error
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthAuthorizationServerError = OIDErrorCodeOAuthServerError,

  /*! @var OIDErrorCodeOAuthAuthorizationTemporarilyUnavailable
      @remarks temporarily_unavailable
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthAuthorizationTemporarilyUnavailable = OIDErrorCodeOAuthTemporarilyUnavailable,

  /*! @var OIDErrorCodeOAuthAuthorizationClientError
      @brief An authorization error occurring on the client rather than the server. For example,
        due to a state mismatch or client misconfiguration. Should be treated as an unrecoverable
        authorization error.
   */
  OIDErrorCodeOAuthAuthorizationClientError = OIDErrorCodeOAuthClientError,

  /*! @var OIDErrorCodeOAuthAuthorizationOther
      @brief An authorization OAuth error not known to this library
      @discussion this indicates an OAuth error as per RFC6749, but the error code was not in our
          list. It could be a custom error code, or one from an OAuth extension. See the "error" key
          of the @c NSError:userInfo property. We assume such errors are not transient.
      @see https://tools.ietf.org/html/rfc6749#section-4.1.2.1
   */
  OIDErrorCodeOAuthAuthorizationOther = OIDErrorCodeOAuthOther,
};


/*! @enum OIDErrorCodeOAuthToken
    @brief The error codes for the @c OIDOAuthTokenErrorDomain error domain
    @see https://tools.ietf.org/html/rfc6749#section-5.2
 */
typedef NS_ENUM(NSInteger, OIDErrorCodeOAuthToken) {
  /*! @var OIDErrorCodeOAuthTokenInvalidRequest
      @remarks invalid_request
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthTokenInvalidRequest = OIDErrorCodeOAuthInvalidRequest,

  /*! @var OIDErrorCodeOAuthTokenInvalidClient
      @remarks invalid_client
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthTokenInvalidClient = OIDErrorCodeOAuthInvalidClient,

  /*! @var OIDErrorCodeOAuthTokenInvalidGrant
      @remarks invalid_grant
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthTokenInvalidGrant = OIDErrorCodeOAuthInvalidGrant,

  /*! @var OIDErrorCodeOAuthTokenUnauthorizedClient
      @remarks unauthorized_client
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthTokenUnauthorizedClient = OIDErrorCodeOAuthUnauthorizedClient,

  /*! @var OIDErrorCodeOAuthTokenUnsupportedGrantType
      @remarks unsupported_grant_type
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthTokenUnsupportedGrantType = OIDErrorCodeOAuthUnsupportedGrantType,

  /*! @var OIDErrorCodeOAuthTokenInvalidScope
      @remarks invalid_scope
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthTokenInvalidScope = OIDErrorCodeOAuthInvalidScope,

  /*! @var OIDErrorCodeOAuthTokenClientError
      @brief An unrecoverable token error occurring on the client rather than the server.
   */
  OIDErrorCodeOAuthTokenClientError = OIDErrorCodeOAuthClientError,

  /*! @var OIDErrorCodeOAuthTokenOther
      @brief A token endpoint OAuth error not known to this library
      @discussion this indicates an OAuth error as per RFC6749, but the error code was not in our
          list. It could be a custom error code, or one from an OAuth extension. See the "error" key
          of the @c NSError:userInfo property. We assume such errors are not transient.
      @see https://tools.ietf.org/html/rfc6749#section-5.2
   */
  OIDErrorCodeOAuthTokenOther = OIDErrorCodeOAuthOther,
};


/*! @var OIDOAuthExceptionInvalidAuthorizationFlow
    @brief The exception text for the exception which occurs when a
        @c OIDAuthorizationFlowSession receives a message after it has already completed.
 */
extern NSString *const OIDOAuthExceptionInvalidAuthorizationFlow;

NS_ASSUME_NONNULL_END
