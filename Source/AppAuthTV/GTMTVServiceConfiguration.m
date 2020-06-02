/*! @file GTMTVServiceConfiguration.m
    @brief GTMAppAuth SDK
    @copyright
        Copyright 2016 Google Inc.
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

#import "GTMTVServiceConfiguration.h"

#ifndef GTMAPPAUTH_USER_IMPORTS
#import <AppAuth/AppAuthCore.h>
#import <AppAuth/OIDDefines.h>
#else // GTMAPPAUTH_USER_IMPORTS
#import "AppAuthCore.h"
#import "OIDDefines.h"
#endif // GTMAPPAUTH_USER_IMPORTS

/*! @brief The key for the @c TVAuthorizationEndpoint property.
 */
static NSString *const kTVAuthorizationEndpointKey = @"TVAuthorizationEndpoint";

NS_ASSUME_NONNULL_BEGIN

@interface GTMTVServiceConfiguration ()

/*! @brief Designated initializer.
    @param aDecoder NSCoder to unserialize the object from.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@implementation GTMTVServiceConfiguration

@synthesize TVAuthorizationEndpoint = _TVAuthorizationEndpoint;

- (instancetype)init
    OID_UNAVAILABLE_USE_INITIALIZER(
        @selector(initWithAuthorizationEndpoint:TVAuthorizationEndpoint:tokenEndpoint:));

- (instancetype)initWithAuthorizationEndpoint:(NSURL *)authorizationEndpoint
                                         tokenEndpoint:(NSURL *)tokenEndpoint
    OID_UNAVAILABLE_USE_INITIALIZER(
        @selector(initWithAuthorizationEndpoint:TVAuthorizationEndpoint:tokenEndpoint:));

- (instancetype)initWithAuthorizationEndpoint:(NSURL *)authorizationEndpoint
                      TVAuthorizationEndpoint:(NSURL *)TVAuthorizationEndpoint
                                tokenEndpoint:(NSURL *)tokenEndpoint {
  self = [super initWithAuthorizationEndpoint:authorizationEndpoint tokenEndpoint:tokenEndpoint];
  if (self) {
    _TVAuthorizationEndpoint = [TVAuthorizationEndpoint copy];
  }
  return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    NSURL *TVAuthorizationEndpoint = [aDecoder decodeObjectOfClass:[NSURL class]
                                                            forKey:kTVAuthorizationEndpointKey];
    _TVAuthorizationEndpoint = TVAuthorizationEndpoint;
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_TVAuthorizationEndpoint forKey:kTVAuthorizationEndpointKey];
}

#pragma mark - description

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, TVAuthorizationEndpoint: %@ tokenEndpoint: %@>",
                                    NSStringFromClass([self class]),
                                    self,
                                    _TVAuthorizationEndpoint,
                                    self.tokenEndpoint];
}

@end

NS_ASSUME_NONNULL_END
