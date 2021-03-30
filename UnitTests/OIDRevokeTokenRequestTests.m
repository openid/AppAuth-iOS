//
//  OIDRevokeTokenRequestTests.m
//  AppAuth
//
//  Created by Thomas Carayol on 30/03/2021.
//  Copyright © 2021 OpenID Foundation. All rights reserved.
//

#import "OIDRevokeTokenRequestTests.h"

#import "OIDAuthorizationResponseTests.h"
#import "OIDServiceConfigurationTests.h"

#if SWIFT_PACKAGE
@import AppAuthCore;
#else
#import "Source/AppAuthCore/OIDAuthorizationRequest.h"
#import "Source/AppAuthCore/OIDAuthorizationResponse.h"
#import "Source/AppAuthCore/OIDServiceConfiguration.h"
#import "Source/AppAuthCore/OIDRevokeTokenRequest.h"
#endif

// Ignore warnings about "Use of GNU statement expression extension" which is raised by our use of
// the XCTAssert___ macros.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"

@implementation OIDRevokeTokenRequestTests

+ (OIDRevokeTokenRequest *)testInstance {
  OIDAuthorizationResponse *authResponse = [OIDAuthorizationResponseTests testInstance];
  OIDRevokeTokenRequest *request =
  [[OIDRevokeTokenRequest alloc] initWithConfiguration:authResponse.request.configuration
                                                 token:authResponse.accessToken
                                         tokenTypeHint:authResponse.tokenType
                                              clientID:authResponse.request.clientID
                                              clientSecret:authResponse.request.clientSecret];
  return request;
}

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
        process and checking to make sure the source and destination instances are equivalent.
 */
- (void)testCopying {
  OIDAuthorizationResponse *authResponse = [OIDAuthorizationResponseTests testInstance];
  OIDRevokeTokenRequest *request = [[self class] testInstance];

  XCTAssertEqualObjects(request.configuration.authorizationEndpoint,
                        authResponse.request.configuration.authorizationEndpoint,
                        @"Request and response authorization endpoints should be equal.");
  XCTAssertEqualObjects(request.token, authResponse.accessToken,
                        @"Request and response access token should be equal.");
  XCTAssertEqualObjects(request.tokenTypeHint, authResponse.tokenType,
                        @"Request and response token type should be equal.");
  XCTAssertEqualObjects(request.clientID, authResponse.request.clientID,
                        @"Request and response clientID should be equal.");
  XCTAssertEqualObjects(request.clientSecret, authResponse.request.clientSecret,
                        @"Request and response clientSecret should be equal.");

  OIDRevokeTokenRequest *requestCopy = [request copy];

  // Not a full test of the configuration deserialization, but should be sufficient as a smoke test
  // to make sure the configuration IS actually getting carried along in the copy implementation.
  XCTAssertEqualObjects(requestCopy.configuration.authorizationEndpoint,
                        request.configuration.authorizationEndpoint, @"");

  XCTAssertEqualObjects(requestCopy.token, request.token, @"");
  XCTAssertEqualObjects(requestCopy.tokenTypeHint, request.tokenTypeHint, @"");
  XCTAssertEqualObjects(request.clientID, request.clientID, @"");
  XCTAssertEqualObjects(request.clientSecret, request.clientSecret, @"");
}

/*! @brief Tests the @c NSSecureCoding by round-tripping an instance through the coding process and
        checking to make sure the source and destination instances are equivalent.
 */
- (void)testSecureCoding {
  OIDAuthorizationResponse *authResponse = [OIDAuthorizationResponseTests testInstance];
  OIDRevokeTokenRequest *request = [[self class] testInstance];

  XCTAssertEqualObjects(request.configuration.authorizationEndpoint,
                        authResponse.request.configuration.authorizationEndpoint,
                        @"Request and response authorization endpoints should be equal.");
  XCTAssertEqualObjects(request.token, authResponse.accessToken,
                        @"Request and response authorization codes should be equal.");
  XCTAssertEqualObjects(request.tokenTypeHint, authResponse.tokenType,
                        @"Request and response token type should be equal.");
  XCTAssertEqualObjects(request.clientID, authResponse.request.clientID,
                        @"Request and response clientID should be equal.");
  XCTAssertEqualObjects(request.clientSecret, authResponse.request.clientSecret,
                        @"Request and response clientSecret should be equal.");

  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
  OIDRevokeTokenRequest *requestCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  // Not a full test of the configuration deserialization, but should be sufficient as a smoke test
  // to make sure the configuration IS actually getting serialized and deserialized in the
  // NSSecureCoding implementation. We'll leave it up to the OIDServiceConfiguration tests to make
  // sure the NSSecureCoding implementation of that class is correct.
  XCTAssertEqualObjects(requestCopy.configuration.authorizationEndpoint,
                        request.configuration.authorizationEndpoint, @"");

  XCTAssertEqualObjects(requestCopy.token, request.token, @"");
  XCTAssertEqualObjects(requestCopy.tokenTypeHint, request.tokenTypeHint, @"");
  XCTAssertEqualObjects(requestCopy.clientID, request.clientID, @"");
  XCTAssertEqualObjects(requestCopy.clientSecret, request.clientSecret, @"");
}

- (void)testURLRequestBasicClientAuth {
  OIDRevokeTokenRequest *request = [[self class] testInstance];
  NSURLRequest* urlRequest = [request URLRequest];

  id authorization = [urlRequest.allHTTPHeaderFields objectForKey:@"Authorization"];
  XCTAssertNotNil(authorization);
}

- (void)testURLRequestBody {
  OIDRevokeTokenRequest *request = [[self class] testInstance];
  NSURLRequest* urlRequest = [request URLRequest];
  XCTAssertNotNil(urlRequest.HTTPBody);
}

@end

#pragma GCC diagnostic pop
