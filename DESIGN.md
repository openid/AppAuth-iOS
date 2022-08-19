# AppAuth Project Design Principles

## About this Doc

The goal of this doc is to define a scope for AppAuth that we can reference when rejecting or
accepting feature requests, and give clarity to extension creators for what features should be
developed outside of the core project.

## What is AppAuth

### OAuth and OpenID Connect standards that support native apps

The goal of AppAuth is to provide a client library that follows best current practices for native
apps to use the OAuth and OpenID Connect authorization and authentication standards. We aim to
implement standards that are designed for, or work well with native apps and are in common use (and
will implement just those components of these standards that are commonly used).

These standards are currently supported:
1. [OAuth 2.0](https://tools.ietf.org/html/rfc67490)
2. [Proof Key for Code Exchange by OAuth Public Clients (PKCE)](https://tools.ietf.org/html/rfc7636)
3. [OAuth 2.0 for Native Apps](https://tools.ietf.org/html/rfc8252)
4. [OpenID Connect Core 1.0](http://openid.net/specs/openid-connect-core-1_0.html)
5. [Open ID Connect Discovery 1.0](https://openid.net/specs/openid-connect-discovery-1_0.html)
6. [OpenID Connect Dynamic Client Registration 1.0](https://openid.net/specs/openid-connect-registration-1_0.html)

Support for the following standards is also considered in-scope (see the below section on
prioritization):
1. [OAuth 2.0 Incremental Auth](https://tools.ietf.org/html/draft-ietf-oauth-incremental-auth)
2. [OAuth 2.0 Device Flow for Browserless and Input Constrained Devices](https://tools.ietf.org/html/rfc8628)
3. [OpenID Connect Front-Channel Logout 1.0](http://openid.net/specs/openid-connect-frontchannel-1_0.html)

### Design Principle

AppAuth aims to present as close to a 1:1 mapping of the spec as is possible, while following
language-specific idioms (like parameter capitalization). It performs some of the heavy lifting for
you so you don’t need to implement the spec yourself, but it does not hide the complexity of the
underlying specs.

Providers who want extremely simple user-friendly libraries aimed at developers who know nothing
about authorization and authentication standards are encouraged to wrap AppAuth in their own
purpose-built libraries.

### Extensibility

AppAuth aims to be as extensible as possible. Just as you can extend OAuth by adding parameters to a
URL (for example), the same should be possible in AppAuth.

This helps reduce the surface area of the library, as not everything needs to be hardcoded in as a
first-class citizen.

## What is out-of-scope for AppAuth

### Non-best-practice patterns

AppAuth is a best-practice library, it’s why we built it. We will not support things like embedded
WebViews, that are not considered a best practice. Please don’t ask.

### Implementing *every* spec parameter or branch

AppAuth exposes some required and popular parameters directly in its data model. It is a non-goal to
offer this support for every single parameter in the specifications. Less popular parameters, or
ones that simply don’t need special handling can be passed using the “additionalParameters” dictionary. 

Likewise, some specifications document several different sub-protocols. We don’t aim to implement
every single branch of the spec.

### Non-standard protocols and parameters

Non-standard protocols and parameters are not supported by AppAuth.  However, AppAuth, like the
specs it implements, is largely extensible and you may be able to achieve what you need through
these extension points. For example, simple additional parameters can be passed in the
“additionalParameters” dictionary, and the TokenRequest can support other grant types. 

By way of example, the tvOS device flow support (which may actually be considered in-scope one day)
was initially implemented on top of these extension points without needing to change AppAuth.

### Provider-specific workarounds, hacks or features

AppAuth implements the pure authentication and authorization standards. Where these standards are
clear in their meaning, errors in provider implementations are not supported or worked around by
AppAuth.  

Identity standards are well specified, and typically undergo years of review, including security
review before publication. If we accept every provider-specific idiosyncrasy then we are changing
the surface area in ways that are harder to maintain, and are less researched from a security
perspective.  There is generally no reason providers can’t offer correct standards-based
implementations, so this is what we expect.

When all providers follow the standards correctly, interoperability is improved for everyone. The
OpenID Connect foundation has been particularly active in supporting certification efforts to verify
implementations, and the test suits for these are available at no charge.

If the spec itself has a bug that cannot be worked around, then changes should be proposed through
the IETF and/or OpenID Foundation channels. AppAuth may implement such proposals, even while they
are in the early stages, if they are well received.

### Provider-specific examples

As AppAuth is pure standards-based, there is no need for provider-specific samples. Instead, we
encourage providers who have proved their compliance with the relevant standards to provide a
customized readme so their users can configure their own samples.

We also encourage providers to host their own AppAuth samples, in their own repositories.

## A word on feature requests

### Priorities

Just because something is in-scope, does not mean that the maintainers of AppAuth will add support
for it, or rapidly integrate pull requests.

The priority of AppAuth is stability and quality, not rapidly integrating feature requests. Pull
requests are thoroughly reviewed for style, the quality of the API, and future maintainability.

### Review Time

Expect review periods of 6 months to a year for integrating major new in-scope features. Our
priority as previously stated is stability and quality, not adding features as quickly as possible.
While you work with us to integrate your feature, we highly encourage you to maintain your own fork
so you and others can use the feature immediately – and gain valuable implementation experience.
