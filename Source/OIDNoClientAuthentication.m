/*! @file OIDNoClientAuthentication.m
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

#import "OIDNoClientAuthentication.h"

NSString *const OIDNoClientAuthenticationName = @"none";

@implementation OIDNoClientAuthentication

+ (nonnull instancetype)instance {
  static OIDNoClientAuthentication *myInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    myInstance = [super alloc];
  });
  return myInstance;
}

- (NSDictionary<NSString *, NSString *> *)constructRequestHeaders:(NSString *)clientID {
  return [[NSDictionary alloc] init];
}

- (NSDictionary<NSString *, NSString *> *)constructRequestParameters:(NSString *)clientID {
  return [[NSDictionary alloc] init];
}

@end
