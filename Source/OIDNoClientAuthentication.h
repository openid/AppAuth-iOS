/*! @file OIDNoClientAuthentication.h
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

/*! @brief Parameter value for the token endpoint authentication method, when not using any client
        authentication.
 */
extern NSString *const OIDNoClientAuthenticationName;

@interface OIDNoClientAuthentication : NSObject <OIDClientAuthentication>

/*! @internal
    @brief Unavailable. Please use the singleton @c instance.
 */
- (nonnull instancetype)init NS_UNAVAILABLE;

+ (nonnull instancetype)instance;

@end

NS_ASSUME_NONNULL_END
