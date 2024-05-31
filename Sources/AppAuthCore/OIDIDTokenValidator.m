//
//  OIDIDTokenVerificator.m
//  
//
//  Created by Andras Kadar on 4/11/22.
//

#import "OIDIDTokenValidator.h"

#import "OIDAuthorizationRequest.h"
#import "OIDAuthorizationResponse.h"
#import "OIDErrorUtilities.h"
#import "OIDIDToken.h"
#import "OIDServiceConfiguration.h"
#import "OIDTokenRequest.h"
#import "OIDTokenResponse.h"

/*! @brief Max allowable iat (Issued At) time skew
 @see https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
 */
static int const kOIDAuthorizationSessionIATMaxSkew = 600;

@implementation OIDIDTokenValidator

- (NSError *)validateIDTokenFromTokenResponse:(OIDTokenResponse *)tokenResponse
                        authorizationResponse:(OIDAuthorizationResponse *)authorizationResponse {
    return [self validateIDToken:[[OIDIDToken alloc] initWithIDTokenString:tokenResponse.idToken]
                          issuer:tokenResponse.request.configuration.issuer
                        clientID:tokenResponse.request.clientID
                       grantType:tokenResponse.request.grantType
                           nonce:authorizationResponse.request.nonce];
}

- (NSError *)validateIDToken:(OIDIDToken *)idToken
                      issuer:(NSURL *)issuer
                    clientID:(NSString *)clientID
                   grantType:(NSString *)grantType
                       nonce:(NSString *)nonce {
    if (!idToken) {
        return [OIDErrorUtilities errorWithCode:OIDErrorCodeIDTokenParsingError
                                underlyingError:nil
                                    description:@"ID Token parsing failed"];
    }

    // OpenID Connect Core Section 3.1.3.7. rule #1
    // Not supported: AppAuth does not support JWT encryption.

    // OpenID Connect Core Section 3.1.3.7. rule #2
    // Validates that the issuer in the ID Token matches that of the discovery document.
    if (issuer && ![idToken.issuer isEqual:issuer]) {
        return [OIDErrorUtilities errorWithCode:OIDErrorCodeIDTokenFailedValidationError
                                underlyingError:nil
                                    description:@"Issuer mismatch"];
    }

    // OpenID Connect Core Section 3.1.3.7. rule #3 & Section 2 azp Claim
    // Validates that the aud (audience) Claim contains the client ID, or that the azp
    // (authorized party) Claim matches the client ID.
    if (![idToken.audience containsObject:clientID] &&
        ![idToken.claims[@"azp"] isEqualToString:clientID]) {
        return [OIDErrorUtilities errorWithCode:OIDErrorCodeIDTokenFailedValidationError
                                underlyingError:nil
                                    description:@"Audience mismatch"];
    }

    // OpenID Connect Core Section 3.1.3.7. rules #4 & #5
    // Not supported.

    // OpenID Connect Core Section 3.1.3.7. rule #6
    // As noted above, AppAuth only supports the code flow which results in direct communication
    // of the ID Token from the Token Endpoint to the Client, and we are exercising the option to
    // use TSL server validation instead of checking the token signature. Users may additionally
    // check the token signature should they wish.

    // OpenID Connect Core Section 3.1.3.7. rules #7 & #8
    // Not applicable. See rule #6.

    // OpenID Connect Core Section 3.1.3.7. rule #9
    // Validates that the current time is before the expiry time.
    NSTimeInterval expiresAtDifference = [idToken.expiresAt timeIntervalSinceNow];
    if (expiresAtDifference < 0) {
        return [OIDErrorUtilities errorWithCode:OIDErrorCodeIDTokenFailedValidationError
                                underlyingError:nil
                                    description:@"ID Token expired"];
    }

    // OpenID Connect Core Section 3.1.3.7. rule #10
    // Validates that the issued at time is not more than +/- 10 minutes on the current time.
    NSTimeInterval issuedAtDifference = [idToken.issuedAt timeIntervalSinceNow];
    if (fabs(issuedAtDifference) > kOIDAuthorizationSessionIATMaxSkew) {
        NSString *message =
        [NSString stringWithFormat:@"Issued at time is more than %d seconds before or after "
         "the current time",
         kOIDAuthorizationSessionIATMaxSkew];
        return [OIDErrorUtilities errorWithCode:OIDErrorCodeIDTokenFailedValidationError
                                underlyingError:nil
                                    description:message];
    }

    // Only relevant for the authorization_code response type
    if ([grantType isEqual:OIDGrantTypeAuthorizationCode]) {
        // OpenID Connect Core Section 3.1.3.7. rule #11
        // Validates the nonce.
        if (nonce && ![idToken.nonce isEqual:nonce]) {
            return [OIDErrorUtilities errorWithCode:OIDErrorCodeIDTokenFailedValidationError
                                    underlyingError:nil
                                        description:@"Nonce mismatch"];
        }
    }

    // OpenID Connect Core Section 3.1.3.7. rules #12
    // ACR is not directly supported by AppAuth.

    // OpenID Connect Core Section 3.1.3.7. rules #12
    // max_age is not directly supported by AppAuth.
    return nil;
}

@end
