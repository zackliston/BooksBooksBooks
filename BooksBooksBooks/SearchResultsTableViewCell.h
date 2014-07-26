//
//  SearchResultsTableViewCell.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/16/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTLBooksVolume;
@class Book;

@interface SearchResultsTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, assign) NSInteger numberOfRatings;

- (void)setupWithGTLBook:(GTLBooksVolume *)book;
- (void)setupWithCoreDataBook:(Book *)book;

@end
