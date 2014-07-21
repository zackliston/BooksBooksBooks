//
//  ZLBCloudConstants.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/19/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "ZLBCloudConstants.h"

#pragma mark - Keys
NSString *const kRecordTypePublicBook = @"Public_Book";
NSString *const kRecordTypePrivateBook = @"Private_Book";
NSString *const kRecordTypeOwner = @"Owner";

#pragma mark Public Book Keys
NSString *const kBookIDKey = @"bookID";
NSString *const kBookAuthorsKey = @"authors";
NSString *const kBookAverageRatingKey = @"averageRating";
NSString *const kBookDescriptionKey = @"bookDescription";
NSString *const kBookCategoriesKey = @"categories";
NSString *const kBookImageURLKey = @"ImageURL";
NSString *const kBookMainAuthorKey = @"mainAuthor";
NSString *const kBookMainCategoryKey = @"mainCategory";
NSString *const kBookPageCountKey = @"pageCount";
NSString *const kBookPublishDateKey = @"publishDate";
NSString *const kBookPublisherKey = @"publisher";
NSString *const kBookRatingsCountKey = @"ratingsCount";
NSString *const kBookSubtitleKey = @"subtitle";
NSString *const kBookTitleKey = @"title";
NSString *const kBookOwnersKey = @"owners";

#pragma mark Private Book Keys
NSString *const kPrivateBookOwnStatusKey = @"ownStatus";
NSString *const kPrivateBookReadStatusKey = @"readStatus";
NSString *const kPrivateBookPersonalRatingKey = @"personalRating";
NSString *const kPrivateBookPersonalNotesKey = @"personalNotes";
NSString *const kPrivateBookDateAddedKey = @"secondsSinceAddedSinceEpoch";
NSString *const kPrivateBookModifiedKey = @"secondsSinceModifiedSinceEpoch";

#pragma mark Owner Keys
NSString *const kOwnerRecordIDKey = @"ownerRecordID";
NSString *const kOwnerOwnedBooksKey = @"ownedBooks";

NSString *const kPreviousServerChangeTokenKey = @"previousChangeTokenKey";
NSString *const kPrivateDatabaseSynceZoneName = @"sync_zone";

@implementation ZLBCloudConstants

@end
