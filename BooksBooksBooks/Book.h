//
//  Book.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/19/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) id authors;
@property (nonatomic, retain) NSNumber * averageRating;
@property (nonatomic, retain) NSString * bookDescription;
@property (nonatomic, retain) NSString * bookID;
@property (nonatomic, retain) id categories;
@property (nonatomic, retain) NSNumber * dateAddedToLibraryInSecondsSinceEpoch;
@property (nonatomic, retain) NSNumber * dateModifiedInSecondsSinceEpoch;
@property (nonatomic, retain) NSNumber * doesOwn;
@property (nonatomic, retain) id imageURLs;
@property (nonatomic, retain) id localImageLinks;
@property (nonatomic, retain) NSString * mainAuthor;
@property (nonatomic, retain) NSString * mainCategory;
@property (nonatomic, retain) NSNumber * pageCount;
@property (nonatomic, retain) NSString * personalNotes;
@property (nonatomic, retain) NSNumber * personalRating;
@property (nonatomic, retain) NSString * publishDate;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSNumber * ratingsCount;
@property (nonatomic, retain) NSNumber * readStatus;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) id privateCloudRecordID;
@property (nonatomic, retain) id publicCloudRecordID;

@end
