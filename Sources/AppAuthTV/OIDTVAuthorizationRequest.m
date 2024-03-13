/*! @file OIDTVAuthorizationRequest.m
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
#import "OIDTVAuthorizationRequest.h"
#import "OIDTVServiceConfiguration.h"
#import "OIDURLQueryComponent.h"

@implementation OIDTVAuthorizationRequest

- (instancetype)
    initWithConfiguration:(OIDTVServiceConfiguration *)configuration
                 clientId:(NSString *)clientID
             clientSecret:(nullable NSString *)clientSecret
                    scope:(nullable NSString *)scope
              redirectURL:(NSURL *)redirectURL
             responseType:(NSString *)responseType
                    state:(nullable NSString *)state
                    nonce:(nullable NSString *)nonce
             codeVerifier:(nullable NSString *)codeVerifier
            codeChallenge:(nullable NSString *)codeChallenge
      codeChallengeMethod:(nullable NSString *)codeChallengeMethod
     additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters {

  if (![configuration isKindOfClass:[OIDTVServiceConfiguration class]]) {
    NSAssert([configuration isKindOfClass:[OIDTVServiceConfiguration class]],
             @"configuration parameter must be of type OIDTVServiceConfiguration, encountered %@",
            NSStringFromClass([configuration class]));
    return nil;
  }

  return [super initWithConfiguration:configuration
                             clientId:clientID
                         clientSecret:clientSecret
                                scope:scope
                          redirectURL:redirectURL
                         responseType:responseType
                                state:state
                                nonce:nonce
                         codeVerifier:codeVerifier
                        codeChallenge:codeChallenge
                  codeChallengeMethod:codeChallengeMethod
                 additionalParameters:additionalParameters];
}

- (instancetype)
    initWithConfiguration:(OIDTVServiceConfiguration *)configuration
                 clientId:(NSString *)clientID
             clientSecret:(NSString *)clientSecret
                   scopes:(nullable NSArray<NSString *> *)scopes
     additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters {
  return [self initWithConfiguration:configuration
                            clientId:clientID
                        clientSecret:clientSecret
                              scopes:scopes
                         redirectURL:[[NSURL alloc] initWithString:@""]
                        responseType:OIDResponseTypeCode
                additionalParameters:additionalParameters];
}

#pragma mark - NSObject overrides

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, request: %@>",
                                    NSStringFromClass([self class]),
                                    (void *)self,
                                    self.authorizationRequestURL];
}

#pragma mark -

- (NSURLRequest *)URLRequest {
  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] init];

  // Required parameters.
  [query addParameter:@"client_id" value:self.clientID];

  if (self.additionalParameters) {
    // Add any additional parameters the client has specified.
    [query addParameters:(NSDictionary *)self.additionalParameters];
  }

  if (self.scope) {
    [query addParameter:@"scope" value:(NSString *)self.scope];
  }

  static NSString *const kHTTPPost = @"POST";
  static NSString *const kHTTPContentTypeHeaderKey = @"Content-Type";
  static NSString *const kHTTPContentTypeHeaderValue =
      @"application/x-www-form-urlencoded; charset=UTF-8";

  OIDTVServiceConfiguration *tvConfiguration = (OIDTVServiceConfiguration *)self.configuration;

  NSMutableURLRequest *URLRequest =
      [[NSURLRequest requestWithURL:tvConfiguration.deviceAuthorizationEndpoint] mutableCopy];
  URLRequest.HTTPMethod = kHTTPPost;
  [URLRequest setValue:kHTTPContentTypeHeaderValue forHTTPHeaderField:kHTTPContentTypeHeaderKey];
  NSString *bodyString = [query URLEncodedParameters];
  NSData *body = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
  URLRequest.HTTPBody = body;
  return URLRequest;
}

@end
