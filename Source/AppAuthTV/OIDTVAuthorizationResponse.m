/*! @file OIDTVAuthorizationResponse.m
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

#import "OIDTVAuthorizationResponse.h"

#import "OIDDefines.h"
#import "OIDFieldMapping.h"

#import "OIDTVTokenRequest.h"
#import "OIDTVAuthorizationRequest.h"

/*! @brief The key for the @c verificationURI property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kVerificationURIKey = @"verification_uri";

/*! @brief An alternative key for the @c verificationURI property in the incoming parameters and for
        @c NSSecureCoding. If "verification_uri" is not found in the response, a "verification_url"
        key is considered equivalent. This is included for compatibility with legacy implementations
        and should ideally be removed in the future.
 */
static NSString *const kVerificationURIAlternativeKey = @"verification_url";

/*! @brief The key for the @c verificationURIComplete property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kVerificationURICompleteKey = @"verification_uri_complete";

/*! @brief The key for the @c userCode property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kUserCodeKey = @"user_code";

/*! @brief The key for the @c deviceCode property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kDeviceCodeKey = @"device_code";

/*! @brief The key for the @c expirationDate property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kExpiresInKey = @"expires_in";

/*! @brief The key for the @c interval property in the incoming parameters and for
        @c NSSecureCoding.
 */
static NSString *const kIntervalKey = @"interval";

/*! @brief Key used to encode the @c additionalParameters property for @c NSSecureCoding
 */
static NSString *const kAdditionalParametersKey = @"additionalParameters";

/*! @brief Key used to encode the @c request property for @c NSSecureCoding
 */
static NSString *const kRequestKey = @"request";

@implementation OIDTVAuthorizationResponse

/*! @brief Returns a mapping of incoming parameters to instance variables.
    @return A mapping of incoming parameters to instance variables.
 */
+ (NSDictionary<NSString *, OIDFieldMapping *> *)fieldMap {
  static NSMutableDictionary<NSString *, OIDFieldMapping *> *fieldMap;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    fieldMap = [NSMutableDictionary dictionary];
    fieldMap[kVerificationURIKey] =
        [[OIDFieldMapping alloc] initWithName:@"_verificationURI" type:[NSString class]];
    fieldMap[kVerificationURICompleteKey] =
        [[OIDFieldMapping alloc] initWithName:@"_verificationURIComplete" type:[NSString class]];
    fieldMap[kUserCodeKey] =
        [[OIDFieldMapping alloc] initWithName:@"_userCode" type:[NSString class]];
    fieldMap[kDeviceCodeKey] =
        [[OIDFieldMapping alloc] initWithName:@"_deviceCode" type:[NSString class]];
    fieldMap[kExpiresInKey] =
        [[OIDFieldMapping alloc] initWithName:@"_expirationDate"
                                         type:[NSDate class]
                                   conversion:^id _Nullable(NSObject *_Nullable value) {
          if (![value isKindOfClass:[NSNumber class]]) {
            return value;
          }
          NSNumber *valueAsNumber = (NSNumber *)value;
          return [NSDate dateWithTimeIntervalSinceNow:[valueAsNumber longLongValue]];
        }];
    fieldMap[kIntervalKey] =
        [[OIDFieldMapping alloc] initWithName:@"_interval" type:[NSNumber class]];

    // Map the alternative verification URI key to "_verificationURI" to support legacy
    // implementations using the alternative key
    fieldMap[kVerificationURIAlternativeKey] =
        [[OIDFieldMapping alloc] initWithName:@"_verificationURI" type:[NSString class]];
  });
  return fieldMap;
}

#pragma mark - Initializers

- (instancetype)initWithRequest:(OIDTVAuthorizationRequest *)request
                     parameters:(NSDictionary<NSString *, NSObject<NSCopying> *> *)parameters {
  self = [super initWithRequest:request parameters:parameters];
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

#pragma mark - NSObject overrides

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, verificationURI: %@, verificationURIComplete: %@, "
                                     "userCode: \"%@\", deviceCode: "
                                     "\"%@\", interval: %@, expirationDate: %@, "
                                     "additionalParameters: %@, "
                                     "request: %@>",
                                    NSStringFromClass([self class]),
                                    (void *)self,
                                    _verificationURI,
                                    _verificationURIComplete,
                                    _userCode,
                                    _deviceCode,
                                    _interval,
                                    _expirationDate,
                                    self.additionalParameters,
                                    self.request];
}

#pragma mark -

- (OIDTVTokenRequest *)tokenPollRequest {
  return [self tokenPollRequestWithAdditionalParameters:nil];
}

- (OIDTVTokenRequest *)tokenPollRequestWithAdditionalParameters:
    (NSDictionary<NSString *, NSString *> *)additionalParameters {
  return [[OIDTVTokenRequest alloc]
      initWithConfiguration:(OIDTVServiceConfiguration *)self.request.configuration
                 deviceCode:_deviceCode
                   clientID:self.request.clientID
               clientSecret:self.request.clientSecret
       additionalParameters:additionalParameters];
}

@end
