/*! @file OIDTVServiceConfiguration.m
    @brief AppAuth iOS SDK
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

#import "OIDTVServiceConfiguration.h"

#import "OIDDefines.h"
#import "OIDServiceDiscovery.h"

/*! @brief The key for the @c TVAuthorizationEndpoint property.
 */
static NSString *const kTVAuthorizationEndpointKey = @"TVAuthorizationEndpoint";

NS_ASSUME_NONNULL_BEGIN

@interface OIDTVServiceConfiguration ()

/*! @brief Designated initializer.
    @param aDecoder NSCoder to unserialize the object from.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@implementation OIDTVServiceConfiguration

- (instancetype)init
    OID_UNAVAILABLE_USE_INITIALIZER(@selector(initWithTVAuthorizationEndpoint:tokenEndpoint:))

- (instancetype)initWithAuthorizationEndpoint:(NSURL *)authorizationEndpoint
                                tokenEndpoint:(NSURL *)tokenEndpoint
    OID_UNAVAILABLE_USE_INITIALIZER(@selector(initWithTVAuthorizationEndpoint:tokenEndpoint:))

- (instancetype)initWithDiscoveryDocument:(OIDServiceDiscovery *)discoveryDocument {
  self = [super initWithDiscoveryDocument:discoveryDocument];

  if (self) {
    _TVAuthorizationEndpoint = [discoveryDocument.deviceAuthorizationEndpoint copy];
  }
  return self;
}

- (instancetype)initWithTVAuthorizationEndpoint:(NSURL *)TVAuthorizationEndpoint
                                  tokenEndpoint:(NSURL *)tokenEndpoint {
  self = [super initWithAuthorizationEndpoint:[[NSURL alloc] initWithString:@""]
                                tokenEndpoint:tokenEndpoint];
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
                                    (void *)self,
                                    _TVAuthorizationEndpoint,
                                    self.tokenEndpoint];
}

@end

NS_ASSUME_NONNULL_END
