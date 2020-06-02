/*! @file GTMTVAuthorizationRequest.h
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

#ifndef GTMAPPAUTH_USER_IMPORTS
#import <AppAuth/AppAuthCore.h>
#else // GTMAPPAUTH_USER_IMPORTS
#import "AppAuthCore.h"
#endif // GTMAPPAUTH_USER_IMPORTS

@class GTMTVServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

/*! @brief Represents a TV and limited input device authorization request.
    @see https://developers.google.com/identity/protocols/OAuth2ForDevices
 */
@interface GTMTVAuthorizationRequest : OIDAuthorizationRequest

/*! @brief Creates a TV authorization request with opinionated defaults
    @param configuration The service's configuration.
    @param clientID The client identifier.
    @param clientSecret The client secret.
    @param scopes An array of scopes to combine into a single scope string per the OAuth2 spec.
    @param additionalParameters The client's additional authorization parameters.
 */
- (instancetype)
    initWithConfiguration:(GTMTVServiceConfiguration *)configuration
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
