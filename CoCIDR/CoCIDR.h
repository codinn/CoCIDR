//
//  CoCIDR.h
//  CoCIDR
//
//  Created by Yang Yubo on 3/23/15.
//  Copyright (c) 2015 Codinn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoCIDR/libcidr.h>

@interface CoCIDR : NSObject <NSCopying>

- (instancetype)initWithNotation:(NSString *)notation error:(NSError **)errPtr;
- (instancetype)initWithAddressV4:(const struct in_addr *)uaddr error:(NSError **)errPtr;
- (instancetype)initWithAddressv6:(const struct in6_addr *)uaddr error:(NSError **)errPtr;

@property (readonly) CoCIDR     *broadcastAddress;
@property (readonly) CoCIDR     *highestHostAddress;
@property (readonly) CoCIDR     *lowestHostAddress;
@property (readonly) CoCIDR     *networkAddress;
@property (readonly) int        protocolFamily;
@property (readonly) BOOL       isV4Mapped;

- (BOOL)contains:(CoCIDR *)netblock error:(NSError **)errPtr;

@end
