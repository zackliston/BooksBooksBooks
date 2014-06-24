//
//  SearchResultsTableViewCell.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/16/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "SearchResultsTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface SearchResultsTableViewCell ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;

@end

@implementation SearchResultsTableViewCell

@synthesize imageURL = _imageURL;

- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL != imageURL) {
        _imageURL = imageURL;
        [self setupActivityIndicator];
        [self.activityIndicator startAnimating];
        [self downloadImageAtAddress:_imageURL];
    }
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


@end
