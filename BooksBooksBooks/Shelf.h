//
//  Shelf.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 8/3/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Shelf : NSManagedObject

@property (nonatomic, retain) NSNumber * averageRating;
@property (nonatomic, retain) NSNumber * ownStatus;
@property (nonatomic, retain) NSNumber * personalRating;
@property (nonatomic, retain) NSNumber * readStatus;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * sortOrder;

@end
