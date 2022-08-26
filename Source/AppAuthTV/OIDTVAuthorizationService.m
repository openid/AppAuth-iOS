/*! @file OIDTVAuthorizationService.m
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

#import "OIDTVAuthorizationService.h"

#import "OIDAuthorizationService.h"
#import "OIDAuthState.h"
#import "OIDDefines.h"
#import "OIDErrorUtilities.h"
#import "OIDServiceDiscovery.h"
#import "OIDURLQueryComponent.h"
#import "OIDURLSessionProvider.h"

#import "OIDTVAuthorizationRequest.h"
#import "OIDTVAuthorizationResponse.h"
#import "OIDTVServiceConfiguration.h"
#import "OIDTVTokenRequest.h"

/*! @brief The authorization pending error code.
    @see https://tools.ietf.org/html/rfc8628#section-3.5
 */
NSString *const kErrorCodeAuthorizationPending = @"authorization_pending";

/*! @brief The slow down error code.
    @see https://tools.ietf.org/html/rfc8628#section-3.5
 */
NSString *const kErrorCodeSlowDown = @"slow_down";

/*! @brief Path appended to an OpenID Connect issuer for discovery
    @see https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfig
 */
static NSString *const kOpenIDConfigurationWellKnownPath = @".well-known/openid-configuration";

@implementation OIDTVAuthorizationService

#pragma mark OIDC Discovery

+ (void)discoverServiceConfigurationForIssuer:(NSURL *)issuerURL
                                   completion:(OIDTVDiscoveryCallback)completion {
  NSURL *fullDiscoveryURL =
      [issuerURL URLByAppendingPathComponent:kOpenIDConfigurationWellKnownPath];

  [[self class] discoverServiceConfigurationForDiscoveryURL:fullDiscoveryURL
                                                 completion:completion];
}

+ (void)discoverServiceConfigurationForDiscoveryURL:(NSURL *)discoveryURL
                                         completion:(OIDTVDiscoveryCallback)completion {
  // Call the corresponding discovery method in OIDAuthorizationService
  [OIDAuthorizationService discoverServiceConfigurationForDiscoveryURL:discoveryURL
      completion:^(OIDServiceConfiguration * _Nullable configuration, NSError * _Nullable error) {
    if (configuration == nil) {
      completion(nil, error);
      return;
    }

    if (configuration.discoveryDocument.deviceAuthorizationEndpoint == nil) {
      NSError *missingEndpointError = [OIDErrorUtilities
            errorWithCode:OIDErrorCodeInvalidDiscoveryDocument
          underlyingError:nil
              description:@"Discovery document does not contain device authorization endpoint."];

      completion(nil, missingEndpointError);
      return;
    }

    // Create an OIDTVServiceConfiguration from the discovery document of the configuration
    OIDTVServiceConfiguration *TVConfiguration = [[OIDTVServiceConfiguration alloc]
        initWithDiscoveryDocument:configuration.discoveryDocument];

    completion(TVConfiguration, nil);
  }];
}

#pragma mark - Initializers

+ (OIDTVAuthorizationCancelBlock)authorizeTVRequest:(OIDTVAuthorizationRequest *)request
                                     initialization:(OIDTVAuthorizationInitialization)initialization
                                         completion:(OIDTVAuthorizationCompletion)completion {
  // Block level variable that can be used to cancel the polling.
  __block BOOL pollRunning = YES;

  // Block that will be returned allowign the caller to cancel the polling.
  OIDTVAuthorizationCancelBlock cancelBlock = ^{
    if (pollRunning) {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSError *cancelError =
            [OIDErrorUtilities errorWithCode:OIDErrorCodeProgramCanceledAuthorizationFlow
                             underlyingError:nil
                                 description:@"Authorization cancelled"];
        completion(nil, cancelError);
      });
    }
    pollRunning = NO;
  };

  // Performs the initial authorization reqeust.
  NSURLRequest *URLRequest = [request URLRequest];
  NSURLSession *session = [NSURLSession sharedSession];
  [[session dataTaskWithRequest:URLRequest
              completionHandler:^(NSData *_Nullable data,
                                  NSURLResponse *_Nullable response,
                                  NSError *_Nullable error) {
    if (error) {
      // A network error or server error occurred.
      NSError *returnedError =
          [OIDErrorUtilities errorWithCode:OIDErrorCodeNetworkError
                           underlyingError:error
                               description:nil];
      dispatch_async(dispatch_get_main_queue(), ^{
        initialization(nil, returnedError);
      });
      return;
    }

    NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;

    if (HTTPURLResponse.statusCode != 200) {
      // A server error occurred.
      NSError *serverError =
          [OIDErrorUtilities HTTPErrorWithHTTPResponse:HTTPURLResponse data:data];

      // HTTP 400 may indicate an RFC6749 Section 5.2 error response, checks for that
      if (HTTPURLResponse.statusCode == 400) {
        NSError *jsonDeserializationError;
        NSDictionary<NSString *, NSObject<NSCopying> *> *json =
            [NSJSONSerialization JSONObjectWithData:(NSData *)data
                                            options:0
                                              error:&jsonDeserializationError];

        // if the HTTP 400 response parses as JSON and has an 'error' key, it's an OAuth error
        // these errors are special as they indicate a problem with the authorization grant
        if (json[OIDOAuthErrorFieldError]) {
          NSError *oauthError =
            [OIDErrorUtilities OAuthErrorWithDomain:OIDOAuthTokenErrorDomain
                                      OAuthResponse:json
                                    underlyingError:serverError];
          dispatch_async(dispatch_get_main_queue(), ^{
            initialization(nil, oauthError);
          });
          return;
        }
      }

      // not an OAuth error, just a generic server error
      NSError *returnedError =
          [OIDErrorUtilities errorWithCode:OIDErrorCodeServerError
                           underlyingError:serverError
                               description:nil];
      dispatch_async(dispatch_get_main_queue(), ^{
        initialization(nil, returnedError);
      });
      return;
    }

    NSError *jsonDeserializationError;
    NSDictionary<NSString *, NSObject<NSCopying> *> *json =
        [NSJSONSerialization JSONObjectWithData:(NSData *)data
                                        options:0
                                          error:&jsonDeserializationError];
    if (jsonDeserializationError) {
      // A problem occurred deserializing the response/JSON.
      NSError *returnedError =
          [OIDErrorUtilities errorWithCode:OIDErrorCodeJSONDeserializationError
                           underlyingError:jsonDeserializationError
                               description:nil];
      dispatch_async(dispatch_get_main_queue(), ^{
        initialization(nil, returnedError);
      });
      return;
    }

    // Parses the authorization response.
    OIDTVAuthorizationResponse *TVAuthorizationResponse =
        [[OIDTVAuthorizationResponse alloc] initWithRequest:request parameters:json];
    if (!TVAuthorizationResponse) {
      // A problem occurred constructing the token response from the JSON.
      NSError *returnedError =
          [OIDErrorUtilities errorWithCode:OIDErrorCodeTokenResponseConstructionError
                           underlyingError:jsonDeserializationError
                               description:nil];
      dispatch_async(dispatch_get_main_queue(), ^{
        initialization(nil, returnedError);
      });
      return;
    }

    // Calls the initialization block to signal that we received a TV authorization response.
    dispatch_async(dispatch_get_main_queue(), ^() {
      initialization(TVAuthorizationResponse, nil);
    });

    // Creates the token request that will be used to poll the token endpoint.
    OIDTVTokenRequest *pollRequest = [TVAuthorizationResponse tokenPollRequest];

    // Starting polling interval (may be increased if a slow down message is received).
    __block NSTimeInterval interval = [TVAuthorizationResponse.interval doubleValue];

    // If no interval is set, use default value of 5 as per RFC.
    // If interval is set to 0, use value of 1 to prevent infinite polling.
    if (TVAuthorizationResponse.interval == nil) {
      interval = 5.0;
    } else if (interval == 0.0) {
      interval = 1.0;
    }

    // Polls the token endpoint until the authorization completes or expires.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      do {
        // Sleeps for polling interval.
        [NSThread sleepForTimeInterval:interval];

        if (!pollRunning) {
          break;
        }

        // Polls token endpoint.
        [OIDAuthorizationService performTokenRequest:pollRequest
                                            callback:^(OIDTokenResponse *_Nullable tokenResponse,
                                                       NSError *_Nullable tokenError) {
          if (!pollRunning) {
            return;
          }
          dispatch_async(dispatch_get_main_queue(), ^() {
            if (tokenResponse) {
              // Success response.
              pollRunning = NO;
              dispatch_async(dispatch_get_main_queue(), ^{
                OIDAuthState *authState =
                    [[OIDAuthState alloc] initWithAuthorizationResponse:TVAuthorizationResponse
                                                          tokenResponse:tokenResponse];
                completion(authState, nil);
              });
            } else {
              if (tokenError.domain == OIDOAuthTokenErrorDomain) {
                // OAuth token errors inspected for device flow specific errors.
                NSString *errorCode =
                    tokenError.userInfo[OIDOAuthErrorResponseErrorKey][OIDOAuthErrorFieldError];
                if ([errorCode isEqual:kErrorCodeAuthorizationPending]) {
                  // authorization_pending is an expected response.
                  return;
                } else if ([errorCode isEqual:kErrorCodeSlowDown]) {
                  // Increase interval by 20%, enforce a lower bound of 5s.
                  interval *= 1.20;
                  interval = MAX(5.0, interval);
                } else {
                  // Unhandled token error, considered fatal.
                  pollRunning = NO;
                  dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, tokenError);
                  });
                }
              } else {
                // All other errors considered fatal.
                pollRunning = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                  completion(nil, tokenError);
                });
              }
            }
          });
        }];
      } while ([TVAuthorizationResponse.expirationDate timeIntervalSinceNow] > 0 && pollRunning);
    });
  }] resume];

  return cancelBlock;
}

@end
