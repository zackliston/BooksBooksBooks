//
//  SearchResultsViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/13/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "MiniBookView.h"
#import "Constants.h"
#import <FXBlurView/FXBlurView.h>

@interface SearchResultsViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIView *customDimmingView;

@end

@implementation SearchResultsViewController

static NSString *collectionCellIdentifier = @"collectionCellIdentifer";

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionCellIdentifier];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    UIImage *originalImage = [UIImage imageNamed:@"books.jpg"];
    self.backgroundImageView.image = [originalImage blurredImageWithRadius:7.5 iterations:10 tintColor:nil];
      self.customDimmingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    
    [self setupNavigationBar];
}

#pragma mark Collection Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    MiniBookView *miniCollectionView = [[MiniBookView alloc] initWithJSONData:@{VOLUME_INFO_KEY:@{AUTHORS_KEY:@[@"Ray Bradbury"], TITLE_KEY:@"Fahrenheit 451"}, IMAGE_LINKS_KEY:@{THUMBNAIL_ADDRESS_KEY:@"http://bks0.books.google.com/books?id=y3CyRurE7P4C&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"}}];
    
    cell.backgroundView = miniCollectionView;
    
    return cell;
}

#pragma mark Collection View Delegate

#pragma mark Setup

- (void)setupNavigationBar
{
    // Remove the 'back' text from the navBar
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = @"Search Results";
}


@end
