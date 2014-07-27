//
//  ZLBReachability.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/27/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Reachability/Reachability.h>

@interface ZLBReachability : Reachability

+ (ZLBReachability *)sharedInstance;

@end
