//
//  OIDIDTokenVerificator.h
//  
//
//  Created by Andras Kadar on 4/11/22.
//

#import <Foundation/Foundation.h>

@class OIDAuthorizationResponse;
@class OIDIDToken;
@class OIDTokenResponse;

@interface OIDIDTokenValidator : NSObject

/// Convenience accessor to the validation. For details please refer to the `validateIDToken:issuer:clientID:grantType:nonce:` method.
- (NSError *)validateIDTokenFromTokenResponse:(OIDTokenResponse *)tokenResponse
                        authorizationResponse:(OIDAuthorizationResponse *)authorizationResponse;

/// If an ID Token is available, validates the ID Token following the rules
/// in OpenID Connect Core Section 3.1.3.7 for features that AppAuth directly supports
/// (which excludes rules #1, #4, #5, #7, #8, #12, and #13). Regarding rule #6, ID Tokens
/// received by this class are received via direct communication between the Client and the Token
/// Endpoint, thus we are exercising the option to rely only on the TLS validation. AppAuth
/// has a zero dependencies policy, and verifying the JWT signature would add a dependency.
/// Users of the library are welcome to perform the JWT signature verification themselves should
/// they wish.
///
/// \return `nil` if the token is valid, a validation error with details if the validation failed
- (NSError *)validateIDToken:(OIDIDToken *)idToken
                      issuer:(NSURL *)issuer
                    clientID:(NSString *)clientID
                   grantType:(NSString *)grantType
                       nonce:(NSString *)nonce;

@end
