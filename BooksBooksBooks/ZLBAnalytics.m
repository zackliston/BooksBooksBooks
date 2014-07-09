//
//  ZLBAnalytics.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/8/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "ZLBAnalytics.h"
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

static NSString *const kAnalyticsBookAction = @"book_action";
static NSString *const kAnalyticsAddBook = @"add_book";
static NSString *const kAnalyticsOwnStatusChange = @"own_status_change";
static NSString *const kAnalyticsReadStatusChange = @"read_status_change";

@implementation ZLBAnalytics

+ (void)logBookAddedEvent
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsBookAction
                                                          action:kAnalyticsAddBook
                                                           label:nil
                                                        value:nil] build]];
}

+ (void)logBookOwnStatusChangedEvent:(BookOwnStatus)newStatus
{
    NSString *status;;

    switch (newStatus) {
        case BookIsOwned:
            status = @"Does Own";
            break;
        case BookWantsToOwn:
            status = @"Wants to Own";
            break;
        case BookDoesNotOwn:
            status = @"Does not Own";
            break;
        default:
            status = @"n/a";
            break;
    }

    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsBookAction
                                                          action:kAnalyticsOwnStatusChange
                                                           label:status
                                                           value:nil] build]];
}

+ (void)logBookReadStatusChangedEvent:(BookReadStatus)newStatus
{
    NSString *status;
    
    switch (newStatus) {
        case BookHasBeenRead:
            status = @"Has Read";
            break;
        case BookIsCurrentlyReading:
            status = @"Currently Reading";
            break;
        case BookWantsToRead:
            status = @"Wants to Read";
            break;
        case BookDoesNotWantToRead:
            status = @"Does not want to read";
            break;
        default:
            status = @"n/a";
            break;
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsBookAction
                                                          action:kAnalyticsReadStatusChange
                                                           label:status
                                                           value:nil] build]];
}
@end
