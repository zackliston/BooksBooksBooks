//
//  SearchResultsTableViewCell.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/16/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *imageURL;

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *title;

@end
