/*! @file OIDGrantTypesTests.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2015 Google Inc. All Rights Reserved.
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

#if SWIFT_PACKAGE
@import AppAuthCore;
#else
#import "Source/AppAuthCore/OIDGrantTypes.h"
#endif

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

/*! @brief Unit tests for constants in @c OIDGrantTypes.m.
    @remarks Arguably not worth tests for this file, but adding them for consistency, and so that
        any future enhancements have a place to add tests if need be.
 */
@interface OIDGrantTypesTests : XCTestCase
@end
@implementation OIDGrantTypesTests

- (void)testAuthorizationCode {
  XCTAssertEqualObjects(OIDGrantTypeAuthorizationCode, @"authorization_code");
}

- (void)testRefreshToken {
  XCTAssertEqualObjects(OIDGrantTypeRefreshToken, @"refresh_token");
}

- (void)testPassword {
  XCTAssertEqualObjects(OIDGrantTypePassword, @"password");
}

- (void)testClientCredentials {
  XCTAssertEqualObjects(OIDGrantTypeClientCredentials, @"client_credentials");
}

@end

#pragma GCC diagnostic pop
