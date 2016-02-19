# Example Project

## Configuration

The example doesn't work out of the box, you need to configure it your own
client ID.

### Creating a Google OAuth Client

To configure the sample with a Google OAuth client, visit
https://console.developers.google.com/apis/credentials?project=_ and create a
new project. Then tap "Create credentials" and select "OAuth client ID".
Follow the instructions to configure the consent screen (just the Product Name
is needed).

Then, complete the OAuth client creation by selecting "iOS" as the Application
type.  Enter the Bundle ID of the project (`net.openid.appauth.Example` by
default, but you may want to change this in the project and use your own
Bundle ID).

Copy the client ID to the clipboard.

### Configure the Example

In `AppAuthExampleViewController.m` update `kClientID` with your new client id.

In the same file, update `kRedirectURI` with the *reverse DNS notation* form
of the client ID. For example, if the client ID is
`YOUR_CLIENT.apps.googleusercontent.com`, the reverse DNS notation would be
`com.googleusercontent.apps.YOUR_CLIENT`. A path component is added resulting in
`com.googleusercontent.apps.YOUR_CLIENT:/oauthredirect`.

Finally, open `Info.plist` and fully expand "URL types" (a.k.a.
"CFBundleURLTypes") and replace `com.googleusercontent.apps.YOUR_CLIENT` with
the reverse DNS notation form of your client id (not including the
`:/oauthredirect` path component).

Once you have made those three changes, the sample should be ready to try with
your new OAuth client.
