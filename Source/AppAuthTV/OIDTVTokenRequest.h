//
//  OIDTVTokenRequest.h
//  AppAuthTV
//
//  Created by Souleiman Benhida on 7/23/20.
//  Copyright © 2020 OpenID Foundation. All rights reserved.
//

#import <AppAuth/AppAuth.h>

NS_ASSUME_NONNULL_BEGIN

@interface OIDTVTokenRequest : OIDTokenRequest

/*! @brief The device code received from the authorization server.
    @remarks device_code
    @see https://tools.ietf.org/html/rfc8628#section-3.4
 */
@property(nonatomic, readonly, nullable) NSString *deviceCode;

-(instancetype) initWithConfiguration:(OIDTVServiceConfiguration *)configuration grantType:(NSString *)grantType deviceCode:(NSString *)deviceCode clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret additionalParameters:(NSDictionary<NSString *,NSString *> *)additionalParameters
    NS_DESIGNATED_INITIALIZER
@end

NS_ASSUME_NONNULL_END
