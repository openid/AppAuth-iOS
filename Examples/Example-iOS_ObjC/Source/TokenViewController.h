//
//  TokenViewController.h
//  Example-iOS_ObjC
//
//  Created by Michael Moore on 10/5/22.
//  Copyright © 2022 William Denniss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogoutOption.h"

@class OIDAuthState;
@class OIDServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

/*! @brief The example token view controller.
 */
@interface TokenViewController : UIViewController

/*! @brief The authorization state. This is the AppAuth object that you should keep around and
 serialize to disk.
 */
@property (nonatomic, readonly, nullable) OIDAuthState* authState;

@property (nullable) IBOutlet UIButton* userinfoButton;
@property (nullable) IBOutlet UIButton* codeExchangeButton;
@property (nullable) IBOutlet UIButton* refreshTokenButton;
@property (nullable) IBOutlet UIButton* browserButton;
@property (nullable) IBOutlet UITextView* logTextView;
@property (nullable) IBOutlet UIButton* profileButton;
@property (nullable) IBOutlet UILabel *accessTokenTitleLabel;
@property (nullable) IBOutlet UILabel *refreshTokenTitleLabel;
@property (nullable) IBOutlet UITextView *accessTokenTextView;
@property (nullable) IBOutlet UITextView *refreshTokenTextView;
@property (nullable) IBOutlet UIStackView *accessTokenStackView;
@property (nullable) IBOutlet UIStackView *refreshTokenStackView;
@property (nullable) IBOutlet UIStackView *tokenStackView;

/*! @brief Authorization code flow using @c OIDAuthState automatic code exchanges.
 @param sender IBAction sender.
 */
- (IBAction)authWithAutoCodeExchange:(nullable id)sender;

/*! @brief Performs the authorization code exchange at the token endpoint.
 @param sender IBAction sender.
 */
- (IBAction)codeExchange:(nullable id)sender;

/*! @brief Performs a Userinfo API call using @c OIDAuthState.performActionWithFreshTokens.
 @param sender IBAction sender.
 */
- (IBAction)userinfo:(nullable id)sender;

/*! @brief Clears the UI log.
 @param sender IBAction sender.
 */
- (IBAction)clearLog:(nullable id)sender;

/*! @brief Opens the user's profile in the browser object.
 @param sender IBAction sender.
 */
- (IBAction)profileManagement:(nullable id)sender;

/*! @brief Logs the user out of the browser session object.
 @param sender IBAction sender.
 */
- (IBAction)logout:(nullable id)sender;

/*! @brief Refreshes the session token.
 @param sender IBAction sender.
 */
- (IBAction)refreshToken:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
