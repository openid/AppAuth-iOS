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

/*! @brief The key for the @c deviceAuthorizationEndpoint property.
 */
static NSString *const kDeviceAuthorizationEndpointKey = @"deviceAuthorizationEndpoint";

NS_ASSUME_NONNULL_BEGIN

@interface OIDTVServiceConfiguration ()

/*! @brief Designated initializer.
    @param aDecoder NSCoder to unserialize the object from.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@implementation OIDTVServiceConfiguration

- (instancetype)init
    OID_UNAVAILABLE_USE_INITIALIZER(@selector(initWithDeviceAuthorizationEndpoint:tokenEndpoint:))

- (instancetype)initWithAuthorizationEndpoint:(NSURL *)authorizationEndpoint
                                tokenEndpoint:(NSURL *)tokenEndpoint
    OID_UNAVAILABLE_USE_INITIALIZER(@selector(initWithDeviceAuthorizationEndpoint:tokenEndpoint:))

- (instancetype)initWithDiscoveryDocument:(OIDServiceDiscovery *)discoveryDocument {
  self = [super initWithDiscoveryDocument:discoveryDocument];

  if (self) {
    if (discoveryDocument.deviceAuthorizationEndpoint == nil) {
      NSLog(@"Warning: Discovery document used to initialize %@ "
            @"does not contain device authorization endpoint.", self);
    } else {
      _deviceAuthorizationEndpoint = [discoveryDocument.deviceAuthorizationEndpoint copy];
    }
  }
  return self;
}

- (instancetype)initWithDeviceAuthorizationEndpoint:(NSURL *)deviceAuthorizationEndpoint
                                      tokenEndpoint:(NSURL *)tokenEndpoint {
  self = [super initWithAuthorizationEndpoint:[[NSURL alloc] initWithString:@""]
                                tokenEndpoint:tokenEndpoint];
  if (self) {
    _deviceAuthorizationEndpoint = [deviceAuthorizationEndpoint copy];
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
    NSURL *deviceAuthorizationEndpoint =
        [aDecoder decodeObjectOfClass:[NSURL class] forKey:kDeviceAuthorizationEndpointKey];
    _deviceAuthorizationEndpoint = deviceAuthorizationEndpoint;
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_deviceAuthorizationEndpoint forKey:kDeviceAuthorizationEndpointKey];
}

#pragma mark - description

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, deviceAuthorizationEndpoint: %@ tokenEndpoint: %@>",
                                    NSStringFromClass([self class]),
                                    (void *)self,
                                    _deviceAuthorizationEndpoint,
                                    self.tokenEndpoint];
}

@end

NS_ASSUME_NONNULL_END
