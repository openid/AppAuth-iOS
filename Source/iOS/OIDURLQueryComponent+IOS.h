#import "OIDURLQueryComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface OIDURLQueryComponent (Mac)

/*! @brief Creates an @c OIDURLQueryComponent by parsing the query string in a URL.
 @param URL The URL from which to extract a query component.
 */
- (nullable instancetype)initWithURL:(NSURL *)URL;


/**
 @brief Builds an x-www-form-urlencoded string representing the parameters.
 @return The x-www-form-urlencoded string representing the parameters.
 */
- (NSString *)URLEncodedParameters;

@end

NS_ASSUME_NONNULL_END

