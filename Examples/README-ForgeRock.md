# Using AppAuth for iOS with ForgeRock

[ForgeRock Access Management](https://www.forgerock.com/platform/access-management/) is a certified OpenID Connect provider and meets the requirements outlined in [RFC 8252](https://tools.ietf.org/html/rfc8252).

## Prerequisites

To configure AppAuth for iOS as an OAuth 2.0 Client/OpenID Connect Relying Party, you will need an instance of ForgeRock Access Management. An easy way to get it up and running is to follow the instructions provided in the [ForgeRock Identity Platform for Development](https://github.com/ForgeRock/forgeops/blob/master/README-skaffold.md) sample.


## Configuring OAuth 2.0 Client

Register your AppAuth application as an OAuth 2.0 client in ForgeRock Access Management Admin UI by navigating to _Realm Name_ > Applications > OAuth 2.0 > Clients.

Then, configure your AppAuth sample with the registered values:

| Configuration | Description      |
|---------------|------------------|
| Issuer        | The fully qualified domain name and the path to your ForgeRock Access Management deployment.|
| Client ID     | The value displayed as CLIENT ID in ForgeRock Access Management Admin UI.|
| Redirect URI  | One of the values listed in the Redirection URIs field for the client. This value can be based on a [private-use (custom) URI scheme](https://tools.ietf.org/html/rfc8252#section-7.1) or a [claimed "https" scheme URI](https://tools.ietf.org/html/rfc8252#section-7.2). In the latter case, the redirection URI will need to be configured as a [Universal Link](https://developer.apple.com/ios/universal-links/).|


A Swift example:

```swift
/**
 The OIDC issuer from which the configuration will be discovered.
*/
let kIssuer: String = "https://default.iam.example.com/am";

/**
 The OAuth client ID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 Set to nil to use dynamic registration with this example.
*/
let kClientID: String? = "CLIENT-ID.apps.example.com";

/**
 The OAuth redirect URI for the client @c kClientID.

 For client configuration instructions, see the [README](https://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
*/
let kRedirectURI: String = "com.example.apps.CLIENT-ID:/oauth2redirect/default.iam.example.com";

// Or, a Universal Link
// let kRedirectURI: String = "https://apps.example.com/CLIENT-ID/oauth2redirect/default.iam.example.com"
```

## Additional Information

The ForgeRock Access Management [OAuth 2.0 Guide](https://backstage.forgerock.com/docs/am/6.5/oauth2-guide/index.html#oauth2-guide) and  [OpenID Connect 1.0 Guide](https://backstage.forgerock.com/docs/am/6.5/oidc1-guide/) cover in detail the concepts, configuration, and usage procedures for working with OAuth 2.0, OpenID Connect, and ForgeRock Access Management.

[Implementing OAuth 2.0 Authorization Code Grant protected by PKCE with the AppAuth SDK in iOS apps](https://developer.forgerock.com/docs/platform/how-tos/implementing-oauth-20-authorization-code-grant-protected-pkce-appauth-sdk-ios), published on the ForgeRock Developer's site, elaborates on the principles of building an OpenID Connect Relying Party in iOS, provides a step-by-step walk through with Swift and AppAuth, and demonstrates how the ForgeRock Platform components can play the roles of an OpenID Connect Provider and a Resource Server.
