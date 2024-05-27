/*! @file AppAuthTVExampleViewController.m
    @brief AppAuth tvOS SDK Example
    @copyright
        Copyright 2016 Google Inc.
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

#import "AppAuthTVExampleViewController.h"

#import <AppAuth/AppAuthCore.h>
#import <AppAuth/AppAuthTV.h>

/*! @brief Indicates whether YES to discover endpoints from @c kIssuer or NO to use the
        @c kDeviceAuthorizationEndpoint, @c kTokenEndpoint, and @c kUserInfoEndpoint values defined
        below.
 */
static BOOL const shouldDiscoverEndpoints = YES;

/*! @brief OAuth client ID.
 */
static NSString *const kClientID = @"YOUR_CLIENT_ID";

/*! @brief OAuth client secret.
 */
static NSString *const kClientSecret = @"YOUR_CLIENT_SECRET";

/*! @brief The OIDC issuer from which the configuration will be discovered.
 */
static NSString *const kIssuer = @"https://issuer.example.com";

/*! @brief Device authorization endpoint.
 */
static NSString *const kDeviceAuthorizationEndpoint = @"https://www.example.com/device";

/*! @brief Token endpoint.
 */
static NSString *const kTokenEndpoint = @"https://www.example.com/token";

/*! @brief User info endpoint.
 */
static NSString *const kUserInfoEndpoint = @"https://www.example.com/userinfo";

/*! @brief NSCoding key for the authorization property.
 */
static NSString *const kExampleAuthorizerKey = @"authorization";

/*! @brief NSCoding key for the authState property.
 */
static NSString *const kExampleAuthStateKey = @"authState";

@interface AppAuthTVExampleViewController () <OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate>
@end

@implementation AppAuthTVExampleViewController {
  OIDTVAuthorizationCancelBlock _cancelBlock;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _logTextView.text = @"";
  _signInView.hidden = YES;
  _cancelSignInButton.hidden = YES;
  _logTextView.selectable = YES;
  _logTextView.panGestureRecognizer.allowedTouchTypes = @[ @(UITouchTypeIndirect) ];

  [self verifyConfig];

  [self loadState];
  [self updateUI];
}

- (void)verifyConfig {
#if !defined(NS_BLOCK_ASSERTIONS)
  NSAssert(![kClientID isEqualToString:@"YOUR_CLIENT_ID"],
           @"Update kClientID with your own client ID. "
            "Instructions: "
            "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-tvOS/README.md");

  NSAssert(![kClientSecret isEqualToString:@"YOUR_CLIENT_SECRET"],
           @"Update kClientSecret with your own client secret. "
            "Instructions: "
            "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-tvOS/README.md");

  if (shouldDiscoverEndpoints) {
    NSAssert(![kIssuer isEqualToString:@"https://issuer.example.com"],
            @"Update kIssuer with your own issuer. "
             "Instructions: "
             "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-tvOS/README.md");
  } else {
    NSAssert(![kDeviceAuthorizationEndpoint isEqualToString:@"https://www.example.com/device"],
             @"Update kDeviceAuthorizationEndpoint with your own device authorization endpoint. "
              "Instructions: "
              "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-tvOS/README.md");

    NSAssert(![kTokenEndpoint isEqualToString:@"https://www.example.com/token"],
             @"Update kTokenEndpoint with your own token endpoint. "
              "Instructions: "
              "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-tvOS/README.md");

    NSAssert(![kUserInfoEndpoint isEqualToString:@"https://www.example.com/userinfo"],
             @"Update kUserInfoEndpoint with your own user info endpoint. "
              "Instructions: "
              "https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-tvOS/README.md");
  }
#endif  // !defined(NS_BLOCK_ASSERTIONS)
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
/*! @brief Initiates the sign-in.
    @param sender IBAction sender.
*/
- (IBAction)signin:(id)sender {
  if (_cancelBlock) {
    [self cancelSignIn:nil];
  }

  if (shouldDiscoverEndpoints) {
    NSURL *issuer = [NSURL URLWithString:kIssuer];

    // Discover endpoints
    [OIDTVAuthorizationService discoverServiceConfigurationForIssuer:issuer
        completion:^(OIDTVServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
      if (!configuration) {
        [self logMessage:@"Error retrieving discovery document: %@", [error localizedDescription]];
        [self setAuthState:nil];
        return;
      }

      [self logMessage:@"Got configuration: %@", configuration];

      // Perform authorization flow
      [self performAuthorizationWithConfiguration:configuration];
     }];
  } else {
    NSURL *deviceAuthorizationEndpoint = [NSURL URLWithString:kDeviceAuthorizationEndpoint];
    NSURL *tokenEndpoint = [NSURL URLWithString:kTokenEndpoint];

    OIDTVServiceConfiguration *configuration = [[OIDTVServiceConfiguration alloc]
        initWithDeviceAuthorizationEndpoint:deviceAuthorizationEndpoint
                              tokenEndpoint:tokenEndpoint];

    // Perform authorization flow
    [self performAuthorizationWithConfiguration:configuration];
  }
}

- (void)performAuthorizationWithConfiguration:(OIDTVServiceConfiguration *)configuration {
  // builds authentication request
  __weak __typeof(self) weakSelf = self;

  OIDTVAuthorizationRequest *request =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:configuration
                                                      clientId:kClientID
                                                  clientSecret:kClientSecret
                                                        scopes:@[ OIDScopeOpenID, OIDScopeProfile ] 
                                          additionalParameters:nil];

  OIDTVAuthorizationInitialization initBlock =
      ^(OIDTVAuthorizationResponse *_Nullable response, NSError *_Nullable error) {
        if (response) {
          [weakSelf logMessage:@"Authorization response: %@", response];
          weakSelf.signInView.hidden = NO;
          weakSelf.cancelSignInButton.hidden = NO;
          weakSelf.verificationURLLabel.text = response.verificationURI;
          weakSelf.userCodeLabel.text = response.userCode;
        } else {
          [weakSelf logMessage:@"Initialization error %@", error];
        }
      };

  OIDTVAuthorizationCompletion completionBlock =
      ^(OIDAuthState *_Nullable authState, NSError *_Nullable error) {
        weakSelf.signInView.hidden = YES;
        if (authState) {
          [weakSelf setAuthState:authState];
          [weakSelf logMessage:@"Token response: %@", authState.lastTokenResponse];
        } else {
          [weakSelf setAuthState:nil];
          [weakSelf logMessage:@"Error: %@", error];
        }
      };

  _cancelBlock = [OIDTVAuthorizationService authorizeTVRequest:request
                                                initialization:initBlock
                                                    completion:completionBlock];
}

/*! @brief Cancels the active sign-in (if any), has no effect if a sign-in isn't in progress.
    @param sender IBAction sender.
*/
- (IBAction)cancelSignIn:(nullable id)sender {
  if (_cancelBlock) {
    _cancelBlock();
    _cancelBlock = nil;
  }
  _signInView.hidden = YES;
  _cancelSignInButton.hidden = YES;
}

- (void)setAuthState:(nullable OIDAuthState *)authState {
  if (_authState == authState) {
    return;
  }
  _authState = authState;
  _authState.stateChangeDelegate = self;
  [self stateChanged];
}

/*! @brief Saves the @c OIDAuthState to @c NSUSerDefaults.
 */
- (void)saveState {
  // for production usage consider using the OS Keychain instead
  NSData *archivedAuthState = [NSKeyedArchiver archivedDataWithRootObject:_authState];
  [[NSUserDefaults standardUserDefaults] setObject:archivedAuthState forKey:kExampleAuthStateKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

/*! @brief Loads the @c OIDAuthState from @c NSUSerDefaults.
 */
- (void)loadState {
  // loads OIDAuthState from NSUSerDefaults
  NSData *archivedAuthState =
      [[NSUserDefaults standardUserDefaults] objectForKey:kExampleAuthStateKey];
  OIDAuthState *authState = [NSKeyedUnarchiver unarchiveObjectWithData:archivedAuthState];
  [self setAuthState:authState];
}

/*! @brief Refreshes UI, typically called after the auth state changed.
 */
- (void)updateUI {
  _signInButtons.hidden = [_authState isAuthorized];
  _signedInButtons.hidden = !_signInButtons.hidden;
}

- (void)updateSignInUIWithResponse:(OIDTVAuthorizationResponse *)response {
  _signInView.hidden = NO;
  _cancelSignInButton.hidden = NO;
  _verificationURLLabel.text = response.verificationURI;
  _userCodeLabel.text = response.userCode;
}

/*! @brief Forgets the authentication state, used to sign-out the user.
    @param sender IBAction sender.
*/
- (IBAction)clearAuthState:(nullable id)sender {
  [self setAuthState:nil];
  [self logMessage:@"Authorization state cleared."];
  _cancelSignInButton.hidden = TRUE;
}

- (IBAction)clearLog:(nullable id)sender {
  _logTextView.text = @"";
}

/*! @brief Performs an authenticated API call.
    @param sender IBAction sender.
*/
- (IBAction)userinfo:(nullable id)sender {
  NSURL *userinfoEndpoint;

  if (shouldDiscoverEndpoints) {
    userinfoEndpoint = _authState.lastAuthorizationResponse.request.configuration.discoveryDocument
                           .userinfoEndpoint;
  } else {
    userinfoEndpoint = [NSURL URLWithString:kUserInfoEndpoint];
  }

  NSString *currentAccessToken = _authState.lastTokenResponse.accessToken;

  [self logMessage:@"Performing userinfo request"];

  [_authState performActionWithFreshTokens:^(NSString *_Nonnull accessToken,
                                             NSString *_Nonnull idToken, NSError *_Nullable error) {
    if (error) {
      [self logMessage:@"Error fetching fresh tokens: %@", [error localizedDescription]];
      return;
    }

    // log whether a token refresh occurred
    if (![currentAccessToken isEqual:accessToken]) {
      [self logMessage:@"Access token was refreshed automatically (%@ to %@)", currentAccessToken,
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
    NSURLSessionDataTask *postDataTask = [session
        dataTaskWithRequest:request
          completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
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
              id jsonDictionaryOrArray = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:NULL];

              if (httpResponse.statusCode != 200) {
                // server replied with an error
                NSString *responseText = [[NSString alloc] initWithData:data
                                                               encoding:NSUTF8StringEncoding];
                if (httpResponse.statusCode == 401) {
                  // "401 Unauthorized" generally indicates there is an issue with the authorization
                  // grant. Puts OIDAuthState into an error state.
                  NSError *oauthError = [OIDErrorUtilities
                      resourceServerAuthorizationErrorWithCode:0
                                                 errorResponse:jsonDictionaryOrArray
                                               underlyingError:error];
                  [self->_authState updateWithAuthorizationError:oauthError];
                  // log error
                  [self logMessage:@"Authorization Error (%@). Response: %@", oauthError,
                                   responseText];
                } else {
                  [self logMessage:@"HTTP: %d. Response: %@", (int)httpResponse.statusCode,
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

/*! @brief Logs a message to stdout and the textfield.
    @param format The format string and arguments.
 */
- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) {
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
  NSString *logLine = [NSString stringWithFormat:@"\n%@: %@", dateString, log];
  UIFont *systemFont = [UIFont systemFontOfSize:36.0f];
  NSDictionary *fontAttributes =
      [[NSDictionary alloc] initWithObjectsAndKeys:systemFont, NSFontAttributeName, nil];
  NSMutableAttributedString *logLineAttr =
      [[NSMutableAttributedString alloc] initWithString:logLine attributes:fontAttributes];
  [[_logTextView textStorage] appendAttributedString:logLineAttr];

  // Scroll to bottom
  if (_logTextView.text.length > 0) {
    NSRange bottom = NSMakeRange(_logTextView.text.length - 1, 1);
    [_logTextView scrollRangeToVisible:bottom];
  }
}

@end
