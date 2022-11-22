//
//  LogoutOption.h
//  Example-iOS_ObjC
//
//  Created by Michael Moore on 11/10/22.
//  Copyright © 2022 William Denniss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*! @brief The existing logout option constants.
 */
#define LogoutOptionRevokeTokens        @"Revoke Tokens"
#define LogoutOptionEndBrowserSession   @"Browser Session"
#define LogoutOptionEndAppSession       @"App Session"

typedef NSString*                       LogoutOption;
