/*! @file OIDRegistrationResponse.h
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2016 The AppAuth for iOS Authors. All Rights Reserved.
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

@class OIDRegistrationRequest;

NS_ASSUME_NONNULL_BEGIN

/*! @var OIDClientIDParam
    @brief Parameter name for the client id.
 */
extern NSString *const OIDClientIDParam;

/*! @var OIDClientIDIssuedAtParam
    @brief Parameter name for the client id issuance timestamp.
 */
extern NSString *const OIDClientIDIssuedAtParam;

/*! @var OIDClientSecretParam
    @brief Parameter name for the client secret.
 */
extern NSString *const OIDClientSecretParam;

/*! @var OIDClientSecretExpirestAtParam
    @brief Parameter name for the client secret expiration time.
 */
extern NSString *const OIDClientSecretExpirestAtParam;

/*! @var OIDRegistrationAccessTokenParam
    @brief Parameter name for the registration access token.
 */
extern NSString *const OIDRegistrationAccessTokenParam;

/*! @var OIDRegistrationClientURIParam
    @brief Parameter name for the client configuration URI.
 */
extern NSString *const OIDRegistrationClientURIParam;

/*! @class OIDRegistrationResponseTests
 @brief Represents a registration response.
 @see https://openid.net/specs/openid-connect-registration-1_0.html#RegistrationResponse
 */
@interface OIDRegistrationResponse : NSObject <NSCopying, NSSecureCoding>

/*! @property request
    @brief The request which was serviced.
 */
@property(nonatomic, readonly) OIDRegistrationRequest *request;

/*! @property clientID
    @brief The registered client identifier.
    @remarks client_id
    @see https://tools.ietf.org/html/rfc6749#section-4
    @see https://tools.ietf.org/html/rfc6749#section-4.1.1
 */
@property(nonatomic, readonly) NSString *clientID;

/*! @property clientIDIssuedAt
    @brief Timestamp of when the client identifier was issued, if provided.
    @remarks client_id_issued_at
    @see https://openid.net/specs/openid-connect-registration-1_0.html#RegistrationResponse
 */
@property(nonatomic, readonly, nullable) NSDate *clientIDIssuedAt;

/*! @property clientSecret
    @brief TThe client secret, which is part of the client credentials, if provided.
    @remarks client_secret
    @see https://openid.net/specs/openid-connect-registration-1_0.html#RegistrationResponse
 */
@property(nonatomic, readonly, nullable) NSString *clientSecret;

/*! @property clientSecretExpiresAt
    @brief Timestamp of when the client credentials expires, if provided.
    @remarks client_secret_expires_at
    @see https://openid.net/specs/openid-connect-registration-1_0.html#RegistrationResponse
 */
@property(nonatomic, readonly, nullable) NSDate *clientSecretExpiresAt;

/*! @property registrationAccessToken
    @brief Client registration access token that can be used for subsequent operations upon the client registration.
    @remarks registration_access_token
    @see https://openid.net/specs/openid-connect-registration-1_0.html#RegistrationResponse
 */
@property(nonatomic, readonly, nullable) NSString *registrationAccessToken;

/*! @property registrationClientURI
    @brief Location of the client configuration endpoint, if provided.
    @remarks registration_client_uri
    @see https://openid.net/specs/openid-connect-registration-1_0.html#RegistrationResponse
 */
@property(nonatomic, readonly, nullable) NSURL *registrationClientURI;

/*! @property tokenEndpointAuthenticationMethod
    @brief Client authentication method to use at the token endpoint, if provided.
    @remarks token_endpoint_auth_method
    @see http://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication
 */
@property(nonatomic, readonly, nullable) NSString *tokenEndpointAuthenticationMethod;

/*! @property additionalParameters
    @brief Additional parameters returned from the token server.
 */
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, NSObject <NSCopying> *> *additionalParameters;

/*! @fn init
    @internal
    @brief Unavailable. Please use initWithRequest
 */
- (nullable instancetype)init NS_UNAVAILABLE;


- (nullable instancetype)initWithRequest:(OIDRegistrationRequest *)request
                              parameters:(NSDictionary<NSString *, NSObject <NSCopying> *> *)parameters
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END