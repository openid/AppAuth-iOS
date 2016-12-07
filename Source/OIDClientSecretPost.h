/*! @file OIDClientSecretPost.h
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

#import "OIDClientAuthentication.h"

NS_ASSUME_NONNULL_BEGIN

/*! @brief Parameter value for the token endpoint authentication method 'client_secret_post'.
 */
extern NSString *const OIDClientSecretPostName;

@interface OIDClientSecretPost : NSObject <OIDClientAuthentication>

/*! @internal
    @brief Unavailable. Please use @c initWithClientSecret:clientSecret.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/*! @brief Creates an authentication instance from a client secret.
    @param clientSecret The client secret.
 */
- (nullable instancetype)initWithClientSecret:(nonnull NSString *)clientSecret
  NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
