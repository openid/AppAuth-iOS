/*! @file OIDExternalUserAgentIOS.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2016 Google Inc. All Rights Reserved.
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

#import <TargetConditionals.h>

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

#import "OIDExternalUserAgentIOS.h"

#import <SafariServices/SafariServices.h>
#import <AuthenticationServices/AuthenticationServices.h>

#import "OIDAuthorizationRequest.h"
#import "OIDEndSessionRequest.h"
#import "OIDErrorUtilities.h"
#import "OIDExternalUserAgentSession.h"
#import "OIDExternalUserAgentRequest.h"

#if !TARGET_OS_MACCATALYST

NS_ASSUME_NONNULL_BEGIN

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
@interface OIDExternalUserAgentIOS ()<SFSafariViewControllerDelegate, ASWebAuthenticationPresentationContextProviding>
@end
#else
@interface OIDExternalUserAgentIOS ()<SFSafariViewControllerDelegate>
@end
#endif

API_AVAILABLE(ios(17.4))
ASWebAuthenticationSessionCallback *_Nullable
    OIDHTTPSCallbackForRequest(id<OIDExternalUserAgentRequest> request) {
  NSURL *redirectURL = nil;
  // OIDExternalUserAgentRequest does not conform to NSObject, so message the request as id.
  id requestObject = request;
  if ([requestObject isKindOfClass:[OIDAuthorizationRequest class]]) {
    redirectURL = ((OIDAuthorizationRequest *)requestObject).redirectURL;
  } else if ([requestObject isKindOfClass:[OIDEndSessionRequest class]]) {
    redirectURL = ((OIDEndSessionRequest *)requestObject).postLogoutRedirectURL;
  }
  if (![[redirectURL.scheme lowercaseString] isEqualToString:@"https"] ||
      redirectURL.host.length == 0) {
    return nil;
  }
  // A redirect URL with no path is normalized to the root path, so that it matches the callback
  // URL the authorization server redirects to.
  NSString *path = redirectURL.path.length > 0 ? redirectURL.path : @"/";
  return [ASWebAuthenticationSessionCallback callbackWithHTTPSHost:redirectURL.host path:path];
}

@implementation OIDExternalUserAgentIOS {
  UIViewController *_presentingViewController;
  BOOL _prefersEphemeralSession;

  BOOL _externalUserAgentFlowInProgress;
  __weak id<OIDExternalUserAgentSession> _session;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
  __weak SFSafariViewController *_safariVC;
  ASWebAuthenticationSession *_webAuthenticationVC;
#pragma clang diagnostic pop
}

- (null_unspecified instancetype)init {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  return [self initWithPresentingViewController:nil];
#pragma clang diagnostic pop
}

- (nullable instancetype)initWithPresentingViewController:
    (UIViewController *)presentingViewController {
  self = [super init];
  if (self) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    NSAssert(presentingViewController != nil,
             @"presentingViewController cannot be nil on iOS 13");
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    
    _presentingViewController = presentingViewController;
  }
  return self;
}

- (nullable instancetype)initWithPresentingViewController:
    (UIViewController *)presentingViewController
                                  prefersEphemeralSession:(BOOL)prefersEphemeralSession {
  self = [self initWithPresentingViewController:presentingViewController];
  if (self) {
    _prefersEphemeralSession = prefersEphemeralSession;
  }
  return self;
}

- (BOOL)presentExternalUserAgentRequest:(id<OIDExternalUserAgentRequest>)request
                                session:(id<OIDExternalUserAgentSession>)session {
  if (_externalUserAgentFlowInProgress) {
    // TODO: Handle errors as authorization is already in progress.
    return NO;
  }

  _externalUserAgentFlowInProgress = YES;
  _session = session;
  BOOL openedUserAgent = NO;
  NSURL *requestURL = [request externalUserAgentRequestURL];
  // An HTTPS redirect is a universal link, which only the iOS 17.4 callback below can handle.
  // ASWebAuthenticationSession does not support @c https as a callbackURLScheme, so such a request
  // must never reach the scheme based session: it would open a browser whose callback never fires.
  // Before iOS 17.4 such a request therefore fails to open, ending the flow with an error rather
  // than leaving it hanging.
  BOOL hasHTTPSRedirect = [[request.redirectScheme lowercaseString] isEqualToString:@"https"];

  // iOS 17.4 and later: if the redirect URL is an HTTPS universal link, use
  // ASWebAuthenticationSession's HTTPS callback.
  if (@available(iOS 17.4, *)) {
    // ASWebAuthenticationSession doesn't work with guided access (rdar://40809553)
    if (hasHTTPSRedirect && !UIAccessibilityIsGuidedAccessEnabled()) {
      ASWebAuthenticationSessionCallback *callback = OIDHTTPSCallbackForRequest(request);
      if (!callback) {
        // The redirect URL is HTTPS but a callback couldn't be created for it (e.g. it has no
        // host). A session started with such a redirect could never complete, so fail instead.
        [self cleanUp];
        NSError *error =
            [OIDErrorUtilities errorWithCode:OIDErrorCodeSafariOpenError
                             underlyingError:nil
                                 description:@"The request's HTTPS redirect URL is not a valid "
                                              "universal link."];
        [session failExternalUserAgentFlowWithError:error];
        return NO;
      }
      __weak OIDExternalUserAgentIOS *weakSelf = self;
      ASWebAuthenticationSession *authenticationVC =
          [[ASWebAuthenticationSession alloc] initWithURL:requestURL
                                                 callback:callback
                                        completionHandler:^(NSURL * _Nullable callbackURL,
                                                            NSError * _Nullable error) {
        __strong OIDExternalUserAgentIOS *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf->_webAuthenticationVC = nil;
        if (callbackURL) {
          // The callback matches the redirect URL case insensitively and ignores its port, so it
          // can fire for a URL the session itself rejects. Report that instead of leaving the
          // flow with neither a response nor an error.
          NSError *resumeError;
          if (![strongSelf->_session resumeExternalUserAgentFlowWithURL:callbackURL
                                                                  error:&resumeError]) {
            [strongSelf->_session failExternalUserAgentFlowWithError:resumeError];
          }
        } else {
          NSError *safariError =
              [OIDErrorUtilities errorWithCode:OIDErrorCodeUserCanceledAuthorizationFlow
                               underlyingError:error
                                   description:nil];
          [strongSelf->_session failExternalUserAgentFlowWithError:safariError];
        }
      }];
      authenticationVC.presentationContextProvider = self;
      authenticationVC.prefersEphemeralWebBrowserSession = _prefersEphemeralSession;
      _webAuthenticationVC = authenticationVC;
      openedUserAgent = [authenticationVC start];
    }
  }

  // iOS 12 and later, use ASWebAuthenticationSession
  if (@available(iOS 12.0, *)) {
    // ASWebAuthenticationSession doesn't work with guided access (rdar://40809553)
    if (!hasHTTPSRedirect && !UIAccessibilityIsGuidedAccessEnabled()) {
      __weak OIDExternalUserAgentIOS *weakSelf = self;
      NSString *redirectScheme = request.redirectScheme;
      ASWebAuthenticationSession *authenticationVC =
          [[ASWebAuthenticationSession alloc] initWithURL:requestURL
                                        callbackURLScheme:redirectScheme
                                        completionHandler:^(NSURL * _Nullable callbackURL,
                                                            NSError * _Nullable error) {
        __strong OIDExternalUserAgentIOS *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf->_webAuthenticationVC = nil;
        if (callbackURL) {
          [strongSelf->_session resumeExternalUserAgentFlowWithURL:callbackURL error:nil];
        } else {
          NSError *safariError =
              [OIDErrorUtilities errorWithCode:OIDErrorCodeUserCanceledAuthorizationFlow
                               underlyingError:error
                                   description:nil];
          [strongSelf->_session failExternalUserAgentFlowWithError:safariError];
        }
      }];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
      if (@available(iOS 13.0, *)) {
        authenticationVC.presentationContextProvider = self;
        authenticationVC.prefersEphemeralWebBrowserSession = _prefersEphemeralSession;
      }
#endif
      _webAuthenticationVC = authenticationVC;
      openedUserAgent = [authenticationVC start];
    }
  }
  if (!openedUserAgent) {
    [self cleanUp];
    return NO;
  }

  return openedUserAgent;
}

- (void)dismissExternalUserAgentAnimated:(BOOL)animated completion:(void (^)(void))completion {
  if (!_externalUserAgentFlowInProgress) {
    // Ignore this call if there is no authorization flow in progress.
    if (completion) completion();
    return;
  }
  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
  SFSafariViewController *safariVC = _safariVC;
  ASWebAuthenticationSession *webAuthenticationVC = _webAuthenticationVC;
#pragma clang diagnostic pop
  
  [self cleanUp];
  
  if (webAuthenticationVC) {
    // dismiss the ASWebAuthenticationSession
    [webAuthenticationVC cancel];
    if (completion) completion();
  } else if (safariVC) {
    // dismiss the SFSafariViewController
    [safariVC dismissViewControllerAnimated:YES completion:completion];
  } else {
    if (completion) completion();
  }
}

- (void)cleanUp {
  // The weak references to |_safariVC| and |_session| are set to nil to avoid accidentally using
  // them while not in an authorization flow.
  _safariVC = nil;
  _webAuthenticationVC = nil;
  _session = nil;
  _externalUserAgentFlowInProgress = NO;
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller NS_AVAILABLE_IOS(9.0) {
  if (controller != _safariVC) {
    // Ignore this call if the safari view controller do not match.
    return;
  }
  if (!_externalUserAgentFlowInProgress) {
    // Ignore this call if there is no authorization flow in progress.
    return;
  }
  id<OIDExternalUserAgentSession> session = _session;
  [self cleanUp];
  NSError *error = [OIDErrorUtilities errorWithCode:OIDErrorCodeUserCanceledAuthorizationFlow
                                    underlyingError:nil
                                        description:@"No external user agent flow in progress."];
  [session failExternalUserAgentFlowWithError:error];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
#pragma mark - ASWebAuthenticationPresentationContextProviding

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session API_AVAILABLE(ios(13.0)){
  return _presentingViewController.view.window;
}
#endif // __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000

@end

NS_ASSUME_NONNULL_END

#endif // !TARGET_OS_MACCATALYST

#endif // TARGET_OS_IOS || TARGET_OS_MACCATALYST
