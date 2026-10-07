# Migrating from CocoaPods to Swift Package Manager

CocoaPods trunk becomes read-only on December 2, 2026. AppAuth 3.0.0 is the last
version published to CocoaPods. Existing pod versions remain installable, but
future AppAuth releases are distributed via Swift Package Manager (and Carthage)
only.

## Steps

1. In the project directory, remove the `pod 'AppAuth'` (and any
   `pod 'AppAuth/...'`) lines from the `Podfile`. If AppAuth was the only pod,
   run `pod deintegrate`, delete the `Podfile`, `Podfile.lock`, and the
   generated `.xcworkspace`, and open the `.xcodeproj` from then on.
2. In Xcode: **File > Add Package Dependencies…**, enter
   `https://github.com/openid/AppAuth-iOS`, and choose "Up to Next Major
   Version" from the current version.
3. Add the product(s) matching your old subspec(s) to each target (table below).
4. Update imports (table below), then clean the build folder and build.

| Podfile entry | SPM product | Swift import | Objective-C import |
| --- | --- | --- | --- |
| `pod 'AppAuth'` (default: Core + ExternalUserAgent) | `AppAuth` | `import AppAuth` | `@import AppAuth;` |
| `pod 'AppAuth/Core'` | `AppAuthCore` | `import AppAuthCore` | `@import AppAuthCore;` |
| `pod 'AppAuth/ExternalUserAgent'` | `AppAuth` | `import AppAuth` | `@import AppAuth;` |
| `pod 'AppAuth/TV'` | `AppAuthTV` | `import AppAuthTV` (plus `import AppAuthCore` for core types) | `@import AppAuthTV;` `@import AppAuthCore;` |

Under CocoaPods every subspec compiled into a single module named `AppAuth`, so
imports such as `#import <AppAuth/AppAuthTV.h>` or `#import "AppAuth.h"` must
change to the module imports above. App extensions that only need core types
should link `AppAuthCore`.

## Don't mix package managers

If another pod in your `Podfile` depends on AppAuth (for example GTMAppAuth or
GoogleSignIn installed via CocoaPods), migrate those to Swift Package Manager at
the same time. Mixing CocoaPods and Swift Package Manager copies of the same
library in one target leads to duplicate symbols, dependency cycles and build
errors.

## If you can't migrate yet

You can stay on AppAuth 3.0.0 via CocoaPods, or use
[Carthage](README.md#carthage).

## Cross-platform wrappers

Cross-platform frameworks (React Native, Flutter, etc.) integrate AppAuth
through their own plugin's packaging. Check the plugin's own documentation for
its Swift Package Manager support rather than editing its `Podfile` entries
directly.
