//
//  TokenViewController.m
//  Example-iOS_ObjC
//
//  Created by Michael Moore on 10/5/22.
//  Copyright © 2022 William Denniss. All rights reserved.
//

#import "TokenViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AppAuth.h"
#import "AppDelegate.h"
#import "LogoutOption.h"
#import "LogoutOptionsController.h"

typedef void (^PostRegistrationCallback)(OIDServiceConfiguration *configuration,
                                         OIDRegistrationResponse *registrationResponse);

typedef void (^completionHandler)(BOOL completed, NSError* _Nullable error);


/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
static NSString *const kIssuer = @"https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/login";

/*! @brief The OAuth client ID.
 @discussion For client configuration instructions, see the README.
 Set to nil to use dynamic registration with this example.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSString *const kClientID = @"cec9a504-a0ab-4b92-879b-711482a3f69b";

/*! @brief The OAuth redirect URI for the client @c kRedirectURI.
 @discussion For client configuration instructions, see the README.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSString *const kRedirectURI = @"net.openid.appauthdemo://oauth2redirect";

/*! @brief The OAuth logout URI for the client @c kLogoutURI.
 @discussion For client configuration instructions, see the README.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSString *const kLogoutURI = @"https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/auth-ui/logout";

/*! @brief The OAuth redirect URI for the client @c kClientID.
 @discussion For client configuration instructions, see the README.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSString *const kProfileURI = @"https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/auth-ui/profile";

/*! @brief The OAuth token revocation URI for the client @c kClientID.
 @discussion For client configuration instructions, see the README.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSString* const kRevokeTokenURI = @"https://api.multi.dev.or.janrain.com/00000000-0000-0000-0000-000000000000/login/token/revoke";

/*! @brief The OAuth specification for prompt @c kPrompt.
 @discussion For client configuration instructions, see the README.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSString *const kPrompt = nil;

/*! @brief The OAuth specification for claims @c kClaims.
 @discussion For client configuration instructions, see the README.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSString *const kClaims = nil;

/*! @brief The OAuth specification for ACR Values @c kAcrValues.
 @discussion For client configuration instructions, see the README.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSString *const kAcrValues = @"urn:akamai-ic:nist:800-63-3:aal:1";

/*! @brief The OAuth specification for scope @c kScopes.
 These are set in @c setupAdditionalParams()
 @discussion For client configuration instructions, see the README.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSArray<NSString *> *kScopes;

/*! @brief The additional paramaters configuration @c kAddParams
 These are set in @c setAdditionalParams()
 @discussion For client configuration instructions, see the README.
 @see https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md
 */
static NSDictionary<NSString *, NSString *> *kAddParams;

/*! @brief The array of options selected for logout @c OIDLogoutOptions
 These are selected by the user in @c logout()
 */
static NSArray<LogoutOption>* kLogoutOptions;

/*! @brief NSCoding key for the authState property.
 */
static NSString* const kAppAuthExampleAuthStateKey = @"authState";

@interface TokenViewController () <OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate, UITextViewDelegate>
@end

@implementation TokenViewController

static BOOL isAccessTokenRevoked = FALSE;
static BOOL isRefreshTokenRevoked = FALSE;
static BOOL isBrowserSessionRevoked = FALSE;

- (void)viewDidLoad {
    [super viewDidLoad];

    _logTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    _logTextView.layer.borderWidth = 1.0f;
    _logTextView.alwaysBounceVertical = TRUE;
    _logTextView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    _logTextView.text = @"";

    _accessTokenTextView.delegate = self;
    _refreshTokenTextView.delegate = self;

    // set the array of logout options
    kLogoutOptions = @[
        LogoutOptionRevokeTokens,
        LogoutOptionEndBrowserSession,
        LogoutOptionEndAppSession
    ];

    [self loadState];
    [self updateUI];
}

- (void)verifyConfig {
#if !defined(NS_BLOCK_ASSERTIONS)

    // The example needs to be configured with your own client details.
    // See: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md

    NSAssert(![kIssuer isEqualToString:@"https://issuer.example.com"],
             @"Update kIssuer with your own issuer. "
             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md");

    NSAssert(![kClientID isEqualToString:@"YOUR_CLIENT_ID"],
             @"Update kClientID with your own client ID. "
             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md");

    NSAssert(![kRedirectURI isEqualToString:@"com.example.app:/oauth2redirect/example-provider"],
             @"Update kRedirectURI with your own redirect URI. "
             "Instructions: https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md");

    // verifies that the custom URI scheme has been updated in the Info.plist
    NSArray __unused* urlTypes =
    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    NSAssert([urlTypes count] > 0, @"No custom URI scheme has been configured for the project.");
    NSArray *urlSchemes =
    [(NSDictionary *)[urlTypes objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"];
    NSAssert([urlSchemes count] > 0, @"No custom URI scheme has been configured for the project.");
    NSString *urlScheme = [urlSchemes objectAtIndex:0];

    NSAssert(![urlScheme isEqualToString:@"com.example.app"],
             @"Configure the URI scheme in Info.plist (URL Types -> Item 0 -> URL Schemes -> Item 0) "
             "with the scheme of your redirect URI. Full instructions: "
             "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_ObjC/README.md");

#endif // !defined(NS_BLOCK_ASSERTIONS)
}

- (void)setAdditionalParams {
    // set the scope parameters
    kScopes = @[OIDScopeOpenID, OIDScopeProfile];

    [kAddParams setValue:kClaims forKey:@"claims"];
    [kAddParams setValue:kPrompt forKey:@"prompt"];
    [kAddParams setValue:kAcrValues forKey:@"acr_values"];
}

/*! @brief Saves the @c OIDAuthState to @c NSUSerDefaults.
 */
- (void)saveState {
    // for production usage consider using the OS Keychain instead
    NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.net.openid.appauth.Example"];
    NSData *archivedAuthState = [NSKeyedArchiver archivedDataWithRootObject:_authState];
    [userDefaults setObject:archivedAuthState
                     forKey:kAppAuthExampleAuthStateKey];
    [userDefaults synchronize];
}

/*! @brief Loads the @c OIDAuthState from @c NSUSerDefaults.
 */
- (void)loadState {
    // loads OIDAuthState from NSUSerDefaults
    NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.net.openid.appauth.Example"];
    NSData *archivedAuthState = [userDefaults objectForKey:kAppAuthExampleAuthStateKey];
    OIDAuthState *authState = [NSKeyedUnarchiver unarchiveObjectWithData:archivedAuthState];
    [self setAuthState:authState];
}

- (void)setAuthState:(nullable OIDAuthState *)authState {
    if (_authState == authState) {
        return;
    }
    _authState = authState;
    _authState.stateChangeDelegate = self;
    [self stateChanged];
}

/*! @brief Refreshes UI, typically called after the auth state changed.
 */
- (void)updateUI {

    [UIView animateWithDuration:0.3 animations:^{
        if (self.authState.lastTokenResponse.accessToken) {
            [self.accessTokenStackView setHidden:FALSE];
            [self.accessTokenTextView setText:self.authState.lastTokenResponse.accessToken];

            if (isAccessTokenRevoked) {
                [self.accessTokenTitleLabel setText:@"Access Token Revoked:"];
            } else {
                [self.accessTokenTitleLabel setText:@"Access Token:"];
            }
        } else {
            [self.accessTokenStackView setHidden:TRUE];
        }

        if (self.authState.lastTokenResponse.refreshToken) {
            [self.refreshTokenStackView setHidden:FALSE];
            [self.refreshTokenTextView setText:self.authState.lastTokenResponse.refreshToken];

            if (isRefreshTokenRevoked) {
                [self.refreshTokenTitleLabel setText:@"Refresh Token Revoked:"];
            } else {
                [self.refreshTokenTitleLabel setText:@"Refresh Token:"];
            }
        } else {
            [self.refreshTokenStackView setHidden:TRUE];
        }

        [self.tokenStackView setHidden:isRefreshTokenRevoked || isAccessTokenRevoked];
        [self.codeExchangeButton setHidden:self.authState.lastTokenResponse || isRefreshTokenRevoked || isAccessTokenRevoked];
        [self.refreshTokenButton setHidden:!self.authState.lastTokenResponse || isRefreshTokenRevoked || isAccessTokenRevoked];
        [self.userinfoButton setHidden:!self.authState.lastTokenResponse || isRefreshTokenRevoked || isAccessTokenRevoked];
        [self.profileButton setHidden:(!self.authState.isAuthorized || isBrowserSessionRevoked)];
    }];
}

- (void)stateChanged {
    [self saveState];
    [self updateUI];
}

- (void)didChangeState:(OIDAuthState *)state {
    [self stateChanged];
}

- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(nonnull NSError *)error {
    [self logMessage:@"Received authorization error: %@", error];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)doClientRegistration:(OIDServiceConfiguration *)configuration
        additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters
                    callback:(PostRegistrationCallback)callback {
    NSURL* redirectURI = [NSURL URLWithString:kRedirectURI];

    OIDRegistrationRequest* request =
    [[OIDRegistrationRequest alloc]
     initWithConfiguration:configuration
     redirectURIs:@[ redirectURI ]
     responseTypes:nil
     grantTypes:nil
     subjectType:nil
     tokenEndpointAuthMethod:@"client_secret_post"
     additionalParameters:additionalParameters];

    // performs registration request
    [self logMessage:@"Initiating registration request"];

    [OIDAuthorizationService performRegistrationRequest:request
                                             completion:^(OIDRegistrationResponse *_Nullable regResp, NSError *_Nullable error) {
        if (regResp) {
            [self setAuthState:[[OIDAuthState alloc] initWithRegistrationResponse:regResp]];
            [self logMessage:@"Got registration response: [%@]", regResp];
            callback(configuration, regResp);
        } else {
            [self logMessage:@"Registration error: %@", [error localizedDescription]];
            [self setAuthState:nil];
        }
    }];
}

- (void)checkBrowserSession:(OIDServiceConfiguration*)configuration
                   clientID:(NSString*)clientID
               clientSecret:(NSString*)clientSecret
       additionalParameters:
(nullable NSDictionary<NSString*, NSString*>*)
additionalParameters {
    NSURL* redirectURI = [NSURL URLWithString:kRedirectURI];

    // builds authentication request
    OIDAuthorizationRequest* request =
    [[OIDAuthorizationRequest alloc]
     initWithConfiguration:configuration
     clientId:clientID
     clientSecret:clientSecret
     scopes:kScopes
     redirectURL:redirectURI
     responseType:OIDResponseTypeCode
     additionalParameters:additionalParameters];

    // performs authentication request
    AppDelegate* appDelegate =
    (AppDelegate*)[UIApplication sharedApplication].delegate;

    [self logMessage:@"Initiating authorization request with scope: %@",
     request.scope];
    [self logMessage:
     @"Initiating authorization request with additional params of : %@",
     request.additionalParameters];

    appDelegate.currentAuthorizationFlow =
    [OIDAuthState
     authStateByPresentingAuthorizationRequest:request
     presentingViewController:self
     callback:^(
                OIDAuthState* _Nullable authState,
                NSError* _Nullable error) {
                    if (authState) {
                        isBrowserSessionRevoked = FALSE;
                        isAccessTokenRevoked = FALSE;
                        isRefreshTokenRevoked = FALSE;

                        [self setAuthState:authState];
                        [self logMessage:@"Got authorization tokens. Access token: %@",
                         authState.lastTokenResponse.accessToken];
                    } else {
                        [self logMessage:@"Authorization error: %@",
                         [error localizedDescription]];
                    }
                }];
}

- (void)loadProfile:(OIDServiceConfiguration*)configuration
           clientID:(NSString*)clientID
       clientSecret:(NSString*)clientSecret
additionalParameters:
(nullable NSDictionary<NSString*, NSString*>*)additionalParameters {
    NSURL* redirectURI = [NSURL URLWithString:kRedirectURI];
    NSURL* profileURI = [NSURL URLWithString:kProfileURI];

    // creates profile management configuration
    OIDServiceConfiguration* profileConfig =
    [[OIDServiceConfiguration alloc]
     initWithAuthorizationEndpoint:profileURI
     tokenEndpoint:configuration.tokenEndpoint
     issuer:configuration.issuer
     registrationEndpoint:configuration.registrationEndpoint
     endSessionEndpoint:configuration.endSessionEndpoint];

    // builds authentication request
    OIDAuthorizationRequest* request =
    [[OIDAuthorizationRequest alloc]
     initWithConfiguration:profileConfig
     clientId:clientID
     clientSecret:clientSecret
     scopes:kScopes
     redirectURL:redirectURI
     responseType:OIDResponseTypeCode
     additionalParameters:additionalParameters];

    // performs authentication request
    AppDelegate* appDelegate =
    (AppDelegate*)[UIApplication sharedApplication].delegate;

    [self logMessage:@"Initiating profile management request with scope: %@",
     request.scope];
    [self logMessage:
     @"Initiating profile management request with additional params of "
     @": %@",
     request.additionalParameters];

    appDelegate.currentAuthorizationFlow =
    [OIDAuthorizationService
     presentAuthorizationRequest:request
     externalUserAgent:[[OIDExternalUserAgentIOS alloc]
                        initWithPresentingViewController:self]
     callback:^(
                OIDAuthorizationResponse* _Nullable authResponse,
                NSError* _Nullable error) {
                    if (error) {
                        [self logMessage:@"Profile management error: %@",
                         [error localizedDescription]];
                        [self logMessage:@"error domain: %@", error.domain];
                    } else {
                        [self logMessage:@"Profile management response: %@",
                         authResponse.description];
                    }
                }];
}

- (void)endBrowserSession:(OIDServiceConfiguration*)configuration
                 clientID:(NSString*)clientID
             clientSecret:(NSString*)clientSecret
        completionHandler:(nullable completionHandler)completion {
    NSURL* redirectURI = [NSURL URLWithString:kRedirectURI];
    NSURL* logoutURI = [NSURL URLWithString:kLogoutURI];

    NSDictionary* clientIdParam = @{@"client_id" : clientID};

    // creates end browser session  configuration
    OIDServiceConfiguration* logoutConfig =
    [[OIDServiceConfiguration alloc]
     initWithAuthorizationEndpoint:configuration.authorizationEndpoint
     tokenEndpoint:configuration.tokenEndpoint
     issuer:configuration.issuer
     registrationEndpoint:configuration.registrationEndpoint
     endSessionEndpoint:logoutURI];

    [self logMessage:@"Logout configuration: %@", logoutConfig];

    // build end browsser session request
    OIDEndSessionRequest* request = [[OIDEndSessionRequest alloc]
                                     initWithConfiguration:logoutConfig
                                     idTokenHint:_authState.lastTokenResponse.idToken
                                     postLogoutRedirectURL:redirectURI
                                     additionalParameters:clientIdParam];

    [self logMessage:@"Logout request: %@", request];
    // performs logout request
    AppDelegate* appDelegate =
    (AppDelegate*)[UIApplication sharedApplication].delegate;

    dispatch_async(dispatch_get_main_queue(), ^{
        appDelegate.currentAuthorizationFlow =
        [OIDAuthorizationService
         presentEndSessionRequest:request
         externalUserAgent:[[OIDExternalUserAgentIOS alloc]
                            initWithPresentingViewController:self]
         callback:^(
                    OIDEndSessionResponse* _Nullable
                    endSessionResponse,
                    NSError* _Nullable error) {
                        if (error) {
                            [self logMessage:@"Logout error: %@",
                             [error localizedDescription]];
                            completion(TRUE, error);
                            [self logMessage:@"error domain: %@", error.domain];
                        } else {
                            [self logMessage:@"Logout response: %@",
                             endSessionResponse.description];
                            completion(TRUE, nil);
                        }
                    }];
    });
}

- (IBAction)authWithAutoCodeExchange:(nullable id)sender {
    [self verifyConfig];
    [self setAdditionalParams];

    NSURL* issuer = [NSURL URLWithString:kIssuer];

    [self logMessage:@"Fetching configuration for issuer: %@", issuer];

    // discovers endpoints
    [OIDAuthorizationService
     discoverServiceConfigurationForIssuer:issuer
     completion:^(
                  OIDServiceConfiguration* _Nullable configuration,
                  NSError* _Nullable error) {
                      if (!configuration) {
                          [self logMessage:
                           @"Error retrieving discovery "
                           @"document: %@",
                           [error localizedDescription]];
                          [self setAuthState:nil];
                          return;
                      }

                      [self logMessage:@"Got configuration: %@", configuration];

                      if (!kClientID) {
                          [self
                           doClientRegistration:configuration
                           additionalParameters:kAddParams
                           callback:^(
                                      OIDServiceConfiguration*
                                      configuration,
                                      OIDRegistrationResponse*
                                      registrationResponse) {
                                          [self checkBrowserSession:configuration
                                                           clientID:registrationResponse.clientID
                                                       clientSecret:registrationResponse.clientSecret
                                               additionalParameters:kAddParams];
                                      }];
                      } else {
                          [self
                           checkBrowserSession:configuration
                           clientID:kClientID
                           clientSecret:nil
                           additionalParameters:kAddParams];
                      }
                  }];
}

- (IBAction)codeExchange:(nullable id)sender {
    // performs code exchange request
    OIDTokenRequest* tokenExchangeRequest =
    [_authState.lastAuthorizationResponse tokenExchangeRequest];

    [self logMessage:@"Performing authorization code exchange with request [%@]",
     tokenExchangeRequest];

    [OIDAuthorizationService
     performTokenRequest:tokenExchangeRequest
     callback:^(OIDTokenResponse* _Nullable tokenResponse,
                NSError* _Nullable error) {
        if (!tokenResponse) {
            [self logMessage:@"Token exchange error: %@",
             [error localizedDescription]];
        } else {
            [self logMessage:
             @"Received token response with accessToken: %@",
             tokenResponse.accessToken];
        }

        [self.authState updateWithTokenResponse:tokenResponse
                                          error:error];
    }];
}

- (IBAction)clearLog:(nullable id)sender {
    _logTextView.text = @"";
}

- (IBAction)profileManagement:(nullable id)sender {
    [self logMessage:@"Profile Button Touched"];
    [self verifyConfig];
    [self setAdditionalParams];

    NSURL* issuer = [NSURL URLWithString:kIssuer];

    [self logMessage:@"Fetching configuration for issuer: %@", issuer];

    // discovers endpoints
    [OIDAuthorizationService
     discoverServiceConfigurationForIssuer:issuer
     completion:^(
                  OIDServiceConfiguration* _Nullable configuration,
                  NSError* _Nullable error) {
                      if (!configuration) {
                          [self logMessage:
                           @"Error retrieving discovery "
                           @"document: %@",
                           [error localizedDescription]];
                          return;
                      }

                      [self logMessage:@"Got configuration: %@",
                       configuration];

                      if (!kClientID) {
                          [self
                           doClientRegistration:configuration
                           additionalParameters:kAddParams
                           callback:^(
                                      OIDServiceConfiguration*
                                      configuration,
                                      OIDRegistrationResponse*
                                      registrationResponse) {
                                          [self loadProfile:configuration
                                                   clientID:registrationResponse.clientID
                                               clientSecret:registrationResponse.clientSecret
                                       additionalParameters:kAddParams];
                                      }];
                      } else {
                          [self loadProfile:configuration
                                   clientID:kClientID
                               clientSecret:nil
                       additionalParameters:kAddParams];
                      }
                  }];
}

- (IBAction)logout:(nullable id)sender {
    [self showLogoutOptionsAlert];
}

- (IBAction)refreshToken:(nullable id)sender {
    // performs token refresh request
    OIDTokenRequest* tokenRefreshRequest = _authState.tokenRefreshRequest;

    [self logMessage:@"Performing token refresh with request %@",
     tokenRefreshRequest];

    [OIDAuthorizationService
     performTokenRequest:tokenRefreshRequest
     callback:^(OIDTokenResponse* _Nullable tokResp,
                NSError* _Nullable error) {
        if (tokResp) {
            [self logMessage:
             @"Received token response with access token: [%@]",
             tokResp.accessToken];
            [self logMessage:
             @"Refresh token response from request: [%@]",
             tokResp.refreshToken];
        } else {
            [self logMessage:@"Token refresh error: %@",
             [error localizedDescription]];
        }

        [self.authState updateWithTokenResponse:tokResp
                                          error:error];
    }];
}

- (IBAction)userinfo:(nullable id)sender {
    NSURL *userinfoEndpoint =
    _authState.lastAuthorizationResponse.request.configuration.discoveryDocument.userinfoEndpoint;
    if (!userinfoEndpoint) {
        [self logMessage:@"Userinfo endpoint not declared in discovery document"];
        return;
    }
    NSString *currentAccessToken = _authState.lastTokenResponse.accessToken;

    [self logMessage:@"Performing userinfo request"];

    [_authState performActionWithFreshTokens:^(NSString *_Nonnull accessToken,
                                               NSString *_Nonnull idToken,
                                               NSError *_Nullable error) {
        if (error) {
            [self logMessage:@"Error fetching fresh tokens: %@", [error localizedDescription]];
            isAccessTokenRevoked = TRUE;
            isRefreshTokenRevoked = TRUE;
            return;
        }

        // log whether a token refresh occurred
        if (![currentAccessToken isEqual:accessToken]) {
            [self logMessage:@"Access token was refreshed automatically (%@ to %@)",
             currentAccessToken,
             accessToken];
        } else {
            [self logMessage:@"Access token was fresh and not updated [%@]", accessToken];
        }

        // creates request to the userinfo endpoint, with access token in the Authorization header
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userinfoEndpoint];
        NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
        [request addValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];

        NSURLSessionConfiguration *configuration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                              delegate:nil
                                                         delegateQueue:nil];

        // performs HTTP request
        NSURLSessionDataTask *postDataTask =
        [session dataTaskWithRequest:request
                   completionHandler:^(NSData *_Nullable data,
                                       NSURLResponse *_Nullable response,
                                       NSError *_Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (error) {
                    [self logMessage:@"HTTP request failed %@", error];
                    return;
                }
                if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
                    [self logMessage:@"Non-HTTP response"];
                    return;
                }

                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                id jsonDictionaryOrArray =
                [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];

                if (httpResponse.statusCode != 200) {
                    // server replied with an error
                    NSString *responseText = [[NSString alloc] initWithData:data
                                                                   encoding:NSUTF8StringEncoding];
                    if (httpResponse.statusCode == 401) {
                        // "401 Unauthorized" generally indicates there is an issue with the authorization
                        // grant. Puts OIDAuthState into an error state.
                        NSError *oauthError =
                        [OIDErrorUtilities resourceServerAuthorizationErrorWithCode:0
                                                                      errorResponse:jsonDictionaryOrArray
                                                                    underlyingError:error];
                        [self.authState updateWithAuthorizationError:oauthError];
                        // log error
                        [self logMessage:@"Authorization Error (%@). Response: %@", oauthError, responseText];
                    } else {
                        [self logMessage:@"HTTP: %d. Response: %@",
                         (int)httpResponse.statusCode,
                         responseText];
                    }
                    return;
                }

                // success response
                [self logMessage:@"Success: %@", jsonDictionaryOrArray];
            });
        }];

        [postDataTask resume];
    }];
}

- (void)endBrowserSession:(nullable completionHandler)completion {
    [self logMessage:@"Logout with Redirect Button Touched"];
    [self verifyConfig];

    NSURL* issuer = [NSURL URLWithString:kIssuer];

    [self logMessage:@"Fetching configuration for issuer: %@", issuer];

    // discovers endpoints
    [OIDAuthorizationService
     discoverServiceConfigurationForIssuer:issuer
     completion:^(
                  OIDServiceConfiguration* _Nullable configuration,
                  NSError* _Nullable error) {
                      if (!configuration) {
                          [self logMessage:
                           @"Error retrieving discovery "
                           @"document: %@",
                           [error localizedDescription]];
                          return;
                      }

                      [self logMessage:@"Got configuration: %@",
                       configuration];

                      if (!kClientID) {
                          [self
                           doClientRegistration:configuration
                           additionalParameters:kAddParams
                           callback:^(
                                      OIDServiceConfiguration*
                                      configuration,
                                      OIDRegistrationResponse*
                                      registrationResponse) {
                                          [self endBrowserSession:configuration
                                                         clientID:registrationResponse.clientID
                                                     clientSecret:registrationResponse.clientSecret
                                                completionHandler:completion];
                                      }];
                      } else {
                          [self endBrowserSession:configuration
                                         clientID:kClientID
                                     clientSecret:nil
                                completionHandler:completion];
                      }
                  }];
}

- (void)revokeAccessToken:(nullable completionHandler)completion {
    NSURL* url = [[NSURL alloc] initWithString:kRevokeTokenURI];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];

    request.HTTPMethod = @"POST";

    NSString* accessToken = _authState.lastTokenResponse.accessToken;

    if (!accessToken) {
        return;
    }

    NSString* bodyString = [NSString
                            stringWithFormat:@"token=%@&client_id=%@", accessToken, kClientID];
    NSData* dataBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:dataBody];

    NSURLSessionDataTask* downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithRequest:request
                                          completionHandler:^(NSData* _Nullable data,
                                                              NSURLResponse* _Nullable response,
                                                              NSError* _Nullable error) {
        if (data) {
            NSString* message =
            [[NSString alloc] initWithData:data
                                  encoding:NSUTF8StringEncoding];
            [self logMessage:@"%@", [NSString stringWithFormat:@"%@\n", message]];

            completion(TRUE, nil);
        } else if (error) {
            NSLog(@"Revoke Token Error: %@", error.description);
            completion(TRUE, error);
        }
    }];

    [downloadTask resume];
}

- (void)revokeRefreshToken:(nullable completionHandler)completion {
    NSURL *url = [[NSURL alloc] initWithString:kRevokeTokenURI];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];

    request.HTTPMethod = @"POST";

    NSString *refreshToken = _authState.lastTokenResponse.refreshToken;

    if (!refreshToken) {
        return;
    }

    NSString *bodyString = [NSString
                            stringWithFormat:@"token=%@&client_id=%@", refreshToken, kClientID];
    NSData *dataBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:dataBody];

    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithRequest:request
                                          completionHandler:^(NSData* _Nullable data,
                                                              NSURLResponse* _Nullable response,
                                                              NSError* _Nullable error) {
        if (data) {
            NSString *message =
            [[NSString alloc] initWithData:data
                                  encoding:NSUTF8StringEncoding];
            [self logMessage:@"%@", [NSString stringWithFormat:@"%@\n", message]];

            completion(TRUE, nil);

        } else if (error) {
            NSLog(@"Revoke Token Error: %@", error.description);
            completion(TRUE, error);
        }
    }];
    [downloadTask resume];
}

- (void)endAppSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController* rootViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:
         @"AppAuthExampleViewController"];

        self.view.window.rootViewController = rootViewController;
        [UIView
         transitionWithView:UIApplication.sharedApplication.keyWindow
         duration:0.5
         options:UIViewAnimationOptionTransitionFlipFromRight
         animations:^{
            BOOL oldState = UIView.areAnimationsEnabled;
            [UIView setAnimationsEnabled:TRUE];
            UIApplication.sharedApplication.keyWindow.rootViewController =
            rootViewController;
            [UIView setAnimationsEnabled:oldState];
        }
         completion:^(BOOL finished){
            isAccessTokenRevoked = FALSE;
            isRefreshTokenRevoked = FALSE;
            isBrowserSessionRevoked = FALSE;
            self.authState = nil;
        }];
    });
}

/*! @brief Logs a message to stdout and the textfield.
 @param format The format string and arguments.
 */
- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    // gets message as string
    va_list argp;
    va_start(argp, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:argp];
    va_end(argp);

    // outputs to stdout
    NSLog(@"%@", log);

    // appends to output log
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[self logTextView]
         setText:[NSString
                  stringWithFormat:@"%@%@%@: %@", [self logTextView].text,
                  [self logTextView].text.length > 0 ? @"\n": @"", dateString, log]];

        NSRange range = NSMakeRange([self logTextView].text.length - 1, 1);

        // automatically scroll the textview as text is added
        [[self logTextView] scrollRangeToVisible:range];
    });
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [textView setSelectedRange:NSMakeRange(0, textView.text.length)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_accessTokenTextView endEditing:TRUE];
    [_refreshTokenTextView endEditing:TRUE];
}

/*! @brief Creates an alert to display the logout options available.
 */
- (void)showLogoutOptionsAlert {
    LogoutOptionsController* logoutOptionsController =
    [LogoutOptionsController controllerWithLogoutOptions:kLogoutOptions];

    UIAlertController* logoutAlertController =
    [UIAlertController alertControllerWithTitle:@"Sign Out Options"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    [logoutAlertController setValue:logoutOptionsController
                             forKey:@"contentViewController"];

    UIAlertAction* cancelAction =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:nil];

    UIAlertAction* submitAction = [UIAlertAction
                                   actionWithTitle:@"Submit"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction* action) {

        dispatch_group_t logoutGroup = dispatch_group_create();

        if ([logoutOptionsController.logoutOptionsSelected
             containsObject:LogoutOptionRevokeTokens] ||
            [logoutOptionsController.logoutOptionsSelected
             containsObject:LogoutOptionEndAppSession]) {

            dispatch_group_enter(logoutGroup);
            dispatch_group_async(logoutGroup,
                                 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self revokeAccessToken:^(BOOL complete, NSError* _Nullable error) {
                    if (complete) {
                        if (error) {
                            [self presentViewController:
                             [UIAlertController
                              alertControllerWithTitle:@"Error"
                              message:@"Failed to revoke access token"
                              preferredStyle:UIAlertControllerStyleAlert]
                                               animated:YES
                                             completion:nil];
                            return;
                        } else {
                            isAccessTokenRevoked = TRUE;
                            dispatch_group_leave(logoutGroup);
                        }
                    }
                }];
            });

            dispatch_group_enter(logoutGroup);
            dispatch_group_async(logoutGroup,
                                 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self revokeRefreshToken:^(BOOL complete, NSError* _Nullable error) {
                    if (complete) {
                        if (error) {
                            [self presentViewController:
                             [UIAlertController
                              alertControllerWithTitle:@"Error"
                              message:@"Failed to revoke refresh token"
                              preferredStyle:UIAlertControllerStyleAlert]
                                               animated:YES
                                             completion:nil];
                            return;
                        } else {
                            isRefreshTokenRevoked = TRUE;

                            if (![logoutOptionsController.logoutOptionsSelected
                                  containsObject:LogoutOptionEndBrowserSession]
                                || ![logoutOptionsController.logoutOptionsSelected
                                     containsObject:LogoutOptionEndAppSession]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self updateUI];
                                });
                            }
                        }

                        dispatch_group_leave(logoutGroup);
                    }
                }];
            });
        }

        if ([logoutOptionsController.logoutOptionsSelected
             containsObject:LogoutOptionEndBrowserSession]) {
            dispatch_group_enter(logoutGroup);
            dispatch_group_async(logoutGroup,
                                 dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self endBrowserSession:^(BOOL complete, NSError* _Nullable error) {
                    if (complete) {
                        if (error) {
                            [self presentViewController:
                             [UIAlertController
                              alertControllerWithTitle:@"Error"
                              message:@"Failed to end browser session"
                              preferredStyle:UIAlertControllerStyleAlert]
                                               animated:YES
                                             completion:nil];
                            return;
                        } else {
                            isBrowserSessionRevoked = TRUE;
                            if (![logoutOptionsController.logoutOptionsSelected
                                  containsObject:LogoutOptionEndAppSession]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self updateUI];
                                });
                            }
                        }
                        dispatch_group_leave(logoutGroup);
                    }
                }];
            });
        }

        if ([logoutOptionsController.logoutOptionsSelected
             containsObject:LogoutOptionEndAppSession]) {
            dispatch_group_notify(logoutGroup,
                                  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                [self endAppSession];
            });
        }
    }];

    [logoutAlertController addAction:cancelAction];
    [logoutAlertController addAction:submitAction];

    [self presentViewController:logoutAlertController
                       animated:YES
                     completion:nil];
}

@end
