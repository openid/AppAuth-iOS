/*! @file OIDTVTokenRequest.m
   @brief AppAuth iOS SDK
   @copyright
       Copyright 2020 Google Inc.
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

#import "OIDTVTokenRequest.h"

#import "OIDDefines.h"
#import "OIDTVServiceConfiguration.h"
#import "OIDURLQueryComponent.h"

/*! @brief The key for the @c deviceCode property for @c NSSecureCoding and request body.
 */
static NSString *const kDeviceCodeKey = @"device_code";

/*! @brief Key used to encode the @c grantType property for @c NSSecureCoding and request body.
 */
static NSString *const kGrantTypeKey = @"grant_type";

/*! @brief Value for @c grant_type key in the request body
    @see https://tools.ietf.org/html/rfc8628#section-3.4
 */
static NSString *const kOIDTVDeviceTokenGrantType = @"urn:ietf:params:oauth:grant-type:device_code";

@implementation OIDTVTokenRequest

- (instancetype)init OID_UNAVAILABLE_USE_INITIALIZER(@selector
                                                     (initWithConfiguration:
                                                                   deviceCode:
                                                                     clientID:
                                                                 clientSecret:
                                                         additionalParameters:
                                                             ))

- (instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
                            grantType:(NSString *)grantType
                    authorizationCode:(nullable NSString *)code
                          redirectURL:(nullable NSURL *)redirectURL
                             clientID:(NSString *)clientID
                         clientSecret:(nullable NSString *)clientSecret
                               scopes:(nullable NSArray<NSString *> *)scopes
                         refreshToken:(nullable NSString *)refreshToken
                         codeVerifier:(nullable NSString *)codeVerifier
                 additionalParameters:
                     (nullable NSDictionary<NSString *, NSString *> *)additionalParameters
    OID_UNAVAILABLE_USE_INITIALIZER(@selector
                                    (initWithConfiguration:
                                                  deviceCode:
                                                    clientID:
                                                clientSecret:
                                        additionalParameters:
                                            ))

- (instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
                            grantType:(NSString *)grantType
                    authorizationCode:(nullable NSString *)code
                          redirectURL:(nullable NSURL *)redirectURL
                             clientID:(NSString *)clientID
                         clientSecret:(nullable NSString *)clientSecret
                                scope:(nullable NSString *)scope
                         refreshToken:(nullable NSString *)refreshToken
                         codeVerifier:(nullable NSString *)codeVerifier
                 additionalParameters:
                     (nullable NSDictionary<NSString *, NSString *> *)additionalParameters
    OID_UNAVAILABLE_USE_INITIALIZER(@selector
                                     (initWithConfiguration:
                                                  deviceCode:
                                                    clientID:
                                                clientSecret:
                                        additionalParameters:
                                              ))

- (instancetype)initWithConfiguration:(OIDTVServiceConfiguration *)configuration
                           deviceCode:(NSString *)deviceCode
                             clientID:(NSString *)clientID
                         clientSecret:(NSString *)clientSecret
                 additionalParameters:(NSDictionary<NSString *, NSString *> *)additionalParameters {
  self = [super initWithConfiguration:configuration
                            grantType:kOIDTVDeviceTokenGrantType
                    authorizationCode:nil
                          redirectURL:[[NSURL alloc] initWithString:@""]
                             clientID:clientID
                         clientSecret:clientSecret
                                scope:nil
                         refreshToken:nil
                         codeVerifier:nil
                 additionalParameters:additionalParameters];

  if (self) {
    _deviceCode = [deviceCode copy];
  }
  return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone {
  // The documentation for NSCopying specifically advises us to return a reference to the original
  // instance in the case where instances are immutable (as ours is):
  // "Implement NSCopying by retaining the original instead of creating a new copy when the class
  // and its contents are immutable."
  return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    NSString *deviceCode = [aDecoder decodeObjectOfClass:[NSString class] forKey:kDeviceCodeKey];
    _deviceCode = deviceCode;
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:_deviceCode forKey:kDeviceCodeKey];
}

- (OIDURLQueryComponent *)tokenRequestBody {
  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] init];

  if (self.grantType) {
    [query addParameter:kGrantTypeKey value:self.grantType];
  }

  [query addParameter:kDeviceCodeKey value:self.deviceCode];

  [query addParameters:self.additionalParameters];

  return query;
}

@end
