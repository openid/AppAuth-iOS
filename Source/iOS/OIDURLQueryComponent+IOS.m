#import "OIDURLQueryComponent+IOS.h"

NS_ASSUME_NONNULL_BEGIN

@implementation OIDURLQueryComponent (Mac)

- (nullable instancetype)initWithURL:(NSURL *)URL {
    self = [self init];
    if (self) {
        if (@available(iOS 8.0, *)) {
            // If NSURLQueryItem is available, use it for deconstructing the new URL. (iOS 8+)
            if (!gOIDURLQueryComponentForceIOS7Handling) {
                NSURLComponents *components =
                [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
                NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
                for (NSURLQueryItem *queryItem in queryItems) {
                    [self addParameter:queryItem.name value:queryItem.value];
                }
                return self;
            }
        }
        
        NSString *query = URL.query;
        NSArray<NSString *> *queryParts = [query componentsSeparatedByString:@"&"];
        for (NSString *queryPart in queryParts) {
            NSRange equalsRange = [queryPart rangeOfString:@"="];
            if (equalsRange.location == NSNotFound) {
                continue;
            }
            NSString *name = [queryPart substringToIndex:equalsRange.location];
            name = name.stringByRemovingPercentEncoding;
            NSString *value = [queryPart substringFromIndex:equalsRange.location + equalsRange.length];
            value = value.stringByRemovingPercentEncoding;
            [self addParameter:name value:value];
        }
        return self;
    }
    return self;
}

- (NSString *)URLEncodedParameters {
    // If NSURLQueryItem is available, uses it for constructing the encoded parameters. (iOS 8+)
    if (@available(iOS 8.0, *)) {
        if (!gOIDURLQueryComponentForceIOS7Handling) {
            NSURLComponents *components = [[NSURLComponents alloc] init];
            components.queryItems = [self queryItems];
            NSString *encodedQuery = components.percentEncodedQuery;
            // NSURLComponents.percentEncodedQuery creates a validly escaped URL query component, but
            // doesn't encode the '+' leading to potential ambiguity with application/x-www-form-urlencoded
            // encoding. Percent encodes '+' to avoid this ambiguity.
            encodedQuery = [encodedQuery stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            return encodedQuery;
        }
    }
    
    return [self percentEncodedQueryString];
}

/*! @brief Builds a query items array that can be set to @c NSURLComponents.queryItems
 @discussion The parameter names and values are NOT URL encoded.
 @return An array of unencoded @c NSURLQueryItem objects.
 */
- (NSMutableArray<NSURLQueryItem *> *)queryItems CF_AVAILABLE_IOS(8.0) {
    NSMutableArray<NSURLQueryItem *> *queryParameters = [NSMutableArray array];
    for (NSString *parameterName in _parameters.allKeys) {
        NSArray<NSString *> *values = _parameters[parameterName];
        for (NSString *value in values) {
            NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:parameterName value:value];
            [queryParameters addObject:item];
        }
    }
    return queryParameters;
}


@end

NS_ASSUME_NONNULL_END
