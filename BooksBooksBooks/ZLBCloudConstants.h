//
//  ZLBCloudConstants.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/19/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Keys
FOUNDATION_EXPORT NSString *const kRecordTypePublicBook;
FOUNDATION_EXPORT NSString *const kRecordTypePrivateBook;
FOUNDATION_EXPORT NSString *const kRecordTypeOwner;

#pragma mark Public Book Keys
FOUNDATION_EXPORT NSString *const kBookIDKey;
FOUNDATION_EXPORT NSString *const kBookAuthorsKey;
FOUNDATION_EXPORT NSString *const kBookAverageRatingKey;
FOUNDATION_EXPORT NSString *const kBookDescriptionKey;
FOUNDATION_EXPORT NSString *const kBookCategoriesKey;
FOUNDATION_EXPORT NSString *const kBookImageURLKey;
FOUNDATION_EXPORT NSString *const kBookMainAuthorKey;
FOUNDATION_EXPORT NSString *const kBookMainCategoryKey;
FOUNDATION_EXPORT NSString *const kBookPageCountKey;
FOUNDATION_EXPORT NSString *const kBookPublishDateKey;
FOUNDATION_EXPORT NSString *const kBookPublisherKey;
FOUNDATION_EXPORT NSString *const kBookRatingsCountKey;
FOUNDATION_EXPORT NSString *const kBookSubtitleKey;
FOUNDATION_EXPORT NSString *const kBookTitleKey;

#pragma mark Private Book Keys
FOUNDATION_EXPORT NSString *const kPrivateBookOwnStatusKey;
FOUNDATION_EXPORT NSString *const kPrivateBookReadStatusKey;
FOUNDATION_EXPORT NSString *const kPrivateBookPersonalRatingKey;
FOUNDATION_EXPORT NSString *const kPrivateBookPersonalNotesKey;
FOUNDATION_EXPORT NSString *const kPrivateBookDateAddedKey;
FOUNDATION_EXPORT NSString *const kPrivateBookModifiedKey;

#pragma mark Owner Keys
FOUNDATION_EXPORT NSString *const kOwnerRecordIDKey;
FOUNDATION_EXPORT NSString *const kOwnerOwnedBooksKey;

FOUNDATION_EXPORT NSString *const kPreviousServerChangeTokenKey;
FOUNDATION_EXPORT NSString *const kPrivateDatabaseSynceZoneName;
@interface ZLBCloudConstants : NSObject

@end
