/*! @file OIDClientSecretBasicTests.m
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

#import "OIDClientSecretBasicTests.h"

#import "Source/OIDClientSecretBasic.h"

/*! @brief The test value for the @c client id.
 */
static NSString *const kClientIDTestValue = @"client1";


/*! @brief The test value for the @c client secret.
 */
static NSString *const kClientSecretTestValue = @"mySecret";

@implementation OIDClientSecretBasicTests
+ (OIDClientSecretBasic *)testInstance {
  return [[OIDClientSecretBasic alloc] initWithClientSecret:kClientSecretTestValue];
}

/*! @brief Make sure the Authorization header contains the appropriate basic auth when using
        'client_secret_basic'.
 */
- (void)testConstructRequestHeaders {
  OIDClientSecretBasic *clientAuth = [[self class] testInstance];
  NSDictionary<NSString *, NSString *> *headers =
      [clientAuth constructRequestHeaders:kClientIDTestValue];
  NSString *credentials =
      [NSString stringWithFormat:@"%@:%@", kClientIDTestValue, kClientSecretTestValue];
  NSData *encData = [credentials dataUsingEncoding:NSUTF8StringEncoding];
  NSString *basicAuth =
      [NSString stringWithFormat:@"Basic %@", [encData base64EncodedStringWithOptions:kNilOptions]];
  XCTAssertTrue([headers count] == 1);
  XCTAssertEqualObjects(headers[@"Authorization"], basicAuth);
}

/*! @brief Make sure the no request parameters are constructed when using 'client_secret_basic',
 */
- (void)testConstructRequestParameters {
  OIDClientSecretBasic *clientAuth = [[self class] testInstance];
  NSDictionary<NSString *, NSString *> *params =
      [clientAuth constructRequestParameters:kClientIDTestValue];
  XCTAssertTrue([params count] == 0);
}
@end
