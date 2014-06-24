//
//  SearchResultsViewController.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/13/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GTLBooks.h>

@interface SearchResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)setVolumes:(GTLBooksVolumes *)volumes;

- (void)startSearchWithQuery:(GTLQueryBooks *)query;

@end
