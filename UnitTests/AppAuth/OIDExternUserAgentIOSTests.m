//
//  OIDExternalUserAgentIOSTests.m
//  
//
//  Created by Matt Mathias on 1/11/23.
//

#import <XCTest/XCTest.h>

#if SWIFT_PACKAGE
@import AppAuth;
@import AppAuthCore;
#else
#import "Source/AppAuth/iOS/OIDExternalUserAgentIOS.h"
#import "Source/AppAuthCore/OIDAuthorizationRequest.h"
#import "Source/AppAuthCore/OIDAuthorizationService.h"
#endif

/*! @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientID = @"ClientID";

/*! @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientSecret = @"ClientSecret";

/*! @brief Test key for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterKey = @"A";

/*! @brief Test value for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterValue = @"1";

/*! @brief Test value for the @c scope property.
 */
static NSString *const kTestScope = @"Scope";

/*! @brief Test value for the @c scope property.
 */
static NSString *const kTestScopeA = @"ScopeA";

/*! @brief Test value for the @c redirectURL property.
 */
static NSString *const kTestRedirectURL = @"http://www.google.com/";

/*! @brief Test value for the @c state property.
 */
static NSString *const kTestState = @"State";

/*! @brief Test value for the @c responseType property.
 */
static NSString *const kTestResponseType = @"code";

/*! @brief Test value for the @c nonce property.
 */
static NSString *const kTestNonce = @"Nonce";

/*! @brief Test value for the @c codeVerifier property.
 */
static NSString *const kTestCodeVerifier = @"code verifier";

/*! @brief Test value for the @c authorizationEndpoint property.
 */
static NSString *const kInitializerTestAuthEndpoint = @"https://www.example.com/auth";

/*! @brief Test value for the @c tokenEndpoint property.
 */
static NSString *const kInitializerTestTokenEndpoint = @"https://www.example.com/token";

/*! @brief Test value for the @c tokenEndpoint property.
 */
static NSString *const kInitializerTestRegistrationEndpoint =
    @"https://www.example.com/registration";

@interface OIDExternalUserAgentIOSTests : XCTestCase

@end

@implementation OIDExternalUserAgentIOSTests

- (void)testThatPresentExternalUserAgentRequestReturnsNoWhenMissingPresentingViewController {
  OIDExternalUserAgentIOS *userAgent = [[OIDExternalUserAgentIOS alloc] init];
  OIDAuthorizationRequest *authRequest = [[self class] authorizationRequestTestInstance];
  [OIDAuthorizationService presentAuthorizationRequest:authRequest externalUserAgent:userAgent callback:^(OIDAuthorizationResponse * _Nullable authorizationResponse, NSError * _Nullable error) {
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OIDErrorCodeSafariOpenError);
    XCTAssertEqualObjects(error.localizedDescription, @"Unable to open Safari.");
  }];
}

+ (OIDAuthorizationRequest *)authorizationRequestTestInstance {
  NSDictionary *additionalParameters =
      @{ kTestAdditionalParameterKey : kTestAdditionalParameterValue };
  OIDServiceConfiguration *configuration = [[self class] serviceConfigurationTestInstance];
  OIDAuthorizationRequest *request =
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                      clientId:kTestClientID
                  clientSecret:kTestClientSecret
                         scope:[OIDScopeUtilities scopesWithArray:@[ kTestScope, kTestScopeA ]]
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

+ (OIDServiceConfiguration *)serviceConfigurationTestInstance {
  NSURL *authEndpoint = [NSURL URLWithString:kInitializerTestAuthEndpoint];
  NSURL *tokenEndpoint = [NSURL URLWithString:kInitializerTestTokenEndpoint];
  NSURL *registrationEndpoint = [NSURL URLWithString:kInitializerTestRegistrationEndpoint];
  OIDServiceConfiguration *configuration =
      [[OIDServiceConfiguration alloc] initWithAuthorizationEndpoint:authEndpoint
                                                       tokenEndpoint:tokenEndpoint
                                                registrationEndpoint:registrationEndpoint];
  return configuration;
}

+ (NSString *)codeChallenge {
  return [OIDAuthorizationRequest codeChallengeS256ForVerifier:kTestCodeVerifier];
}

+ (NSString *)codeChallengeMethod {
  return OIDOAuthorizationRequestCodeChallengeMethodS256;
}

@end
