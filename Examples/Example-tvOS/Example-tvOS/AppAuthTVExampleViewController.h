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

/*! @brief An example app that uses the TV authorization flow to obtain authorization from the user
        and make an authorized API call.
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
 */
- (IBAction)signin:(nullable id)sender;

/*! @brief Cancels the active sign-in (if any), has no effect if a sign-in isn't in progress.
 */
- (IBAction)cancelSignIn:(nullable id)sender;

/*! @brief Forgets the authentication state, used to sign-out the user.
 */
- (IBAction)clearAuthState:(nullable id)sender;

/*! @brief Performs an authenticated API call.
 */
- (IBAction)userinfo:(nullable id)sender;

@end


