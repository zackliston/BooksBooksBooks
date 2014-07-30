//
//  ZLBZoomHeaderView.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/29/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLBZoomHeaderViewProtocol.h"

@interface ZLBZoomHeaderView : UIView

@property (nonatomic, weak) id<ZLBZoomHeaderViewProtocol>delegate;
@property (nonatomic, assign) CGFloat originalHeight;

@end

@interface UIScrollView (ZLBZoomHeaderView)

@property (nonatomic, strong) ZLBZoomHeaderView *headerView;

- (void)addHeaderWithRandomImageRandomQuote;

@end