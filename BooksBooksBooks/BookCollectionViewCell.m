//
//  BookCollectionViewCell.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/23/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "BookCollectionViewCell.h"
#import <UIImageView+AFNetworking.h>

@interface BookCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation BookCollectionViewCell

- (void)awakeFromNib
{
    [self setupShadow];
}

#pragma mark Image stuff

- (void)setImageURL:(NSString *)imageURL
{
    [self downloadImageAtAddress:imageURL toImageView:self.imageView];
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
    __weak BookCollectionViewCell *weakSelf = self;
    
    [self.imageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
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
    UILabel *failureLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.imageView.frame, 5.0, 5.0)];
    failureLabel.backgroundColor = [UIColor clearColor];
    failureLabel.textColor = [UIColor darkGrayColor];
    failureLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    failureLabel.text = @"Could not download image at this time.";
    failureLabel.textAlignment = NSTextAlignmentCenter;
    failureLabel.numberOfLines = 0;
    failureLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.imageView addSubview:failureLabel];
}

- (UIActivityIndicatorView *)craftActivityIndicatorInView:(UIView *)view
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    activityIndicator.hidesWhenStopped = YES;
    [view addSubview:activityIndicator];
    
    return activityIndicator;
}

#pragma mark Setup

- (void)setupShadow
{
    self.layer.masksToBounds = NO;
    self.layer.shadowRadius = 5.0;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}
@end
