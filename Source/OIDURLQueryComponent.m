/*! @file OIDURLQueryComponent.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2015 Google Inc. All Rights Reserved.
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

#import "OIDURLQueryComponent.h"

#if TARGET_OS_IOS
#import "OIDURLQueryComponent+IOS.h"
#elif TARGET_OS_MAC
#import "OIDURLQueryComponent+Mac.h"
#endif

BOOL gOIDURLQueryComponentForceIOS7Handling = NO;

/*! @brief String representing the set of characters that are valid for the URL query
        (per @ NSCharacterSet.URLQueryAllowedCharacterSet), but are disallowed in URL query
        parameters and values.
 */
static NSString *const kQueryStringParamAdditionalDisallowedCharacters = @"=&+";

@implementation OIDURLQueryComponent

- (nullable instancetype)init {
  self = [super init];
  if (self) {
    _parameters = [NSMutableDictionary dictionary];
  }
  return self;
}

- (NSArray<NSString *> *)parameters {
  return _parameters.allKeys;
}

- (NSDictionary<NSString *, NSObject<NSCopying> *> *)dictionaryValue {
  // This method will flatten arrays in our @c _parameters' values if only one value exists.
  NSMutableDictionary<NSString *, NSObject<NSCopying> *> *values = [NSMutableDictionary dictionary];
  for (NSString *parameter in _parameters.allKeys) {
    NSArray<NSString *> *value = _parameters[parameter];
    if (value.count == 1) {
      values[parameter] = [value.firstObject copy];
    } else {
      values[parameter] = [value copy];
    }
  }
  return values;
}

- (NSArray<NSString *> *)valuesForParameter:(NSString *)parameter {
  return _parameters[parameter];
}

- (void)addParameter:(NSString *)parameter value:(NSString *)value {
  NSMutableArray<NSString *> *parameterValues = _parameters[parameter];
  if (!parameterValues) {
    parameterValues = [NSMutableArray array];
    _parameters[parameter] = parameterValues;
  }
  [parameterValues addObject:value];
}

- (void)addParameters:(NSDictionary<NSString *, NSString *> *)parameters {
  for (NSString *parameterName in parameters.allKeys) {
    [self addParameter:parameterName value:parameters[parameterName]];
  }
}

/*! @brief Builds a query string that can be set to @c NSURLComponents.percentEncodedQuery
    @discussion This string is percent encoded, and shouldn't be used with
        @c NSURLComponents.query.
    @return An percentage encoded query string.
 */
- (NSString *)percentEncodedQueryString {
  NSMutableArray<NSString *> *parameterizedValues = [NSMutableArray array];

  // Starts with the standard URL-allowed character set.
  NSMutableCharacterSet *allowedParamCharacters =
      [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
  // Removes additional characters we don't want to see in the query component.
  [allowedParamCharacters removeCharactersInString:kQueryStringParamAdditionalDisallowedCharacters];

  for (NSString *parameterName in _parameters.allKeys) {
    NSString *encodedParameterName =
        [parameterName stringByAddingPercentEncodingWithAllowedCharacters:allowedParamCharacters];

    NSArray<NSString *> *values = _parameters[parameterName];
    for (NSString *value in values) {
      NSString *encodedValue =
          [value stringByAddingPercentEncodingWithAllowedCharacters:allowedParamCharacters];
      NSString *parameterizedValue =
          [NSString stringWithFormat:@"%@=%@", encodedParameterName, encodedValue];
      [parameterizedValues addObject:parameterizedValue];
    }
  }

  NSString *queryString = [parameterizedValues componentsJoinedByString:@"&"];
  return queryString;
}

- (NSURL *)URLByReplacingQueryInURL:(NSURL *)URL {
  NSURLComponents *components =
      [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];

  // Replaces encodedQuery component
  NSString *queryString = [self URLEncodedParameters];
  components.percentEncodedQuery = queryString;

  NSURL *URLWithParameters = components.URL;
  return URLWithParameters;
}

#pragma mark - NSObject overrides

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, parameters: %@>",
                                    NSStringFromClass([self class]),
                                    self,
                                    _parameters];
}

@end
