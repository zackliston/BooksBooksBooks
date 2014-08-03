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
@import CloudKit;

@class Book;

FOUNDATION_EXPORT NSString *const kBookReadStatusKey;
FOUNDATION_EXPORT NSString *const kBookOwnStatusKey;
FOUNDATION_EXPORT NSString *const kBookPersonalRatingKey;
FOUNDATION_EXPORT NSString *const kBookPersonalNotesKey;

@interface DataController : NSObject

+ (DataController *)sharedInstance;

#pragma mark - Save
- (void)saveContextUpdateCloud:(BOOL)shouldUpdateCloud;
- (NSManagedObjectContext *)managedObjectContext;

#pragma mark Save Book
- (void)saveBook:(Book *)book;

#pragma mark - Add Books
- (void)addBookToCoreDataWithGTLBook:(GTLBooksVolume *)gtlBook withUserInfo:(NSDictionary *)userInfo;
- (void)addBookToCoreDataWithCKRecord:(CKRecord *)record;

#pragma mark - Update Book
- (void)updateBook:(Book *)book withCKRecord:(CKRecord *)record;

#pragma mark - Fetch
- (Book *)fetchBookWithBookID:(NSString *)bookID;
- (NSArray *)fetchAllBooks;

#pragma mark - Search

- (NSArray *)searchBooksWithSearchText:(NSString *)searchText;

@end
