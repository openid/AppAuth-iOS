/*! @file UIApplication+openURL.h
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

#import "UIApplication+openURL.h"
#import <objc/message.h>

@implementation UIApplication (openURL)

+ (BOOL)mayUseNonAppExtensionSafeAPI {
    NSString* mainBundlePath = [[NSBundle mainBundle] bundlePath];
    return ![mainBundlePath hasSuffix:@"appex"];
}

+ (BOOL)openURL:(NSURL*)url {
    if ([[self class] mayUseNonAppExtensionSafeAPI]) {
        // +[UIApplication sharedApplication] must not be called from app extensions
        // +mayUseNonAppExtensionSafeAPI returns YES only when called from the main app
        // Calling +sharedApplication directly will cause a compiler error, so objc_msgSend is used instead
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UIApplication *sharedApplication = ((UIApplication * (*)(id, SEL, ...))objc_msgSend)([UIApplication class], NSSelectorFromString(@"sharedApplication"));
        return ((BOOL (*)(id, SEL, NSURL *, ...))objc_msgSend)(sharedApplication, NSSelectorFromString(@"openURL:"), url);
#pragma clang diagnostic pop
    }
    return NO;
}

+ (BOOL)canOpenURL:(NSURL*)url {
    if ([[self class] mayUseNonAppExtensionSafeAPI]) {
        // +[UIApplication sharedApplication] must not be called from app extensions
        // +mayUseNonAppExtensionSafeAPI returns YES only when called from the main app
        // Calling +sharedApplication directly will cause a compiler error, so objc_msgSend is used instead
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UIApplication *sharedApplication = ((UIApplication * (*)(id, SEL, ...))objc_msgSend)([UIApplication class], NSSelectorFromString(@"sharedApplication"));
        return ((BOOL (*)(id, SEL, NSURL *, ...))objc_msgSend)(sharedApplication, NSSelectorFromString(@"canOpenURL:"), url);
#pragma clang diagnostic pop
    }
    return NO;
}

@end
