#import "OIDLogoutRequestTests.h"

#import "OIDServiceDiscoveryTests.h"
#import "Source/OIDLogoutRequest.h"
#import "Source/OIDServiceConfiguration.h"
#import "Source/OIDServiceDiscovery.h"

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

@implementation OIDLogoutRequestTests

+ (OIDLogoutRequest *)testInstance {
    NSDictionary *additionalParameters =
        @{ kTestAdditionalParameterKey : kTestAdditionalParameterValue };

    OIDServiceDiscovery *discoveryDocument = [[OIDServiceDiscovery alloc] initWithDictionary:[OIDServiceDiscoveryTests completeServiceDiscoveryDictionary] error:nil];
    OIDServiceConfiguration *configuration = [[OIDServiceConfiguration alloc] initWithDiscoveryDocument:discoveryDocument];

    return [[OIDLogoutRequest alloc] initWithConfiguration:configuration
                                               idTokenHint:kTestIdTokenHint
                                     postLogoutRedirectURL:[NSURL URLWithString:kTestRedirectURL]
                                                     state:kTestState
                                      additionalParameters:additionalParameters];
}

/*! @brief Tests the @c NSCopying implementation by round-tripping an instance through the copying
 process and checking to make sure the source and destination instances are equivalent.
 */
- (void)testCopying {
    OIDLogoutRequest *request = [[self class] testInstance];

    XCTAssertEqualObjects(request.idTokenHint, kTestIdTokenHint);
    XCTAssertEqualObjects(request.postLogoutRedirectURL, [NSURL URLWithString:kTestRedirectURL]);
    XCTAssertEqualObjects(request.state, kTestState);
    XCTAssertEqualObjects(request.additionalParameters[kTestAdditionalParameterKey],
                          kTestAdditionalParameterValue);

    OIDLogoutRequest *requestCopy = [request copy];

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
    OIDLogoutRequest *request = [[self class] testInstance];

    XCTAssertEqualObjects(request.idTokenHint, kTestIdTokenHint);
    XCTAssertEqualObjects(request.postLogoutRedirectURL, [NSURL URLWithString:kTestRedirectURL]);
    XCTAssertEqualObjects(request.state, kTestState);
    XCTAssertEqualObjects(request.additionalParameters[kTestAdditionalParameterKey],
                          kTestAdditionalParameterValue);

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
    OIDLogoutRequest *requestCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    XCTAssertNotNil(requestCopy.configuration);
    XCTAssertEqualObjects(requestCopy.configuration.authorizationEndpoint,
                          request.configuration.authorizationEndpoint);
    XCTAssertEqualObjects(requestCopy.postLogoutRedirectURL, request.postLogoutRedirectURL);
    XCTAssertEqualObjects(requestCopy.state, request.state);
    XCTAssertEqualObjects(requestCopy.idTokenHint, request.idTokenHint);
}

- (void)testLogoutRequestURL {
    OIDLogoutRequest *request = [[self class] testInstance];
    NSURL *logoutRequestURL = request.logoutRequestURL;

    NSURLComponents *components = [NSURLComponents componentsWithString:logoutRequestURL.absoluteString];

    XCTAssertTrue([logoutRequestURL.absoluteString hasPrefix:@"https://www.example.com/logout"]);

    NSMutableDictionary<NSString *, NSString*> *query = [[NSMutableDictionary alloc] init];
    for (NSURLQueryItem *queryItem in components.queryItems) {
        query[queryItem.name] = queryItem.value;
    }

    XCTAssertEqualObjects(query[@"state"], kTestState);
    XCTAssertEqualObjects(query[@"id_token_hint"], kTestIdTokenHint);
    XCTAssertEqualObjects(query[@"post_logout_redirect_uri"], kTestRedirectURL);
}

@end
