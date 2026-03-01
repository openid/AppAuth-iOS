/*! @file AppAuthTVExampleViewController.h
    @brief AppAuth tvOS SDK Example
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

#import <UIKit/UIKit.h>

@class OIDAuthState;

NS_ASSUME_NONNULL_BEGIN

/*! @brief The example application's view controller.
 */
@interface AppAuthTVExampleViewController : UIViewController

@property(nullable) IBOutlet UIView *signInView;
@property(nullable) IBOutlet UILabel *verificationURLLabel;
@property(nullable) IBOutlet UILabel *userCodeLabel;
@property(nullable) IBOutlet UIView *signInButtons;
@property(nullable) IBOutlet UIButton *cancelSignInButton;
@property(nullable) IBOutlet UIView *signedInButtons;
@property(nullable) IBOutlet UITextView *logTextView;

/*! @brief The authorization state.
 */
@property(nonatomic, nullable) OIDAuthState *authState;

/*! @brief Initiates the sign-in.
    @param sender IBAction sender.
 */
- (IBAction)signin:(nullable id)sender;

/*! @brief Cancels the active sign-in (if any), has no effect if a sign-in isn't in progress.
    @param sender IBAction sender.
 */
- (IBAction)cancelSignIn:(nullable id)sender;

/*! @brief Forgets the authentication state, used to sign-out the user.
    @param sender IBAction sender.
 */
- (IBAction)clearAuthState:(nullable id)sender;

/*! @brief Performs an authenticated API call.
    @param sender IBAction sender.
 */
- (IBAction)userinfo:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
