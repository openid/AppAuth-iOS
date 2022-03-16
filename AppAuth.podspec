Pod::Spec.new do |s|

  s.name         = "AppAuth"
  s.version      = "1.4.0"
  s.summary      = "AppAuth for iOS and macOS is a client SDK for communicating with OAuth 2.0 and OpenID Connect providers."

  s.description  = <<-DESC

AppAuth for iOS and macOS is a client SDK for communicating with [OAuth 2.0]
(https://tools.ietf.org/html/rfc6749) and [OpenID Connect]
(http://openid.net/specs/openid-connect-core-1_0.html) providers. It strives to
directly map the requests and responses of those specifications, while following
the idiomatic style of the implementation language. In addition to mapping the
raw protocol flows, convenience methods are available to assist with common
tasks like performing an action with fresh tokens.

It follows the OAuth 2.0 for Native Apps best current practice
([RFC 8252](https://tools.ietf.org/html/rfc8252)).

                   DESC

  s.homepage     = "https://openid.github.io/AppAuth-iOS"
  s.license      = "Apache License, Version 2.0"
  s.authors      = { "William Denniss" => "wdenniss@google.com",
                     "Steven E Wright" => "stevewright@google.com",
                     "Julien Bodet" => "julien.bodet92@gmail.com"
                   }

  # Note: While watchOS and tvOS are specified here, only iOS and macOS have
  #       UI implementations of the authorization service. You can use the
  #       classes of AppAuth with tokens on watchOS and tvOS, but currently the
  #       library won't help you obtain authorization grants on those platforms.

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/openid/AppAuth-iOS.git", :tag => s.version }
  s.requires_arc = true

  # Subspec for the core AppAuth library classes only, suitable for extensions.
  s.subspec 'Core' do |core|
     core.source_files = "Source/*.{h,m}", "Source/AppAuthCore/*.{h,m}"
     core.exclude_files = "Source/AppAuth.h"
  end

  # Subspec for the full AppAuth library, including platform-dependant external user agents.
  s.subspec 'ExternalUserAgent' do |externalUserAgent|
    externalUserAgent.dependency 'AppAuth/Core'
    
    externalUserAgent.source_files = "Source/AppAuth.h", "Source/AppAuth/*.{h,m}"
    
    # iOS
    externalUserAgent.ios.source_files      = "Source/AppAuth/iOS/**/*.{h,m}"
    externalUserAgent.ios.deployment_target = "7.0"
    externalUserAgent.ios.frameworks        = "SafariServices"
    externalUserAgent.ios.weak_frameworks   = "AuthenticationServices"

    # macOS
    externalUserAgent.osx.source_files = "Source/AppAuth/macOS/**/*.{h,m}"
    externalUserAgent.osx.deployment_target = '10.9'
  end
  
  s.default_subspec = 'Core', 'ExternalUserAgent'
end
