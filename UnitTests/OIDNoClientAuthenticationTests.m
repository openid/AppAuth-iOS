/*! @file OIDNoClientAuthenticationTests.m
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

#import <XCTest/XCTest.h>

#import "Source/OIDNoClientAuthentication.h"

/*! @brief The test value for the @c clientID.
 */
static NSString *const kClientIDTestValue = @"client1";

/*! @brief Unit tests for @c OIDNoClientAuthentication.
 */
@interface OIDNoClientAuthenticationTests : XCTestCase
@end

@implementation OIDNoClientAuthenticationTests

+ (OIDNoClientAuthentication *)testInstance {
  return [OIDNoClientAuthentication instance];
}

/*! @brief Make sure no headers are specified when not using client authentication.
 */
- (void)testConstructRequestHeaders {
  OIDNoClientAuthentication *clientAuth = [OIDNoClientAuthentication instance];
  NSDictionary<NSString *, NSString *> *headers =
      [clientAuth constructRequestHeaders:kClientIDTestValue];
  XCTAssertTrue([headers count] == 0);
}

/*! @brief Make sure no request parameters are specified when not using client authentication.
 */
- (void)testConstructRequestParameters {
  OIDNoClientAuthentication *clientAuth = [OIDNoClientAuthentication instance];
  NSDictionary<NSString *, NSString *> *requestParams =
      [clientAuth constructRequestParameters:kClientIDTestValue];
  XCTAssertTrue([requestParams count] == 0);
}
@end
