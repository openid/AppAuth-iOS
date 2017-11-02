#import <Foundation/Foundation.h>

@class OIDServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OIDLogoutRequest : NSObject <NSCopying, NSSecureCoding> {
    OIDServiceConfiguration *_configuration;
    NSURL *_postLogoutRedirectURL;
    NSString *_idTokenHint;
    NSString *_state;
    NSDictionary<NSString *, NSString *> *_additionalParameters;
}

/*! @brief The service's configuration.
 @remarks This configuration specifies how to connect to a particular OAuth provider.
 Configurations may be created manually, or via an OpenID Connect Discovery Document.
 */
@property(nonatomic, readonly) OIDServiceConfiguration *configuration;

/*! @brief The client's redirect URI.
 @remarks post_logout_redirect_uri
 @see http://openid.net/specs/openid-connect-session-1_0.html#RPLogout
 */
@property(nonatomic, readonly, nullable) NSURL *postLogoutRedirectURL;

/*! @brief  Previously issued ID Token passed to the logout endpoint as a hint about the End-User's current authenticated session with the Client
 @remarks id_token_hint
 @see http://openid.net/specs/openid-connect-session-1_0.html#RPLogout
 */
@property(nonatomic, readonly, nullable) NSString *idTokenHint;

/*! @brief An opaque value used by the client to maintain state between the request and callback.
 @remarks state
 @discussion If this value is not explicitly set, this library will automatically add state and
 perform appropriate validation of the state in the authorization response. It is recommended
 that the default implementation of this parameter be used wherever possible. Typically used
 to prevent CSRF attacks, as recommended in RFC6819 Section 5.3.5.
 @see https://tools.ietf.org/html/rfc6749#section-4.1.1
 @see https://tools.ietf.org/html/rfc6819#section-5.3.5
 @see http://openid.net/specs/openid-connect-session-1_0.html#RPLogout
 */
@property(nonatomic, readonly, nullable) NSString *state;

/*! @brief The client's additional authorization parameters.
 @see https://tools.ietf.org/html/rfc6749#section-3.1
 */
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *additionalParameters;

/*! @internal
 @brief Unavailable. Please use
 @c initWithConfiguration:clientId:scopes:redirectURL:additionalParameters:.
 */
- (instancetype)init NS_UNAVAILABLE;

/*! @brief Creates an authorization request with opinionated defaults (a secure @c state).
 @param configuration The service's configuration.
 @param idTokenHint The previously issued ID Token
 @param postLogoutRedirectURL The client's post-logout redirect URI.
 callback.
 @param additionalParameters The client's additional authorization parameters.
*/
- (instancetype)
    initWithConfiguration:(OIDServiceConfiguration *)configuration
              idTokenHint:(NSString *)idTokenHint
    postLogoutRedirectURL:(NSURL *)postLogoutRedirectURL
     additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters;

/*! @brief Designated initializer.
 @param configuration The service's configuration.
 @param idTokenHint The previously issued ID Token
 @param postLogoutRedirectURL The client's post-logout redirect URI.
 @param state An opaque value used by the client to maintain state between the request and
 callback.
 @param additionalParameters The client's additional authorization parameters.
 */
- (instancetype)
    initWithConfiguration:(OIDServiceConfiguration *)configuration
              idTokenHint:(NSString *)idTokenHint
    postLogoutRedirectURL:(NSURL *)postLogoutRedirectURL
                    state:(NSString *)state
     additionalParameters:(nullable NSDictionary<NSString *, NSString *> *)additionalParameters
    NS_DESIGNATED_INITIALIZER;

/*! @brief Constructs the request URI by adding the request parameters to the query component of the
 authorization endpoint URI using the "application/x-www-form-urlencoded" format.
 @return A URL representing the authorization request.
 @see http://openid.net/specs/openid-connect-session-1_0.html#RPLogout
 */
- (NSURL *)logoutRequestURL;

@end

NS_ASSUME_NONNULL_END
