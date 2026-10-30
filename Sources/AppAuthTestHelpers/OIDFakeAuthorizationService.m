/*! @file OIDFakeAuthorizationService.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2026 The AppAuth Authors. All Rights Reserved.
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

#import "OIDFakeAuthorizationService.h"

#import "OIDAuthorizationRequest.h"
#import "OIDAuthorizationResponse.h"
#import "OIDEndSessionRequest.h"
#import "OIDExternalUserAgent.h"
#import "OIDRegistrationRequest.h"
#import "OIDTokenRequest.h"

NS_ASSUME_NONNULL_BEGIN

@implementation OIDFakeAuthorizationService

- (id<OIDExternalUserAgentSession>)presentAuthorizationRequest:(OIDAuthorizationRequest *)request
                                             externalUserAgent:(id<OIDExternalUserAgent>)externalUserAgent
                                                      callback:(OIDAuthorizationCallback)callback {
  _lastAuthorizationRequest = request;
  _lastExternalUserAgent = externalUserAgent;
  _lastAuthorizationCallback = [callback copy];
  _lastAuthorizationSession = [[OIDFakeExternalUserAgentSession alloc] init];
  return _lastAuthorizationSession;
}

- (id<OIDExternalUserAgentSession>)presentEndSessionRequest:(OIDEndSessionRequest *)request
                                          externalUserAgent:(id<OIDExternalUserAgent>)externalUserAgent
                                                   callback:(OIDEndSessionCallback)callback {
  _lastEndSessionRequest = request;
  _lastEndSessionCallback = [callback copy];
  return [[OIDFakeExternalUserAgentSession alloc] init];
}

- (void)performTokenRequest:(OIDTokenRequest *)request
    originalAuthorizationResponse:(nullable OIDAuthorizationResponse *)authorizationResponse
                         callback:(OIDTokenCallback)callback {
  _tokenRequestCount++;
  _lastTokenRequest = request;
  _lastOriginalAuthorizationResponse = authorizationResponse;
  _lastTokenCallback = [callback copy];
}

- (void)performRegistrationRequest:(OIDRegistrationRequest *)request
                        completion:(OIDRegistrationCompletion)completion {
  _lastRegistrationRequest = request;
  _lastRegistrationCompletion = [completion copy];
}

@end

NS_ASSUME_NONNULL_END
