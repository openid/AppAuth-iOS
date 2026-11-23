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
#import "OIDEndSessionResponse.h"
#import "OIDExternalUserAgent.h"
#import "OIDRegistrationRequest.h"
#import "OIDRegistrationResponse.h"
#import "OIDTokenRequest.h"
#import "OIDTokenResponse.h"

#if SWIFT_PACKAGE
@import AppAuth;
#else
#import "OIDExternalUserAgentCatalyst.h"
#import "OIDExternalUserAgentIOS.h"
#import "OIDExternalUserAgentMac.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@implementation OIDFakeAuthorizationService {
  /*! @brief How many authorization requests have been made. A kept callback checks it, so an
          older callback doesn't clear a newer one.
   */
  NSUInteger _authorizationRequestCount;

  /*! @brief How many end-session requests have been made. Used the same way.
   */
  NSUInteger _endSessionRequestCount;

  /*! @brief How many registration requests have been made. Used the same way.
   */
  NSUInteger _registrationRequestCount;
}

- (id<OIDExternalUserAgentSession>)
    presentAuthorizationRequest:(OIDAuthorizationRequest *)request
              externalUserAgent:(id<OIDExternalUserAgent>)externalUserAgent
                       callback:(OIDAuthorizationCallback)callback {
  NSUInteger requestNumber = ++_authorizationRequestCount;
  __weak OIDFakeAuthorizationService *weakSelf = self;
  _lastAuthorizationRequest = request;
  _lastAuthorizationExternalUserAgent = externalUserAgent;
  _lastAuthorizationCallback = ^(OIDAuthorizationResponse *_Nullable authorizationResponse,
                                 NSError *_Nullable error) {
    callback(authorizationResponse, error);
    OIDFakeAuthorizationService *strongSelf = weakSelf;
    if (strongSelf && strongSelf->_authorizationRequestCount == requestNumber) {
      strongSelf->_lastAuthorizationCallback = nil;
    }
  };
  _lastAuthorizationSession = [[OIDFakeExternalUserAgentSession alloc] init];
  return _lastAuthorizationSession;
}

- (id<OIDExternalUserAgentSession>)
    presentEndSessionRequest:(OIDEndSessionRequest *)request
           externalUserAgent:(id<OIDExternalUserAgent>)externalUserAgent
                    callback:(OIDEndSessionCallback)callback {
  NSUInteger requestNumber = ++_endSessionRequestCount;
  __weak OIDFakeAuthorizationService *weakSelf = self;
  _lastEndSessionRequest = request;
  _lastEndSessionExternalUserAgent = externalUserAgent;
  _lastEndSessionCallback = ^(OIDEndSessionResponse *_Nullable endSessionResponse,
                              NSError *_Nullable error) {
    callback(endSessionResponse, error);
    OIDFakeAuthorizationService *strongSelf = weakSelf;
    if (strongSelf && strongSelf->_endSessionRequestCount == requestNumber) {
      strongSelf->_lastEndSessionCallback = nil;
    }
  };
  _lastEndSessionSession = [[OIDFakeExternalUserAgentSession alloc] init];
  return _lastEndSessionSession;
}

- (void)performTokenRequest:(OIDTokenRequest *)request callback:(OIDTokenCallback)callback {
  [self performTokenRequest:request originalAuthorizationResponse:nil callback:callback];
}

- (void)performTokenRequest:(OIDTokenRequest *)request
    originalAuthorizationResponse:(nullable OIDAuthorizationResponse *)authorizationResponse
                         callback:(OIDTokenCallback)callback {
  NSUInteger requestNumber = ++_tokenRequestCount;
  __weak OIDFakeAuthorizationService *weakSelf = self;
  _lastTokenRequest = request;
  _lastOriginalAuthorizationResponse = authorizationResponse;
  _lastTokenCallback = ^(OIDTokenResponse *_Nullable tokenResponse, NSError *_Nullable error) {
    callback(tokenResponse, error);
    OIDFakeAuthorizationService *strongSelf = weakSelf;
    if (strongSelf && strongSelf->_tokenRequestCount == requestNumber) {
      strongSelf->_lastTokenCallback = nil;
    }
  };
}

- (void)performRegistrationRequest:(OIDRegistrationRequest *)request
                        completion:(OIDRegistrationCompletion)completion {
  NSUInteger requestNumber = ++_registrationRequestCount;
  __weak OIDFakeAuthorizationService *weakSelf = self;
  _lastRegistrationRequest = request;
  _lastRegistrationCompletion = ^(OIDRegistrationResponse *_Nullable registrationResponse,
                                  NSError *_Nullable error) {
    completion(registrationResponse, error);
    OIDFakeAuthorizationService *strongSelf = weakSelf;
    if (strongSelf && strongSelf->_registrationRequestCount == requestNumber) {
      strongSelf->_lastRegistrationCompletion = nil;
    }
  };
}

@end

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

@implementation OIDFakeAuthorizationService (IOS)

- (id<OIDExternalUserAgentSession>)
    presentAuthorizationRequest:(OIDAuthorizationRequest *)request
       presentingViewController:(UIViewController *)presentingViewController
                       callback:(OIDAuthorizationCallback)callback {
#if TARGET_OS_MACCATALYST
  id<OIDExternalUserAgent> externalUserAgent = [[OIDExternalUserAgentCatalyst alloc]
      initWithPresentingViewController:presentingViewController];
#else // TARGET_OS_MACCATALYST
  id<OIDExternalUserAgent> externalUserAgent = [[OIDExternalUserAgentIOS alloc]
      initWithPresentingViewController:presentingViewController];
#endif // TARGET_OS_MACCATALYST
  return [self presentAuthorizationRequest:request
                         externalUserAgent:externalUserAgent
                                  callback:callback];
}

- (id<OIDExternalUserAgentSession>)
    presentAuthorizationRequest:(OIDAuthorizationRequest *)request
       presentingViewController:(UIViewController *)presentingViewController
        prefersEphemeralSession:(BOOL)prefersEphemeralSession
                       callback:(OIDAuthorizationCallback)callback {
#if TARGET_OS_MACCATALYST
  id<OIDExternalUserAgent> externalUserAgent = [[OIDExternalUserAgentCatalyst alloc]
      initWithPresentingViewController:presentingViewController
               prefersEphemeralSession:prefersEphemeralSession];
#else // TARGET_OS_MACCATALYST
  id<OIDExternalUserAgent> externalUserAgent = [[OIDExternalUserAgentIOS alloc]
      initWithPresentingViewController:presentingViewController
               prefersEphemeralSession:prefersEphemeralSession];
#endif // TARGET_OS_MACCATALYST
  return [self presentAuthorizationRequest:request
                         externalUserAgent:externalUserAgent
                                  callback:callback];
}

@end

#endif // TARGET_OS_IOS || TARGET_OS_MACCATALYST

#if TARGET_OS_OSX

@implementation OIDFakeAuthorizationService (Mac)

- (id<OIDExternalUserAgentSession>)
    presentAuthorizationRequest:(OIDAuthorizationRequest *)request
               presentingWindow:(NSWindow *)presentingWindow
                       callback:(OIDAuthorizationCallback)callback {
  OIDExternalUserAgentMac *externalUserAgent =
      [[OIDExternalUserAgentMac alloc] initWithPresentingWindow:presentingWindow];
  return [self presentAuthorizationRequest:request
                         externalUserAgent:externalUserAgent
                                  callback:callback];
}

- (id<OIDExternalUserAgentSession>)
    presentAuthorizationRequest:(OIDAuthorizationRequest *)request
               presentingWindow:(NSWindow *)presentingWindow
        prefersEphemeralSession:(BOOL)prefersEphemeralSession
                       callback:(OIDAuthorizationCallback)callback {
  OIDExternalUserAgentMac *externalUserAgent =
      [[OIDExternalUserAgentMac alloc] initWithPresentingWindow:presentingWindow
                                        prefersEphemeralSession:prefersEphemeralSession];
  return [self presentAuthorizationRequest:request
                         externalUserAgent:externalUserAgent
                                  callback:callback];
}

@end

#endif // TARGET_OS_OSX

NS_ASSUME_NONNULL_END
