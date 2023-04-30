/*! @file OIDExternalUserAgentTests.m
   @brief AppAuth iOS SDK
   @copyright
       Copyright 2023 The AppAuth Authors. All Rights Reserved.
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

#import <XCTest/XCTest.h>

#if SWIFT_PACKAGE
@import AppAuth;
@import TestHelpers;
#else
#import "Source/AppAuth/iOS/OIDExternalUserAgentCatalyst.h"
#import "Source/AppAuth/iOS/OIDExternalUserAgentIOS.h"
#import "Source/AppAuthCore/OIDError.h"
#import "UnitTests/TestHelpers/OIDAuthorizationRequest+TestHelper.h"
#endif

@interface OIDExternalUserAgentTests : XCTestCase

@end

@implementation OIDExternalUserAgentTests

- (void)testThatPresentExternalUserAgentRequestReturnsNoWhenMissingPresentingViewController {
  id<OIDExternalUserAgent> userAgent;

#if TARGET_OS_MACCATALYST
  userAgent = [[OIDExternalUserAgentCatalyst alloc] init];
#elif TARGET_OS_IOS
  userAgent = [[OIDExternalUserAgentIOS alloc] init];
#endif

  OIDAuthorizationRequest *authRequest = [OIDAuthorizationRequest testInstance];
  [OIDAuthorizationService
      presentAuthorizationRequest:authRequest
      externalUserAgent:userAgent
      callback:^(OIDAuthorizationResponse * _Nullable authorizationResponse,
                 NSError * _Nullable error) {
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OIDErrorCodeSafariOpenError);
    XCTAssertEqualObjects(error.localizedDescription, @"Unable to open Safari.");
  }];
}

@end
