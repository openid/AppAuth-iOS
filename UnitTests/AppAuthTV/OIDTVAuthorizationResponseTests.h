/*! @file OIDTVAuthorizationResponseTests.h
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2020 Google Inc. All Rights Reserved.
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

#import <XCTest/XCTest.h>

@class OIDTVAuthorizationResponse;

NS_ASSUME_NONNULL_BEGIN

/*! @brief Unit tests for @c OIDTVAuthorizationResponse.
 */
@interface OIDTVAuthorizationResponseTests : XCTestCase

/*! @brief Tests the initializer using the standard key for @c verificationURI.
 */
- (void)testInitializer;

/*! @brief Tests the initializer using the alternative key for @c verificationURI.
 */
- (void)testInitializerAlternativeKey;

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
 *      process and checking to make sure the source and destination are equivalent.
 */
- (void)testCopying;

/*! @brief Tests the @c NSSecureCoding implementation by round-tripping an instance through the
 *      coding process and checking to make sure the source and destination are equivalent.
 */
- (void)testSecureCoding;

/*! @brief Tests the @c tokenPollRequest method that takes no additional parameters.
 */
- (void)testTokenPollRequest;

/*! @brief Tests the @c tokenPollRequestWithAdditionalParameters method with one additional
        parameter.
 */
- (void)testTokenPollRequestWithAdditionalParameters;

@end

NS_ASSUME_NONNULL_END

