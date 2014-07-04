//
//  BookDetailViewController.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GTLBooks.h>


@class Book;

@interface BookDetailViewController : UIViewController <UIActionSheetDelegate>

- (void)setupWithGTLBook:(GTLBooksVolume *)book;
- (void)setupWithCoreDataBook:(Book *)book;

@end
