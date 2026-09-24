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

/*! @brief Creates the callback for a request whose redirect URL is an HTTPS URL.
    @return The callback, or nil if the request is of an unsupported type, or its redirect URL is
        not an HTTPS URL with a host.
 */
+ (nullable ASWebAuthenticationSessionCallback *)HTTPSCallbackForRequest:
    (id<OIDExternalUserAgentRequest>)request API_AVAILABLE(ios(17.4)) {
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

  // ASWebAuthenticationSession doesn't work with guided access (rdar://40809553)
  if (!UIAccessibilityIsGuidedAccessEnabled()) {
    __weak OIDExternalUserAgentIOS *weakSelf = self;
    ASWebAuthenticationSessionCompletionHandler completionHandler =
        ^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
      __strong OIDExternalUserAgentIOS *strongSelf = weakSelf;
      if (!strongSelf) {
          return;
      }
      strongSelf->_webAuthenticationVC = nil;
      if (callbackURL) {
        // The session matches callback URLs more loosely than the flow checks the redirect URL (a
        // custom scheme callback matches on the scheme alone, and an HTTPS callback ignores case
        // and the port), so the flow can reject the URL. Fail the flow if it does, rather than
        // leaving it with neither a response nor an error.
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
    };

    ASWebAuthenticationSession *authenticationVC = nil;
    NSString *redirectScheme = request.redirectScheme;
    if ([[redirectScheme lowercaseString] isEqualToString:@"https"]) {
      // An HTTPS redirect URL needs the HTTPS callback added in iOS 17.4.
      // Without one no session is started, as https is not supported as a callbackURLScheme: the
      // session's callback would never fire.
      if (@available(iOS 17.4, *)) {
        ASWebAuthenticationSessionCallback *callback =
            [[self class] HTTPSCallbackForRequest:request];
        if (callback) {
          authenticationVC = [[ASWebAuthenticationSession alloc] initWithURL:requestURL
                                                                   callback:callback
                                                          completionHandler:completionHandler];
        }
      }
    } else {
      authenticationVC = [[ASWebAuthenticationSession alloc] initWithURL:requestURL
                                                       callbackURLScheme:redirectScheme
                                                       completionHandler:completionHandler];
    }
    authenticationVC.presentationContextProvider = self;
    authenticationVC.prefersEphemeralWebBrowserSession = _prefersEphemeralSession;
    _webAuthenticationVC = authenticationVC;
    openedUserAgent = [authenticationVC start];
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
