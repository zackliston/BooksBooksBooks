//
//  ZLBCloudManager.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/19/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "ZLBCloudManager.h"
#import "DataController.h"
#import "ZLBCloudConstants.h"
#import "Book+Constants.h"

@import CloudKit;

static ZLBCloudManager *sharedInstance;

@interface ZLBCloudManager ()

@property (nonatomic, weak) CKDatabase *publicDatabase;
@property (nonatomic, weak) CKDatabase *privateDatabase;
@property (nonatomic, strong) CKRecordZoneID *syncZoneID;

@end

@implementation ZLBCloudManager {
    CKRecordID *_userRecordID;
    BOOL _hasiCloudAccount;
    
    BOOL shouldFetchChangesWhenSyncZoneIDIsSet;
    BOOL shouldUploadChangesWhenSyncZoneIDIsSet;
    BOOL hasUploadedChangesToPublicDatabase;
    
    NSInteger retryAddingBooksToOwnerCount;
}

#pragma mark - Getters/Setters

- (CKDatabase *)publicDatabase
{
    if (!_publicDatabase) {
        _publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    }
    return _publicDatabase;
}

- (CKDatabase *)privateDatabase
{
    if (!_hasiCloudAccount) {
        return nil;
    }
    
    if (!_privateDatabase) {
        _privateDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
    }
    return _privateDatabase;
}

- (void)saveServerChangeToken:(CKServerChangeToken *)serverChangeToken
{
    NSData *serverChangeData = [NSKeyedArchiver archivedDataWithRootObject:serverChangeToken];
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [[NSString alloc] initWithString:[cachesDirectory stringByAppendingPathComponent:kPreviousServerChangeTokenKey]];
    
    [serverChangeData writeToFile:path atomically:NO];
}

- (CKServerChangeToken *)getServerChangeToken
{
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [[NSString alloc] initWithString:[cachesDirectory stringByAppendingPathComponent:kPreviousServerChangeTokenKey]];
  
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *serverChangeData = [NSData dataWithContentsOfFile:path];
        CKServerChangeToken *changeToken = [NSKeyedUnarchiver unarchiveObjectWithData:serverChangeData];
        
        return changeToken;
    } else {
        return nil;
    }
}

- (void)setSyncZoneID:(CKRecordZoneID *)syncZoneID
{
    _syncZoneID = syncZoneID;
    if (shouldFetchChangesWhenSyncZoneIDIsSet) {
        [self fetchCloudChanges];
        shouldFetchChangesWhenSyncZoneIDIsSet = NO;
    }
    if (shouldUploadChangesWhenSyncZoneIDIsSet) {
        [self uploadLocalChangesToCloud];
        shouldUploadChangesWhenSyncZoneIDIsSet = NO;
    }
}

#pragma mark - Initialization

+ (ZLBCloudManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZLBCloudManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _hasiCloudAccount = YES;
        retryAddingBooksToOwnerCount = 0;
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)setupCloudUser
{
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        if (!error) {
            NSLog(@"User %@ has confirmed with iCloud", recordID.recordName);
            _userRecordID = [recordID copy];
            _hasiCloudAccount = YES;
        } else {
            if (error.code == CKErrorNotAuthenticated) {
                _hasiCloudAccount = NO;
            }
            NSLog(@"There was an error fetching the UserRecordID %@", error);
        }
    }];
}

- (void)updateCloudWithInsertedObjects:(NSSet *)insertedObjects updatedObjects:(NSSet *)updatedObjects deletedObjects:(NSSet *)deletedObjects
{
    for (id object in insertedObjects) {
        [self insertOrUpdateObject:object];
    }
    
    for (id object in updatedObjects) {
        [self insertOrUpdateObject:object];
    }
}

- (void)setupSyncZoneAndSubscription:(BOOL)shouldStartSubscription
{
    CKRecordZone *syncZone = [[CKRecordZone alloc] initWithZoneName:kPrivateDatabaseSynceZoneName];
    CKModifyRecordZonesOperation *zoneOperation = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:@[syncZone] recordZoneIDsToDelete:nil];
    [zoneOperation setModifyRecordZonesCompletionBlock:^(NSArray *savedZones, NSArray *deletedZoneIDs, NSError *error) {
        if (!error) {
            if (savedZones.count == 1) {
                CKRecordZone *zone = [savedZones firstObject];
                self.syncZoneID = zone.zoneID;
                NSLog(@"Successfully saved Synce Zone");
                
                if (shouldStartSubscription) {
                    [self startSubscription];
                }
            } else {
                NSLog(@"One Zone was supposed to be returned from the save record zone operation buy %lu were", (unsigned long)savedZones.count);
            }
        } else {
            NSLog(@"CLOUD ERROR Could not save zone %@", error);
        }
    }];
    [zoneOperation setQualityOfService:NSQualityOfServiceUserInitiated];
    
    [self.privateDatabase addOperation:zoneOperation];
}

- (void)fetchCloudChanges
{
    if (self.syncZoneID) {
        CKServerChangeToken *serverChangeToken = [self getServerChangeToken];
        
        CKFetchRecordChangesOperation *fetchChangesOperation = [[CKFetchRecordChangesOperation alloc] initWithRecordZoneID:self.syncZoneID previousServerChangeToken:serverChangeToken];
        [fetchChangesOperation setRecordChangedBlock:^(CKRecord *record) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self insertOrUpdateCoreDataForCKRecord:record];
            });
        }];
        
        [fetchChangesOperation setFetchRecordChangesCompletionBlock:^(CKServerChangeToken *serverChangeToken, NSData *oldServerChangeToken, NSError *error) {
            if (!error) {
                NSLog(@"Successfully updated server changes to client. Saving new Server Change Token");
                [self saveServerChangeToken:serverChangeToken];
            } else {
                NSLog(@"CLOUD ERROR trying to fetch the changes from the server %@", error);
            }
        }];
        
        [self.privateDatabase addOperation:fetchChangesOperation];
    } else {
        shouldFetchChangesWhenSyncZoneIDIsSet = YES;
    }
}

- (void)uploadLocalChangesToCloud
{
    NSArray *books = [[DataController sharedInstance] fetchAllBooks];
    
    if (self.syncZoneID) {
        [self batchUploadLocalChangesToPrivateDatabaseWithBooks:books];
        
    } else {
        shouldUploadChangesWhenSyncZoneIDIsSet = YES;
    }
    
    if (!hasUploadedChangesToPublicDatabase) {
        [self batchUploadLocalChangesToPublicDatabaseWithBooks:books];
        hasUploadedChangesToPublicDatabase = YES;
    }
}

#pragma mark - Public Method Helpers

- (void)startSubscription
{
    if (self.syncZoneID) {
        CKFetchSubscriptionsOperation *fetchSubscriptionsOperation = [CKFetchSubscriptionsOperation fetchAllSubscriptionsOperation];
        [fetchSubscriptionsOperation setFetchSubscriptionCompletionBlock:^(NSDictionary *subscriptionsBySubscriptionID, NSError *error) {
            if (!error) {
            if (subscriptionsBySubscriptionID.allKeys.count == 0) {
                [self addSingleSubsriptionAndRemoveSubscriptions:nil];
            } else if (subscriptionsBySubscriptionID.allKeys.count == 1) {
                NSLog(@"CLOUD we have a subscription so we are not adding anymore");
            } else {
                [self addSingleSubsriptionAndRemoveSubscriptions:subscriptionsBySubscriptionID.allKeys];
            }
            } else {
                NSLog(@"CLOUD ERROR fetching subscriptions from private database sync zone %@", error);
            }
        }];
        
        [self.privateDatabase addOperation:fetchSubscriptionsOperation];
    }
}

- (void)addSingleSubsriptionAndRemoveSubscriptions:(NSArray *)subscriptionKeys
{
    CKSubscription *syncZoneSubscription = [[CKSubscription alloc] initWithZoneID:self.syncZoneID options:CKSubscriptionOptionsThisClientOnly];
    CKNotificationInfo *notificationInfo = [[CKNotificationInfo alloc] init];
    notificationInfo.desiredKeys = @[kBookIDKey];
    syncZoneSubscription.notificationInfo = notificationInfo;
    
    CKModifySubscriptionsOperation *addSubscriptionOperation = [[CKModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:@[syncZoneSubscription] subscriptionIDsToDelete:subscriptionKeys];
    [addSubscriptionOperation setModifySubscriptionsCompletionBlock:^(NSArray *savedSubscriptions, NSArray *deletedSubscriptionIDs, NSError *error) {
        if (!error) {
            NSLog(@"Successfully subscribed to all record creations and updates in sync_zone of private database");
        } else {
            NSLog(@"CLOUD ERROR Failed to subscribe to record creations and updates %@", error);
        }
    }];
    
    [self.privateDatabase addOperation:addSubscriptionOperation];
}

- (void)batchUploadLocalChangesToPrivateDatabaseWithBooks:(NSArray *)books
{
    NSMutableArray *bookIDs = [NSMutableArray new];
    for (Book *book in books) {
        if (!book.privateCloudRecordID) {
            [self checkIfBookExistsInPrivateDatabaseAndAddOrUpdateBook:book];
        } else {
            [bookIDs addObject:book.privateCloudRecordID];
        }
    }
    
    __block NSArray *blockBooks = books;
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:[bookIDs copy]];
    [fetchOperation setFetchRecordsCompletionBlock:^(NSDictionary *recordsByRecordID, NSError *error) {
        if (!error) {
            [self updateBooksInPrivateDataBase:[recordsByRecordID allValues] withCoreDataBooks:blockBooks];
        } else {
            NSLog(@"CLOUD ERROR fetching Books with IDs %@ %@", bookIDs, error);
        }
    }];
    
    [self.privateDatabase addOperation:fetchOperation];
}

- (void)batchUploadLocalChangesToPublicDatabaseWithBooks:(NSArray *)books
{
    NSMutableArray *bookIDs = [NSMutableArray new];
    for (Book *book in books) {
        if (!book.publicCloudRecordID) {
            [self checkIfBookExistsInPublicDatabaseAndAddOrUpdateBook:book];
        } else {
            [bookIDs addObject:book.publicCloudRecordID];
        }
    }
    
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:[bookIDs copy]];
    [fetchOperation setFetchRecordsCompletionBlock:^(NSDictionary *recordsByRecordID, NSError *error) {
        if (!error) {
            [self fetchUserRecordAndAddAsOwnerOfBooks:[recordsByRecordID allValues]];
        } else {
            NSLog(@"CLOUD ERROR fetching books from public database %@", error);
        }
    }];

    
    [self.publicDatabase addOperation:fetchOperation];
}

#pragma mark - Update iCloud
#pragma mark Insert

- (void)insertOrUpdateObject:(id)object
{
    if ([object isKindOfClass:[Book class]]) {
        Book *book = (Book *)object;
        [self insertOrUpdateBook:book];
    }
}

- (void)insertOrUpdateBook:(Book *)book
{
    [self insertOrUpdateBookOnPublicDatabase:book];
    [self insertOrUpdateBookOnPrivateDatabase:book];
}

- (void)insertOrUpdateBookOnPublicDatabase:(Book *)book
{
    if (book.publicCloudRecordID) {
        [self fetchRecordAndUpdateBookToPublicDatabaseWithBook:book];
    } else {
        [self checkIfBookExistsInPublicDatabaseAndAddOrUpdateBook:book];
    }
}

- (void)insertOrUpdateBookOnPrivateDatabase:(Book *)book
{
    if (book.privateCloudRecordID) {
        [self fetchRecordAndUpdateBookToPrivateDatabaseWithBook:book];
    } else {
        [self checkIfBookExistsInPrivateDatabaseAndAddOrUpdateBook:book];
    }
}

- (void)fetchRecordAndUpdateBookToPublicDatabaseWithBook:(Book *)book
{
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[book.publicCloudRecordID]];
    [fetchOperation setPerRecordCompletionBlock:^(CKRecord *record, CKRecordID *recordID, NSError *error) {
        if (!error) {
            [self fetchUserRecordAndAddAsOwnerOfBooks:@[record]];
        } else {
            NSLog(@"CLOUD ERROR: Could not fetch Book %@ from cloud %@", book.title, error);
        }
    }];
    
    [self.publicDatabase addOperation:fetchOperation];
}

- (void)fetchRecordAndUpdateBookToPrivateDatabaseWithBook:(Book *)book
{
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[book.privateCloudRecordID]];
    [fetchOperation setPerRecordCompletionBlock:^(CKRecord *record, CKRecordID *recordID, NSError *error) {
        if (!error) {
            [self updateBookInPrivateDatabase:record withCoreDataBook:book];
        } else {
            NSLog(@"CLOUD ERROR: Could not fetch Book %@ from cloud %@", book.title, error);
        }
    }];
    
    [self.privateDatabase addOperation:fetchOperation];
}

- (void)checkIfBookExistsInPublicDatabaseAndAddOrUpdateBook:(Book *)book
{
    NSPredicate *publicPredicate = [NSPredicate predicateWithFormat:@"%K == %@", kBookIDKey, book.bookID];
    CKQuery *publicQuery = [[CKQuery alloc] initWithRecordType:kRecordTypePublicBook predicate:publicPredicate];
    
    [self.publicDatabase performQuery:publicQuery inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            if (results.count == 0) {
                [self insertBookToPublicDatabase:book];
            } else if (results.count == 1) {
                CKRecord *record = [results firstObject];
                [self fetchUserRecordAndAddAsOwnerOfBooks:@[record]];
                
            } else {
                NSLog(@"ERROR: There should only be one book with ID %@ but there are %lu Updated only the first one", book.bookID, (unsigned long)results.count);
            }
        } else {
            NSLog(@"ERROR fetching Book %@ from iCloud public database %@", book.title, error);
        }
    }];
}

- (void)checkIfBookExistsInPrivateDatabaseAndAddOrUpdateBook:(Book *)book
{
    if (self.syncZoneID) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", kBookIDKey, book.bookID];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:kRecordTypePrivateBook predicate:predicate];
        
        [self.privateDatabase performQuery:query inZoneWithID:self.syncZoneID completionHandler:^(NSArray *results, NSError *error) {
            if (!error) {
                if (results.count == 0) {
                    [self insertBookToPrivateDatabase:book];
                } else if (results.count == 1) {
                    [self updateBookInPrivateDatabase:[results firstObject] withCoreDataBook:book];
                } else {
                    NSLog(@"ERROR: There should only be one book with ID %@ but there are %lu Updated only the first one", book.bookID, (unsigned long)results.count);
                    [self updateBookInPrivateDatabase:[results firstObject] withCoreDataBook:book];
                }
            } else {
                NSLog(@"ERROR fetching Book %@ from iCloud private database %@", book.title, error);
            }
        }];
    } else {
        NSLog(@"CLOUD ERROR: Could not query Private Database because we do not have a syncZoneID right now");
    }
}

- (void)insertBookToPublicDatabase:(Book *)book
{
    CKRecord *publicBookRecord = [self publicBookRecordFromCoreDataBook:book];
    CKModifyRecordsOperation *insertOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[publicBookRecord] recordIDsToDelete:nil];
    [insertOperation setModifyRecordsCompletionBlock:^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
        if (!error) {
            CKRecord *record = [savedRecords firstObject];
            [self fetchUserRecordAndAddAsOwnerOfBooks:@[record]];
    
            dispatch_async(dispatch_get_main_queue(), ^{
                book.publicCloudRecordID = record.recordID;
                [[DataController sharedInstance] saveContextUpdateCloud:NO];
            });
            
            NSLog(@"Successfully saved Book %@ to the public iCloud database", book.title);
        } else {
            NSLog(@"There was an error savig Book %@ to the public iCloud database %@", book.title, error);
        }
    }];
    
    [self.publicDatabase addOperation:insertOperation];
}

- (void)insertBookToPrivateDatabase:(Book *)book
{
    if (_hasiCloudAccount) {
        CKRecord *privateRecord = [self privateBookRecordFromCoreDataBook:book];
        CKModifyRecordsOperation *insertOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[privateRecord] recordIDsToDelete:nil];
        [insertOperation setModifyRecordsCompletionBlock:^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CKRecord *record = [savedRecords firstObject];
                    book.privateCloudRecordID = record.recordID;
                    [[DataController sharedInstance] saveContextUpdateCloud:NO];
                });
                
                NSLog(@"Successfully saved Book %@ to the private iCloud database", book.title);
            } else {
                NSLog(@"There was an error savig Book %@ to the private iCloud database %@", book.title, error);
            }
        }];
        
        [self.privateDatabase addOperation:insertOperation];
    }
}

#pragma mark - Add Reference

- (void)fetchUserRecordAndAddAsOwnerOfBooks:(NSArray *)bookRecords
{
    if (_userRecordID) {
        CKFetchRecordsOperation *fetchOp = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[_userRecordID]];
        [fetchOp setPerRecordCompletionBlock:^(CKRecord *userRecord, CKRecordID *userRecordID, NSError *error) {
            if (!error) {
                
                [self addUser:userRecord asOwnerOfBooks:bookRecords];
            } else {
                NSLog(@"CLOUD ERROR fetching User Record %@ %@", userRecordID.recordName, error);
            }
        }];
        
        [fetchOp setFetchRecordsCompletionBlock:^(NSDictionary *recordsByRecordID, NSError *error) {
            if (!error) {
                if (recordsByRecordID.allKeys.count > 1) {
                    NSLog(@"CLOUD ERROR there should never be more than one userRecord for a userrRecordID but there are %lu", (unsigned long)recordsByRecordID.allKeys.count);
                }
            } else {
                NSLog(@"Error fetching UserRecord %@", error);
            }
        }];
        
        [self.publicDatabase addOperation:fetchOp];
    } else {
        NSLog(@"CLOUD Cannot add user as owner of books because the user is not logged into an iCloud account. Retrying in 2 seconds");
        if (retryAddingBooksToOwnerCount < 3) {
            [self performSelector:@selector(fetchUserRecordAndAddAsOwnerOfBooks:) withObject:bookRecords afterDelay:2.0];
            retryAddingBooksToOwnerCount ++;
        }
    }
}

- (void)addUser:(CKRecord *)userRecord asOwnerOfBooks:(NSArray *)bookRecords
{
    NSArray *ownedBooks = [userRecord objectForKey:kOwnerOwnedBooksKey];
    BOOL hasNewReferences = NO;
    
    for (CKRecord *bookRecord in bookRecords) {
        BOOL isNewReference = YES;
        CKReference *reference = [[CKReference alloc] initWithRecord:bookRecord action:CKReferenceActionNone];
        
        if (ownedBooks && ownedBooks.count>0) {
            for (CKReference *previousReference in ownedBooks) {
                if ([previousReference.recordID.recordName isEqualToString:reference.recordID.recordName]) {
                    isNewReference = NO;
                }
            }
            
            if (isNewReference) {
                NSMutableArray *mutableCopy = [ownedBooks mutableCopy];
                [mutableCopy addObject:reference];
                ownedBooks = [mutableCopy copy];
                hasNewReferences = YES;
            }
        } else {
            ownedBooks = @[reference];
        }
    }
    
    if (hasNewReferences) {
        [userRecord setObject:ownedBooks forKey:kOwnerOwnedBooksKey];
        
        CKModifyRecordsOperation *modifyOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[userRecord] recordIDsToDelete:nil];
        [modifyOperation setModifyRecordsCompletionBlock:^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
            if (!error) {
                NSLog(@"Successfully added user as owner of a books");
                /**
                CKReference* recordToMatch = [[CKReference alloc] initWithRecord:bookRecord action:CKReferenceActionNone];
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ownedBooks CONTAINS %@",kOwnerOwnedBooksKey, recordToMatch];
            
                // Create the query object.
                CKQuery* query = [[CKQuery alloc] initWithRecordType:@"Users" predicate:predicate];
               
                CKQueryOperation* queryOp = [[CKQueryOperation alloc] initWithQuery:query];
                [queryOp setRecordFetchedBlock:^(CKRecord *record) {
                    NSLog(@"book %@", [record objectForKey:kBookTitleKey]);
                }];
                
                [queryOp setQueryCompletionBlock:^(CKQueryCursor *c, NSError *error) {
                    if (error) {
                        NSLog(@"errrr %@", error);
                    } else {
                        NSLog(@"works");
                    }
                }];
                [self.publicDatabase addOperation:queryOp];
                 */
            } else {
                NSLog(@"CLOUD ERROR adding user as owner of book %@", error);
            }
        }];
        
        [self.publicDatabase addOperation:modifyOperation];
    }
}

#pragma mark Update

- (void)updateBookInPrivateDatabase:(CKRecord *)bookRecord withCoreDataBook:(Book *)coreDataBook
{
    bookRecord = [self privateBookRecordFromPreviousBookRecord:bookRecord andCoreDataBook:coreDataBook];
    
    CKModifyRecordsOperation *insertOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[bookRecord] recordIDsToDelete:nil];
    [insertOperation setModifyRecordsCompletionBlock:^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
        if (!error) {
            NSLog(@"Successfully updated Book %@ to the private iCloud database", coreDataBook.title);
        } else {
            NSLog(@"There was an error updating Book %@ to the private iCloud database %@", coreDataBook.title, error);
        }
    }];
    
    [self.privateDatabase addOperation:insertOperation];
}

- (void)updateBooksInPrivateDataBase:(NSArray *)bookRecordArray withCoreDataBooks:(NSArray *)coreDataBookArray
{
    
    NSMutableArray *updatedRecords = [NSMutableArray new];
    for (NSInteger i = 0; i < bookRecordArray.count; i++) {
        CKRecord *oldRecord = [bookRecordArray objectAtIndex:i];
        
        NSPredicate *bookIDPredicate = [NSPredicate predicateWithFormat:@"bookID = %@", [oldRecord objectForKey:kBookIDKey]];
        Book *coreDataBook = [[coreDataBookArray filteredArrayUsingPredicate:bookIDPredicate] firstObject];
        if (!coreDataBook) {
            NSLog(@"CLOUD ERROR No CoreData book found for ID %@", [oldRecord objectForKey:kBookIDKey]);
            return;
        }
        
        CKRecord *updatedRecord = [self privateBookRecordFromPreviousBookRecord:oldRecord andCoreDataBook:coreDataBook];
        [updatedRecords addObject:updatedRecord];
    }
    
    CKModifyRecordsOperation *updateOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:[updatedRecords copy] recordIDsToDelete:nil];
    [updateOperation setModifyRecordsCompletionBlock:^(NSArray *savedRecords, NSArray *deletedRecords, NSError *error) {
        if (!error) {
            NSLog(@"Successfully updated Books %@ to the private iCloud database", [coreDataBookArray valueForKey:@"title"]);
        } else {
            NSLog(@"There was an error updating Book %@ to the private iCloud database %@", [coreDataBookArray valueForKey:@"title"], error);
        }
    }];
    
    [self.privateDatabase addOperation:updateOperation];
}

#pragma mark - iCloud Helpers

- (CKRecord *)publicBookRecordFromCoreDataBook:(Book *)book
{
    CKRecord *record = [[CKRecord alloc] initWithRecordType:kRecordTypePublicBook];
    [record setObject:book.title forKey:kBookTitleKey];
    [record setObject:book.bookID forKey:kBookIDKey];
    [record setObject:book.authors forKey:kBookAuthorsKey];
    [record setObject:book.averageRating forKey:kBookAverageRatingKey];
    [record setObject:book.bookDescription forKey:kBookDescriptionKey];
    [record setObject:book.categories forKey:kBookCategoriesKey];
    [record setObject:[self biggestImagePathInDictionary:book.imageURLs] forKey:kBookImageURLKey];
    [record setObject:book.mainAuthor forKey:kBookMainAuthorKey];
    [record setObject:book.mainCategory forKey:kBookMainCategoryKey];
    [record setObject:book.pageCount forKey:kBookPageCountKey];
    [record setObject:book.publishDate forKey:kBookPublishDateKey];
    [record setObject:book.publisher forKey:kBookPublisherKey];
    [record setObject:book.ratingsCount forKey:kBookRatingsCountKey];
    [record setObject:book.subtitle forKey:kBookSubtitleKey];
    
    return record;
}

- (CKRecord *)privateBookRecordFromCoreDataBook:(Book *)book
{
    CKRecord *record = nil;
    
    if (self.syncZoneID) {
        record = [[CKRecord alloc] initWithRecordType:kRecordTypePrivateBook zoneID:self.syncZoneID];
        [record setObject:book.title forKey:kBookTitleKey];
        [record setObject:book.bookID forKey:kBookIDKey];
        [record setObject:book.authors forKey:kBookAuthorsKey];
        [record setObject:book.averageRating forKey:kBookAverageRatingKey];
        [record setObject:book.bookDescription forKey:kBookDescriptionKey];
        [record setObject:book.categories forKey:kBookCategoriesKey];
        [record setObject:[self biggestImagePathInDictionary:book.imageURLs] forKey:kBookImageURLKey];
        [record setObject:book.mainAuthor forKey:kBookMainAuthorKey];
        [record setObject:book.mainCategory forKey:kBookMainCategoryKey];
        [record setObject:book.pageCount forKey:kBookPageCountKey];
        [record setObject:book.publishDate forKey:kBookPublishDateKey];
        [record setObject:book.publisher forKey:kBookPublisherKey];
        [record setObject:book.ratingsCount forKey:kBookRatingsCountKey];
        [record setObject:book.subtitle forKey:kBookSubtitleKey];
        [record setObject:book.ownStatus forKey:kPrivateBookOwnStatusKey];
        [record setObject:book.readStatus forKey:kPrivateBookReadStatusKey];
        [record setObject:book.personalRating forKey:kPrivateBookPersonalRatingKey];
        [record setObject:book.personalNotes forKey:kPrivateBookPersonalNotesKey];
        [record setObject:book.dateAddedToLibraryInSecondsSinceEpoch forKey:kPrivateBookDateAddedKey];
        [record setObject:book.dateModifiedInSecondsSinceEpoch forKey:kPrivateBookModifiedKey];
    }
    
    return record;
}

- (CKRecord *)privateBookRecordFromPreviousBookRecord:(CKRecord *)record andCoreDataBook:(Book *)book
{
    [record setObject:book.bookID forKey:kBookIDKey];
    [record setObject:book.title forKey:kBookTitleKey];
    [record setObject:book.authors forKey:kBookAuthorsKey];
    [record setObject:book.averageRating forKey:kBookAverageRatingKey];
    [record setObject:book.bookDescription forKey:kBookDescriptionKey];
    [record setObject:book.categories forKey:kBookCategoriesKey];
    [record setObject:[self biggestImagePathInDictionary:book.imageURLs] forKey:kBookImageURLKey];
    [record setObject:book.mainAuthor forKey:kBookMainAuthorKey];
    [record setObject:book.mainCategory forKey:kBookMainCategoryKey];
    [record setObject:book.pageCount forKey:kBookPageCountKey];
    [record setObject:book.publishDate forKey:kBookPublishDateKey];
    [record setObject:book.publisher forKey:kBookPublisherKey];
    [record setObject:book.ratingsCount forKey:kBookRatingsCountKey];
    [record setObject:book.subtitle forKey:kBookSubtitleKey];
    [record setObject:book.ownStatus forKey:kPrivateBookOwnStatusKey];
    [record setObject:book.readStatus forKey:kPrivateBookReadStatusKey];
    [record setObject:book.personalRating forKey:kPrivateBookPersonalRatingKey];
    [record setObject:book.personalNotes forKey:kPrivateBookPersonalNotesKey];
    [record setObject:book.dateAddedToLibraryInSecondsSinceEpoch forKey:kPrivateBookDateAddedKey];
    [record setObject:book.dateModifiedInSecondsSinceEpoch forKey:kPrivateBookModifiedKey];
    
    return record;
}

- (CKRecord *)ownerRecord
{
    CKRecord *ownerRecord = [[CKRecord alloc] initWithRecordType:kRecordTypeOwner];
    [ownerRecord setObject:_userRecordID.recordName forKey:kOwnerRecordIDKey];
    
    return ownerRecord;
}

- (NSString *)biggestImagePathInDictionary:(NSDictionary *)dictionary
{
    NSString *pathToImage;
    
    if ([dictionary objectForKey:mediumImageKey]) {
        pathToImage = [dictionary objectForKey:mediumImageKey];
    } else if ([dictionary objectForKey:smallImageKey]) {
        pathToImage = [dictionary objectForKey:smallImageKey];
    } else if ([dictionary objectForKey:thumbnailImageKey]) {
        pathToImage = [dictionary objectForKey:thumbnailImageKey];
    }
    return pathToImage;
}

#pragma mark - Update CoreData From Cloud

- (void)insertOrUpdateCoreDataForCKRecord:(CKRecord *)record
{
    Book *book = [[DataController sharedInstance] fetchBookWithBookID:[record objectForKey:kBookIDKey]];
    
    if (!book) {
        CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[record.recordID]];
        [fetchOperation setPerRecordCompletionBlock:^(CKRecord *fetchedRecord, CKRecordID *recordID, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[DataController sharedInstance] addBookToCoreDataWithCKRecord:fetchedRecord];
                });
            } else {
                NSLog(@"CLOUD ERROR fetching record with recordID %@ %@", recordID.recordName, error);
            }
        }];
        [self.privateDatabase addOperation:fetchOperation];
    } else {
        [[DataController sharedInstance] updateBook:book withCKRecord:record];
    }
}

@end
