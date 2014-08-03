//
//  DataController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "DataController.h"
#import "DownloadManager.h"
#import "Book+Constants.h"
#import "ZLBCloudManager.h"
#import "Book.h"
#import "Book+Constants.h"
#import "Shelf+Books.h"
#import "ZLBCloudConstants.h"

NSString *const kBookReadStatusKey = @"bookReadStatusKey";
NSString *const kBookOwnStatusKey = @"bookOwnStatusKey";
NSString *const kBookPersonalRatingKey = @"bookPersonalRatingKey";
NSString *const kBookPersonalNotesKey = @"bookPersonalNotesKey";


@interface DataController ()

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation DataController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static DataController *sharedInstance;

+ (DataController *)sharedInstance
{
    if (!sharedInstance) {
        sharedInstance = [[DataController alloc] init];
    }
    return sharedInstance;
}


#pragma mark - Core Data stack

- (void)saveContextUpdateCloud:(BOOL)shouldUpdateCloud
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    NSSet *insertedObjects = managedObjectContext.insertedObjects;
    NSSet *updatedObjects = managedObjectContext.updatedObjects;
    NSSet *deletedObjects = managedObjectContext.deletedObjects;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) {
            [managedObjectContext save:&error];
        } else {
            NSLog(@"No changes to save. Not saving context");
        }
        
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } else {
            NSLog(@"Successfully saved context!");
        }
    }
    
    if (shouldUpdateCloud) {
        [[ZLBCloudManager sharedInstance] updateCloudWithInsertedObjects:insertedObjects updatedObjects:updatedObjects deletedObjects:deletedObjects];
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BooksBooksBooks" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BooksBooksBooks.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Add Book

- (void)addBookToCoreDataWithGTLBook:(GTLBooksVolume *)gtlBook withUserInfo:(NSDictionary *)userInfo
{
    NSManagedObjectContext *context = [self managedObjectContext];
    Book *newBook = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
    newBook.authors = gtlBook.volumeInfo.authors;
    newBook.averageRating = gtlBook.volumeInfo.averageRating;
    newBook.bookDescription = gtlBook.volumeInfo.descriptionProperty;
    newBook.bookID = gtlBook.identifier;
    newBook.categories = gtlBook.volumeInfo.categories;
    newBook.mainAuthor = [gtlBook.volumeInfo.authors firstObject];
    newBook.mainCategory = gtlBook.volumeInfo.mainCategory;
    newBook.pageCount = gtlBook.volumeInfo.pageCount;
    newBook.publisher = gtlBook.volumeInfo.publisher;
    newBook.publishDate = gtlBook.volumeInfo.publishedDate;
    newBook.ratingsCount = gtlBook.volumeInfo.ratingsCount;
    newBook.subtitle = gtlBook.volumeInfo.subtitle;
    newBook.title = gtlBook.volumeInfo.title;
    newBook.imageURLs = [self convertImageLinksPropertyToDictionary:gtlBook.volumeInfo.imageLinks];
    newBook.localImageLinks = [self localImageLinksFromExternalImageLinks:newBook.imageURLs bookID:newBook.bookID];
    
    newBook.ownStatus = [userInfo objectForKey:kBookOwnStatusKey];
    newBook.readStatus = [userInfo objectForKey:kBookReadStatusKey];
    newBook.personalNotes = [userInfo objectForKey:kBookPersonalNotesKey];
    newBook.personalRating = [userInfo objectForKey:kBookPersonalRatingKey];
    
    float currentTime = [[NSDate date] timeIntervalSince1970];
    newBook.dateAddedToLibraryInSecondsSinceEpoch = [NSNumber numberWithFloat:currentTime];
    newBook.dateModifiedInSecondsSinceEpoch = [NSNumber numberWithFloat:currentTime];
    
    [self saveContextUpdateCloud:YES];
}

- (void)saveBook:(Book *)book
{
    book.dateModifiedInSecondsSinceEpoch = [NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970]];
    [self saveContextUpdateCloud:YES];
}

- (Shelf *)addShelfWithTitle:(NSString *)title ownStatus:(BookOwnStatus)ownStatus readStatus:(BookReadStatus)readStatus averageRating:(NSNumber *)averageRating personalRating:(NSNumber *)personalRating sortOrder:(NSInteger)sortOrder
{
    NSManagedObjectContext *context = [self managedObjectContext];
    Shelf *shelf = [NSEntityDescription insertNewObjectForEntityForName:@"Shelf" inManagedObjectContext:context];
    shelf.title = title;
    shelf.ownStatus = [NSNumber numberWithInteger:(NSInteger)ownStatus];
    shelf.readStatus = [NSNumber numberWithInteger:(NSInteger)readStatus];
    shelf.sortOrder = [NSNumber numberWithInteger:sortOrder];
    
    if (averageRating) {
        shelf.averageRating = averageRating;
    } else {
        shelf.averageRating = [NSNumber numberWithDouble:-1.0];
    }
    
    if (personalRating) {
        shelf.personalRating = personalRating;
    } else {
        shelf.personalRating = [NSNumber numberWithDouble:-1.0];
    }
    
    [self saveContextUpdateCloud:NO];
    return shelf;
}

#pragma mark Add Book Helpers

- (NSDictionary *)convertImageLinksPropertyToDictionary:(GTLBooksVolumeVolumeInfoImageLinks *)imageLinks
{
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    if (imageLinks.large) [tempDictionary setObject:imageLinks.large forKey:largeImageKey];
    if (imageLinks.medium) [tempDictionary setObject:imageLinks.medium forKey:mediumImageKey];
    if (imageLinks.small) [tempDictionary setObject:imageLinks.small forKey:smallImageKey];
    if (imageLinks.thumbnail) [tempDictionary setObject:imageLinks.thumbnail forKey:thumbnailImageKey];
    
    return [NSDictionary dictionaryWithDictionary:tempDictionary];
}

- (NSDictionary *)localImageLinksFromExternalImageLinks:(NSDictionary *)externalLinks bookID:(NSString *)bookID
{
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    NSString *imageDirectoryPath = [DownloadManager getImageDirectoryLocation];
    
    for (NSString *key in externalLinks.allKeys) {
        
        NSString *localLink = [NSString stringWithFormat:@"%@/%@-%@.png", imageDirectoryPath, bookID, key];
        [tempDictionary setObject:localLink forKey:key];
        
        [DownloadManager downloadImageFrom:[externalLinks objectForKey:key] to:localLink];
    }
    
    return [NSDictionary dictionaryWithDictionary:tempDictionary];
}

#pragma mark - Fetch Book

- (Book *)fetchBookWithBookID:(NSString *)bookID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Book" inManagedObjectContext:[self managedObjectContext]]];
    
    NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:@"bookID == %@", bookID];
    [fetchRequest setPredicate:fetchPredicate];
    
    NSError *fetchError = nil;
    
    NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&fetchError];
    
    if (fetchError) {
        NSLog(@"Error fetching book with ID = %@ \n%@", bookID, fetchError);
        return nil;
    }
    
    if ([results count] > 1) {
        NSLog(@"Error! There should only be one or less results for any bookID");
        return [results firstObject];
    } else {
        return [results lastObject];
    }
    
}

- (NSArray *)fetchBooksWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Error fetching books in method fetchBooksWithPredicate %@", error);
    }
    
    return results;
}

- (NSArray *)fetchAllBooks
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error fetching Books %@", error);
        return nil;
    }
    return fetchedObjects;
}

- (NSArray *)fetchAllShelves
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shelf" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error fetching Books %@", error);
        return nil;
    } else {
        if (fetchedObjects.count > 0) {
            return fetchedObjects;
        } else {
            return [self createAndReturnDefaultShelves];
        }
    }
}

#pragma mark - Handle CKRecords

- (void)addBookToCoreDataWithCKRecord:(CKRecord *)record
{
    NSManagedObjectContext *context = [self managedObjectContext];
    Book *newBook = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
    newBook.authors = [record objectForKey:kBookAuthorsKey];
    newBook.averageRating = [record objectForKey:kBookAverageRatingKey];
    newBook.bookDescription = [record objectForKey:kBookDescriptionKey];
    newBook.bookID = [record objectForKey:kBookIDKey];
    newBook.categories = [record objectForKey:kBookCategoriesKey];
    newBook.mainAuthor = [record objectForKey:kBookMainAuthorKey];
    newBook.mainCategory = [record objectForKey:kBookMainAuthorKey];
    newBook.pageCount = [record objectForKey:kBookPageCountKey];
    newBook.publisher = [record objectForKey:kBookPublisherKey];
    newBook.publishDate = [record objectForKey:kBookPublishDateKey];
    newBook.ratingsCount = [record objectForKey:kBookRatingsCountKey];
    newBook.subtitle = [record objectForKey:kBookSubtitleKey];
    newBook.title = [record objectForKey:kBookTitleKey];

    if ([record objectForKey:kBookImageURLKey]) {
        NSDictionary *imageURLs = @{thumbnailImageKey:[record objectForKey:kBookImageURLKey]};
        newBook.imageURLs = imageURLs;
        newBook.localImageLinks = [self localImageLinksFromExternalImageLinks:imageURLs bookID:newBook.bookID];
    }
    newBook.ownStatus = [record objectForKey:kPrivateBookOwnStatusKey];
    newBook.readStatus = [record objectForKey:kPrivateBookReadStatusKey];
    newBook.personalNotes = [record objectForKey:kPrivateBookPersonalNotesKey];
    newBook.personalRating = [record objectForKey:kPrivateBookPersonalRatingKey];
    newBook.dateAddedToLibraryInSecondsSinceEpoch = [record objectForKey:kPrivateBookDateAddedKey];
    newBook.dateModifiedInSecondsSinceEpoch = [record objectForKey:kPrivateBookModifiedKey];
    
    newBook.privateCloudRecordID = record.recordID;
    
    [self saveContextUpdateCloud:NO];
}

- (void)updateBook:(Book *)book withCKRecord:(CKRecord *)record
{
    if ( [record objectForKey:kBookAuthorsKey]) {
        book.authors = [record objectForKey:kBookAuthorsKey];
    }
    if ([record objectForKey:kBookAverageRatingKey]) {
        book.averageRating = [record objectForKey:kBookAverageRatingKey];
    }
    if ([record objectForKey:kBookDescriptionKey]) {
        book.bookDescription = [record objectForKey:kBookDescriptionKey];
    }
    if ([record objectForKey:kBookIDKey]) {
        book.bookID = [record objectForKey:kBookIDKey];
    }
    if ([record objectForKey:kBookCategoriesKey]) {
        book.categories = [record objectForKey:kBookCategoriesKey];
    }
    if ([record objectForKey:kBookMainAuthorKey]) {
        book.mainAuthor = [record objectForKey:kBookMainAuthorKey];
    }
    if ([record objectForKey:kBookMainAuthorKey]) {
        book.mainCategory = [record objectForKey:kBookMainAuthorKey];
    }
    if ([record objectForKey:kBookPageCountKey]) {
        book.pageCount = [record objectForKey:kBookPageCountKey];
    }
    if ([record objectForKey:kBookPublisherKey]) {
        book.publisher = [record objectForKey:kBookPublisherKey];
    }
    if ([record objectForKey:kBookPublishDateKey]) {
        book.publishDate = [record objectForKey:kBookPublishDateKey];
    }
    if ([record objectForKey:kBookRatingsCountKey]) {
        book.ratingsCount = [record objectForKey:kBookRatingsCountKey];
    }
    if ([record objectForKey:kBookSubtitleKey]) {
        book.subtitle = [record objectForKey:kBookSubtitleKey];
    }
    if ([record objectForKey:kBookTitleKey]) {
        book.title = [record objectForKey:kBookTitleKey];
    }
    
    if ([record objectForKey:kBookImageURLKey]) {
        NSDictionary *imageURLs = @{thumbnailImageKey:[record objectForKey:kBookImageURLKey]};
        book.imageURLs = imageURLs;
        book.localImageLinks = [self localImageLinksFromExternalImageLinks:imageURLs bookID:book.bookID];
    }
    
    if ([record objectForKey:kPrivateBookOwnStatusKey]) {
        book.ownStatus = [record objectForKey:kPrivateBookOwnStatusKey];
    }
    if ([record objectForKey:kPrivateBookReadStatusKey]) {
        book.readStatus = [record objectForKey:kPrivateBookReadStatusKey];
    }
    if ([record objectForKey:kPrivateBookPersonalNotesKey]) {
        book.personalNotes = [record objectForKey:kPrivateBookPersonalNotesKey];
    }
    if ([record objectForKey:kPrivateBookPersonalRatingKey]) {
        book.personalRating = [record objectForKey:kPrivateBookPersonalRatingKey];
    }
    if ([record objectForKey:kPrivateBookDateAddedKey]) {
        book.dateAddedToLibraryInSecondsSinceEpoch = [record objectForKey:kPrivateBookDateAddedKey];
    }
    if ([record objectForKey:kPrivateBookModifiedKey]) {
        book.dateModifiedInSecondsSinceEpoch = [record objectForKey:kPrivateBookModifiedKey];
    }
    
    [self saveContextUpdateCloud:NO];
}

#pragma mark - Search

- (NSArray *)searchBooksWithSearchText:(NSString *)searchText
{
    searchText = [searchText lowercaseString];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Book"];
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@ OR mainAuthor CONTAINS[c] %@", searchText, searchText];
    [fetchRequest setPredicate:searchPredicate];
    
    NSError *searchError = nil;
    NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&searchError];
    
    if (searchError) {
        NSLog(@"Error searching database for %@ %@", searchText, searchError);
    }
    
    return results;
}

#pragma mark - Helpers

- (NSArray *)createAndReturnDefaultShelves
{
    NSMutableArray *shelves = [NSMutableArray new];
    
    [shelves addObject:[self addShelfWithTitle:@"Currently Reading" ownStatus:BookOwnStatusNone readStatus:BookIsCurrentlyReading averageRating:nil personalRating:nil sortOrder:0]];
    [shelves addObject:[self addShelfWithTitle:@"Books you want to read" ownStatus:BookOwnStatusNone readStatus:BookWantsToRead averageRating:nil personalRating:nil sortOrder:2]];
    [shelves addObject:[self addShelfWithTitle:@"Your Wishlist" ownStatus:BookWantsToOwn readStatus:BookReadStatusNone averageRating:nil personalRating:nil sortOrder:3]];
    [shelves addObject:[self addShelfWithTitle:@"All the books you own" ownStatus:BookIsOwned readStatus:BookReadStatusNone averageRating:nil personalRating:nil sortOrder:4]];
    [shelves addObject:[self addShelfWithTitle:@"All Books" ownStatus:BookOwnStatusNone readStatus:BookReadStatusNone averageRating:nil personalRating:nil sortOrder:5]];
    [shelves addObject:[self addShelfWithTitle:@"Your top rated" ownStatus:BookOwnStatusNone readStatus:BookReadStatusNone averageRating:nil personalRating:[NSNumber numberWithDouble:3.5] sortOrder:1]];
    
    return [shelves copy];
}

@end
