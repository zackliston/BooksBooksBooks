//
//  ChangeBookDetailsViewController.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/5/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangeBookDetailsResultsProtocol.h"
#import <GAITrackedViewController.h>

FOUNDATION_EXPORT NSString *const BookDetailsChangeResultOwnKey;
FOUNDATION_EXPORT NSString *const BookDetailsChangeResultReadKey;

@class Book;

typedef NS_ENUM(NSInteger, ChangeBookDetailsOptions) {
    ChangeBookOwnershipOption = 0,
    ChangeBookReadStatusOption
};

@interface ChangeBookDetailsViewController : GAITrackedViewController

- (id)initForExistingBook:(Book *)book WithOption:(ChangeBookDetailsOptions)option;
- (id)initWithResultsDelegate:(id<ChangeBookDetailsResultsProtocol>)delegate;

@end
