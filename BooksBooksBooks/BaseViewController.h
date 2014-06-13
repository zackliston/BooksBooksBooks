//
//  BaseViewController.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/12/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DismissPresenedViewController <NSObject>

- (void)dismissPresentedViewController;

@end

@interface BaseViewController : UIViewController <DismissPresenedViewController>

@property (nonatomic, assign) BOOL hasAddButton;

@end
