# Example Project

## Hosted Login Comments

You need to install cocoa pods. I found it not terrible but a necessary step. Then follow the setup steps under Setup & Open the Project
```
gem install cocoapods
```

This has been configured to work with my client. If you want to use your own make sure the deep-link is correctly set up in your client.


## Gizmo Cert

Out of the box this is configured for your vagrant box. This causes that your simulated phone will not trust the certificate.
This link : https://developer.apple.com/documentation/security/preventing_insecure_network_connections has the settings that should allow you to configure
your phone to trust the sites. If after set up it still causing issues when shown the insecure connection page press 'you can visit the website' then 'visit the website' and it will allow you through.

## Setup & Open the Project

1. In the `Example-iOS_ObjC` folder, run the following command to install the
AppAuth pod.

```
pod install
```

2. Open the `Example-iOS_ObjC.xcworkspace` workspace.

```
open Example-iOS_ObjC.xcworkspace
```

This workspace is configured to include AppAuth via CocoaPods. You can also
directly include AppAuth as a static library using the build targets in the
`AppAuth.xcodeproj` project.

## Configuration

The example doesn't work out of the box, you need to configure it with your own
client ID.

### Information You'll Need

* Issuer
* Client ID
* Redirect URI
* Logout url

How to get this information varies by IdP, but we have
[instructions](../README.md#openid-certified-providers) for some OpenID
Certified providers.

### Configure the Example

#### In the file `AppAuthExampleViewController.m` 

1. Update `kIssuer` with the IdP's issuer.
2. Update `kClientID` with your new client id.
3. Update `kRedirectURI` redirect URI
4. Update 'kLogoutURI' logout endpoint

#### In the file `Info.plist`

Fully expand "URL types" (a.k.a. `CFBundleURLTypes`) and replace
`com.example.app` with the *scheme* of your redirect URI. 
The scheme is everything before the colon (`:`).  For example, if the redirect
URI is `com.example.app:/oauth2redirect/example-provider`, then the scheme
would be `com.example.app`.

### Running the Example

Now your example should be ready to run.

