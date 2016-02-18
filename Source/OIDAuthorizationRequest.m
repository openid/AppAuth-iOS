/*! @file OIDAuthorizationRequest.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2015 Google Inc. All Rights Reserved.
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

#import "OIDAuthorizationRequest.h"

#import "OIDDefines.h"
#import "OIDScopeUtilities.h"
#import "OIDServiceConfiguration.h"
#import "OIDTokenUtilities.h"
#import "OIDURLQueryComponent.h"

/*! @var kConfigurationKey
    @brief The key for the @c configuration property for @c NSSecureCoding
 */
static NSString *const kConfigurationKey = @"configuration";

/*! @var kResponseTypeKey
    @brief Key used to encode the @c responseType property for @c NSSecureCoding, and on the URL
        request.
 */
static NSString *const kResponseTypeKey = @"response_type";

/*! @var kClientIDKey
    @brief Key used to encode the @c clientID property for @c NSSecureCoding, and on the URL
        request.
 */
static NSString *const kClientIDKey = @"client_id";

/*! @var kScopeKey
    @brief Key used to encode the @c scope property for @c NSSecureCoding, and on the URL request.
 */
static NSString *const kScopeKey = @"scope";

/*! @var kRedirectURLKey
    @brief Key used to encode the @c redirectURL property for @c NSSecureCoding, and on the URL
        request.
 */
static NSString *const kRedirectURLKey = @"redirect_uri";

/*! @var kStateKey
    @brief Key used to encode the @c state property for @c NSSecureCoding, and on the URL request.
 */
static NSString *const kStateKey = @"state";

/*! @var kCodeVerifierKey
    @brief Key used to encode the @c codeVerifier property for @c NSSecureCoding.
 */
static NSString *const kCodeVerifierKey = @"code_verifier";

/*! @var kCodeChallengeKey
    @brief Key used to send the @c codeChallenge on the URL request.
 */
static NSString *const kCodeChallengeKey = @"code_challenge";

/*! @var kCodeChallengeMethodKey
    @brief Key used to send the @c codeChallengeMethod on the URL request.
 */
static NSString *const kCodeChallengeMethodKey = @"code_challenge_method";

/*! @var kAdditionalParametersKey
    @brief Key used to encode the @c additionalParameters property for
        @c NSSecureCoding
 */
static NSString *const kAdditionalParametersKey = @"additionalParameters";

/*! @var kStateSizeBytes
    @brief Number of random bytes generated for the @ state.
 */
static NSUInteger const kStateSizeBytes = 32;

/*! @var kCodeVerifierBytes
    @brief Number of random bytes generated for the @ codeVerifier.
 */
static NSUInteger const kCodeVerifierBytes = 32;

/*! @var kPKCEChallengeMethodS256
    @brief The code_challenge_method used by this library (always S256 since iOS is capable of
        generating a SHA256 hash easily).
    @see https://tools.ietf.org/html/rfc7636#section-4.3
 */
static NSString *const kPKCEChallengeMethodS256 = @"S256";

@implementation OIDAuthorizationRequest

- (instancetype)init
    OID_UNAVAILABLE_USE_INITIALIZER(
        @selector(initWithConfiguration:
                               clientId:
                                  scope:
                            redirectURL:
                           responseType:
                                  state:
                           codeVerifier:
                   additionalParameters:)
    );

- (nullable instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
                clientId:(NSString *)clientID
                   scope:(nullable NSString *)scope
             redirectURL:(NSURL *)redirectURL
            responseType:(NSString *)responseType
                   state:(nullable NSString *)state
            codeVerifier:(nullable NSString *)codeVerifier
    additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters {
  self = [super init];
  if (self) {
    _configuration = [configuration copy];
    _clientID = [clientID copy];
    _scope = [scope copy];
    _redirectURL = [redirectURL copy];
    _responseType = [responseType copy];
    _state = [state copy];
    _codeVerifier = [codeVerifier copy];
    _additionalParameters =
        [[NSDictionary alloc] initWithDictionary:additionalParameters copyItems:YES];
  }
  return self;
}

- (nullable instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
                clientId:(NSString *)clientID
                  scopes:(nullable NSArray<NSString *> *)scopes
             redirectURL:(NSURL *)redirectURL
            responseType:(NSString *)responseType
    additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters {
  return [self initWithConfiguration:configuration
                            clientId:clientID
                               scope:[OIDScopeUtilities scopesWithArray:scopes]
                         redirectURL:redirectURL
                        responseType:responseType
                               state:[[self class] generateState]
                        codeVerifier:[[self class] generateCodeVerifier]
                additionalParameters:additionalParameters];
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
  OIDServiceConfiguration *configuration =
      [aDecoder decodeObjectOfClass:[OIDServiceConfiguration class]
                             forKey:kConfigurationKey];
  NSString *responseType = [aDecoder decodeObjectOfClass:[NSString class] forKey:kResponseTypeKey];
  NSString *clientID = [aDecoder decodeObjectOfClass:[NSString class] forKey:kClientIDKey];
  NSString *scope = [aDecoder decodeObjectOfClass:[NSString class] forKey:kScopeKey];
  NSURL *redirectURL = [aDecoder decodeObjectOfClass:[NSURL class] forKey:kRedirectURLKey];
  NSString *state = [aDecoder decodeObjectOfClass:[NSString class] forKey:kStateKey];
  NSString *codeVerifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:kCodeVerifierKey];
  NSSet *additionalParameterCodingClasses = [NSSet setWithArray:@[
    [NSDictionary class],
    [NSString class]
  ]];
  NSDictionary *additionalParameters =
      [aDecoder decodeObjectOfClasses:additionalParameterCodingClasses
                               forKey:kAdditionalParametersKey];

  self = [self initWithConfiguration:configuration
                            clientId:clientID
                               scope:scope
                         redirectURL:redirectURL
                        responseType:responseType
                               state:state
                        codeVerifier:codeVerifier
                additionalParameters:additionalParameters];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_configuration forKey:kConfigurationKey];
  [aCoder encodeObject:_responseType forKey:kResponseTypeKey];
  [aCoder encodeObject:_clientID forKey:kClientIDKey];
  [aCoder encodeObject:_scope forKey:kScopeKey];
  [aCoder encodeObject:_redirectURL forKey:kRedirectURLKey];
  [aCoder encodeObject:_state forKey:kStateKey];
  [aCoder encodeObject:_codeVerifier forKey:kCodeVerifierKey];
  [aCoder encodeObject:_additionalParameters forKey:kAdditionalParametersKey];
}

#pragma mark - NSObject overrides

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, request: %@>",
                                    NSStringFromClass([self class]),
                                    self,
                                    self.authorizationRequestURL];
}

#pragma mark - CodeVerifier/state Generation Methods

+ (NSString *)generateCodeVerifier {
  return [OIDTokenUtilities randomURLSafeStringWithSize:kCodeVerifierBytes];
}

+ (NSString *)generateState {
  return [OIDTokenUtilities randomURLSafeStringWithSize:kStateSizeBytes];
}

#pragma mark - PKCE params

- (NSString *)codeChallenge {
  if (!_codeVerifier) {
    return nil;
  }
  // generates the code_challenge per spec https://tools.ietf.org/html/rfc7636#section-4.2
  // code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
  // NB. the ASCII conversion on the code_verifier entropy was done at time of generation.
  NSData *sha256Verifier = [OIDTokenUtilities sha265:_codeVerifier];
  return [OIDTokenUtilities encodeBase64urlNoPadding:sha256Verifier];
}

- (NSString *)codeChallengeMethod {
  if (!_codeVerifier) {
    return nil;
  }
  return kPKCEChallengeMethodS256;
}


#pragma mark -

- (NSURL *)authorizationRequestURL {
  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] init];

  // Required parameters.
  [query addParameter:kResponseTypeKey value:_responseType];
  [query addParameter:kClientIDKey value:_clientID];

  // Add any additional parameters the client has specified.
  [query addParameters:_additionalParameters];

  // Add optional parameters, as applicable.
  if (_redirectURL) {
    [query addParameter:kRedirectURLKey value:_redirectURL.absoluteString];
  }
  if (_scope) {
    [query addParameter:kScopeKey value:_scope];
  }
  if (_state) {
    [query addParameter:kStateKey value:_state];
  }
  if (_codeVerifier) {
    [query addParameter:kCodeChallengeKey value:self.codeChallenge];
    [query addParameter:kCodeChallengeMethodKey value:self.codeChallengeMethod];
  }

  // Construct the URL:
  return [query URLByReplacingQueryInURL:_configuration.authorizationEndpoint];
}

@end
