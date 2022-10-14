/*! @file AppAuthExampleViewController.h
    @brief AppAuth iOS SDK Example
    @copyright
        Copyright 2015 Google Inc. All Rights Reserved.
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
@class OIDServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

/*! @brief The example application's view controller.
 */
@interface AppAuthExampleViewController : UIViewController

@property(nullable) IBOutlet UIButton *authButton;
@property(nullable) IBOutlet UITextView *logTextView;
@property(nullable) IBOutlet UISegmentedControl *authTypeSegmentedControl;
@property(nullable) IBOutlet UIActivityIndicatorView *authActivityIndicator;

/*! @brief The authorization state. This is the AppAuth object that you should keep around and
        serialize to disk.
 */
@property(nonatomic, readonly, nullable) OIDAuthState *authState;

/*! @brief Authorization code flow using @c OIDAuthState automatic code exchanges.
    @param sender IBAction sender.
 */
- (IBAction)authorizeUser:(nullable id)sender;

/*! @brief Clears the UI log.
    @param sender IBAction sender.
 */
- (IBAction)clearLog:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
