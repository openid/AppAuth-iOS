/*! @file OIDTVAuthorizationRequest.h
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

#import "OIDAuthorizationRequest.h"

@class OIDTVServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

/*! @brief Represents a TV and limited input device authorization request.
    @see https://tools.ietf.org/html/rfc8628#section-3.1
 */
@interface OIDTVAuthorizationRequest : OIDAuthorizationRequest

/*! @brief Creates a TV authorization request with opinionated defaults
    @param configuration The service's configuration.
    @param clientID The client identifier.
    @param clientSecret The client secret.
    @param scopes An array of scopes to combine into a single scope string per the OAuth2 spec.
    @param additionalParameters The client's additional authorization parameters.
 */
- (instancetype)
    initWithConfiguration:(OIDTVServiceConfiguration *)configuration
                 clientId:(NSString *)clientID
             clientSecret:(NSString *)clientSecret
                   scopes:(nullable NSArray<NSString *> *)scopes
     additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters;

/*! @brief Constructs an @c NSURLRequest representing the TV authorization request.
    @return An @c NSURLRequest representing the TV authorization request.
 */
- (NSURLRequest *)URLRequest;

@end

NS_ASSUME_NONNULL_END
