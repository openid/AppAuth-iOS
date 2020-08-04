/*! @file OIDTVAuthorizationResponse.h
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

#import "OIDAuthorizationResponse.h"

@class OIDTVAuthorizationRequest;
@class OIDTVTokenRequest;

NS_ASSUME_NONNULL_BEGIN

/*! @brief Represents the response to a TV authorization request.
    @see https://tools.ietf.org/html/rfc8628#section-3.5
 */
@interface OIDTVAuthorizationResponse : OIDAuthorizationResponse

/*! @brief The verification URI that should be displayed to the user instructing them to visit the
        URI and enter the code.
    @remarks verification_uri
 */
@property(nonatomic, readonly, nullable) NSString *verificationURI;

/*! @brief A complete verification URI to allow for verification without entering the user code.
    @remarks verification_uri
 */
@property(nonatomic, readonly, nullable) NSString *verificationURIComplete;

/*! @brief The code that should be displayed to the user which they enter at the @c verificationURI.
    @remarks user_code
 */
@property(nonatomic, readonly, nullable) NSString *userCode;

/*! @brief The device code grant used to poll the token endpoint. Rather than using this directly,
        use the provided @c tokenPollRequest method to create the token request.
    @remarks device_code
 */
@property(nonatomic, readonly, nullable) NSString *deviceCode;

/*! @brief The interval at which the token endpoint should be polled with the @c deviceCode.
    @remarks interval
 */
@property(nonatomic, readonly, nullable) NSNumber *interval;

/*! @brief The date at which the user can no longer authorize this request.
    @remarks expires_in
 */
@property(nonatomic, readonly, nullable) NSDate *expirationDate;

/*! @brief Designated initializer.
    @param request The serviced request.
    @param parameters The decoded parameters returned from the Authorization Server.
    @remarks Known parameters are extracted from the @c parameters parameter and the normative
        properties are populated. Non-normative parameters are placed in the
        @c #additionalParameters dictionary.
 */
- (instancetype)initWithRequest:(OIDTVAuthorizationRequest *)request
                     parameters:(NSDictionary<NSString *, NSObject<NSCopying> *> *)parameters
    NS_DESIGNATED_INITIALIZER;

/*! @brief Creates a token request suitable for polling the token endpoint with the @c deviceCode.
    @return A @c OIDTVTokenRequest suitable for polling the token endpoint.
    @see https://tools.ietf.org/html/rfc8628#section-3.4
 */
- (nullable OIDTVTokenRequest *)tokenPollRequest;

/*! @brief Creates a token request suitable for polling the token endpoint with the @c deviceCode.
    @param additionalParameters Additional parameters for the token request.
    @return A @c OIDTVTokenRequest suitable for polling the token endpoint.
    @see https://tools.ietf.org/html/rfc8628#section-3.4
 */
- (nullable OIDTVTokenRequest *)tokenPollRequestWithAdditionalParameters:
    (nullable NSDictionary<NSString *, NSString *> *)additionalParameters;

@end

NS_ASSUME_NONNULL_END
