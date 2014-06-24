//
//  BookDetailViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "BookDetailViewController.h"

@interface BookDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIButton *addToLibraryButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation BookDetailViewController

@synthesize book = _book;

#pragma mark Getters and setters

- (void)setBook:(GTLBooksVolume *)book
{
    if (_book != book) {
        _book = book;
        [self setupWithBook];
    }
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self setupWithBook];
}

- (IBAction)addToLibraryClicked:(UIButton *)sender
{
}

#pragma mark Setup

- (void)setupWithBook
{
    if (self.book) {
        self.authorLabel.text = [self.book.volumeInfo.authors lastObject];
        self.titleLabel.text = self.book.volumeInfo.title;
    }
}

- (void)setupUI
{
    self.addToLibraryButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
}

@end
