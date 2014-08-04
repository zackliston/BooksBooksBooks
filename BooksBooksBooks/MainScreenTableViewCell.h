//
//  MainScreenTableViewCell.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/23/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScreenTableViewCellDelegate.h"

@interface MainScreenTableViewCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,weak) id<MainScreenTableViewCellDelegate>delegate;

- (void)setupWithArrayOfBooks:(NSArray *)books;
- (void)setEditButtonSelected:(BOOL)isSelected;

@end
