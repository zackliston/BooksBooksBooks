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
#import "ChangeBookDetailsViewController.h"
#import <UIImageView+AFNetworking.h>
#import <DJWStarRatingView/DJWStarRatingView.h>

static double const kAddButtonHeight = 50.0;
static double const kReadOwnButtonHeights = 50.0;
static double const kMargin = 15.0;
static double const kDefaultDescriptionHeight = 50.0;
static double const kMaxTitleFontSize = 40.0;
static double const kMaxAuthorFontSize = 20.0;
static double const kMaxTitleLabelHeight = 60.0;
static double const kMaxAuthorLabelHeight = 40.0;
static double const kDefaultTitleAuthorLabelWidth = 250;
static double const kDefaultNotesTextViewHeight = 100.0;

@interface BookDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;

@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *topBarView;
@property (strong, nonatomic) IBOutlet UIView *starView;
@property (strong, nonatomic) IBOutlet UIView *personalRatingView;
@property (nonatomic, strong) DJWStarRatingView *personalStars;

@property (strong, nonatomic) IBOutlet UITextView *notesTextView;

@property (strong, nonatomic) IBOutlet UILabel *ratingCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIImageView *bookImageView;

@property (nonatomic, strong) Book *coreDataBook;
@property (nonatomic, strong) GTLBooksVolume *gtlBook;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *authorLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verticalSpaceBetweenMainViewAndBottomOrScreen;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *notesTextViewHeight;


@property (nonatomic, assign) BOOL existsInLibrary;

@property (nonatomic, assign) CGFloat width;

@end

@implementation BookDetailViewController {
    CGFloat expandedDescriptionHeight;
    CGFloat personalRating;
    BOOL personalDetailsDidChange;
}

#pragma mark Lifecycle

- (id)initWithBook:(id)book width:(CGFloat)width
{
    self = [super init];
    if (self) {
        personalDetailsDidChange = NO;
        self.width = width;
        
        if ([book isKindOfClass:[Book class]]) {
            [self setupWithCoreDataBook:book];
        } else if ([book isKindOfClass:[GTLBooksVolume class]]) {
            [self setupWithGTLBook:book];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
        @try {
            [self.personalStars removeObserver:self forKeyPath:NSStringFromSelector(@selector(isFinished))];
        }
        @catch (NSException * __unused exception) {}
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self setupUI];
    [self setupKeyboardListeners];
    [self setupBookView];
    [self setupNotificationObservers];
    [self setupImageView];
    personalDetailsDidChange = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Book Details";
    
}

#pragma mark - Setup

#pragma mark Setup With Book

- (void)setupWithGTLBook:(GTLBooksVolume *)book
{
    self.gtlBook = book;
    
    self.coreDataBook = [[DataController sharedInstance] fetchBookWithBookID:_gtlBook.identifier];
   
    if (self.coreDataBook) {
        self.existsInLibrary = YES;
    }
    
    [self setupBookView];
}

- (void)setupWithCoreDataBook:(Book *)book
{
    self.coreDataBook = book;
    self.existsInLibrary = YES;
    
    [self setupBookView];
}

#pragma mark Setup buttons

- (void)setupForExistsInLibrary
{
    self.buttonViewHeight.constant = kReadOwnButtonHeights;
    
    for (UIView *subView in self.buttonView.subviews) {
        [subView removeFromSuperview];
    }
    
    [self.buttonView addSubview:[self craftReadButton]];
    [self.buttonView addSubview:[self craftOwnButton]];
}

- (UIButton *)craftReadButton
{
    CGFloat buttonWidth = (self.width-1.0)/2.0;
    UIButton *readButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, buttonWidth, kReadOwnButtonHeights)];
    readButton.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.85];
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
    [readButton addTarget:self action:@selector(readButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return readButton;
}

- (UIButton *)craftOwnButton
{
    CGFloat buttonWidth = (self.width-1.0)/2.0;
    
    UIButton *ownButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width-buttonWidth, 0.0, buttonWidth, kReadOwnButtonHeights)];
    ownButton.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.85];
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
    [ownButton addTarget:self action:@selector(ownButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return ownButton;
}

- (void)setupForDoesNotExistInLibrary
{
    UIButton *addToLibraryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, self.width, kAddButtonHeight)];
    addToLibraryButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [addToLibraryButton setTitle:@"Add Book" forState:UIControlStateNormal];
    addToLibraryButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    [addToLibraryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [addToLibraryButton addTarget:self action:@selector(addToLibraryClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.buttonViewHeight.constant = kAddButtonHeight;
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
    
    [self setTitleAndHeightForTitle:title];
    [self setAuthorAndHeightForAuthor:author];
    [self setBookDescriptionAndHeightForDescription:self.gtlBook.volumeInfo.descriptionProperty];
    [self setRating:[self.gtlBook.volumeInfo.averageRating floatValue] ratingCount:[self.gtlBook.volumeInfo.ratingsCount integerValue]];
}

- (void)setupBookViewForCoreDataBook
{
    NSString *author = self.coreDataBook.mainAuthor;
    NSString *title = self.coreDataBook.title;

    self.personalStars.rating = [self.coreDataBook.personalRating floatValue];
    self.notesTextView.text = self.coreDataBook.personalNotes;
    [self setTitleAndHeightForTitle:title];
    [self setAuthorAndHeightForAuthor:author];
    [self setBookDescriptionAndHeightForDescription:self.coreDataBook.bookDescription];
    [self setRating:[self.coreDataBook.averageRating floatValue] ratingCount:[self.coreDataBook.ratingsCount integerValue]];
}

- (void)setupUI
{
    [self setupPersonalRating];
    [self setupNotesTextView];
    
    self.topBarView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.buttonView.backgroundColor = [UIColor clearColor];
}

- (void)setRating:(CGFloat)rating ratingCount:(NSInteger)ratingCount
{
    DJWStarRatingView *stars = [[DJWStarRatingView alloc] initWithStarSize:CGSizeMake(15.0, 15.0) numberOfStars:5 rating:rating fillColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] unfilledColor:[UIColor clearColor] strokeColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    stars.editable = NO;
    
    
    
    self.ratingCountLabel.text = [NSString stringWithFormat:@"(%li)", (long)ratingCount];
    [self.starView addSubview:stars];
}

- (void)setupPersonalRating
{
    self.personalStars = [[DJWStarRatingView alloc] initWithStarSize:CGSizeMake(30.0, 30.0) numberOfStars:5 rating:0.0 fillColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] unfilledColor:[UIColor clearColor] strokeColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    self.personalStars.editable = YES;
    [self.personalRatingView addSubview:self.personalStars];
    
    CGPoint newCenter = self.personalStars.center;
    newCenter.x = self.personalRatingView.bounds.size.width/2.0;
    self.personalStars.center = newCenter;
    
    [self.personalStars addObserver:self forKeyPath:@"rating" options:0 context:NULL];
}

- (void)setupNotesTextView
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScrollView:)];
    gesture.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:gesture];
    
    self.notesTextView.scrollEnabled = NO;
    self.notesTextView.layer.cornerRadius = 5.0;
    self.notesTextView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.notesTextView.layer.shadowOpacity = 9.0;
    self.notesTextView.layer.shadowRadius = 2.0;
    self.notesTextView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.notesTextView.layer.masksToBounds = NO;
}

- (void)tapScrollView:(UITapGestureRecognizer *)tap
{
    [self.notesTextView resignFirstResponder];
}

- (void)setupKeyboardListeners
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark Setup Image Stuff

- (void)setupImageView
{
    [self setupImageShadow];
    
    UIImage *image = [self getLocalImage];
    if (image) {
        self.bookImageView.image = image;
    } else if (self.coreDataBook) {
        NSString *remoteURL = [self getBiggestImagePathInDictionary:self.coreDataBook.imageURLs];
        [self setRemoteImageURL:remoteURL];
    } else {
        NSString *remoteURL = [self getBiggestImageInGTLImageLinks:self.gtlBook.volumeInfo.imageLinks];
        [self setRemoteImageURL:remoteURL];
    }
}

- (UIImage *)getLocalImage
{
    NSMutableDictionary *availableLocalImages = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [self.coreDataBook.localImageLinks allKeys]) {
        NSString *path = [self.coreDataBook.localImageLinks objectForKey:key];
        
        if ([DownloadManager doesImageExistAtPath:path]) {
            
            [availableLocalImages setObject:path forKey:key];
        } else {
            NSString *remoteURL = [self.coreDataBook.imageURLs objectForKey:key];
            
            if (remoteURL) {
                [DownloadManager downloadImageFrom:remoteURL to:path];
                
            }
        }
    }
    
    NSString *pathToImage = [self getBiggestImagePathInDictionary:availableLocalImages];
    
    if (pathToImage) {
        return [[UIImage alloc] initWithContentsOfFile:pathToImage];
    } else {
        return nil;
    }
}

- (NSString *)getBiggestImagePathInDictionary:(NSDictionary *)dictionary
{
    NSString *pathToImage;
    
    if ([dictionary objectForKey:mediumImageKey]) {
        pathToImage = [dictionary objectForKey:mediumImageKey];
    } else if ([dictionary objectForKey:smallImageKey]) {
        pathToImage = [dictionary objectForKey:smallImageKey];
    } else if ([dictionary objectForKey:thumbnailImageKey]) {
        pathToImage = [dictionary objectForKey:thumbnailImageKey];
    }
    
    return pathToImage;
}

- (NSString *)getBiggestImageInGTLImageLinks:(GTLBooksVolumeVolumeInfoImageLinks *)imageLinks
{
    if (imageLinks.medium) {
        return imageLinks.medium;
    } else if (imageLinks.small) {
        return imageLinks.small;
    } else if (imageLinks.thumbnail) {
        return imageLinks.thumbnail;
    } else {
        return imageLinks.smallThumbnail;
    }
}

- (void)setRemoteImageURL:(NSString *)imageURL
{
    [self downloadImageAtAddress:imageURL toImageView:self.bookImageView];
}

- (void)downloadImageAtAddress:(NSString *)address toImageView:(UIImageView *)imageView
{
    UIActivityIndicatorView *activityIndicator = [self craftActivityIndicatorInView:imageView];
    [activityIndicator startAnimating];
    
    // Craft the request based on the provided address
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    
    // Create a weak reference to the coverImageView and activityView so we can add the image and stop the spinner from inside the block
    __weak UIImageView *weakCoverImageView = imageView;
    __weak UIActivityIndicatorView *weakActivityView = activityIndicator;
    __weak BookDetailViewController *weakSelf = self;
    
    [self.bookImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        // If the image is successfully downloaded, set it as the coverImageView
        weakCoverImageView.image = image;
        [weakActivityView stopAnimating];
        [weakActivityView removeFromSuperview];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakActivityView stopAnimating];
        [weakSelf performSelectorOnMainThread:@selector(failedImageDownload) withObject:nil waitUntilDone:NO];
        [weakActivityView removeFromSuperview];
    }];
}

- (void)failedImageDownload
{
    UILabel *failureLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bookImageView.frame, 5.0, 5.0)];
    failureLabel.backgroundColor = [UIColor clearColor];
    failureLabel.textColor = [UIColor darkGrayColor];
    failureLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    failureLabel.text = @"Could not download image at this time.";
    failureLabel.textAlignment = NSTextAlignmentCenter;
    failureLabel.numberOfLines = 0;
    failureLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.bookImageView addSubview:failureLabel];
}

- (UIActivityIndicatorView *)craftActivityIndicatorInView:(UIView *)view
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    activityIndicator.hidesWhenStopped = YES;
    [view addSubview:activityIndicator];
    
    return activityIndicator;
}

- (void)setupImageShadow
{
    
    self.bookImageView.layer.masksToBounds = NO;
    self.bookImageView.layer.shadowRadius = 8.0;
    self.bookImageView.layer.shadowOpacity = 0.9;
    self.bookImageView.layer.shadowOffset = CGSizeZero;
    self.bookImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bookImageView.layer.cornerRadius = 5.0;
}

#pragma mark Setup Notification Obsevers

- (void)setupNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[[DataController sharedInstance] managedObjectContext]];
}

#pragma mark - Save Book

- (void)setNewBookValuesAndSave
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.coreDataBook.personalRating = [NSNumber numberWithDouble:personalRating];
    self.coreDataBook.personalNotes = self.notesTextView.text;
    
    [[DataController sharedInstance] saveBook:self.coreDataBook];
}

- (void)promptAddBook
{
    NSString *message = @"";
    if (self.notesTextView.text.length >0 && personalRating >0.4) {
        message = @"If you want to save your notes and rating for this book you must add it. Would you like to add this book?";
    } else if (self.notesTextView.text.length>0) {
        message = @"If you want to save your notes for this book you must add it. Would you like to add this book?";
    } else {
        message = @"If you want to save your rating for this book you must add it. Would you like to add this book?";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Book" message:message delegate:self cancelButtonTitle:@"Don't Add" otherButtonTitles:@"Add Book", nil];
    [alert show];
}

#pragma mark - Button Listeners

- (IBAction)closeButtonPressed:(UIButton *)sender
{
    if (personalDetailsDidChange) {
        if (!self.coreDataBook) {
            [self promptAddBook];
        } else {
            [self setNewBookValuesAndSave];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        }
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)addToLibraryClicked:(UIButton *)button
{
    ChangeBookDetailsViewController *changeVC = [[ChangeBookDetailsViewController alloc] init];
    changeVC.resultsDelegate = self;
    [self.view addSubview:changeVC.view];
    [self addChildViewController:changeVC];
}

- (void)readButtonPressed:(UIButton *)button
{
    ChangeBookDetailsViewController *changeVC = [[ChangeBookDetailsViewController alloc] initForExistingBook:self.coreDataBook WithOption:ChangeBookReadStatusOption];
    changeVC.resultsDelegate = self;
    [self.view addSubview:changeVC.view];
    [self addChildViewController:changeVC];
}

- (void)ownButtonPressed:(UIButton *)button
{
    ChangeBookDetailsViewController *changeVC = [[ChangeBookDetailsViewController alloc] initForExistingBook:self.coreDataBook WithOption:ChangeBookOwnershipOption];
    changeVC.resultsDelegate = self;
    [self.view addSubview:changeVC.view];
    [self addChildViewController:changeVC];
}

- (IBAction)moreButtonPressed:(UIButton *)sender
{
    if (self.descriptionLabelHeight.constant < expandedDescriptionHeight) {
        self.descriptionLabelHeight.constant = expandedDescriptionHeight;
        [self.moreButton setTitle:@"Less" forState:UIControlStateNormal];
    } else {
        self.descriptionLabelHeight.constant = kDefaultDescriptionHeight;
        [self.moreButton setTitle:@"More" forState:UIControlStateNormal];
    }
}
#pragma mark - Set Heights and Labels

- (void)setBookDescriptionAndHeightForDescription:(NSString *)description
{
    if (!description || description.length < 1) {
        description = @"No description available for this book";
    }
    
    UIFont *descriptionFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    self.descriptionLabel.font = descriptionFont;
    
    CGSize maxSize = CGSizeMake(self.width-(kMargin*2.0), MAXFLOAT);
    CGRect boundingRect = [description boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:descriptionFont} context:nil];
    CGFloat height = boundingRect.size.height;
    
    if (height > kDefaultDescriptionHeight) {
        self.moreButton.hidden = NO;
    } else {
        self.moreButton.hidden = YES;
    }
    
    expandedDescriptionHeight = height+15.0;
    self.descriptionLabelHeight.constant = kDefaultDescriptionHeight;
    self.descriptionLabel.text = description;
}

- (void)setTitleAndHeightForTitle:(NSString *)title
{
    CGSize maxSize = CGSizeMake(kDefaultTitleAuthorLabelWidth, kMaxTitleLabelHeight);
    CGRect boundingRect = [title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:kMaxTitleFontSize]} context:nil];
    
    self.titleLabelHeight.constant = boundingRect.size.height;
    self.titleLabel.text = title;
}

- (void)setAuthorAndHeightForAuthor:(NSString *)author
{
    CGSize maxSize = CGSizeMake(kDefaultTitleAuthorLabelWidth, kMaxAuthorLabelHeight);
    CGRect boundingRect = [author boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:kMaxAuthorFontSize]} context:nil];
    
    self.authorLabelHeight.constant = boundingRect.size.height;
    self.authorLabel.text = author;
}

#pragma mark Notification Listeners

- (void)contextDidSave
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextDidSave) withObject:nil waitUntilDone:NO];
        return;
    }
    [self setupBookView];
}

#pragma mark - Chage Book Details Delegate Methods

- (void)handleResults:(NSDictionary *)results newBook:(BOOL)isNewBook
{
    NSNumber *readStatus = [results objectForKey:BookDetailsChangeResultReadKey];
    NSNumber *ownStatus = [results objectForKey:BookDetailsChangeResultOwnKey];
    
    if (isNewBook) {
        NSDictionary *userInfo = @{kBookPersonalRatingKey: [NSNumber numberWithFloat:personalRating], kBookPersonalNotesKey:self.notesTextView.text, kBookOwnStatusKey:ownStatus, kBookReadStatusKey:readStatus};
        [[DataController sharedInstance] addBookToCoreDataWithGTLBook:self.gtlBook withUserInfo:userInfo];
    } else {
        personalDetailsDidChange = YES;
        if (readStatus) {
            self.coreDataBook.readStatus = readStatus;
        }
        if (ownStatus) {
            self.coreDataBook.doesOwn = ownStatus;
        }
    }

    [self.dismissDelegate dismissBookDetailViewController];
}

#pragma mark - AlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    } else if (buttonIndex == 1) {
        ChangeBookDetailsViewController *changeVC = [[ChangeBookDetailsViewController alloc] init];
        changeVC.resultsDelegate = self;
        [self.view addSubview:changeVC.view];
        [self addChildViewController:changeVC];
    }
}

#pragma mark - Keyboard Show Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGFloat height = 0.0;
    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        height = keyboardFrame.size.height;
    } else if (UIInterfaceOrientationIsLandscape(orientation)) {
        height = keyboardFrame.size.width;
    }
    
    [UIView animateWithDuration:0.33 animations:^{
        
        self.verticalSpaceBetweenMainViewAndBottomOrScreen.constant = height;
        
    } completion:^(BOOL finished) {
        [self.scrollView scrollRectToVisible:self.notesTextView.frame animated:YES];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.33 animations:^{
        self.verticalSpaceBetweenMainViewAndBottomOrScreen.constant = 0.0;
    }];
}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Your notes here"]) {
        textView.text = @"";
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    personalDetailsDidChange = YES;
    
    CGSize maxSize = CGSizeMake(self.notesTextView.bounds.size.width, MAXFLOAT);
    CGRect boundingRect = [textView.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]} context:nil];
    
    CGFloat height = MAX(kDefaultNotesTextViewHeight, boundingRect.size.height);
    CGFloat difference = self.notesTextViewHeight.constant-height;
    difference = fabs(difference);
    
    if (difference > 1.0) {
        self.notesTextViewHeight.constant = height;
        [self.scrollView scrollRectToVisible:CGRectMake(1.0, self.scrollView.contentSize.height, 1.0, 1.0) animated:YES];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"rating"]) {
        DJWStarRatingView *stars = (DJWStarRatingView *)object;
        CGFloat difference = fabs(stars.rating-personalRating);
        
        if (difference > 0.49 && stars.rating >= 0.0 && stars.rating <= 5.0) {
            personalRating = stars.rating;
            personalDetailsDidChange = YES;
        }
    }
}

@end
