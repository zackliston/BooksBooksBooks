//
//  UIViewController+ZLBBannerView.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/27/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "UIViewController+ZLBBannerView.h"
#import <objc/runtime.h>

static char UIViewControllerZLBBannerView;

static CGFloat const kMinBannerHeight = 44.0;

@interface UIViewController ()

@property (nonatomic, strong) UIView *bannerView;

@end

@implementation UIViewController (ZLBBannerView)

#pragma mark - Public Methods

- (void)showBannerWithMessage:(NSString *)message timeInterval:(NSTimeInterval)time
{
    if (self.bannerView) return;
    self.bannerView = [self craftBannerViewWithMessage:message width:self.view.bounds.size.width];
    CGRect newFrame = self.bannerView.frame;
    newFrame.origin.y += newFrame.size.height;
    
    [self.view addSubview:self.bannerView];
    
    [UIView animateWithDuration:0.33 animations:^{
        self.bannerView.frame = newFrame;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
    
    [UIView animateWithDuration:0.33 delay:time options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect oldFrame = self.bannerView.frame;
        oldFrame.origin.y -= oldFrame.size.height;
        self.bannerView.frame = oldFrame;
    } completion:^(BOOL finished) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

#pragma mark - Getters/Setters

- (void)setBannerView:(UIView *)bannerView
{
    objc_setAssociatedObject(self, &UIViewControllerZLBBannerView,
                             bannerView,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)bannerView
{
    return objc_getAssociatedObject(self, &UIViewControllerZLBBannerView);
}

#pragma mark - UIView Stuff

- (UIView *)craftBannerViewWithMessage:(NSString *)message width:(CGFloat)width
{
    UIFont *defaultFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    
    CGSize maxSize = CGSizeMake(width-30.0, MAXFLOAT);
    CGRect boundingRect = [message boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:defaultFont} context:nil];
    CGFloat height = MAX(kMinBannerHeight, boundingRect.size.height+30.0);
    
    
    CGRect frame = CGRectMake(0.0, -height, width, height);
    UIView *bannerView = [[UIView alloc] initWithFrame:frame];
    bannerView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:205.0/255.0 alpha:1.0];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0, bannerView.bounds.size.height-0.5, bannerView.bounds.size.width, 0.5);
    bottomBorder.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:194.0/255.0 blue:31.0/255.0 alpha:1.0].CGColor;
    [bannerView.layer addSublayer:bottomBorder];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, bannerView.bounds.size.width, 0.5);
    topBorder.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:194.0/255.0 blue:31.0/255.0 alpha:1.0].CGColor;
    [bannerView.layer addSublayer:topBorder];
    
    CGRect labelFrame = CGRectInset(bannerView.bounds, 15.0, 10.0);
    labelFrame.origin.y += 10.0;
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:labelFrame];
    
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.font = defaultFont;
    messageLabel.textColor = [UIColor darkTextColor];
    messageLabel.numberOfLines = 0;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = message;
    
    [bannerView addSubview:messageLabel];

    return bannerView;
}

@end
