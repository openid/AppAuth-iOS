/*! @file OIDAuthorizationRequestion+TestHelper.h
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

#import "OIDAuthorizationRequest.h"

NS_ASSUME_NONNULL_BEGIN

/*! @brief Test value for the @c clientID property.
 */
extern NSString *const kTestClientID;

/*! @brief Test value for the @c clientID property.
 */
extern NSString *const kTestClientSecret;

/*! @brief Test key for the @c additionalParameters property.
 */
extern NSString *const kTestAdditionalParameterKey;

/*! @brief Test value for the @c additionalParameters property.
 */
extern NSString *const kTestAdditionalParameterValue;

/*! @brief Test value for the @c scope property.
 */
extern NSString *const kTestScope;

/*! @brief Test value for the @c scope property.
 */
extern NSString *const kTestScopeA;

/*! @brief Test value for the @c redirectURL property.
 */
extern NSString *const kTestRedirectURL;

/*! @brief Test value for the @c state property.
 */
extern NSString *const kTestState;

/*! @brief Test value for the @c responseType property.
 */
extern NSString *const kTestResponseType;

/*! @brief Test value for the @c nonce property.
 */
extern NSString *const kTestNonce;

/*! @brief Test value for the @c codeVerifier property.
 */
extern NSString *const kTestCodeVerifier;

@interface OIDAuthorizationRequest (TestHelper)

+ (OIDAuthorizationRequest *)testInstance;

@end

NS_ASSUME_NONNULL_END
