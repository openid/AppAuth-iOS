/*! @file AppAuth.h
 @brief AppAuth iOS SDK
 @copyright
 Copyright 2018 Google LLC
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

#ifndef AppAuth_h
#define AppAuth_h

#import "OIDAuthState.h"
#import "OIDAuthStateChangeDelegate.h"
#import "OIDAuthStateErrorDelegate.h"
#import "OIDAuthorizationRequest.h"
#import "OIDAuthorizationResponse.h"
#import "OIDAuthorizationService.h"
#import "OIDError.h"
#import "OIDErrorUtilities.h"
#import "OIDExternalUserAgent.h"
#import "OIDExternalUserAgentRequest.h"
#import "OIDExternalUserAgentSession.h"
#import "OIDGrantTypes.h"
#import "OIDIDToken.h"
#import "OIDRegistrationRequest.h"
#import "OIDRegistrationResponse.h"
#import "OIDResponseTypes.h"
#import "OIDScopes.h"
#import "OIDScopeUtilities.h"
#import "OIDServiceConfiguration.h"
#import "OIDServiceDiscovery.h"
#import "OIDTokenRequest.h"
#import "OIDTokenResponse.h"
#import "OIDTokenUtilities.h"
#import "OIDURLSessionProvider.h"

#ifdef APPAUTH_USERAGENT

#if TARGET_OS_TV
#elif TARGET_OS_WATCH
#elif TARGET_OS_IOS
#import "OIDAuthState+IOS.h"
#import "OIDAuthorizationService+IOS.h"
#import "OIDExternalUserAgentIOS.h"
#import "OIDExternalUserAgentIOSCustomBrowser.h"
#elif TARGET_OS_MAC
#import "OIDAuthState+Mac.h"
#import "OIDAuthorizationService+Mac.h"
#import "OIDExternalUserAgentMac.h"
#import "OIDRedirectHTTPHandler.h"
#else
#error "Platform Undefined"
#endif

# endif /* APPAUTH_USERAGENT */

#endif /* AppAuth_h */
