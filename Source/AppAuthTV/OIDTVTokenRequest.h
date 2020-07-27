/*! @file OIDTVTokenRequest.h
   @brief AppAuth iOS SDK
   @copyright
       Copyright 2020 Google Inc.
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

#import "OIDTokenRequest.h"

#import <Foundation/Foundation.h>

@class OIDServiceConfiguration;
@class OIDTVServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OIDTVTokenRequest : OIDTokenRequest

/*! @brief The device code received from the authorization server.
    @remarks device_code
    @see https://tools.ietf.org/html/rfc8628#section-3.4
 */
@property(nonatomic, readonly) NSString *deviceCode;

/*! @internal
   @brief Unavailable. Please use @c initWithConfiguration:grantType:deviceCode:clientID:clientSecret:additionalParameters: or @c initWithCoder:.
*/
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
                            grantType:(NSString *)grantType
                    authorizationCode:(nullable NSString *)code
                          redirectURL:(nullable NSURL *)redirectURL
                             clientID:(NSString *)clientID
                         clientSecret:(nullable NSString *)clientSecret
                               scopes:(nullable NSArray<NSString *> *)scopes
                         refreshToken:(nullable NSString *)refreshToken
                         codeVerifier:(nullable NSString *)codeVerifier
                 additionalParameters:
                     (nullable NSDictionary<NSString *, NSString *> *)additionalParameters
    NS_UNAVAILABLE;

- (instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
                            grantType:(NSString *)grantType
                    authorizationCode:(nullable NSString *)code
                          redirectURL:(nullable NSURL *)redirectURL
                             clientID:(NSString *)clientID
                         clientSecret:(nullable NSString *)clientSecret
                                scope:(nullable NSString *)scope
                         refreshToken:(nullable NSString *)refreshToken
                         codeVerifier:(nullable NSString *)codeVerifier
                 additionalParameters:
                     (nullable NSDictionary<NSString *, NSString *> *)additionalParameters
    NS_UNAVAILABLE;

- (instancetype)initWithConfiguration:(OIDTVServiceConfiguration *)configuration
                            grantType:(NSString *)grantType
                           deviceCode:(NSString *)deviceCode
                             clientID:(NSString *)clientID
                         clientSecret:(NSString *)clientSecret
                 additionalParameters:(NSDictionary<NSString *, NSString *> *)additionalParameters
    NS_DESIGNATED_INITIALIZER;

/*! @brief Designated initializer for NSSecureCoding.
    @param aDecoder Unarchiver object to decode
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
