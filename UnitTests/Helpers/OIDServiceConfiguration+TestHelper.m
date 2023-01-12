/*! @file OIDServiceConfiguration+TestHelper.m
   @brief AppAuth iOS SDK
   @copyright
       Copyright 2023 The AppAuth Authors. All Rights Reserved.
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

#import "OIDServiceConfiguration+TestHelper.h"

/*! @brief Test value for the @c authorizationEndpoint property.
 */
static NSString *const kInitializerTestAuthEndpoint = @"https://www.example.com/auth";

/*! @brief Test value for the @c tokenEndpoint property.
 */
static NSString *const kInitializerTestTokenEndpoint = @"https://www.example.com/token";

/*! @brief Test value for the @c tokenEndpoint property.
 */
static NSString *const kInitializerTestRegistrationEndpoint =
    @"https://www.example.com/registration";

@implementation OIDServiceConfiguration (TestHelper)

+ (OIDServiceConfiguration *)testInstance {
  NSURL *authEndpoint = [NSURL URLWithString:kInitializerTestAuthEndpoint];
  NSURL *tokenEndpoint = [NSURL URLWithString:kInitializerTestTokenEndpoint];
  NSURL *registrationEndpoint = [NSURL URLWithString:kInitializerTestRegistrationEndpoint];
  OIDServiceConfiguration *configuration =
      [[OIDServiceConfiguration alloc] initWithAuthorizationEndpoint:authEndpoint
                                                       tokenEndpoint:tokenEndpoint
                                                registrationEndpoint:registrationEndpoint];
  return configuration;
}

@end
