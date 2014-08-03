//
//  PushViewControllerProtocol.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/28/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MainScreenTableViewCell;

@protocol MainScreenTableViewCellDelegate <NSObject>

- (void)pushViewController:(UIViewController *)viewController;
- (void)mainScreenTableViewCell:(MainScreenTableViewCell *)cell enabledEditing:(BOOL)enabled;
@end
