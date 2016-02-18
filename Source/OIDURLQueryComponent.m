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

BOOL gOIDURLQueryComponentForceIOS7Handling = NO;

@implementation OIDURLQueryComponent {
  /*! @var _parameters
      @brief A dictionary of parameter names and values representing the contents of the query.
   */
  NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *_parameters;
}

- (nullable instancetype)init {
  self = [super init];
  if (self) {
    _parameters = [NSMutableDictionary dictionary];
  }
  return self;
}

- (nullable instancetype)initWithURL:(NSURL *)URL {
  self = [self init];
  if (self) {
    if (!gOIDURLQueryComponentForceIOS7Handling && NSClassFromString(@"NSURLQueryItem")) {
      // If NSURLQueryItem is available, use it for deconstructing the new URL. (iOS 8+)
      NSURLComponents *components =
          [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
      NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
      for (NSURLQueryItem *queryItem in queryItems) {
        [self addParameter:queryItem.name value:queryItem.value];
      }
    } else {
      // Fallback for iOS 7
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
    }
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

- (NSMutableArray<NSURLQueryItem *> *)queryItems {
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

- (NSString *)queryString {
  NSMutableArray<NSString *> *parameterizedValues = [NSMutableArray array];
  NSCharacterSet *allowedQueryCharacters = [NSCharacterSet URLQueryAllowedCharacterSet];

  for (NSString *parameterName in _parameters.allKeys) {
    NSString *encodedParameterName =
        [parameterName stringByAddingPercentEncodingWithAllowedCharacters:allowedQueryCharacters];

    NSArray<NSString *> *values = _parameters[parameterName];
    for (NSString *value in values) {
      NSString *encodedValue =
          [value stringByAddingPercentEncodingWithAllowedCharacters:allowedQueryCharacters];
      NSString *parameterizedValue =
          [NSString stringWithFormat:@"%@=%@", encodedParameterName, encodedValue];
      [parameterizedValues addObject:parameterizedValue];
    }
  }

  NSString *queryString = [parameterizedValues componentsJoinedByString:@"&"];
  return queryString;
}

- (NSString *)URLEncodedParameters {
  // If NSURLQueryItem is available, use it for constructing the new URL. (iOS 8+)
  if (!gOIDURLQueryComponentForceIOS7Handling && NSClassFromString(@"NSURLQueryItem")) {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    NSMutableArray<NSURLQueryItem *> *queryItems = [self queryItems];
    components.queryItems = queryItems;
    NSString *query = components.query;
    return query;
  }

  return [self queryString];
}

- (NSURL *)URLByReplacingQueryInURL:(NSURL *)URL {
  NSURLComponents *components =
      [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];

  // If NSURLQueryItem is available, use it for constructing the new URL. (iOS 8+)
  if (!gOIDURLQueryComponentForceIOS7Handling && NSClassFromString(@"NSURLQueryItem")) {
    NSMutableArray<NSURLQueryItem *> *queryItems = [self queryItems];
    components.queryItems = queryItems;
  } else {
    // Fallback for iOS 7
    NSString *queryString = [self queryString];
    components.query = queryString;
  }

  NSURL *URLWithParameters = components.URL;
  return URLWithParameters;
}

@end
