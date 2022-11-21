//
//  LogoutOptionsController.h.h
//  Example-iOS_ObjC
//
//  Created by Michael Moore on 11/15/22.
//  Copyright © 2022 William Denniss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogoutOption.h"

NS_ASSUME_NONNULL_BEGIN

@interface LogoutOptionsController : UIViewController

@property (nonatomic, nullable) NSMutableArray<LogoutOption>* logoutOptionsSelected;

/**
 Initializes the logout options controller with one or more logout options.
 @param logoutOptions is an array containing all the logout options available.
 */
+ (instancetype)controllerWithLogoutOptions:(NSArray<LogoutOption>*)logoutOptions;

@end

NS_ASSUME_NONNULL_END
