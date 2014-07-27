//
//  ZLBReachability.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/27/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "ZLBReachability.h"

@implementation ZLBReachability

+ (ZLBReachability *)sharedInstance
{
    static ZLBReachability *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = (ZLBReachability *)[ZLBReachability reachabilityForInternetConnection];
    });
    return _sharedInstance;
}

@end
