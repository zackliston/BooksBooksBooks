//
//  BookDetailViewController.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GTLBooks.h>
#import "ChangeBookDetailsResultsProtocol.h"
#import "DismissBookDetailProtocol.h"
#import <GAITrackedViewController.h>
@class Book;

@interface BookDetailViewController : GAITrackedViewController <UIActionSheetDelegate, ChangeBookDetailsResultsProtocol, UIScrollViewDelegate, UIAlertViewDelegate, UITextViewDelegate>

- (id)initWithBook:(id)book width:(CGFloat)width;

@property (nonatomic, weak) id<DismissBookDetailProtocol>dismissDelegate;

@end
