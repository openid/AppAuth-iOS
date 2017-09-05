#import <Foundation/Foundation.h>

@class OIDLogoutRequest;

NS_ASSUME_NONNULL_BEGIN

/*! @brief Represents the response to an authorization request.
 @see https://tools.ietf.org/html/rfc6749#section-4.1.2
 */

@interface OIDLogoutResponse : NSObject <NSCopying, NSSecureCoding> {
    OIDLogoutRequest *_request;
    NSString *_state;
}

/*! @brief The request which was serviced.
 */
@property(nonatomic, readonly) OIDLogoutRequest *request;

/*! @brief REQUIRED if the "state" parameter was present in the client authorization request. The
 exact value received from the client.
 @remarks state
 */
@property(nonatomic, readonly, nullable) NSString *state;

/*! @internal
 @brief Unavailable. Please use initWithParameters:.
 */
- (instancetype)init NS_UNAVAILABLE;

/*! @brief Designated initializer.
 @param request The serviced request.
 @param parameters The decoded parameters returned from the Authorization Server.
 @remarks Known parameters are extracted from the @c parameters parameter and the normative
 properties are populated. Non-normative parameters are placed in the
 @c #additionalParameters dictionary.
 */
- (instancetype)initWithRequest:(OIDLogoutRequest *)request
                     parameters:(NSDictionary<NSString *, NSObject<NSCopying> *> *)parameters
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
