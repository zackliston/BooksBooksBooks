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
#import <DJWStarRatingView/DJWStarRatingView.h>

static NSInteger const ownActionSheetTag = 111;
static NSInteger const readActionSheetTag = 112;
static double const AddButtonHeight = 50.0;
static double const ReadOwnButtonHeights = 50.0;

static double const margin = 15.0;

@interface BookDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;

@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *topBarView;
@property (strong, nonatomic) IBOutlet UIView *starView;
@property (strong, nonatomic) IBOutlet UILabel *ratingCountLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionLabel;

@property (nonatomic, assign) BookOwnStatus ownStatus;
@property (nonatomic, assign) BookReadStatus readStatus;

@property (nonatomic, strong) Book *coreDataBook;
@property (nonatomic, strong) GTLBooksVolume *gtlBook;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *authorLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonViewHeight;


@property (nonatomic, assign) BOOL existsInLibrary;

@property (nonatomic, assign) CGFloat width;

@end

@implementation BookDetailViewController

#pragma mark Lifecycle

- (id)initWithBook:(id)book width:(CGFloat)width
{
    self = [super init];
    if (self) {
        self.width = width;
        
        if ([book isKindOfClass:[Book class]]) {
            [self setupWithCoreDataBook:book];
        } else if ([book isKindOfClass:[GTLBooksVolume class]]) {
            [self setupWithGTLBook:book];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self setupUI];
    [self setupBookView];
}

#pragma mark - Setup

#pragma mark Setup With Book

- (void)setupWithGTLBook:(GTLBooksVolume *)book
{
    self.gtlBook = book;
    
    self.coreDataBook = [[DataController sharedInstance] fetchBookWithBookID:_gtlBook.identifier];
    [self setupBookView];
}

- (void)setupWithCoreDataBook:(Book *)book
{
    self.coreDataBook = book;
    [self setupBookView];
}

- (void)setupBookExistsInLibrary:(BOOL)existsInLibrary
{
    self.existsInLibrary = existsInLibrary;
}

#pragma mark Setup buttons

- (void)setupForExistsInLibrary
{
    self.buttonViewHeight.constant = ReadOwnButtonHeights;
    [self.buttonView addSubview:[self craftReadButton]];
    [self.buttonView addSubview:[self craftOwnButton]];
}

- (UIButton *)craftReadButton
{
    CGFloat buttonWidth = (self.width-1.0)/2.0;
    UIButton *readButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, buttonWidth, ReadOwnButtonHeights)];
    readButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    readButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    [readButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSString *readButtonText;
    switch ([self.coreDataBook.readStatus integerValue]) {
        case BookHasBeenRead:
            readButtonText = @"Have Read";
            break;
        case BookIsCurrentlyReading:
            readButtonText = @"Currently Reading";
            break;
        case BookWantsToRead:
            readButtonText = @"Want to Read";
            break;
        case BookDoesNotWantToRead:
            readButtonText = @"Not Reading";
            break;
        default:
            break;
    }
    [readButton setTitle:readButtonText forState:UIControlStateNormal];
    
    return readButton;
}

- (UIButton *)craftOwnButton
{
    CGFloat buttonWidth = (self.width-1.0)/2.0;
    
    UIButton *ownButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width-buttonWidth, 0.0, buttonWidth, ReadOwnButtonHeights)];
    ownButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    ownButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    [ownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    NSString *ownButtonText;
    switch ([self.coreDataBook.doesOwn integerValue]) {
        case BookIsOwned:
            ownButtonText = @"In Library";
            break;
        case BookWantsToOwn:
            ownButtonText = @"In Wishlist";
            break;
        case BookDoesNotOwn:
            ownButtonText = @"Not Owned";
            break;
        default:
            break;
    }
    
    [ownButton setTitle:ownButtonText forState:UIControlStateNormal];
    return ownButton;
}
- (void)setupForDoesNotExistInLibrary
{
    UIButton *addToLibraryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, self.width, AddButtonHeight)];
    addToLibraryButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [addToLibraryButton setTitle:@"Add To Library" forState:UIControlStateNormal];
    addToLibraryButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    [addToLibraryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [addToLibraryButton addTarget:self action:@selector(addToLibraryClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.buttonViewHeight.constant = AddButtonHeight;
    [self.buttonView addSubview:addToLibraryButton];
}

#pragma mark Setup Book View
- (void)setupBookView
{
    if (self.existsInLibrary) {
        [self setupForExistsInLibrary];
    } else {
        [self setupForDoesNotExistInLibrary];
    }
    
    if (self.coreDataBook) {
        [self setupBookViewForCoreDataBook];
    } else if (self.gtlBook) {
        [self setupBookViewForGTLBook];
    }
}

- (void)setupBookViewForGTLBook
{
    NSString *author = [self.gtlBook.volumeInfo.authors lastObject];
    NSString *title = self.gtlBook.volumeInfo.title;
    
    [self setTitleLabelAndHeightForTitle:title];
    [self setAuthorLabelAndHeightForAuthor:author];
    [self setBookDescriptionAndHeightForDescription:self.gtlBook.volumeInfo.descriptionProperty];
    [self setRating:[self.gtlBook.volumeInfo.averageRating floatValue] ratingCount:[self.gtlBook.volumeInfo.ratingsCount integerValue]];
}

- (void)setupBookViewForCoreDataBook
{
    NSString *author = self.coreDataBook.mainAuthor;
    NSString *title = self.coreDataBook.title;

    [self setTitleLabelAndHeightForTitle:title];
    [self setAuthorLabelAndHeightForAuthor:author];
    [self setBookDescriptionAndHeightForDescription:self.coreDataBook.bookDescription];
    [self setRating:[self.coreDataBook.averageRating floatValue] ratingCount:[self.coreDataBook.ratingsCount integerValue]];
}

- (void)setupUI
{
    self.topBarView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
}

- (void)setRating:(CGFloat)rating ratingCount:(NSInteger)ratingCount
{
    DJWStarRatingView *stars = [[DJWStarRatingView alloc] initWithStarSize:CGSizeMake(20.0, 20.0) numberOfStars:5 rating:rating fillColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] unfilledColor:[UIColor clearColor] strokeColor:[UIColor lightGrayColor]];
    stars.editable = NO;
    
    self.ratingCountLabel.text = [NSString stringWithFormat:@"(%li)", (long)ratingCount];
    [self.starView addSubview:stars];
}

#pragma mark Add to library Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ownActionSheetTag) {
        if (buttonIndex < 3) {
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
    if (ownOption == 0) {
        self.ownStatus = BookIsOwned;
    } else if (ownOption == 1) {
        self.ownStatus = BookWantsToOwn;
    } else if (ownOption == 2) {
        self.ownStatus = BookDoesNotOwn;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I have read it", @"I want to read it", @"I am currently reading it", @"None of the above", nil];
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
    [[DataController sharedInstance] addBookToCoreDataWithGTLBook:self.gtlBook withReadStatus:self.readStatus ownStatus:self.ownStatus];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Button Listeners

- (IBAction)closeButtonPressed:(UIButton *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)addToLibraryClicked:(UIButton *)button
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I own this book", @"I want to own this book", @"Neither", nil];
    actionSheet.tag = ownActionSheetTag;
    [actionSheet showInView:self.view];
}

#pragma mark - Set Heights and Labels
- (void)setTitleLabelAndHeightForTitle:(NSString *)title
{
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    self.titleLabel.font = titleFont;
    
    CGSize maxSize = CGSizeMake(self.width-(margin*2.0), MAXFLOAT);
    CGRect boundingRect = [title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleFont} context:nil];
    self.titleLabelHeight.constant = boundingRect.size.height;
    
    self.titleLabel.text = title;
}

- (void)setAuthorLabelAndHeightForAuthor:(NSString *)author
{
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    self.authorLabel.font = titleFont;
    
    CGSize maxSize = CGSizeMake(self.width-(margin*2.0), MAXFLOAT);
    CGRect boundingRect = [author boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleFont} context:nil];
    self.authorLabelHeight.constant = boundingRect.size.height;
    
    self.authorLabel.text = author;
}

- (void)setBookDescriptionAndHeightForDescription:(NSString *)description
{
    if (!description || description.length < 1) {
        description = @"No description available for this book";
    }
    UIFont *descriptionFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    self.descriptionLabel.font = descriptionFont;
    
    CGSize maxSize = CGSizeMake(self.width-50.0, MAXFLOAT);
    CGRect boundingRect = [description boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:descriptionFont} context:nil];
    CGFloat height = boundingRect.size.height+20.0;
    
    CGFloat maxHeight = self.descriptionLabel.bounds.size.height;

    if (height > maxHeight) {
        self.descriptionLabel.scrollEnabled = YES;
    } else {
        self.descriptionLabel.scrollEnabled = NO;
    }
    
    self.descriptionLabel.text = description;
}

@end
