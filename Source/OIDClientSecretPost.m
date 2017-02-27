/*! @file OIDClientSecretPost.m
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

#import "OIDClientSecretPost.h"

#import "OIDDefines.h"

NSString *const OIDClientSecretPostName = @"client_secret_post";

@implementation OIDClientSecretPost {
  /*! @brief The client secret to use as client credentials.
   */
  NSString *_clientSecret;
}

- (nullable instancetype)init OID_UNAVAILABLE_USE_INITIALIZER(@selector(initWithClientSecret:));

- (nullable instancetype)initWithClientSecret:(NSString *)clientSecret {
  self = [super init];
  if (self) {
    _clientSecret = [clientSecret copy];
  }

  return self;
}

- (NSDictionary<NSString *, NSString *> *)constructRequestHeaders:(NSString *)clientID {
  return [[NSDictionary alloc] init];
}

- (NSDictionary<NSString *, NSString *> *)constructRequestParameters:(NSString *)clientID {
  return @{@"client_id" : clientID, @"client_secret" : _clientSecret};
}

@end
