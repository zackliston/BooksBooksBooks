//
//  BookDetailViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "BookDetailViewController.h"
#import "Book+Constants.h"
#import "DataController.h"
#import "DownloadManager.h"

static NSInteger const ownActionSheetTag = 111;
static NSInteger const readActionSheetTag = 112;

@interface BookDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIButton *addToLibraryButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *topBarView;

@property (nonatomic, assign) BOOL doesOwn;
@property (nonatomic, assign) NSInteger readStatus;

@property (nonatomic, strong) Book *coreDataBook;
@end

@implementation BookDetailViewController

@synthesize gtlBook = _gtlBook;

#pragma mark Getters and setters

- (void)setGtlBook:(GTLBooksVolume *)gtlBook
{
    if (_gtlBook != gtlBook) {
        _gtlBook = gtlBook;
        
        self.coreDataBook = [[DataController sharedInstance] fetchBookWithBookID:_gtlBook.identifier];
        
        [self setupBookView];
    }
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self setupBookView];
}

- (IBAction)addToLibraryClicked:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I own this book", @"I want to own this book", nil];
    actionSheet.tag = ownActionSheetTag;
    [actionSheet showInView:self.view];
}

#pragma mark - Setup

#pragma mark Setup Book View
- (void)setupBookView
{
    if (self.coreDataBook) {
        [self setupBookViewForCoreDataBook];
    } else if (self.gtlBook) {
        [self setupBookViewForGTLBook];
    }
}

- (void)setupBookViewForGTLBook
{
    self.authorLabel.text = [self.gtlBook.volumeInfo.authors lastObject];
    self.titleLabel.text = self.gtlBook.volumeInfo.title;
    self.addToLibraryButton.hidden = NO;
}

- (void)setupBookViewForCoreDataBook
{
    self.authorLabel.text = self.coreDataBook.mainAuthor;
    self.titleLabel.text = self.coreDataBook.title;
    self.addToLibraryButton.hidden = YES;
}

- (void)setupUI
{
    self.addToLibraryButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.topBarView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
}

#pragma mark Add to library Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ownActionSheetTag) {
        if (buttonIndex < 2) {
            [self clickedOwnOption:buttonIndex];
        }
    } else if (actionSheet.tag == readActionSheetTag) {
        if (buttonIndex < 4) {
            [self clickedReadOption:buttonIndex];
        }
    }
}

- (void)clickedOwnOption:(NSInteger)ownOption
{
    NSString *thirdButtonOption = @"";
    if (ownOption == 0) {
        self.doesOwn = YES;
        thirdButtonOption = @"Neither, I just own it";
    } else {
        self.doesOwn = NO;
        thirdButtonOption = @"Neither, I just want to own it";
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I have read it", @"I want to read it", @"I am currently reading it", thirdButtonOption, nil];
    actionSheet.tag = readActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)clickedReadOption:(NSInteger)readOption
{
    if (readOption == 0) {
        self.readStatus = BookHasBeenRead;
    } else if (readOption == 1) {
        self.readStatus = BookWantsToRead;
    } else if (readOption == 2) {
        self.readStatus = BookIsCurrentlyReading;
    } else if (readOption == 3) {
        self.readStatus = BookDoesNotWantToRead;
    }
    
    [self addBookToCoreData];
}

- (void)addBookToCoreData
{
    [[DataController sharedInstance] addBookToCoreDataWithGTLBook:self.gtlBook withReadStatus:self.readStatus doesOwn:self.doesOwn];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Button Listeners

- (IBAction)closeButtonPressed:(UIButton *)sender
{
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
