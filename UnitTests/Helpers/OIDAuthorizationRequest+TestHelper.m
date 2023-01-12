/*! @file OIDAuthorizationRequestion+TestHelper.m
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

#import "OIDAuthorizationRequest+TestHelper.h"
#import "OIDServiceConfiguration+TestHelper.h"

NSString *const kTestClientID = @"ClientID";
NSString *const kTestClientSecret = @"ClientSecret";
NSString *const kTestAdditionalParameterKey = @"A";
NSString *const kTestAdditionalParameterValue = @"1";
NSString *const kTestScope = @"Scope";
NSString *const kTestScopeA = @"ScopeA";
NSString *const kTestRedirectURL = @"http://www.google.com/";
NSString *const kTestState = @"State";
NSString *const kTestResponseType = @"code";
NSString *const kTestNonce = @"Nonce";
NSString *const kTestCodeVerifier = @"code verifier";

@implementation OIDAuthorizationRequest (TestHelper)

+ (OIDAuthorizationRequest *)testInstance {
  NSDictionary *additionalParameters =
      @{ kTestAdditionalParameterKey : kTestAdditionalParameterValue };
  OIDServiceConfiguration *configuration = [OIDServiceConfiguration testInstance];
  OIDAuthorizationRequest *request =
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                clientSecret:kTestClientSecret
                                                       scope:[OIDScopeUtilities scopesWithArray:
                                                                 @[ kTestScope, kTestScopeA ]]
                                                 redirectURL:[NSURL URLWithString:kTestRedirectURL]
                                                responseType:kTestResponseType
                                                       state:kTestState
                                                       nonce:kTestNonce
                                                codeVerifier:kTestCodeVerifier
                                               codeChallenge:[[self class] codeChallenge]
                                         codeChallengeMethod:[[self class] codeChallengeMethod]
                                        additionalParameters:additionalParameters];
  return request;
}

+ (NSString *)codeChallenge {
  return [OIDAuthorizationRequest codeChallengeS256ForVerifier:kTestCodeVerifier];
}

+ (NSString *)codeChallengeMethod {
  return OIDOAuthorizationRequestCodeChallengeMethodS256;
}

@end
