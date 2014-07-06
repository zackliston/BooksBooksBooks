//
//  DataController.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <GTLBooks.h>
#import "Book.h"
#import "Book+Constants.h"

@interface DataController : NSObject

+ (DataController *)sharedInstance;
- (void)saveContext;
- (NSManagedObjectContext *)managedObjectContext;

- (void)addBookToCoreDataWithGTLBook:(GTLBooksVolume *)gtlBook withReadStatus:(BookReadStatus)readStatus ownStatus:(BookOwnStatus)ownStatus;
- (Book *)fetchBookWithBookID:(NSString *)bookID;

@end
