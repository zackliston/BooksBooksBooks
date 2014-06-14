//
//  MiniBookView.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/13/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "MiniBookView.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"

@interface MiniBookView ()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation MiniBookView

- (instancetype)initWithJSONData:(NSDictionary *)jsonData
{
    CGRect mainViewRect = CGRectMake(0.0, 0.0, 128.0, 200.0);

    self = [super initWithFrame:mainViewRect];
    
    if (self) {
        self.jsonData = jsonData;
        [self craftMiniBookView];
    }
    
    return self;
}

#pragma mark Getters and Setters
- (void)setJsonData:(NSDictionary *)jsonData
{
    if (jsonData != _jsonData) {
        _jsonData = jsonData;
        self.title = [[_jsonData objectForKey:VOLUME_INFO_KEY] objectForKey:TITLE_KEY];
        self.author = [[[_jsonData objectForKey:VOLUME_INFO_KEY] objectForKey:AUTHORS_KEY] firstObject];
        self.thumbnailAddress = [[_jsonData objectForKey:IMAGE_LINKS_KEY] objectForKey:THUMBNAIL_ADDRESS_KEY];
        
    }
}

#pragma mark Visual Stuff

- (void)craftMiniBookView
{
    CGRect imageViewFrame = CGRectMake(0.0, 0.0, 128.0, 180.0);
    
    self.coverImageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    self.coverImageView.backgroundColor = [UIColor lightGrayColor];
    
    // Create the activityView
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // Make sure it's in the center of the coverImageView
    self.activityView.center = self.coverImageView.center;
    
    // Make it disappear when it stops spinning
    self.activityView.hidesWhenStopped = YES;
    
    // Start spinning
    [self.activityView startAnimating];
    
    // Add the activityView to the coverImageView
    [self.coverImageView addSubview:self.activityView];
    
    // Start the image download process
    [self downloadImageAtAddress:self.thumbnailAddress];
    
    
    // Create the priceView Frame
    CGRect authorViewFrame = CGRectMake(0.0, 150.0, 128.0, 50.0);
    
    // Create the priceView, on which the price label will sit
    UIView *authorView = [[UIView alloc] initWithFrame:authorViewFrame];
    authorView.backgroundColor = [UIColor colorWithRed:128.0/256.0 green:128.0/256.0 blue:128.0/256.0 alpha:1.0];
    // Create the priceLabel Frame
    CGRect authorLabelFrame = CGRectMake(5.0, 0.0, 118.0, 50.0);
    
    // Create and initialize the priceLabel
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:authorLabelFrame];
    authorLabel.backgroundColor = [UIColor clearColor];
    authorLabel.textColor = [UIColor whiteColor];
    authorLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    authorLabel.text = self.author;
    authorLabel.textAlignment = NSTextAlignmentCenter;
    
    // Place the priceLabel on the priceView
    [authorView addSubview:authorLabel];
    
    // Place the converImageView on the main view
    [self addSubview:self.coverImageView];
    
    // Place the priceView on the main view
    [self addSubview:authorView];
}

- (void)downloadImageAtAddress:(NSString *)address
{
    // Craft the request based on the provided address
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    
    // Create a weak reference to the coverImageView and activityView so we can add the image and stop the spinner from inside the block
    __weak UIImageView *weakCoverImageView = self.coverImageView;
    __weak UIActivityIndicatorView *weakActivityView = self.activityView;
    __weak MiniBookView *weakSelf = self;
    
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

@end
