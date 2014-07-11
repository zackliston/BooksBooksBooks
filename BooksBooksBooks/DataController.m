//
//  DataController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "DataController.h"
#import "DownloadManager.h"

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

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) {
            [managedObjectContext save:&error];
        } else {
            NSLog(@"No changes to save. Not saving context");
        }
        if (error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } else {
            NSLog(@"Successfully saved context!");
        }
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

- (void)addBookToCoreDataWithGTLBook:(GTLBooksVolume *)gtlBook withReadStatus:(BookReadStatus)readStatus ownStatus:(BookOwnStatus)ownStatus
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
    newBook.doesOwn = [NSNumber numberWithInteger:ownStatus];
    newBook.readStatus = [NSNumber numberWithInteger:readStatus];
    
    newBook.imageURLs = [self convertImageLinksPropertyToDictionary:gtlBook.volumeInfo.imageLinks];
    newBook.localImageLinks = [self localImageLinksFromExternalImageLinks:newBook.imageURLs bookID:newBook.bookID];
    
    double currentTime = (double)[[NSDate date] timeIntervalSince1970];
    newBook.dateAddedToLibraryInSecondsSinceEpoch = [NSNumber numberWithDouble:currentTime];
    newBook.dateModifiedInSecondsSinceEpoch = [NSNumber numberWithDouble:currentTime];
    
    NSError *saveError;
    
    [context save:&saveError];
    if (saveError) {
        NSLog(@"Error saving context after adding book. %@", saveError);
    } else {
        NSLog(@"Successfully added a book to CoreData!");
    }
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
@end
