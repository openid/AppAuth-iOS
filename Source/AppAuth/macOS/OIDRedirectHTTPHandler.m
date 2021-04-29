/*! @file OIDRedirectHTTPHandler.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2016 Google Inc. All Rights Reserved.
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

#import <TargetConditionals.h>

#if TARGET_OS_OSX

#import "OIDRedirectHTTPHandler.h"

#import "OIDAuthorizationService.h"
#import "OIDErrorUtilities.h"
#import "OIDExternalUserAgentSession.h"
#import "OIDLoopbackHTTPServer.h"

/*! @brief Template for page that is returned following a completed authorization or authorization error.
        Show your own success page instead by supplying a URL in @c initWithSuccessURL that
        the user will be redirected to.
 */
static NSString *const kHTMLPageTemplate = @""
    "<!DOCTYPE html>"
    "<html lang=\"en\" dir=\"ltr\" xmlns=\"http://www.w3.org/1999/xhtml\">"
    "<head>"
    "    <meta charset=\"utf-8\" />"
    "    <title>%@</title>"
    "    <style>"
    "body {"
    "    font-family: -apple-system, BlinkMacSystemFont, \"Avenir Next\", Avenir,"
    "                 \"Nimbus Sans L\", Roboto, Noto, \"Segoe UI\", Arial,"
    "                 Helvetica, \"Helvetica Neue\", sans-serif;"
    "    margin: 0;"
    "    height: 100vh;"
    "    display: flex;"
    "    align-items: center;"
    "    justify-content: center;"
    "    background: #ccc;"
    "    color: #888;"
    "}"
    "main {"
    "    padding: 1em 2em;"
    "    text-align: center;"
    "    border: 1pt solid #666;"
    "    box-shadow: rgba(0, 0, 0, 0.2) 0px 1px 4px;"
    "    border-color: #aaa;"
    "    background: #ddd;"
    "}"
    "    </style>"
    "</head>"
    "<body class=\"finished\">"
    "    <main>"
    "        <h2>%@</h2>"
    "        <p>%@</p>"
    "    </main>"
    "</body>"
    "</html>";

/*! @brief Title, heading and message for HTML success page that is shown following a completed authorization.
        Show your own page instead by supplying a URL in @c initWithSuccessURL that
        the user will be redirected to.
 */
static NSString *const kStringsAuthorizationComplete[] =
    {
        @"Authorization Successful",
        @"The client authorized succesfully",
        @"You can now close this tab."
    };

/*! @brief Title, heading and message for HTML error page warning that the
        @c currentAuthorizationFlow is not set on this object (likely a
        developer error, unless the user stumbled upon the loopback server before the authorization
        had started completely).
        @description An object conforming to @c OIDExternalUserAgentSession is returned when the
        authorization is presented with
        @c OIDAuthorizationService::presentAuthorizationRequest:callback:. It should be set to
        @c currentAuthorization when using a loopback redirect.
 */
static NSString *const kStringsErrorMissingCurrentAuthorizationFlow[] =
    {
        @"Authorization Error",
        @"Authorization Error",
        @"AppAuth Error: No <code>currentAuthorizationFlow</code> is set on the "
         "<code>OIDRedirectHTTPHandler</code>. Cannot process redirect."
    };

/*! @brief Title, heading and message for HTML error page warning that the URL does not represent a
        valid redirect. This should be rare, may happen if the user stumbles upon the loopback server randomly.
 */
static NSString *const kStringsErrorRedirectNotValid[] =
    {
        @"Authorization Error",
        @"Authorization Error",
        @"AppAuth Error: Not a valid redirect."
    };

@implementation OIDRedirectHTTPHandler {
  HTTPServer *_httpServ;
  NSURL *_successURL;
}

- (instancetype)init {
  return [self initWithSuccessURL:nil];
}

- (instancetype)initWithSuccessURL:(nullable NSURL *)successURL {
  self = [super init];
  if (self) {
    _successURL = [successURL copy];
  }
  return self;
}

- (NSURL *)startHTTPListener:(NSError **)returnError withPort:(uint16_t)port {
  // Cancels any pending requests.
  [self cancelHTTPListener];

  // Starts a HTTP server on the loopback interface.
  // By not specifying a port, a random available one will be assigned.
  _httpServ = [[HTTPServer alloc] init];
  [_httpServ setPort:port];
  [_httpServ setDelegate:self];
  NSError *error = nil;
  if (![_httpServ start:&error]) {
    if (returnError) {
      *returnError = error;
    }
    return nil;
  } else if ([_httpServ hasIPv4Socket]) {
    // Prefer the IPv4 loopback address
    NSString *serverURL = [NSString stringWithFormat:@"http://127.0.0.1:%d/", [_httpServ port]];
    return [NSURL URLWithString:serverURL];
  } else if ([_httpServ hasIPv6Socket]) {
    // Use the IPv6 loopback address if IPv4 isn't available
    NSString *serverURL = [NSString stringWithFormat:@"http://[::1]:%d/", [_httpServ port]];
    return [NSURL URLWithString:serverURL];
  }

  return nil;
}

- (NSURL *)startHTTPListener:(NSError **)returnError {
  // A port of 0 requests a random available port
  return [self startHTTPListener:returnError withPort:0];
}

- (void)cancelHTTPListener {
  [self stopHTTPListener];

  // Cancels the pending authorization flow (if any) with error.
  NSError *cancelledError =
      [OIDErrorUtilities errorWithCode:OIDErrorCodeProgramCanceledAuthorizationFlow
                       underlyingError:nil
                           description:@"The HTTP listener was cancelled programmatically."];
  [_currentAuthorizationFlow failExternalUserAgentFlowWithError:cancelledError];
  _currentAuthorizationFlow = nil;
}

/*! @brief Stops listening on the loopback interface without modifying the state of the
        @c currentAuthorizationFlow. Should be called when the authorization flow completes or is
        cancelled.
 */
- (void)stopHTTPListener {
  _httpServ.delegate = nil;
  [_httpServ stop];
  _httpServ = nil;
}

- (void)HTTPConnection:(HTTPConnection *)conn didReceiveRequest:(HTTPServerRequest *)mess {
  // Sends URL to AppAuth.
  CFURLRef url = CFHTTPMessageCopyRequestURL(mess.request);
  BOOL handled = [_currentAuthorizationFlow resumeExternalUserAgentFlowWithURL:(__bridge NSURL *)url];

  // Stops listening to further requests after the first valid authorization response.
  if (handled) {
    _currentAuthorizationFlow = nil;
    [self stopHTTPListener];
  }

  NSString *bodyText = @"";
  NSInteger httpResponseCode = 0;

  if (handled) {
    bodyText = [NSString stringWithFormat:kHTMLPageTemplate,
                kStringsAuthorizationComplete[0],
                kStringsAuthorizationComplete[1],
                kStringsAuthorizationComplete[2]];
    httpResponseCode = (_successURL) ? 302 : 200;
  } else if (_currentAuthorizationFlow) {
    bodyText = [NSString stringWithFormat:kHTMLPageTemplate,
                kStringsErrorMissingCurrentAuthorizationFlow[0],
                kStringsErrorMissingCurrentAuthorizationFlow[1],
                kStringsErrorMissingCurrentAuthorizationFlow[2]];
    httpResponseCode = 404;
  } else {
    bodyText = [NSString stringWithFormat:kHTMLPageTemplate,
                kStringsErrorRedirectNotValid[0],
                kStringsErrorRedirectNotValid[1],
                kStringsErrorRedirectNotValid[2]];
    httpResponseCode = 400;
  }

  NSAssert([bodyText length] > 0, @"bodyText is empty");
  NSAssert(httpResponseCode > 0, @"httpResponseCode is %d, should be greater than 0", httpResponseCode);

  NSData *data = [bodyText dataUsingEncoding:NSUTF8StringEncoding];

  CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault,
                                                          httpResponseCode,
                                                          NULL,
                                                          kCFHTTPVersion1_1);
  if (httpResponseCode == 302) {
    CFHTTPMessageSetHeaderFieldValue(response,
                                     (__bridge CFStringRef)@"Location",
                                     (__bridge CFStringRef)_successURL.absoluteString);
  }
  CFHTTPMessageSetHeaderFieldValue(response,
                                   (__bridge CFStringRef)@"Content-Length",
                                   (__bridge CFStringRef)[NSString stringWithFormat:@"%lu",
                                       (unsigned long)data.length]);
  CFHTTPMessageSetBody(response, (__bridge CFDataRef)data);

  [mess setResponse:response];
  CFRelease(response);
}

- (void)dealloc {
  [self cancelHTTPListener];
}

@end

#endif // TARGET_OS_MAC
