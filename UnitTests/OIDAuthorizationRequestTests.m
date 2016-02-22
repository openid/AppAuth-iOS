/*! @file OIDAuthorizationRequestTests.m
    @brief AppAuth iOS SDK
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

#import "OIDAuthorizationRequestTests.h"

#import "OIDServiceConfigurationTests.h"
#import "Source/OIDAuthorizationRequest.h"
#import "Source/OIDScopeUtilities.h"
#import "Source/OIDServiceConfiguration.h"

/*! @var kTestResponseType
    @brief Test value for the @c responseType property.
 */
static NSString *const kTestResponseType = @"ResponseType";

/*! @var kTestClientID
    @brief Test value for the @c clientID property.
 */
static NSString *const kTestClientID = @"ClientID";

/*! @var kTestScope
    @brief Test value for the @c scope property.
 */
static NSString *const kTestScope = @"Scope";

/*! @var kTestScopeA
    @brief Test value for the @c scope property.
 */
static NSString *const kTestScopeA = @"ScopeA";

/*! @var kTestScopesMerged
    @brief Test value for the @c scope property.
 */
static NSString *const kTestScopesMerged = @"Scope ScopeA";

/*! @var kTestRedirectURL
    @brief Test value for the @c redirectURL property.
 */
static NSString *const kTestRedirectURL = @"http://www.google.com/";

/*! @var kTestAdditionalParameterKey
    @brief Test key for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterKey = @"A";

/*! @var kTestAdditionalParameterValue
    @brief Test value for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterValue = @"1";

/*! @var kTestState
    @brief Test value for the @c state property.
 */
static NSString *const kTestState = @"State";

/*! @var kTestCodeVerifier
    @brief Test value for the @c codeVerifier property.
 */
static NSString *const kTestCodeVerifier = @"code verifier";

/*! @var kTestInvalidScope1
    @brief This test scope contains a character which is one character below the allowed character
        range.
 */
static NSString *const kTestInvalidScope1 = @"\x20";

/*! @var kTestInvalidScope2
    @brief This test scope contains the double-quote character, which is one of two characters not
        allowed from the general allowed characters range.
 */
static NSString *const kTestInvalidScope2 = @"\x22";

/*! @var kTestInvalidScope3
    @brief This test scope contains the second of two characters which is not allowed in the general
        allowed characters range (the forward slash "\").
 */
static NSString *const kTestInvalidScope3 = @"\x5C";

/*! @var kTestInvalidScope4
    @brief This test scope contains the character immediately after the allowed character range.
 */
static NSString *const kTestInvalidScope4 = @"\x7F";

/*! @var kTestValidScope1
    @brief This test scope contains a valid character from the allowed character range.
 */
static NSString *const kTestValidScope1 = @"\x21";

/*! @var kTestValidScope2
    @brief This test scope contains a valid character from the allowed character range.
 */
static NSString *const kTestValidScope2 = @"\x23";

/*! @var kTestValidScope3
    @brief This test scope contains a valid character from the allowed character range.
 */
static NSString *const kTestValidScope3 = @"\x5B";

/*! @var kTestValidScope4
    @brief This test scope contains a valid character from the allowed character range.
 */
static NSString *const kTestValidScope4 = @"\x5D";

/*! @var kTestValidScope5
    @brief This test scope contains a valid character from the allowed character range.
 */
static NSString *const kTestValidScope5 = @"\x7E";

/*! @var kCodeVerifierMinLength
    @brief The minimum length of the codeVerifier per the PKCE spec.
    @see https://tools.ietf.org/html/rfc7636#section-4.1
 */
static int const kCodeVerifierMinLength = 43;

/*! @var kCodeVerifierMaxLength
    @brief The maximum length of the codeVerifier per the PKCE spec.
    @see https://tools.ietf.org/html/rfc7636#section-4.1
 */
static int const kCodeVerifierMaxLength = 128;

/*! @var kCodeVerifierRecommendedLength
    @brief The RECOMMENDED length of the codeVerifier per the PKCE spec.
    @see https://tools.ietf.org/html/rfc7636#section-4.1
 */
static int const kCodeVerifierRecommendedLength = 43;

@implementation OIDAuthorizationRequestTests

+ (NSString *)codeChallenge {
  return [OIDAuthorizationRequest codeChallengeS256ForVerifier:kTestCodeVerifier];
}
+ (NSString *)codeChallengeMethod {
  return OIDOAuthorizationRequestCodeChallengeMethodS256;
}

+ (OIDAuthorizationRequest *)testInstance {
  NSDictionary *additionalParameters =
      @{ kTestAdditionalParameterKey : kTestAdditionalParameterValue };
  OIDServiceConfiguration *configuration = [OIDServiceConfigurationTests testInstance];
  OIDAuthorizationRequest *request =
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                      clientId:kTestClientID
                        scope:[OIDScopeUtilities scopesWithArray:@[ kTestScope, kTestScopeA ]]
                   redirectURL:[NSURL URLWithString:kTestRedirectURL]
                  responseType:kTestResponseType
                         state:kTestState
                  codeVerifier:kTestCodeVerifier
                 codeChallenge:[[self class] codeChallenge]
           codeChallengeMethod:[[self class] codeChallengeMethod]
          additionalParameters:additionalParameters];
  return request;
}

+ (OIDAuthorizationRequest *)testInstanceCodeFlow {
  OIDServiceConfiguration *configuration = [OIDServiceConfigurationTests testInstance];
  OIDAuthorizationRequest *request =
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                      clientId:kTestClientID
                        scope:[OIDScopeUtilities scopesWithArray:@[ kTestScope, kTestScopeA ]]
                   redirectURL:[NSURL URLWithString:kTestRedirectURL]
                  responseType:OIDResponseTypeCode
                         state:kTestState
                  codeVerifier:kTestCodeVerifier
                 codeChallenge:[[self class] codeChallenge]
           codeChallengeMethod:[[self class] codeChallengeMethod]
          additionalParameters:nil];
  return request;
}

/*! @fn testScopeInitializerWithManyScopes
    @brief Tests the initializer which takes an array of scopes.
 */
- (void)testScopeInitializerWithManyScopes {
  NSDictionary *additionalParameters =
      @{ kTestAdditionalParameterKey : kTestAdditionalParameterValue };
  OIDServiceConfiguration *configuration = [OIDServiceConfigurationTests testInstance];
  OIDAuthorizationRequest *request =
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                      clientId:kTestClientID
                        scopes:@[ kTestScope, kTestScopeA ]
                   redirectURL:[NSURL URLWithString:kTestRedirectURL]
                  responseType:OIDResponseTypeCode
          additionalParameters:additionalParameters];

  XCTAssertEqualObjects(request.responseType, @"code");
  XCTAssertEqualObjects(request.scope, kTestScopesMerged);
  XCTAssertEqualObjects(request.clientID, kTestClientID);
  XCTAssertEqualObjects(request.redirectURL, [NSURL URLWithString:kTestRedirectURL]);
  XCTAssertEqualObjects(request.additionalParameters[kTestAdditionalParameterKey],
                        kTestAdditionalParameterValue);
}

/*! @fn testCopying
    @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
        process and checking to make sure the source and destination instances are equivalent.
 */
- (void)testCopying {
  OIDAuthorizationRequest *request = [[self class] testInstance];

  XCTAssertEqualObjects(request.responseType, kTestResponseType);
  XCTAssertEqualObjects(request.scope, kTestScopesMerged);
  XCTAssertEqualObjects(request.clientID, kTestClientID);
  XCTAssertEqualObjects(request.redirectURL, [NSURL URLWithString:kTestRedirectURL]);
  XCTAssertEqualObjects(request.state, kTestState);
  XCTAssertEqualObjects(request.codeVerifier, kTestCodeVerifier);
  XCTAssertEqualObjects(request.codeChallenge, [[self class] codeChallenge]);
  XCTAssertEqualObjects(request.codeChallengeMethod, [[self class] codeChallengeMethod]);
  XCTAssertEqualObjects(request.additionalParameters[kTestAdditionalParameterKey],
                        kTestAdditionalParameterValue);

  OIDAuthorizationRequest *requestCopy = [request copy];

  XCTAssertNotNil(requestCopy.configuration);
  XCTAssertEqualObjects(requestCopy.configuration, request.configuration);
  XCTAssertEqualObjects(requestCopy.responseType, request.responseType);
  XCTAssertEqualObjects(requestCopy.scope, request.scope);
  XCTAssertEqualObjects(requestCopy.clientID, request.clientID);
  XCTAssertEqualObjects(requestCopy.redirectURL, request.redirectURL);
  XCTAssertEqualObjects(requestCopy.state, request.state);
  XCTAssertEqualObjects(requestCopy.codeVerifier, request.codeVerifier);
  XCTAssertEqualObjects(requestCopy.codeChallenge, request.codeChallenge);
  XCTAssertEqualObjects(requestCopy.codeChallengeMethod, request.codeChallengeMethod);
  XCTAssertEqualObjects(requestCopy.additionalParameters,
                        request.additionalParameters);
}

/*! @fn testSecureCoding
    @brief Tests the @c NSSecureCoding by round-tripping an instance through the coding process and
        checking to make sure the source and destination instances are equivalent.
 */
- (void)testSecureCoding {
  OIDAuthorizationRequest *request = [[self class] testInstance];

  XCTAssertEqualObjects(request.responseType, kTestResponseType);
  XCTAssertEqualObjects(request.scope, kTestScopesMerged);
  XCTAssertEqualObjects(request.clientID, kTestClientID);
  XCTAssertEqualObjects(request.redirectURL, [NSURL URLWithString:kTestRedirectURL]);
  XCTAssertEqualObjects(request.state, kTestState);
  XCTAssertEqualObjects(request.codeVerifier, kTestCodeVerifier);
  XCTAssertEqualObjects(request.codeChallenge, [[self class] codeChallenge]);
  XCTAssertEqualObjects(request.codeChallengeMethod, [[self class] codeChallengeMethod]);
  XCTAssertEqualObjects(request.additionalParameters[kTestAdditionalParameterKey],
                        kTestAdditionalParameterValue);

  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
  OIDAuthorizationRequest *requestCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  // Not a full test of the configuration deserialization, but should be sufficient as a smoke test
  // to make sure the configuration IS actually getting serialized and deserialized in the
  // NSSecureCoding implementation. We'll leave it up to the OIDServiceConfiguration tests to make
  // sure the NSSecureCoding implementation of that class is correct.
  XCTAssertNotNil(requestCopy.configuration);
  XCTAssertEqualObjects(requestCopy.configuration.authorizationEndpoint,
                        request.configuration.authorizationEndpoint);

  XCTAssertEqualObjects(requestCopy.responseType, kTestResponseType);
  XCTAssertEqualObjects(requestCopy.scope, kTestScopesMerged);
  XCTAssertEqualObjects(requestCopy.clientID, kTestClientID);
  XCTAssertEqualObjects(requestCopy.redirectURL, [NSURL URLWithString:kTestRedirectURL]);
  XCTAssertEqualObjects(requestCopy.state, kTestState);
  XCTAssertEqualObjects(requestCopy.codeVerifier, kTestCodeVerifier);
  XCTAssertEqualObjects(requestCopy.codeChallenge, [[self class] codeChallenge]);
  XCTAssertEqualObjects(requestCopy.codeChallengeMethod, [[self class] codeChallengeMethod]);
  XCTAssertEqualObjects(requestCopy.additionalParameters[kTestAdditionalParameterKey],
                        kTestAdditionalParameterValue);
}

/*! @fn testDisallowedCharactersInScopes
    @brief Tests the scope string logic to make sure the disallowed characters are properly
        enforced.
 */
- (void)testDisallowedCharactersInScopes {
  NSURL *redirectURL = [NSURL URLWithString:kTestRedirectURL];
  OIDServiceConfiguration *configuration = [OIDServiceConfigurationTests testInstance];
  XCTAssertThrows(
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                      scopes:@[ kTestInvalidScope1 ]
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil]);
  XCTAssertThrows(
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                      scopes:@[ kTestInvalidScope2 ]
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil]);
  XCTAssertThrows(
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                      scopes:@[ kTestInvalidScope3 ]
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil]);
  XCTAssertThrows(
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                      scopes:@[ kTestInvalidScope4 ]
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil]);
  XCTAssertNoThrow(
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                      scopes:@[ kTestValidScope1 ]
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil]);
  XCTAssertNoThrow(
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                      scopes:@[ kTestValidScope2 ]
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil]);
  XCTAssertNoThrow(
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                      scopes:@[ kTestValidScope3 ]
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil]);
  XCTAssertNoThrow(
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                      scopes:@[ kTestValidScope4 ]
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil]);
  XCTAssertNoThrow(
      [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                    clientId:kTestClientID
                                                      scopes:@[ kTestValidScope5 ]
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:nil]);
}
/*! @fn legalPKCECharacters
    @brief Returns a character set with all legal PKCE characters for the codeVerifier.
    @return Character set representing all legal codeVerifier characters.
    @see https://tools.ietf.org/html/rfc7636#section-4.1
 */
+ (NSCharacterSet *)legalPKCECharacters {
  // per spec: [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~"
  NSMutableCharacterSet *legalChars = [[NSMutableCharacterSet alloc] init];
  [legalChars addCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
  [legalChars addCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
  [legalChars addCharactersInString:@"0123456789"];
  [legalChars addCharactersInString:@"-._~"];
  return legalChars;
}

/*! @fn testPKCEVerifierCompliance
    @brief Tests generated PKCE codeVerifiers for strict spec compliance.
    @see https://tools.ietf.org/html/rfc7636#section-4.1
 */
- (void)testPKCEVerifierCompliance {
  // as this test involves random numbers, repeats multiple times
  for (int i = 0; i < 1000; i++) {
    NSString *codeVerifier = [OIDAuthorizationRequest generateCodeVerifier];
    XCTAssertNotNil(codeVerifier);

    // tests that the code verifier is within the specified size bounds
    XCTAssertGreaterThanOrEqual(codeVerifier.length, kCodeVerifierMinLength);
    XCTAssertLessThanOrEqual(codeVerifier.length, kCodeVerifierMaxLength);

    // tests that the code verifier uses legal characters
    NSCharacterSet *legalChars = [[self class] legalPKCECharacters];
    NSCharacterSet *illegalChars = [legalChars invertedSet];
    NSArray *components = [codeVerifier componentsSeparatedByCharactersInSet:illegalChars];
    XCTAssertEqual(components.count, 1, @"codeVerifier contains illegal characters");
  }
}

/*! @fn testPKCEVerifierRecommendations
    @brief Tests generated PKCE codeVerifiers for adherence to spec RECOMMENDED requirements.
    @see https://tools.ietf.org/html/rfc7636#section-4.1
 */
- (void)testPKCEVerifierRecommendations {
  NSString *codeVerifier = [OIDAuthorizationRequest generateCodeVerifier];
  XCTAssertNotNil(codeVerifier);
  XCTAssertEqual(codeVerifier.length,
                 kCodeVerifierRecommendedLength,
                 @"The spec RECOMMENDS a '43-octet URL safe string'");
}

@end
