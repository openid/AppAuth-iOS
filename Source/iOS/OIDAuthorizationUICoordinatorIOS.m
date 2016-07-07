/*! @file OIDAuthorizationUICoordinatorIOS.m
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

#import "OIDAuthorizationUICoordinatorIOS.h"

#import <SafariServices/SafariServices.h>

#import "OIDAuthorizationService.h"
#import "OIDErrorUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface OIDAuthorizationUICoordinatorIOS ()<SFSafariViewControllerDelegate>
@end

@implementation OIDAuthorizationUICoordinatorIOS {
  UIViewController *_presentingViewController;

  BOOL _authorizationFlowInProgress;
  __weak id<OIDAuthorizationFlowSession> _session;
  __weak SFSafariViewController *_safariVC;
}

- (nullable instancetype)initWithPresentingViewController:
        (UIViewController *)presentingViewController {
  self = [super init];
  if (self) {
    _presentingViewController = presentingViewController;
  }
  return self;
}

- (BOOL)presentAuthorizationWithURL:(NSURL *)URL session:(id<OIDAuthorizationFlowSession>)session {
  if (_authorizationFlowInProgress) {
    // TODO: Handle errors as authorization is already in progress.
    return NO;
  }

  _authorizationFlowInProgress = YES;
  _session = session;
  if ([SFSafariViewController class]) {
    SFSafariViewController *safariVC =
        [[SFSafariViewController alloc] initWithURL:URL entersReaderIfAvailable:NO];
    safariVC.delegate = self;
    _safariVC = safariVC;
    [_presentingViewController presentViewController:safariVC animated:YES completion:nil];
    return YES;
  }
  BOOL openedSafari = [[UIApplication sharedApplication] openURL:URL];
  if (!openedSafari) {
    [self cleanUp];
    NSError *safariError = [OIDErrorUtilities errorWithCode:OIDErrorCodeSafariOpenError
                                            underlyingError:nil
                                                description:@"Unable to open Safari."];
    [session failAuthorizationFlowWithError:safariError];
  }
  return openedSafari;
}

- (void)dismissAuthorizationAnimated:(BOOL)animated completion:(void (^)(void))completion {
  if (!_authorizationFlowInProgress) {
    // Ignore this call if there is no authorization flow in progress.
    return;
  }
  SFSafariViewController *safariVC = _safariVC;
  [self cleanUp];
  if (safariVC) {
    [safariVC dismissViewControllerAnimated:YES completion:completion];
  } else {
    if (completion) completion();
  }
}

- (void)cleanUp {
  // The weak references to |_safariVC| and |_session| are set to nil to avoid accidentally using
  // them while not in an authorization flow.
  _safariVC = nil;
  _session = nil;
  _authorizationFlowInProgress = NO;
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
  if (controller != _safariVC) {
    // Ignore this call if the safari view controller do not match.
    return;
  }
  if (!_authorizationFlowInProgress) {
    // Ignore this call if there is no authorization flow in progress.
    return;
  }
  id<OIDAuthorizationFlowSession> session = _session;
  [self cleanUp];
  NSError *error = [OIDErrorUtilities errorWithCode:OIDErrorCodeProgramCanceledAuthorizationFlow
                                    underlyingError:nil
                                        description:nil];
  [session failAuthorizationFlowWithError:error];
}

@end

NS_ASSUME_NONNULL_END
