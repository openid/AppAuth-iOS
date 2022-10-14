/*! @file AppAuthExampleViewController.m
 @brief AppAuth iOS SDK Example
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

#import "AppAuthExampleViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AppAuth.h"
#import "AppDelegate.h"

typedef void (^PostRegistrationCallback)(OIDServiceConfiguration *configuration,
                                         OIDRegistrationResponse *registrationResponse);

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

/*! @brief NSCoding key for the authState property.
 */
static NSString *const kAppAuthExampleAuthStateKey = @"authState";

@interface AppAuthExampleViewController () <OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate>
@end

@implementation AppAuthExampleViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  _logTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
  _logTextView.layer.borderWidth = 1.0f;
  _logTextView.alwaysBounceVertical = true;
  _logTextView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
  _logTextView.text = @"";

  [self loadState];
  [self updateUI:false];
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

  [self updateUI:false];

  if (_authState == authState) {
    return;
  }
  _authState = authState;
  _authState.stateChangeDelegate = self;
  [self stateChanged];
}

/*! @brief Refreshes UI, typically called after the auth state changed.
 */
- (void)updateUI:(BOOL)isLoading {
  if (isLoading) {
    [_authActivityIndicator startAnimating];
    [UIView animateWithDuration:0.25 animations:^{
      _authButton.alpha = 0.5;
    }];
  } else {
    [_authActivityIndicator stopAnimating];
    [UIView animateWithDuration:0.25 animations:^{
      _authButton.alpha = 1.0;
    }];
  }
}

- (void)stateChanged {
  [self saveState];
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
  NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];

  OIDRegistrationRequest *request =
  [[OIDRegistrationRequest alloc] initWithConfiguration:configuration
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

- (void)doAuthWithAutoCodeExchange:(OIDServiceConfiguration *)configuration
                          clientID:(NSString *)clientID
                      clientSecret:(NSString *)clientSecret
              additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters {
  NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
  // builds authentication request
  OIDAuthorizationRequest *request =
  [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                clientId:clientID
                                            clientSecret:clientSecret
                                                  scopes:kScopes
                                             redirectURL:redirectURI
                                            responseType:OIDResponseTypeCode
                                    additionalParameters:additionalParameters];
  // performs authentication request
  AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
  [self logMessage:@"Initiating authorization request with scope: %@", request.scope];
  [self logMessage:@"Initiating authorization request with additional params of : %@", request.additionalParameters];
  appDelegate.currentAuthorizationFlow =
  [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                 presentingViewController:self
                                                 callback:^(OIDAuthState *_Nullable authState, NSError *_Nullable error) {
    if (authState) {
      [self setAuthState:authState];
      [self logMessage:@"Got authorization tokens. Access token: %@",
       authState.lastTokenResponse.accessToken];

      UIViewController *rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TokenViewController"];
      self.view.window.rootViewController = rootViewController;

      [UIView transitionWithView:UIApplication.sharedApplication.keyWindow duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        BOOL oldState = UIView.areAnimationsEnabled;
        [UIView setAnimationsEnabled:true];
        UIApplication.sharedApplication.keyWindow.rootViewController = rootViewController;
        [UIView setAnimationsEnabled:oldState];
      } completion:^(BOOL finished) {
      }];
    } else {
      [self logMessage:@"Authorization error: %@", [error localizedDescription]];
      [self setAuthState:nil];
    }
  }];
}

- (void)doAuthWithoutCodeExchange:(OIDServiceConfiguration *)configuration
                         clientID:(NSString *)clientID
                     clientSecret:(NSString *)clientSecret
             additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters {
  NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];

  // builds authentication request
  OIDAuthorizationRequest *request =
  [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                clientId:clientID
                                            clientSecret:clientSecret
                                                  scopes:kScopes
                                             redirectURL:redirectURI
                                            responseType:OIDResponseTypeCode
                                    additionalParameters:additionalParameters];
  // performs authentication request
  AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
  [self logMessage:@"Initiating authorization request %@", request];
  appDelegate.currentAuthorizationFlow =
  [OIDAuthorizationService presentAuthorizationRequest:request
                              presentingViewController:self
                                              callback:^(OIDAuthorizationResponse *_Nullable authorizationResponse,
                                                         NSError *_Nullable error) {
    if (authorizationResponse) {
      OIDAuthState *authState =
      [[OIDAuthState alloc] initWithAuthorizationResponse:authorizationResponse];
      [self setAuthState:authState];

      [self logMessage:@"Authorization response with code: %@",
       authorizationResponse.authorizationCode];
      
      UIViewController *rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TokenViewController"];
      self.view.window.rootViewController = rootViewController;

      [UIView transitionWithView:UIApplication.sharedApplication.keyWindow duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        BOOL oldState = UIView.areAnimationsEnabled;
        [UIView setAnimationsEnabled:true];
        UIApplication.sharedApplication.keyWindow.rootViewController = rootViewController;
        [UIView setAnimationsEnabled:oldState];
      } completion:^(BOOL finished) {
      }];
      // could just call [self tokenExchange:nil] directly, but will let the user initiate it.
    } else {
      [self logMessage:@"Authorization error: %@", [error localizedDescription]];
      [self setAuthState:nil];
    }
  }];
}

- (IBAction)authorizeUser:(nullable id)sender {

  if (_authTypeSegmentedControl.selectedSegmentIndex == 0) {
    [self authWithAutoCodeExchange];
  } else {
    [self authNoCodeExchange];
  }

  [self updateUI:true];
}

- (void)authWithAutoCodeExchange {
  [self verifyConfig];
  [self setAdditionalParams];
  
  NSURL *issuer = [NSURL URLWithString:kIssuer];
  
  [self logMessage:@"Fetching configuration for issuer: %@", issuer];
  
  // discovers endpoints
  [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                      completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
    if (!configuration) {
      [self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
      [self setAuthState:nil];
      [self updateUI:false];
      return;
    }
    
    [self logMessage:@"Got configuration: %@", configuration];
    
    if (!kClientID) {
      [self doClientRegistration:configuration
            additionalParameters:kAddParams
                        callback:^(OIDServiceConfiguration *configuration,
                                   OIDRegistrationResponse *registrationResponse) {
        [self doAuthWithAutoCodeExchange:configuration
                                clientID:registrationResponse.clientID
                            clientSecret:registrationResponse.clientSecret
                    additionalParameters:kAddParams];
      }];
    } else {
      [self doAuthWithAutoCodeExchange:configuration clientID:kClientID clientSecret:nil additionalParameters:kAddParams];
    }
  }];
}

- (void)authNoCodeExchange {
  [self verifyConfig];
  [self setAdditionalParams];
  
  NSURL *issuer = [NSURL URLWithString:kIssuer];
  
  [self logMessage:@"Fetching configuration for issuer: %@", issuer];
  
  // discovers endpoints
  [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
                                                      completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
    
    if (!configuration) {
      [self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
      [self updateUI:false];
      return;
    }
    
    [self logMessage:@"Got configuration: %@", configuration];
    
    if (!kClientID) {
      [self doClientRegistration:configuration
            additionalParameters:kAddParams
                        callback:^(OIDServiceConfiguration *configuration,
                                   OIDRegistrationResponse *registrationResponse) {
        [self doAuthWithoutCodeExchange:configuration
                               clientID:registrationResponse.clientID
                           clientSecret:registrationResponse.clientSecret
                   additionalParameters:kAddParams];
      }];
    } else {
      [self doAuthWithoutCodeExchange:configuration clientID:kClientID clientSecret:nil additionalParameters:kAddParams];
    }
  }];
}

- (IBAction)clearLog:(nullable id)sender {
  _logTextView.text = @"";
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
  NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
  _logTextView.text = [NSString stringWithFormat:@"%@%@%@: %@",
                       _logTextView.text,
                       ([_logTextView.text length] > 0) ? @"\n" : @"",
                       dateString,
                       log];
  
  NSRange range = NSMakeRange(_logTextView.text.length - 1, 1);
  
  // automatically scroll the textview as text is added
  [_logTextView scrollRangeToVisible:range];
}

@end
