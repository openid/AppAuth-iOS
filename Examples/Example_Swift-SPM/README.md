# Example Project (SwiftUI + Swift Package Manager)

## Setup & Open the Project

This sample uses the local AppAuth Swift Package via a relative path (`../..`), so Xcode resolves it automatically.

Just open `Example.xcodeproj` to get started, and complete the configuration.

## Configuration

The example doesn't work out of the box — you need to configure it with your own OpenID Connect client.

### Information You'll Need

* Issuer
* Client ID
* Redirect URI

How to get this information varies by IdP, but we have [instructions](../README.md#openid-certified-providers) for some OpenID Certified providers.

### Configure the Example

This sample reads them from an xcconfig file. Create your local override file by copying the committed defaults:

    cp Config/Example.xcconfig Config/Example.local.xcconfig

Then edit `Config/Example.local.xcconfig` and set:

    OIDC_ISSUER = <your IdP's issuer URL>
    OIDC_CLIENT_ID = <your client ID>
    OIDC_REDIRECT_URI = <your redirect URI>
    OIDC_REDIRECT_URI_SCHEME = <scheme portion of redirect URI>

The scheme is everything before the colon (:) of your redirect URI. For example, if the redirect URI is `com.example.app:/oauth2redirect/example-provider`, the scheme is `com.example.app`.

Note that the local version you create, `Config/Example.local.xcconfig`, is gitignored.

The same file can also override code-signing. By default the committed xcconfig sets CODE_SIGN_STYLE = Automatic, which causes Xcode to prompt for your team on first build — the same experience as the sibling samples. To use Manual signing with a specific provisioning profile, add these lines to Config/Example.local.xcconfig:

    CODE_SIGN_STYLE = Manual
    DEVELOPMENT_TEAM = <your team ID>
    PROVISIONING_PROFILE_SPECIFIER = <your profile name>

Note: Xcode may cache Info.plist substitutions — after editing the xcconfig, run **Product > Clean Build Folder**.

### Running the Example

Now your example should be ready to run.
