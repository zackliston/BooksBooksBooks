//
//  BookCollectionViewCell.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/23/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface BookCollectionViewCell : UICollectionViewCell

- (void)setupWithBook:(Book *)book;

@end
