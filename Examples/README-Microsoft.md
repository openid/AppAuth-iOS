NOTE TO SELF: This project on hold because our /common endpoint messes things up, and it's weird to use a tenant endpoint. 04-09-17

# Using AppAuth for iOS and macOS with Microsoft

Microsoft now supports signing in to both Azure Active Directory and Microsoft Accounts with a single client. To configure the sample with a Microsoft OAuth client, first visit
https://apps.dev.microsoft.com and create a
new app. Then tap "Add Platform" and select mobile. Save your application. Make note of your application/client ID.

## Add Redirect URI

Once saved, click "Edit Manifest" and a replyURLs to your application manifest. The format we recommend is `appauth://<client id>`. Below is an example.

```
    "replyUrls": [
        "http://localhost",
        "appauth://213a422f-837a-48db-9215-c8b7b98a2585"
        
    ],
```
Click Save.

Then follow the instructions for your platform:

## iOS

Then, setup the example with your configuration:

| Configuration | Description      |
|---------------|------------------|
| Issuer        | `https://accounts.google.com`|
| Client ID     | The value named `Client ID` in the console, has the format `213a422f-837a-48db-9215-c8b7b98a2585`.|
| Client Secret | Microsoft's iOS clients do not have a secret.|
| Redirect URI  | The value for `iOS URL scheme` wil be the scheme of your redirect URI. This is the Client ID in reverse domain name notation, e.g. `	com.googleusercontent.apps.IDENTIFIER`. To construct the redirect URI, add your own path component. E.g. `	com.googleusercontent.apps.IDENTIFIER:/oauth2redirect/google`. Note that there is only a single slash (`/`) after the scheme.| 
|

## macOS

Select "Other" as the application type.

Then, setup the example with your configuration:

| Configuration | Description      |
|---------------|------------------|
| Issuer        | `https://accounts.google.com`|
| Client ID     | The value named `Client ID` in the console, has the format `IDENTIFIER.apps.googleusercontent.com`.|
| Client Secret | The value named `Client secret` in the console.|
| Redirect URI  | For macOS, you can use either the loopback interface (where AppAuth will generate the redirect URI for you), or a custom scheme. To create a custom scheme redirect URI, reverse the client id to get the URI scheme, for example `	com.googleusercontent.apps.IDENTIFIER` and, add your own path component. E.g. `com.googleusercontent.apps.IDENTIFIER:/oauth2redirect/google`. Note that there is only a single slash (`/`) after the scheme.| 

