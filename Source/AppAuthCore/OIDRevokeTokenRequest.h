/*! @file OIDRevokeTokenRequest.h
 @brief AppAuth iOS SDK
 @copyright
 Copyright 2017 The AppAuth Authors. All Rights Reserved.
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

@class OIDServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

/*! @brief Represents a revoke token request.
 @see https://tools.ietf.org/html/rfc7009#section-2.1
 */
@interface OIDRevokeTokenRequest : NSObject <NSCopying, NSSecureCoding>

/*! @brief The service's configuration.
 @remarks This configuration specifies how to connect to a particular OAuth provider.
 Configurations may be created manually, or via an OpenID Connect Discovery Document.
 */
@property(nonatomic, readonly) OIDServiceConfiguration *configuration;

/*! @brief REQUIRED.  The token that the client wants to get revoked.
 @remarks token
 */
@property(nonatomic, readonly) NSString *token;

/*! @brief OPTIONAL. A hint about the type of the token
 submitted for revocation. Clients MAY pass this parameter in
 order to help the authorization server to optimize the token
 lookup.
 @remarks token_type_hint
 */
@property(nonatomic, readonly, nullable) NSString *tokenTypeHint;

/*! @brief The client identifier.
    @remarks client_id
    @see https://tools.ietf.org/html/rfc6749#section-4.1.3
 */
@property(nonatomic, readonly) NSString *clientID;

/*! @brief The client secret.
    @remarks client_secret
    @see https://tools.ietf.org/html/rfc6749#section-2.3.1
 */
@property(nonatomic, readonly, nullable) NSString *clientSecret;

/*! @internal
 @brief Unavailable. Please use @c initWithConfiguration:token:tokenTypeHint:clientID:clientSecret:.
 */
- (instancetype)init NS_UNAVAILABLE;

/*! @brief Designated initializer.
 @param configuration The service's configuration.
 @param token The previously issued ID Token
 @param tokenTypeHint The client's post-logout redirect URI.
 */
- (instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
                                token:(NSString *)token
                        tokenTypeHint:(nullable NSString *)tokenTypeHint
                             clientID:(NSString *)clientID
                         clientSecret:(nullable NSString *)clientSecret
NS_DESIGNATED_INITIALIZER;

/*! @brief Designated initializer for NSSecureCoding.
    @param aDecoder Unarchiver object to decode
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/*! @brief Constructs an @c NSURLRequest representing the revoke token request.
    @return An @c NSURLRequest representing the token request.
 */
- (NSURLRequest *)URLRequest;
@end

NS_ASSUME_NONNULL_END
