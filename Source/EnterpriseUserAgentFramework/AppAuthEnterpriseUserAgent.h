/*! @file AppAuthEnterpriseUserAgentEnterpriseUserAgent.h
   @brief AppAuthEnterpriseUserAgent iOS SDK
   @copyright
       Copyright 2020 Google Inc. All Rights Reserved.
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

#import <Foundation/Foundation.h>

//! Project version number for AppAuthEnterpriseUserAgentEnterpriseUserAgentFramework.
FOUNDATION_EXPORT double AppAuthEnterpriseUserAgentEnterpriseUserAgentVersionNumber;

//! Project version string for AppAuthEnterpriseUserAgentEnterpriseUserAgentFramework.
FOUNDATION_EXPORT const unsigned char AppAuthEnterpriseUserAgentEnterpriseUserAgentVersionString[];

#import <AppAuthEnterpriseUserAgent/OIDAuthState.h>
#import <AppAuthEnterpriseUserAgent/OIDAuthStateChangeDelegate.h>
#import <AppAuthEnterpriseUserAgent/OIDAuthStateErrorDelegate.h>
#import <AppAuthEnterpriseUserAgent/OIDAuthorizationRequest.h>
#import <AppAuthEnterpriseUserAgent/OIDAuthorizationResponse.h>
#import <AppAuthEnterpriseUserAgent/OIDAuthorizationService.h>
#import <AppAuthEnterpriseUserAgent/OIDError.h>
#import <AppAuthEnterpriseUserAgent/OIDErrorUtilities.h>
#import <AppAuthEnterpriseUserAgent/OIDExternalUserAgent.h>
#import <AppAuthEnterpriseUserAgent/OIDExternalUserAgentRequest.h>
#import <AppAuthEnterpriseUserAgent/OIDExternalUserAgentSession.h>
#import <AppAuthEnterpriseUserAgent/OIDGrantTypes.h>
#import <AppAuthEnterpriseUserAgent/OIDIDToken.h>
#import <AppAuthEnterpriseUserAgent/OIDRegistrationRequest.h>
#import <AppAuthEnterpriseUserAgent/OIDRegistrationResponse.h>
#import <AppAuthEnterpriseUserAgent/OIDResponseTypes.h>
#import <AppAuthEnterpriseUserAgent/OIDScopes.h>
#import <AppAuthEnterpriseUserAgent/OIDScopeUtilities.h>
#import <AppAuthEnterpriseUserAgent/OIDServiceConfiguration.h>
#import <AppAuthEnterpriseUserAgent/OIDServiceDiscovery.h>
#import <AppAuthEnterpriseUserAgent/OIDTokenRequest.h>
#import <AppAuthEnterpriseUserAgent/OIDTokenResponse.h>
#import <AppAuthEnterpriseUserAgent/OIDTokenUtilities.h>
#import <AppAuthEnterpriseUserAgent/OIDURLSessionProvider.h>
#import <AppAuthEnterpriseUserAgent/OIDEndSessionRequest.h>
#import <AppAuthEnterpriseUserAgent/OIDEndSessionResponse.h>

#import <AppAuthEnterpriseUserAgent/OIDAuthState+IOS.h>
#import <AppAuthEnterpriseUserAgent/OIDAuthorizationService+IOS.h>
#import <AppAuthEnterpriseUserAgent/OIDExternalUserAgentIOS.h>
#import "AppAuthEnterpriseUserAgent/OIDExternalUserAgentCatalyst.h"

#import <AppAuthEnterpriseUserAgent/OIDExternalUserAgentIOSCustomBrowser.h>
