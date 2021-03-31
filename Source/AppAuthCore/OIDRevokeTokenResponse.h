/*! @file OIDRevokeTokenResponse.h
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

@class OIDRevokeTokenRequest;

NS_ASSUME_NONNULL_BEGIN

/*! @brief Represents the response to a Revoke Token request.
    @see https://tools.ietf.org/html/rfc7009#section-2.2
 */
@interface OIDRevokeTokenResponse : NSObject <NSCopying, NSSecureCoding>

/*! @brief The request which was serviced.
 */
@property(nonatomic, readonly) OIDRevokeTokenRequest *request;

/*! @internal
    @brief Unavailable. Please use initWithRequest:.
 */
- (instancetype)init NS_UNAVAILABLE;

/*! @brief Designated initializer.
    @param request The serviced request.
 */
- (instancetype)initWithRequest:(OIDRevokeTokenRequest *)request
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
