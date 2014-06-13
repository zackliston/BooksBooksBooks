//
//  MainNavigationController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/12/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "MainNavigationController.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentAddViewController)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)presentAddViewController
{
    
}

@end
