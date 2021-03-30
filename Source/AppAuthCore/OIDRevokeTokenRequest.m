/*! @file OIDEndSessionRequest.m
 @brief AppAuth iOS SDK
 @copyright
 Copyright 2017 The AppAuth Authors. All Rights Reserved.
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

#import "OIDRevokeTokenRequest.h"

#import "OIDDefines.h"
#import "OIDServiceConfiguration.h"
#import "OIDURLQueryComponent.h"
#import "OIDTokenUtilities.h"

/*! @brief The key for the @c configuration property for @c NSSecureCoding
 */
static NSString *const kConfigurationKey = @"configuration";

/*! @brief Key used to encode the @c token property for @c NSSecureCoding, and on the URL request.
 */
static NSString *const kTokenKey = @"token";

/*! @brief Key used to encode the @c tokenTypeHint property for @c NSSecureCoding, and on the URL request.
 */
static NSString *const kTokenTypeHintKey = @"token_type_hint";

/*! @brief Key used to encode the @c clientID property for @c NSSecureCoding
 */
static NSString *const kClientIDKey = @"client_id";

/*! @brief Key used to encode the @c clientSecret property for @c NSSecureCoding
 */
static NSString *const kClientSecretKey = @"client_secret";

/*! @brief Assertion text for missing revoke_token_endpoint.
 */
static NSString *const OIDMissingRevokeTokenEndpointMessage =
@"The service configuration is missing an revoke_token_endpoint.";

@implementation OIDRevokeTokenRequest

- (instancetype)init
OID_UNAVAILABLE_USE_INITIALIZER(
                                @selector(initWithConfiguration:
                                          token:
                                          tokenTypeHint:
                                          clientID:
                                          clientSecret:)
                                )

- (instancetype)initWithConfiguration:(OIDServiceConfiguration *)configuration
                                token:(NSString *)token
                        tokenTypeHint:(nullable NSString *)tokenTypeHint
                             clientID:(NSString *)clientID
                         clientSecret:(nullable NSString *)clientSecret
{
  self = [super init];
  if (self) {
    _configuration = [configuration copy];
    _token = [token copy];
    _tokenTypeHint = [tokenTypeHint copy];
    _clientID = [clientID copy];
    _clientSecret = [clientSecret copy];
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
  OIDServiceConfiguration *configuration = [aDecoder decodeObjectOfClass:[OIDServiceConfiguration class] forKey:kConfigurationKey];
  
  NSString *token = [aDecoder decodeObjectOfClass:[NSString class] forKey:kTokenKey];
  NSString *tokenTypeHint = [aDecoder decodeObjectOfClass:[NSString class] forKey:kTokenTypeHintKey];
  NSString *clientID = [aDecoder decodeObjectOfClass:[NSString class] forKey:kClientIDKey];
  NSString *clientSecret = [aDecoder decodeObjectOfClass:[NSString class] forKey:kClientSecretKey];
  
  self = [super init];
  if (self) {
    _configuration = [configuration copy];
    _token = [token copy];
    _tokenTypeHint = [tokenTypeHint copy];
    _clientID = [clientID copy];
    _clientSecret = [clientSecret copy];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:_configuration forKey:kConfigurationKey];
  [aCoder encodeObject:_token forKey:kTokenKey];
  [aCoder encodeObject:_tokenTypeHint forKey:kTokenTypeHintKey];
  [aCoder encodeObject:_clientID forKey:kClientIDKey];
  [aCoder encodeObject:_clientSecret forKey:kClientSecretKey];
}

#pragma mark - NSObject overrides

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, request: %@>",
          NSStringFromClass([self class]),
          (void *)self,
          self.revokeTokenRequestURL];
}

#pragma mark -

/*! @brief Constructs the request URI.
    @return A URL representing the token revocation request.
    @see https://tools.ietf.org/html/rfc7009#section-2.1
 */
- (NSURL *)revokeTokenRequestURL {
  return _configuration.revocationEndpoint;
}

/*! @brief Constructs the request body data by combining the request parameters using the
        "application/x-www-form-urlencoded" format.
    @return The data to pass to the token revocation request URL.
    @see https://tools.ietf.org/html/rfc7009#section-2.1
 */
- (OIDURLQueryComponent *)revokeTokenRequestBody {
  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] init];

  // Add parameters, as applicable.
  [query addParameter:kTokenKey value:_token];
  
  if (_tokenTypeHint) {
    [query addParameter:kTokenTypeHintKey value:_tokenTypeHint];
  }

  return query;
}

- (NSURLRequest *)URLRequest {
  static NSString *const kHTTPPost = @"POST";
  static NSString *const kHTTPContentTypeHeaderKey = @"Content-Type";
  static NSString *const kHTTPContentTypeHeaderValue =
      @"application/x-www-form-urlencoded; charset=UTF-8";

  NSURL *tokenRequestURL = [self revokeTokenRequestURL];
  NSMutableURLRequest *URLRequest = [[NSURLRequest requestWithURL:tokenRequestURL] mutableCopy];
  URLRequest.HTTPMethod = kHTTPPost;
  [URLRequest setValue:kHTTPContentTypeHeaderValue forHTTPHeaderField:kHTTPContentTypeHeaderKey];

  OIDURLQueryComponent *bodyParameters = [self revokeTokenRequestBody];
  NSMutableDictionary *httpHeaders = [[NSMutableDictionary alloc] init];

  if (_clientSecret) {
    // The client id and secret are encoded using the "application/x-www-form-urlencoded"
    // encoding algorithm per RFC 6749 Section 2.3.1.
    // https://tools.ietf.org/html/rfc6749#section-2.3.1
    NSString *encodedClientID = [OIDTokenUtilities formUrlEncode:_clientID];
    NSString *encodedClientSecret = [OIDTokenUtilities formUrlEncode:_clientSecret];
    
    NSString *credentials =
        [NSString stringWithFormat:@"%@:%@", encodedClientID, encodedClientSecret];
    NSData *plainData = [credentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString *basicAuth = [plainData base64EncodedStringWithOptions:kNilOptions];

    NSString *authValue = [NSString stringWithFormat:@"Basic %@", basicAuth];
    [httpHeaders setObject:authValue forKey:@"Authorization"];
  } else  {
    [bodyParameters addParameter:kClientIDKey value:_clientID];
  }

  // Constructs request with the body string and headers.
  NSString *bodyString = [bodyParameters URLEncodedParameters];
  NSData *body = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
  URLRequest.HTTPBody = body;

  for (id header in httpHeaders) {
    [URLRequest setValue:httpHeaders[header] forHTTPHeaderField:header];
  }

  return URLRequest;
}

@end
