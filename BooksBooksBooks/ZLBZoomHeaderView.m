//
//  ZLBZoomHeaderView.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/29/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "ZLBZoomHeaderView.h"
#import <objc/runtime.h>


#define NUMBER_OF_BANNER_IMAGES 24

typedef NS_ENUM(NSUInteger, ParallaxTrackingState) {
    ParallaxTrackingActive = 0,
    ParallaxTrackingInactive
};

static CGFloat const HeaderHeight = 140.0;
static CGFloat const AuthorLabelHeight = 30.0;
static CGFloat const QuoteLabelHeight = 80.0;

static NSString *const AuthorKey = @"author";
static NSString *const QuoteKey = @"quote";

static char UIScrollViewZoomHeaderView;

@interface ZLBZoomHeaderView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageDimmingView;
@property (nonatomic, strong) UILabel *quoteLabel;
@property (nonatomic, strong) UILabel *authorLabel;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *quote;
@property (nonatomic, strong) NSString *author;

@property (nonatomic, assign) ParallaxTrackingState state;

- (instancetype)initWithRandomImageRandomQuoteWidth:(CGFloat)width;

@end

@implementation ZLBZoomHeaderView {
    CGFloat labelWidths;
}

- (instancetype)initWithRandomImageRandomQuoteWidth:(CGFloat)width
{
    CGRect frame = CGRectMake(0.0, -HeaderHeight, width, HeaderHeight);
    NSLog(@"Frame %@", NSStringFromCGRect(frame));
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        labelWidths = width - 20.0;
        self.image = [self fetchRandomImage];
        NSDictionary *randomQuote = [self fetchRandomQuote];
        self.author = [randomQuote objectForKey:AuthorKey];
        self.quote = [randomQuote objectForKey:QuoteKey];
        
        [self setupUI];
        [self setInfo];
        
    }
    return self;
}

#pragma mark - Setup

- (void)setInfo
{
    self.authorLabel.text = self.author;
    self.quoteLabel.text = self.quote;
    self.imageView.image = self.image;
}

#pragma mark Setup UI

- (void)setupUI
{
    [self addSubview:[self craftImageViewWithDimmingView]];
    [self addSubview:[self craftQuoteLabel]];
    [self addSubview:[self craftAuthorLabel]];
}

- (UIImageView *)craftImageViewWithDimmingView
{
    CGRect imageViewRect = self.bounds;
    self.imageView = [[UIImageView alloc] initWithFrame:imageViewRect];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
    self.imageDimmingView = [[UIView alloc] initWithFrame:imageViewRect];
    self.imageDimmingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    self.imageDimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageDimmingView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    [self.imageView addSubview:self.imageDimmingView];
    
    return self.imageView;
}

- (UILabel *)craftQuoteLabel
{
    CGRect quoteLabelRect = CGRectMake(10.0, 20.0, labelWidths, QuoteLabelHeight);
    self.quoteLabel = [[UILabel alloc] initWithFrame:quoteLabelRect];
    
    self.quoteLabel.textColor = [UIColor whiteColor];
    self.quoteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:36.0];
    self.quoteLabel.backgroundColor = [UIColor clearColor];
    self.quoteLabel.numberOfLines = 0;
    self.quoteLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.quoteLabel.textAlignment = NSTextAlignmentLeft;
    self.quoteLabel.minimumScaleFactor = 0.25;
    self.quoteLabel.adjustsFontSizeToFitWidth = YES;
    
    self.quoteLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    return self.quoteLabel;
}

- (UILabel *)craftAuthorLabel
{
    CGRect authorLabelRect = CGRectMake(10.0, 10.0+QuoteLabelHeight+10.0, labelWidths, AuthorLabelHeight);
    self.authorLabel = [[UILabel alloc] initWithFrame:authorLabelRect];
    
    self.authorLabel.textColor = [UIColor whiteColor];
    self.authorLabel.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16.0];
    self.authorLabel.backgroundColor = [UIColor clearColor];
    self.authorLabel.numberOfLines = 1;
    self.authorLabel.textAlignment = NSTextAlignmentRight;
    self.authorLabel.minimumScaleFactor = 0.8;
    self.authorLabel.adjustsFontSizeToFitWidth = YES;
    
    self.authorLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    return self.authorLabel;
}

#pragma mark - Get Random Stuff

- (UIImage *)fetchRandomImage
{
    NSInteger bannerImageNumber = (arc4random()%NUMBER_OF_BANNER_IMAGES)+1;
    NSString *imageName = [NSString stringWithFormat:@"bannerImage%li.jpg", (long)bannerImageNumber];
    
    return [UIImage imageNamed:imageName];
}

- (NSDictionary *)fetchRandomQuote
{
    NSString *libraryPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"quotes.json"];
    NSData *rawLibrary = [NSData dataWithContentsOfFile:libraryPath];
    NSError *ddtErr = nil;
    NSArray *libraryJSON = [NSJSONSerialization JSONObjectWithData:rawLibrary
                                                           options:NSJSONReadingAllowFragments
                                                             error:&ddtErr];
    
    if (ddtErr) {
        NSLog(@"Error %@", ddtErr);
    } else {
        NSUInteger randomIndex = arc4random() % [libraryJSON count];
        return libraryJSON[randomIndex];
    }
    return @{AuthorKey:@"Jorge Luis Borges", QuoteKey:@"I have always imagined that Paradise will be a kind of library."};
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"frame"])
        [self layoutSubviews];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
    if ((-contentOffset.y) < self.originalHeight) {
        [self setState:ParallaxTrackingInactive];
        
        static CGFloat oldShowingHeight = 0.0;
        
        if (contentOffset.y < 0) {
            CGFloat showingHeight = self.originalHeight - (self.originalHeight + contentOffset.y);
            [self.delegate zoomHeaderView:self heightShowingChanged:showingHeight];
            oldShowingHeight = showingHeight;
            
        } else {
            if (oldShowingHeight != 0.0) {
                [self.delegate zoomHeaderView:self heightShowingChanged:0.0];
            }
            
            oldShowingHeight = 0.0;
        }
    } else {
        [self setState:ParallaxTrackingActive];
    }
    
    if (self.state == ParallaxTrackingActive) {
        CGFloat yOffset = contentOffset.y*-1;
        [self setFrame:CGRectMake(0, contentOffset.y, CGRectGetWidth(self.frame), yOffset)];
        
    }
}

@end

@implementation UIScrollView (ZLBZoomHeaderView)

- (void)addHeaderWithRandomImageRandomQuote
{
    [self setContentInset:UIEdgeInsetsMake(HeaderHeight, self.contentInset.left, self.contentInset.bottom, self.contentInset.right)];
    
    ZLBZoomHeaderView *headerView = [[ZLBZoomHeaderView alloc] initWithRandomImageRandomQuoteWidth:self.bounds.size.width];
    [self addSubview:headerView];
    
    self.headerView = headerView;
    self.headerView.originalHeight = HeaderHeight;
    self.contentOffset = CGPointMake(0.0, -HeaderHeight);
    [self addObserver:self.headerView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self.headerView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setHeaderView:(ZLBZoomHeaderView *)headerView
{
    objc_setAssociatedObject(self, &UIScrollViewZoomHeaderView,
                             headerView,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (ZLBZoomHeaderView *)headerView
{
    return objc_getAssociatedObject(self, &UIScrollViewZoomHeaderView);
}

@end