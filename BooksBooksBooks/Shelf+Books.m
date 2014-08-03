//
//  Shelf+Books.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 8/3/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "Shelf+Books.h"
#import "Book+Constants.h"
#import "DataController.h"

@implementation Shelf (Books)

- (NSArray *)books
{
    NSMutableArray *subPredicates = [NSMutableArray new];
    [subPredicates addObject:[NSPredicate predicateWithFormat:@"bookID != %@", @""]];
    
    if ([self.readStatus integerValue] != BookReadStatusNone) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"readStatus == %@", self.readStatus]];
    }
    if ([self.ownStatus integerValue] != BookOwnStatusNone) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"ownStatus == %@", self.ownStatus]];
    }
    if ([self.averageRating doubleValue] >= 0.0) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"averageRating >= %@", self.averageRating]];
    }
    if ([self.personalRating doubleValue] >= 0.0) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"personalRating >= %@", self.personalRating]];
    }

    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[subPredicates copy]];
    
    return [[DataController sharedInstance] fetchBooksWithPredicate:compoundPredicate];
}

@end
