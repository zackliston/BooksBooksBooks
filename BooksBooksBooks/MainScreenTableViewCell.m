//
//  MainScreenTableViewCell.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/23/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "MainScreenTableViewCell.h"
#import "BookCollectionViewCell.h"
#import "Book.h"
#import "Book+Constants.h"

static NSString *const MainScreenCollectionViewCellIdentifier = @"MainScreenCollectionViewIdentifer";

@interface MainScreenTableViewCell ()

@property (nonatomic, strong) NSArray *books;

@end

@implementation MainScreenTableViewCell

- (void)awakeFromNib
{
    [self setupCollectionView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark CollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.books.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Book *book = [self.books objectAtIndex:indexPath.row];
    
    BookCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MainScreenCollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor darkGrayColor];
    [cell setupWithBook:book];
    
    return cell;
}

#pragma mark Setup

- (void)setupWithArrayOfBooks:(NSArray *)books
{
    self.books = books;
    [self.collectionView reloadData];
}

- (void)setupCollectionView
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"BookCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:MainScreenCollectionViewCellIdentifier];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

@end
