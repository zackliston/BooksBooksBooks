//
//  ADZoomHeaderViewProtocol.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/29/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//
@class ZLBZoomHeaderView;

@protocol ZLBZoomHeaderViewProtocol <NSObject>

@optional
- (void)zoomHeaderView:(ZLBZoomHeaderView *)zoomHeaderView heightShowingChanged:(CGFloat)newHeightShowing;

@end