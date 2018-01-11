/*! @file OIDEndSessionResponse.m
    @brief AppAuth iOS SDK
    @copyright
        Copyright 2017 The AppAuth Authors. All Rights Reserved.
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

#import "OIDEndSessionResponse.h"

#import "OIDEndSessionRequest.h"
#import "OIDDefines.h"

/*! @brief The key for the @c state property in the incoming parameters and for @c NSSecureCoding.
 */
static NSString *const kStateKey = @"state";

/*! @brief Key used to encode the @c request property for @c NSSecureCoding
 */
static NSString *const kRequestKey = @"request";

@implementation OIDEndSessionResponse

@synthesize request = _request;
@synthesize state = _state;

#pragma mark - Initializers

- (instancetype)init
OID_UNAVAILABLE_USE_INITIALIZER(@selector(initWithRequest:parameters:))

- (instancetype)initWithRequest:(OIDEndSessionRequest *)request parameters:(NSDictionary<NSString *,NSObject<NSCopying> *> *)parameters
{
    self = [super init];
    if (self) {
        _request = [request copy];
        _state = [parameters[kStateKey] copy];
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    // The documentation for NSCopying specifically advises us to return a reference to the original
    // instance in the case where instances are immutable (as ours is):
    // "Implement NSCopying by retaining the original instead of creating a new copy when the class
    // and its contents are immutable."
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    OIDEndSessionRequest *request = [aDecoder decodeObjectOfClass:[OIDEndSessionRequest class] forKey:kRequestKey];
    NSString *state = [aDecoder decodeObjectOfClass:[NSString class] forKey:kStateKey];

    self = [self initWithRequest:request parameters:@{}];
    if (self) {
        _state = state;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_request forKey:kRequestKey];
    [aCoder encodeObject:_state forKey:kStateKey];
}

@end
