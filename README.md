# AppAuth for iOS

[![Build Status](https://www.bitrise.io/app/8e4dbca635a964dc.svg?token=8rT4oJnhjUuFWH-QvXuJzg&branch=master)](https://www.bitrise.io/app/8e4dbca635a964dc)

AppAuth for iOS is a client SDK for communicating with [OAuth 2.0]
(https://tools.ietf.org/html/rfc6749) and [OpenID Connect]
(http://openid.net/specs/openid-connect-core-1_0.html) providers. It strives to
directly map the requests and responses of those specifications, while following
the idiomatic style of the implementation language. In addition to mapping the
raw protocol flows, convenience methods are available to assist with common
tasks like performing an action with fresh tokens.

It follows the best practices set out in [OAuth 2.0 for Native Apps]
(https://tools.ietf.org/html/draft-ietf-oauth-native-apps)
including using `SFSafariViewController` for the auth request. For this reason,
`UIWebView` is explicitly *not* supported due to usability and security reasons.

It also supports the [PKCE](https://tools.ietf.org/html/rfc7636) extension to
OAuth which was created to secure authorization codes in public clients when
custom URI scheme redirects are used. The library is friendly to other
extensions (standard or otherwise) with the ability to handle additional params
in all protocol requests and responses.

## Specification

### Supported iOS Versions

AppAuth supports iOS 7 and above.

iOS 9+ uses the in-app browser tab pattern
(via `SFSafariViewController`), and falls back to the system browser (mobile
Safari) on earlier versions.

### Authorization Server Support

Both Custom URI Schemes (all supported versions of iOS) and Universal Links
(iOS 9+) can be used with the library.

In general, AppAuth can work with any Authorization Server (AS) that [supports
apps](https://tools.ietf.org/html/draft-ietf-oauth-native-apps-00),
either through custom URI scheme redirects, or universal links.
AS's that assume all clients are web-based or require clients to maintain
confidentiality of the client secrets may not work well.

## Try

Want to try out AppAuth? Just run:

    pod try AppAuth

Follow the instructions in [Example/README.md](Example/README.md) to configure
with your own OAuth client (you need to update 3 configuration points with your
client info to try the demo).

## Setup

If you use [CocoaPods](https://guides.cocoapods.org/using/getting-started.html),
simply add:

    pod 'AppAuth'

To your `Podfile` and run `pod install`. Otherwise, add `AppAuth.xcodeproj`
into your workspace.

## Auth Flow

AppAuth supports both manual interaction with the Authorization Server
where you need to perform your own token exchanges, as well as convenience
methods that perform some of this logic for you. This example uses the
convenience method which returns either an `OIDAuthState` object, or an error.

`OIDAuthState` is a class that keeps track of the authorization and token
requests and responses, and provides a convenience method to call an API with
fresh tokens. This is the only object that you need to serialize to retain the
authorization state of the session.

### Authorizing

The OAuth configuration can be fetched via OpenID Connect discovery, or created
manually. Here we construct it manually by specifying the endpoints.

```objc
// property of the app's AppDelegate
@property(nonatomic, strong, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;

// property of the containing class
@property(nonatomic, strong, nullable) OIDAuthState *authState;

//...

OIDServiceConfiguration *configuration =
    [[OIDServiceConfiguration alloc] initWithAuthorizationEndpoint:kAuthorizationEndpoint
                                                     tokenEndpoint:kTokenEndpoint];
// builds authentication request
OIDAuthorizationRequest *request =
    [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                  clientId:kClientID
                                                    scopes:@[OIDScopeOpenID, OIDScopeProfile]
                                               redirectURL:KRedirectURI
                                              responseType:OIDResponseTypeCode
                                      additionalParameters:nil];

// performs authentication request
AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
NSLog(@"Initiating authorization request with scope: %@", request.scope);

appDelegate.currentAuthorizationFlow =
    [OIDAuthState authStateByPresentingAuthorizationRequest:request
        presentingViewController:self
                        callback:^(OIDAuthState *_Nullable authState,
                                   NSError *_Nullable error) {
  if (authState) {
    NSLog(@"Got authorization tokens. Access token: %@",
          authState.lastTokenResponse.accessToken);
    [self setAuthState:authState];
  } else {
    NSLog(@"Authorization error: %@", [error localizedDescription]);
    [self setAuthState:nil];
  }
}];
```

### Handling the Redirect

The authorization response URL is returned to the app via the iOS openURL
app delegate method, so you need to pipe this through to the current
authorization session (created in the previous session).

```objc
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
  // Sends the URL to the current authorization flow (if any) which will
  // process it if it relates to an authorization response.
  if ([_currentAuthorizationFlow resumeAuthorizationFlowWithURL:url]) {
    _currentAuthorizationFlow = nil;
    return YES;
  }

  // Your additional URL handling (if any) goes here.

  return NO;
}
```

### Making API Calls

AppAuth gives you the raw token information, if you need it. However we
recommend that users of the `OIDAuthState` convenience wrapper use the provided
`withFreshTokensPerformAction:` method to perform their API calls to avoid
needing to worry about token freshness.

```objc
[_authState withFreshTokensPerformAction:^(NSString *_Nonnull accessToken,
                                           NSString *_Nonnull idToken,
                                           NSError *_Nullable error) {
  if (error) {
    NSLog(@"Error fetching fresh tokens: %@", [error localizedDescription]);
    return;
  }

  // perform your API request using the tokens
}];
```

## API Documentation

Browse the [API documentation](http://openid.github.io/AppAuth-iOS/docs/latest/annotated.html).

## Included Sample

You can try out sample included in the source distribution by opening
`Example/Example.xcworkspace`. You can easily convert the Example
workspace to a Pod workspace by deleting the `AppAuth` project, and
[configuring the pod](#setup).

You can also [try out the sample via CocoaPods](#try).

Be sure to follow the instructions in [Example/README.md](Example/README.md)
to configure your own OAuth client ID for use with the example.
