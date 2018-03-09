/*! @file OIDEndSessionFlowSession.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2018 The AppAuth Authors. All Rights Reserved.
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

#import "OIDEndSessionFlowSession.h"

#import "OIDEndSessionRequest.h"
#import "OIDExternalUserAgent.h"
#import "OIDErrorUtilities.h"
#import "OIDDefines.h"
#import "OIDURLQueryComponent.h"
#import "OIDEndSessionResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface OIDEndSessionFlowSession() {
    // private variables
    OIDEndSessionRequest *_request;
    id<OIDExternalUserAgent> _externalUserAgent;
    OIDEndSessionCallback _pendingEndSessionFlowCallback;
}
@end

@implementation OIDEndSessionFlowSession

- (instancetype)initWithRequest:(OIDEndSessionRequest *)request {
    self = [super init];
    if (self) {
        _request = [request copy];
    }
    return self;
}

- (void)presentEndSessionWithExternalUserAgent:(id<OIDExternalUserAgent>)externalUserAgent
                                   callback:(OIDEndSessionCallback)endSessionFlowCallback {
    _externalUserAgent = externalUserAgent;
    _pendingEndSessionFlowCallback = endSessionFlowCallback;
    BOOL authorizationFlowStarted =
            [_externalUserAgent presentExternalUserAgentRequest:_request session:self];
    if (!authorizationFlowStarted) {
        NSError *safariError = [OIDErrorUtilities errorWithCode:OIDErrorCodeSafariOpenError
                                                underlyingError:nil
                                                    description:@"Unable to open Safari."];
        [self didFinishWithResponse:nil error:safariError];
    }
}

- (void)cancel {
    [_externalUserAgent dismissExternalUserAgentAnimated:YES completion:^{
        NSError *error = [OIDErrorUtilities
                errorWithCode:OIDErrorCodeUserCanceledAuthorizationFlow
              underlyingError:nil
                  description:nil];
        [self didFinishWithResponse:nil error:error];
    }];
}

- (BOOL)shouldHandleURL:(NSURL *)URL {
    NSURL *standardizedURL = [URL standardizedURL];
    NSURL *standardizedRedirectURL = [_request.postLogoutRedirectURL standardizedURL];

    return OIDIsEqualIncludingNil(standardizedURL.scheme, standardizedRedirectURL.scheme) &&
            OIDIsEqualIncludingNil(standardizedURL.user, standardizedRedirectURL.user) &&
            OIDIsEqualIncludingNil(standardizedURL.password, standardizedRedirectURL.password) &&
            OIDIsEqualIncludingNil(standardizedURL.host, standardizedRedirectURL.host) &&
            OIDIsEqualIncludingNil(standardizedURL.port, standardizedRedirectURL.port) &&
            OIDIsEqualIncludingNil(standardizedURL.path, standardizedRedirectURL.path);
}

- (BOOL)resumeExternalUserAgentFlowWithURL:(NSURL *)URL {
    // rejects URLs that don't match redirect (these may be completely unrelated to the authorization)
    if (![self shouldHandleURL:URL]) {
        return NO;
    }
    // checks for an invalid state
    if (!_pendingEndSessionFlowCallback) {
        [NSException raise:OIDOAuthExceptionInvalidAuthorizationFlow
                    format:@"%@", OIDOAuthExceptionInvalidAuthorizationFlow, nil];
    }

    OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] initWithURL:URL];

    NSError *error;
    OIDEndSessionResponse *response = nil;

    // checks for an OAuth error response as per RFC6749 Section 4.1.2.1
    if (query.dictionaryValue[OIDOAuthErrorFieldError]) {
        error = [OIDErrorUtilities OAuthErrorWithDomain:OIDOAuthAuthorizationErrorDomain
                                          OAuthResponse:query.dictionaryValue
                                        underlyingError:nil];
    }

    // no error, should be a valid OAuth 2.0 response
    if (!error) {
        response = [[OIDEndSessionResponse alloc] initWithRequest:_request
                                                          parameters:query.dictionaryValue];

        // verifies that the state in the response matches the state in the request, or both are nil
        if (!OIDIsEqualIncludingNil(_request.state, response.state)) {
            NSMutableDictionary *userInfo = [query.dictionaryValue mutableCopy];
            userInfo[NSLocalizedDescriptionKey] =
                    [NSString stringWithFormat:@"State mismatch, expecting %@ but got %@ in authorization "
                                                       "response %@",
                                               _request.state,
                                               response.state,
                                               response];
            response = nil;
            error = [NSError errorWithDomain:OIDOAuthAuthorizationErrorDomain
                                        code:OIDErrorCodeOAuthAuthorizationClientError
                                    userInfo:userInfo];
        }
    }

    [_externalUserAgent dismissExternalUserAgentAnimated:YES completion:^{
        [self didFinishWithResponse:response error:error];
    }];

    return YES;
}

- (void)failExternalUserAgentFlowWithError:(NSError *)error {
    [self didFinishWithResponse:nil error:error];
}

/*! @brief Invokes the pending callback and performs cleanup.
    @param response The authorization response, if any to return to the callback.
    @param error The error, if any, to return to the callback.
 */
- (void)didFinishWithResponse:(nullable OIDEndSessionResponse *)response
                        error:(nullable NSError *)error {
    OIDEndSessionCallback callback = _pendingEndSessionFlowCallback;
    _pendingEndSessionFlowCallback = nil;
    _externalUserAgent = nil;
    if (callback) {
        callback(response, error);
    }
}

- (void)failAuthorizationFlowWithError:(NSError *)error {
    [self failExternalUserAgentFlowWithError:error];
}

- (BOOL)resumeAuthorizationFlowWithURL:(NSURL *)URL {
    return [self resumeExternalUserAgentFlowWithURL:URL];
}

@end

NS_ASSUME_NONNULL_END
