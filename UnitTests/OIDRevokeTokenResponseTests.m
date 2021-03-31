/*! @file OIDRevokeTokenResponseTests.m
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

#import "OIDRevokeTokenResponseTests.h"

#import "OIDRevokeTokenRequestTests.h"

#if SWIFT_PACKAGE
@import AppAuthCore;
#else
#import "Source/AppAuthCore/OIDRevokeTokenRequest.h"
#import "Source/AppAuthCore/OIDRevokeTokenResponse.h"
#endif

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

@implementation OIDRevokeTokenResponseTests

+ (OIDRevokeTokenResponse *)testInstance {
  OIDRevokeTokenRequest *request = [OIDRevokeTokenRequestTests testInstance];
  OIDRevokeTokenResponse *response =
      [[OIDRevokeTokenResponse alloc] initWithRequest:request];
  return response;
}

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
        process and checking to make sure the source and destination instances are equivalent.
 */
- (void)testCopying {
  OIDRevokeTokenResponse *response = [[self class] testInstance];
  XCTAssertNotNil(response.request, @"");

  OIDRevokeTokenResponse *responseCopy = [response copy];
  XCTAssertNotNil(responseCopy.request, @"");
}

/*! @brief Tests the @c NSSecureCoding by round-tripping an instance through the coding process and
        checking to make sure the source and destination instances are equivalent.
 */
- (void)testSecureCoding {
  OIDRevokeTokenResponse *response = [[self class] testInstance];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:response];
  OIDRevokeTokenResponse *responseCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  // Not a full test of the request deserialization, but should be sufficient as a smoke test
  // to make sure the request IS actually getting serialized and deserialized in the
  // NSSecureCoding implementation. We'll leave it up to the OIDAuthorizationRequest tests to make
  // sure the NSSecureCoding implementation of that class is correct.
  XCTAssertNotNil(responseCopy.request, @"");
}

@end

#pragma GCC diagnostic pop
