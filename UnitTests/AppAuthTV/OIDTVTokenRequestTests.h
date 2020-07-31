/*! @file OIDTVTokenRequestTests.h
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

@class OIDTVTokenRequest;

NS_ASSUME_NONNULL_BEGIN

/*! @brief Unit tests for @c OIDTVTokenRequest.
 */
@interface OIDTVTokenRequestTests : XCTestCase

/*! @brief Tests the initializer
*/
- (void)testInitializer;

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
 *      process and checking to make sure the source and destination both contain the @c deviceCode.
 */
- (void)testCopying;

/*! @brief Tests the @c NSSecureCoding implementation by round-tripping an instance through the
 *      coding process and checking to make sure the source and destination both contain the
 *      @c deviceCode
 */
- (void)testSecureCoding;

/*! @brief Tests the @c URLRequest method to verify that the body parameters include the correct
 *      grant type, device code and additional parameters.
 */
- (void)testURLRequest;

@end

NS_ASSUME_NONNULL_END
