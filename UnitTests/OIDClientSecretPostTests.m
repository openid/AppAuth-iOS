/*! @file OIDClientSecretPostTests.m
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

#import "OIDClientSecretPostTests.h"

#import "Source/OIDClientSecretPost.h"

/*! @brief The test value for the @c client id.
 */
static NSString *const kClientIDTestValue = @"client1";

/*! @brief The test value for the @c client secret.
 */
static NSString *const kClientSecretTestValue = @"mySecret";

@implementation OIDClientSecretPostTests
+ (OIDClientSecretPost *)testInstance {
  return [[OIDClientSecretPost alloc] initWithClientSecret:kClientSecretTestValue];
}

/*! @brief Make sure the Authorization header contains no headers when using 'client_secret_post'.
 */
- (void)testConstructRequestHeaders {
  OIDClientSecretPost *clientAuth = [[self class] testInstance];
  NSDictionary<NSString *, NSString *> *headers =
      [clientAuth constructRequestHeaders:kClientIDTestValue];
  XCTAssertTrue([headers count] == 0);
}

/*! @brief Make sure the appropriate request parameters are constructed when using
        'client_secret_post'.
 */
- (void)testConstructRequestParameters {
  OIDClientSecretPost *clientAuth = [[self class] testInstance];
  NSDictionary<NSString *, NSString *> *params =
      [clientAuth constructRequestParameters:kClientIDTestValue];
  XCTAssertEqualObjects(params[@"client_id"], kClientIDTestValue);
  XCTAssertEqualObjects(params[@"client_secret"], kClientSecretTestValue);
}
@end
