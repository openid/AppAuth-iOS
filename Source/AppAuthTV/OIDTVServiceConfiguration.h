/*! @file OIDTVServiceConfiguration.h
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

#import "OIDServiceConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/*! @brief Configuration for authorizing the user with the @c OIDTVAuthorizationService.
 */
@interface OIDTVServiceConfiguration : OIDServiceConfiguration

/*! @brief The device authorization endpoint URI.
 */
@property(nonatomic, readonly) NSURL *deviceAuthorizationEndpoint;

/*! @internal
    @brief Unavailable. Please use
        @c initWithDeviceAuthorizationEndpoint:tokenEndpoint:
 */
- (instancetype)init NS_UNAVAILABLE;

/*! @internal
    @brief Unavailable. Please use
        @c initWithDeviceAuthorizationEndpoint:tokenEndpoint:
 */
- (instancetype)initWithAuthorizationEndpoint:(NSURL *)authorizationEndpoint
                                tokenEndpoint:(NSURL *)tokenEndpoint NS_UNAVAILABLE;

/*! @brief Designated initializer.
    @param discoveryDocument The discovery document from which to extract the required OAuth
       configuration.
*/
- (instancetype)initWithDiscoveryDocument:(OIDServiceDiscovery *)discoveryDocument
    NS_DESIGNATED_INITIALIZER;

/*! @brief Designated initializer.
    @param deviceAuthorizationEndpoint The device authorization endpoint URI.
    @param tokenEndpoint The token exchange and refresh endpoint URI.
 */
- (instancetype)initWithDeviceAuthorizationEndpoint:(NSURL *)deviceAuthorizationEndpoint
                                      tokenEndpoint:(NSURL *)tokenEndpoint
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
