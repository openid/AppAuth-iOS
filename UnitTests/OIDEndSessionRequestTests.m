/*! @file OIDServiceDiscoveryTests.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2017 The AppAuth Authors. All Rights Reserved.
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

#import "OIDEndSessionRequestTests.h"

#import "OIDServiceDiscoveryTests.h"

#if SWIFT_PACKAGE
@import AppAuthCore;
#else
#import "Sources/AppAuthCore/OIDEndSessionRequest.h"
#import "Sources/AppAuthCore/OIDServiceConfiguration.h"
#import "Sources/AppAuthCore/OIDServiceDiscovery.h"
#endif

/*! @brief Test value for the @c redirectURL property.
 */
static NSString *const kTestRedirectURL = @"http://www.google.com/";

/*! @brief Test key for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterKey = @"A";

/*! @brief Test value for the @c additionalParameters property.
 */
static NSString *const kTestAdditionalParameterValue = @"1";

/*! @brief Test value for the @c state property.
 */
static NSString *const kTestState = @"State";

/*! @brief Test value for the @c idTokenHint property.
 */
static NSString *const kTestIdTokenHint = @"id-token-hint";

@implementation OIDEndSessionRequestTests

+ (OIDEndSessionRequest *)testInstance {
    NSDictionary *additionalParameters =
        @{ kTestAdditionalParameterKey : kTestAdditionalParameterValue };

    OIDServiceDiscovery *discoveryDocument = [[OIDServiceDiscovery alloc] initWithDictionary:[OIDServiceDiscoveryTests completeServiceDiscoveryDictionary] error:nil];
    OIDServiceConfiguration *configuration = [[OIDServiceConfiguration alloc] initWithDiscoveryDocument:discoveryDocument];

    return [[OIDEndSessionRequest alloc] initWithConfiguration:configuration
                                               idTokenHint:kTestIdTokenHint
                                     postLogoutRedirectURL:[NSURL URLWithString:kTestRedirectURL]
                                                     state:kTestState
                                      additionalParameters:additionalParameters];
}

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
 process and checking to make sure the source and destination instances are equivalent.
 */
- (void)testCopying {
    OIDEndSessionRequest *request = [[self class] testInstance];

    XCTAssertEqualObjects(request.idTokenHint, kTestIdTokenHint);
    XCTAssertEqualObjects(request.postLogoutRedirectURL, [NSURL URLWithString:kTestRedirectURL]);
    XCTAssertEqualObjects(request.state, kTestState);
    XCTAssertEqualObjects(request.additionalParameters[kTestAdditionalParameterKey],
                          kTestAdditionalParameterValue);

    OIDEndSessionRequest *requestCopy = [request copy];

    XCTAssertNotNil(requestCopy.configuration);
    XCTAssertEqualObjects(requestCopy.configuration, request.configuration);
    XCTAssertEqualObjects(requestCopy.postLogoutRedirectURL, request.postLogoutRedirectURL);
    XCTAssertEqualObjects(requestCopy.state, request.state);
    XCTAssertEqualObjects(requestCopy.idTokenHint, request.idTokenHint);
}

/*! @brief Tests the @c NSSecureCoding by round-tripping an instance through the coding process and
 checking to make sure the source and destination instances are equivalent.
 */
- (void)testSecureCoding {
    OIDEndSessionRequest *request = [[self class] testInstance];

    XCTAssertEqualObjects(request.idTokenHint, kTestIdTokenHint);
    XCTAssertEqualObjects(request.postLogoutRedirectURL, [NSURL URLWithString:kTestRedirectURL]);
    XCTAssertEqualObjects(request.state, kTestState);
    XCTAssertEqualObjects(request.additionalParameters[kTestAdditionalParameterKey],
                          kTestAdditionalParameterValue);

    OIDEndSessionRequest *requestCopy;
    NSError *error;
    NSData *data;
    if (@available(iOS 12.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *)) {
      data = [NSKeyedArchiver archivedDataWithRootObject:request
                                   requiringSecureCoding:YES
                                                   error:&error];
      requestCopy = [NSKeyedUnarchiver unarchivedObjectOfClass:[OIDEndSessionRequest class]
                                                      fromData:data
                                                         error:&error];
    } else {
#if !TARGET_OS_IOS
      data = [NSKeyedArchiver archivedDataWithRootObject:request];
      requestCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
#endif
    }

    XCTAssertNotNil(requestCopy.configuration);
    XCTAssertEqualObjects(requestCopy.configuration.authorizationEndpoint,
                          request.configuration.authorizationEndpoint);
    XCTAssertEqualObjects(requestCopy.postLogoutRedirectURL, request.postLogoutRedirectURL);
    XCTAssertEqualObjects(requestCopy.state, request.state);
    XCTAssertEqualObjects(requestCopy.idTokenHint, request.idTokenHint);
}

- (void)testLogoutRequestURL {
    OIDEndSessionRequest *request = [[self class] testInstance];
    NSURL *endSessionRequestURL = request.endSessionRequestURL;

    NSURLComponents *components = [NSURLComponents componentsWithString:endSessionRequestURL.absoluteString];

    XCTAssertTrue([endSessionRequestURL.absoluteString hasPrefix:@"https://www.example.com/logout"]);

    NSMutableDictionary<NSString *, NSString*> *query = [[NSMutableDictionary alloc] init];
    for (NSURLQueryItem *queryItem in components.queryItems) {
        query[queryItem.name] = queryItem.value;
    }

    XCTAssertEqualObjects(query[@"state"], kTestState);
    XCTAssertEqualObjects(query[@"id_token_hint"], kTestIdTokenHint);
    XCTAssertEqualObjects(query[@"post_logout_redirect_uri"], kTestRedirectURL);
}

@end
