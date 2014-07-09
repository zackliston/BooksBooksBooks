//
//  ZLBAnalytics.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/8/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book+Constants.h"

@interface ZLBAnalytics : NSObject

+ (void)logBookAddedEvent;
+ (void)logBookReadStatusChangedEvent:(BookReadStatus)newStatus;
+ (void)logBookOwnStatusChangedEvent:(BookOwnStatus)newStatus;

@end
