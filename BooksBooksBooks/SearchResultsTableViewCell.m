//
//  SearchResultsTableViewCell.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/16/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "SearchResultsTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import <DJWStarRatingView/DJWStarRatingView.h>
#import <GTLBooks.h>
#import "Book+Constants.h"
#import "DownloadManager.h"

static CGFloat const MaxTitleHeight = 60.0;
static CGFloat const MaxAuthorHeight = 35.0;
static CGFloat const Margins = 145.0;

@interface SearchResultsTableViewCell ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *authorLabelHeight;

@property (strong, nonatomic) IBOutlet UILabel *numberOfRatingsLabel;
@property (strong, nonatomic) IBOutlet UIView *starView;

@end

@implementation SearchResultsTableViewCell

@synthesize imageURL = _imageURL;
@synthesize title = _title;
@synthesize author = _author;
@synthesize rating = _rating;
@synthesize numberOfRatings = _numberOfRatings;

#pragma mark Getters and Setters

- (void)awakeFromNib
{
    [self setupShadow];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setupWithGTLBook:(GTLBooksVolume *)book
{
    self.imageURL = book.volumeInfo.imageLinks.thumbnail;
    self.title = book.volumeInfo.title;
    self.author = [book.volumeInfo.authors firstObject];
    self.rating = [book.volumeInfo.averageRating floatValue];
    self.numberOfRatings = [book.volumeInfo.ratingsCount integerValue];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setupWithCoreDataBook:(Book *)book
{
    self.coverImageView.image = [self getLocalImageFromBook:book];
    self.title = book.title;
    self.author = book.mainAuthor;
    self.rating = [book.averageRating floatValue];
    self.numberOfRatings = [book.ratingsCount integerValue];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL != imageURL) {
        _imageURL = imageURL;
        [self setupActivityIndicator];
        [self.activityIndicator startAnimating];
        [self downloadImageAtAddress:_imageURL];
    }
}

- (void)setTitle:(NSString *)title
{
        _title = title;
        
        CGSize maxSize = CGSizeMake(self.bounds.size.width-Margins, MAXFLOAT);
        CGRect boundingRect = [_title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]} context:nil];
        CGFloat height = boundingRect.size.height+5.0;
        
        self.titleLabelHeight.constant = MIN(height, MaxTitleHeight);
        self.titleLabel.text = _title;
}

- (void)setAuthor:(NSString *)author
{
        _author = author;
        
        CGSize maxSize = CGSizeMake(self.bounds.size.width-Margins, MAXFLOAT);
        CGRect boundingRect = [_author boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]} context:nil];
        CGFloat height = boundingRect.size.height+5.0;
        
        self.authorLabelHeight.constant = MIN(height, MaxAuthorHeight);
        self.authorLabel.text = _author;
}

- (void)setRating:(CGFloat)rating
{
    _rating = rating;
        
    DJWStarRatingView *stars = [[DJWStarRatingView alloc] initWithStarSize:CGSizeMake(20.0, 20.0) numberOfStars:5 rating:rating fillColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] unfilledColor:[UIColor clearColor] strokeColor:[UIColor lightGrayColor]];
        stars.editable = NO;
        
        [self.starView addSubview:stars];
}

- (void)setNumberOfRatings:(NSInteger)numberOfRatings
{
    _numberOfRatings = numberOfRatings;
    
    self.numberOfRatingsLabel.text = [NSString stringWithFormat:@"(%li)", (long)numberOfRatings];
}

- (void)setupActivityIndicator
{
    if (!self.activityIndicator) {
        CGRect activityFrame = CGRectMake(0.0, 0.0, 25.0, 25.0);
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:activityFrame];
        self.activityIndicator.center = self.imageView.center;
        self.activityIndicator.hidesWhenStopped = YES;
        
        [self.imageView addSubview:self.activityIndicator];
    }
}

- (void)downloadImageAtAddress:(NSString *)address
{
    // Craft the request based on the provided address
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    
    // Create a weak reference to the coverImageView and activityView so we can add the image and stop the spinner from inside the block
    __weak UIImageView *weakCoverImageView = self.coverImageView;
    __weak UIActivityIndicatorView *weakActivityView = self.activityIndicator;
    __weak SearchResultsTableViewCell *weakSelf = self;
    [self.coverImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        // If the image is successfully downloaded, set it as the coverImageView
        weakCoverImageView.image = image;
        [weakActivityView stopAnimating];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakActivityView stopAnimating];
        [weakSelf performSelectorOnMainThread:@selector(failedImageDownload) withObject:nil waitUntilDone:NO];
    }];
}

- (void)failedImageDownload
{
    UILabel *failureLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.coverImageView.frame, 5.0, 5.0)];
    failureLabel.backgroundColor = [UIColor clearColor];
    failureLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
    failureLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    failureLabel.text = @"Could not download image at this time.";
    failureLabel.textAlignment = NSTextAlignmentCenter;
    failureLabel.numberOfLines = 0;
    failureLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.coverImageView addSubview:failureLabel];
}

- (void)setupShadow
{
    self.coverImageView.layer.masksToBounds = NO;
    self.coverImageView.layer.shadowRadius = 5.0;
    self.coverImageView.layer.shadowOpacity = 0.8;
    self.coverImageView.layer.shadowOffset = CGSizeZero;
    self.coverImageView.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)prepareForReuse
{
    self.imageView.image = nil;
    self.titleLabel.text = @"";
    self.authorLabel.text = @"";
    self.rating = 0.0;
    self.numberOfRatings = 0;
}

#pragma mark - Helpers

- (UIImage *)getLocalImageFromBook:(Book *)book
{
    NSMutableDictionary *availableLocalImages = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [book.localImageLinks allKeys]) {
        NSString *path = [book.localImageLinks objectForKey:key];
        
        if ([DownloadManager doesImageExistAtPath:path]) {
            [availableLocalImages setObject:path forKey:key];
        } else {
            NSString *remoteURL = [book.imageURLs objectForKey:key];
            
            if (remoteURL) {
                [DownloadManager downloadImageFrom:remoteURL to:path];
            }
        }
    }
    
    NSString *pathToImage = [availableLocalImages objectForKey:thumbnailImageKey];
    
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
@end
