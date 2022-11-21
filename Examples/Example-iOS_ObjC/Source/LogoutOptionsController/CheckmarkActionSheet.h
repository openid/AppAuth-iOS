//
//  LogoutActionSheet.h
//  Example-iOS_ObjC
//
//  Created by Michael Moore on 11/10/22.
//  Copyright © 2022 William Denniss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckmarkAlertAction.h"

@class LogoutActionSheet;

#pragma mark - LogoutActionSheetDelegate
@protocol LogoutActionSheetDelegate <NSObject>
@optional

// Called when a button is clicked.
// The view will be automatically dismissed after the callback
- (void)actionSheet:(nonnull LogoutActionSheet*)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex;

// Cancel button click
- (void)actionSheetCancel:(nonnull LogoutActionSheet*)actionSheet;

// detructive button click
- (void)actionSheetDetructive:(nonnull LogoutActionSheet*)actionSheet;

@end

#pragma mark - LogoutActionSheet
@interface LogoutActionSheet
    : UIAlertController <LogoutActionSheetDelegate>

- (nonnull id)initWithTitle:(nullable NSString*)title
                   delegate:(nullable id<LogoutActionSheetDelegate>)delegate
          cancelButtonTitle:(nullable NSString*)cancelButtonTitle
     destructiveButtonTitle:(nullable NSString*)destructiveButtonTitle
          otherButtonTitles:(nullable NSArray<NSString*>*)otherButtonTitles
                  textColor:(nullable UIColor*)color
         checkedButtonIndex:(nullable NSInteger*)checkedButtonIndex;

@property(nullable, nonatomic, weak) id<LogoutActionSheetDelegate> delegate;

@property(nullable) CheckmarkAlertAction* cancelButton;
@property(nullable) CheckmarkAlertAction* destructiveButton;
@property(nullable) NSMutableArray<CheckmarkAlertAction*>* otherButtons;

@end
