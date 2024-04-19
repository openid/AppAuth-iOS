# 1.7.5
- Use correct xcconfig syntax for podspec ([#851](https://github.com/openid/AppAuth-iOS/pull/851))

# 1.7.4
- Adds defines module to AppAuth.podspec ([#845](https://github.com/openid/AppAuth-iOS/pull/845))

# 1.7.3
- Fix missing manifest in bundle using SPM ([#833](https://github.com/openid/AppAuth-iOS/pull/833))

# 1.7.2
 - Streamline copying of privacy manifest ([#830](https://github.com/openid/AppAuth-iOS/pull/830))

# 1.7.1
- Add back missing method to OIDAuthorizationResponse ([#825](https://github.com/openid/AppAuth-iOS/pull/825))
- Fix OIDTokenRequest for AppAuthCore and AppAuthTV ([#826](https://github.com/openid/AppAuth-iOS/pull/826))

# 1.7.0
- Introduce addtional http headers to OIDTokenRequest ([#770](https://github.com/openid/AppAuth-iOS/pull/770))
- Fix nullability annotation for -[OIDExternalUserAgentIOS init] ([#727](https://github.com/openid/AppAuth-iOS/pull/727))
- Feat: allow custom nonce in OIDAuthorizationRequest ([#788](https://github.com/openid/AppAuth-iOS/pull/788))
- Add privacy manifest ([#822](https://github.com/openid/AppAuth-iOS/pull/822))

# 1.6.2
- Increased minimum iOS and macOS versions to 9.0 and 10.12 respectively to fix [framework build issue](https://github.com/openid/AppAuth-iOS/issues/765)

# 1.6.1
- Increased minimum iOS and macOS versions to fix [build issue](https://github.com/openid/AppAuth-iOS/pull/761)

# 1.6.0
- Added a `prefersEphemeralSession` parameter for external user-agents. ([#645](https://github.com/openid/AppAuth-iOS/pull/645))
- Fixed errors encountered when using secure coding to decode `OIDAuthState`. ([#656](https://github.com/openid/AppAuth-iOS/pull/656), [#721](https://github.com/openid/AppAuth-iOS/pull/721))

# 1.5.0
- Improved tvOS support. ([#111](https://github.com/openid/AppAuth-iOS/issues/111))
- ASWebAuthenticationSession on macOS. ([#675](https://github.com/openid/AppAuth-iOS/pull/675))

# 1.4.0

## Added

1. Support for Swift Package Manager

# 1.3.1

## Fixes

1. Removed `UIWebView` reference in comment

# 1.3.0

## Notable Changes

1. Support for Mac Catalyst

# 1.2.0

## Notable Changes

1. Support for iOS 13

# 1.1.0

## Notable Changes

1. [OpenID Connect RP-Initiated Logout](http://openid.net/specs/openid-connect-session-1_0.html#RPLogout) implemented
2. Added logic for the `azp` claim

## Fixes

1. Scheme comparison for redirects is now case insensitive
2. Improved error handling during discovery when a non-JSON document
   is encountered.

# 1.0.0

1.0.0! 🎉

## Notable Changes

1. **All deprecated APIs removed.** Please ensure your code builds on
   version 0.95.0 with no deprecation warnings before upgrading!
   Notably, if you started with a version of AppAuth prior to 0.93.0
   you will need to follow the instructions in 
   [Upgrading to 0.93.0](#upgrading-to-0930)
2. Updated for iOS 12, and Xcode 10. **Xcode 10 is now required.**
   NB. per policy, AppAuth supports many older versions of iOS and
   macOS, but only the current Xcode toolchain.
   If you need to stay on old versions of Xcode for some reason, stay
   on the pre-1.0 releases.
3. macOS 32-bit support removed. If you need this support, stay on the
   pre-1.0 releases.
4. `AppAuth/Core` subspec, and AppAuthCore Framework added to support
    iOS extensions.

# 1.0.0.beta2 (2018-09-27)

## Notable Changes

1. `AppAuth/Core` subspec, and AppAuthCore Framework added to support
    iOS extensions.

# 1.0.0.beta1 (2018-09-27)

First 1.0.0 beta!  HEAD is now tracking changes for the 1.0.0 release.
The `pre-1.0` branch was cut prior to the breaking changes for 1.0.0,
bug fixes for critical issues may be backported for a time.

## Notable Changes

1. **All deprecated APIs removed.** Please ensure your code builds on
   version 0.95.0 with no deprecation warnings before upgrading!
   Notably, if you started with a version of AppAuth prior to 0.93.0
   you will need to follow the instructions in 
   [Upgrading to 0.93.0](#upgrading-to-0930)
2. Updated for iOS 12, and Xcode 10. **Xcode 10 is now required.**
   NB. per policy, AppAuth supports many older versions of iOS and
   macOS, but only the current Xcode toolchain.
   If you need to stay on old versions of Xcode for some reason, stay
   on the pre-1.0 releases.
3. macOS 32-bit support removed. If you need this support, stay on the
   pre-1.0 releases.

## Fixes

1. All fixes in the 0.95.0 release are incorporated in this release.

# 0.95.0 (2018-09-27)

## Fixes

1. `x-www-form-urlencoded` encoding and decoding should be 100%
   spec compliant now, previously the `+` character was not decoded as
   0x20 space. https://github.com/openid/AppAuth-iOS/pull/291

2. `scope` no longer sent during token refresh (was redundant)
    https://github.com/openid/AppAuth-iOS/pull/301

# 0.94.0 (2018-07-13)

## Fixes
1. `form-urlencode` client ID and client secret in Authorization header

## Added

1. Samples have icons now!
2. Output trace logs by defining `_APPAUTHTRACE`

# 0.93.0 (2018-06-26)

## Notable Changes

1. Implements OpenID Connect (ID Token handling) and the OpenID Connect
   RP Certification test suite.
   https://github.com/openid/AppAuth-iOS/pull/101

2. The `OIDAuthorizationUICoordinator` pattern was genericized to
   support non-authorization external user-agent flows like logout
   (though none are directly implemented by AppAuth, yet). 
   `OIDAuthorizationUICoordinator*` classes renamed to
   `OIDExternalUserAgent*`.
   https://github.com/openid/AppAuth-iOS/pull/196
   https://github.com/openid/AppAuth-iOS/pull/212
   See [Upgrading to 0.93.0](#upgrading-to-0930).

3. Added custom browser support on iOS. Provides several 
   convenience implementations of alternative external user-agents on
   iOS such as Chrome and Firefox. These are intended for
   **enterprise use only**, where the app developers have greater
   control over the operating environment and have special requirements
   that require a custom browser like Chrome.
   See the [code example](https://github.com/openid/AppAuth-iOS/issues/200#issuecomment-364610027).
   https://github.com/openid/AppAuth-iOS/issues/200
   https://github.com/openid/AppAuth-iOS/pull/201

## Upgrading to 0.93.0

0.93.0 deprecates several methods. To update your code to avoid the
deprecated methods (which will be required for the 1.0.0 release),
you will need to make changes.

If you implemented your own `OIDAuthorizationUICoordinator`, or called
the methods which accepted a `UICoordinator` instance, you will need to
update to the new method names. See the deprecation error messages
for the new methods to use in those cases.

Most users who are using the convenience methods of AppAuth will only
need to make the following 3 minor changes to their AppDelegate:

### Import:

Change
```objc
@protocol OIDAuthorizationFlowSession;	
```
to
```objc
@protocol OIDExternalUserAgentSession;
```

### Property:

Change
```objc
@property(nonatomic, strong, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;	
```
to
```objc
@property(nonatomic, strong, nullable) id<OIDExternalUserAgentSession>currentAuthorizationFlow;
```

###  Implementation of `-(BOOL)application:openURL:options:`
Change
```objc
if ([_currentAuthorizationFlow resumeAuthorizationFlowWithURL:url]) {	
```
to
```objc
if ([_currentAuthorizationFlow resumeExternalUserAgentFlowWithURL:url]) {
```

See also the changes made to the sample which you can copy:
https://github.com/openid/AppAuth-iOS/commit/619bb7c7d5f83cc2ed19380d425ca8afa279644c?diff=unified


# 0.92.0 (2018-01-05)

## Improvements

1. Added an official Swift sample, and included Swift testing in the
   continuous integration tests.

# Pre 0.92.0

No changelog entries exist for changes prior to 2018, please review the
[git history](https://github.com/openid/AppAuth-iOS/commits/0.91.0).
