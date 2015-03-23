//
//  NSObject_CoCIDR.h
//  CoCIDR
//
//  Created by Yang Yubo on 3/23/15.
//  Copyright (c) 2015 Codinn. All rights reserved.
//

#import "CoCIDR.h"

@interface CoCIDR() {
    CIDR *_rawCIDR;
}

@end

#define CoCIDRErrorDomain @"CoCIDR"

@implementation CoCIDR

- (instancetype)initWithNotation:(NSString *)notation error:(NSError **)errPtr
{
    self = [super init];
    
    if (self) {
        _rawCIDR = cidr_from_str(notation.UTF8String);
        
        if (!_rawCIDR) {
            if (errPtr) *errPtr = [self _errnoError];
            return  nil;
        }
    }
    
    return self;
}

- (instancetype)initWithAddressV4:(const struct in_addr *)uaddr error:(NSError **)errPtr
{
    self = [super init];
    
    if (self) {
        _rawCIDR = cidr_from_inaddr(uaddr);
        
        if (!_rawCIDR) {
            if (errPtr) *errPtr = [self _errnoError];
            return  nil;
        }
    }
    
    return self;
}

- (instancetype)initWithAddressv6:(const struct in6_addr *)uaddr error:(NSError **)errPtr
{
    self = [super init];
    
    if (self) {
        _rawCIDR = cidr_from_in6addr(uaddr);
        
        if (!_rawCIDR) {
            if (errPtr) *errPtr = [self _errnoError];
            return  nil;
        }
    }
    
    return self;
}

// for internal usage
- (instancetype)initWithRawCIDR:(CIDR *)rawCIDR
{
    self = [super init];
    
    if (self) {
        _rawCIDR = rawCIDR;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    CoCIDR *target = (CoCIDR *)object;
    
    if ( ![target isKindOfClass:[CoCIDR class]]) {
        return NO;
    }
    
    int ret = cidr_equals(_rawCIDR, target->_rawCIDR);
    return ret==0;
}

- (void)dealloc
{
    if(_rawCIDR) {
        cidr_free(_rawCIDR);
    }
}

#pragma mark - CIDR functions

- (CoCIDR *)broadcastAddress
{
    CIDR * cidr = cidr_addr_broadcast(_rawCIDR);
    return [[CoCIDR alloc] initWithRawCIDR:cidr];
}

- (CoCIDR *)highestHostAddress
{
    CIDR * cidr = cidr_addr_hostmax(_rawCIDR);
    return [[CoCIDR alloc] initWithRawCIDR:cidr];
}

- (CoCIDR *)lowestHostAddress
{
    CIDR * cidr = cidr_addr_network(_rawCIDR);
    return [[CoCIDR alloc] initWithRawCIDR:cidr];
}

- (CoCIDR *)networkAddress
{
    CIDR * cidr = cidr_addr_hostmin(_rawCIDR);
    return [[CoCIDR alloc] initWithRawCIDR:cidr];
}

- (int)protocolFamily
{
    return cidr_get_proto(_rawCIDR);
}

- (BOOL)isV4Mapped
{
    int ret = cidr_is_v4mapped(_rawCIDR);
    return ret==0;
}

- (BOOL)contains:(CoCIDR *)netblock error:(NSError **)errPtr
{
    int ret = cidr_contains(_rawCIDR, netblock->_rawCIDR);
    
    if (ret!=0) {
        if (errPtr) *errPtr = [self _errnoError];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CIDR *cidr = cidr_dup(_rawCIDR);
    
    CoCIDR *copied = [[CoCIDR allocWithZone:zone] initWithRawCIDR:cidr];
    return copied;
}

#pragma mark - internal

- (NSError *)_errnoError
{
    NSString *errMsg = [NSString stringWithUTF8String:strerror(errno)];
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey : errMsg,
                               };
    
    return [NSError errorWithDomain:CoCIDRErrorDomain code:errno userInfo:userInfo];
}

@end
