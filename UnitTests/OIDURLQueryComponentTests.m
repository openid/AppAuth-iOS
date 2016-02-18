/*! @file OIDURLQueryComponentTests.m
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

#import "OIDURLQueryComponentTests.h"

#import "Source/OIDURLQueryComponent.h"

/*! @var kTestParameterName
    @brief A testing parameter name.
 */
static NSString *const kTestParameterName = @"ParameterName";

/*! @var kTestParameterName2
    @brief A different testing parameter name.
 */
static NSString *const kTestParameterName2 = @"ParameterName2";

/*! @var kTestParameterValue
    @brief A testing parameter value.
 */
static NSString *const kTestParameterValue = @"ParameterValue";

/*! @var kTestParameterValue2
    @brief A different testing parameter value.
 */
static NSString *const kTestParameterValue2 = @"ParameterValue2";

/*! @var kTestSimpleParameterString
    @brief The result of generating a parameter string from:
        @@{ kTestParameterName : kTestParameterValue, kTestParameterName2 : kTestParameterValue2 }
 */
static NSString *const kTestSimpleParameterString =
    @"ParameterName=ParameterValue&ParameterName2=ParameterValue2";

/*! @var kTestMultipleValuesForKeyParameterString
    @brief The result of generating a parameter string from:
        @@{ kTestParameterName : @[ kTestParameterValue, kTestParameterValue2 ] }
 */
static NSString *const kTestMultipleValuesForKeyParameterString =
    @"ParameterName=ParameterValue&ParameterName=ParameterValue2";

/*! @var kTestURLRoot
    @brief A URL string to use for testing.
 */
static NSString *const kTestURLRoot = @"https://www.google.com/";

@implementation OIDURLQueryComponentTests

- (void)testAddingParameter {
  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] init];
  [query addParameter:kTestParameterName value:kTestParameterValue];
  XCTAssertEqualObjects([query valuesForParameter:kTestParameterName].firstObject,
                        kTestParameterValue);
}

- (void)testAddingTwoParameters {
  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] init];
  [query addParameter:kTestParameterName value:kTestParameterValue];
  XCTAssertEqualObjects([query valuesForParameter:kTestParameterName].firstObject,
                        kTestParameterValue);

  [query addParameter:kTestParameterName value:kTestParameterValue2];
  NSArray<NSString *> *values = [query valuesForParameter:kTestParameterName];
  XCTAssertNotNil(values);
  XCTAssertEqual(values.count, 2);
  XCTAssertEqualObjects(values.firstObject, kTestParameterValue);
  XCTAssertEqualObjects(values[1], kTestParameterValue2);
}

- (void)testAddingThreeParameters {
  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] init];
  [query addParameter:kTestParameterName value:kTestParameterValue];
  XCTAssertEqualObjects([query valuesForParameter:kTestParameterName].firstObject,
                        kTestParameterValue);

  [query addParameter:kTestParameterName value:kTestParameterValue2];
  [query addParameter:kTestParameterName value:kTestParameterValue];
  NSArray<NSString *> *values = [query valuesForParameter:kTestParameterName];
  XCTAssertNotNil(values);
  XCTAssertEqual(values.count, 3);
  XCTAssertEqualObjects(values.firstObject, kTestParameterValue);
  XCTAssertEqualObjects(values[1], kTestParameterValue2);
  XCTAssertEqualObjects(values[2], kTestParameterValue);

  NSDictionary<NSString *, NSObject<NSCopying> *> *parametersAsDictionary = @{
    kTestParameterName : @[ kTestParameterValue, kTestParameterValue2, kTestParameterValue ]
  };

  XCTAssertEqualObjects(query.dictionaryValue, parametersAsDictionary);
}

- (void)testBuildingParameterStringWithSimpleParameters {
  NSDictionary<NSString *, NSString *> *parameters =
      @{
        kTestParameterName : kTestParameterValue,
        kTestParameterName2 : kTestParameterValue2
      };
  NSURL *rootURL = [NSURL URLWithString:kTestURLRoot];

  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] init];
  [query addParameters:parameters];
  NSURL *rootURLWithParameters = [query URLByReplacingQueryInURL:rootURL];

  OIDURLQueryComponent *parsedParameters =
      [[OIDURLQueryComponent alloc] initWithURL:rootURLWithParameters];

  XCTAssertEqualObjects(parsedParameters.dictionaryValue, parameters);
}

- (void)testParsingQueryString {
  NSString *URLString =
      [NSString stringWithFormat:@"%@?%@", kTestURLRoot, kTestSimpleParameterString];
  NSURL *URLToParse = [NSURL URLWithString:URLString];
  OIDURLQueryComponent *query = [[OIDURLQueryComponent alloc] initWithURL:URLToParse];

  NSDictionary<NSString *, NSObject<NSCopying> *> *parameters =
      @{
        kTestParameterName : kTestParameterValue,
        kTestParameterName2 : kTestParameterValue2
      };

  XCTAssertEqualObjects(query.dictionaryValue, parameters);
}

@end
