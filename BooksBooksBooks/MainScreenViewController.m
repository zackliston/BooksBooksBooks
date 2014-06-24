//
//  MainScreenViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "MainScreenViewController.h"
#import "AddViewController.h"

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBar];
}


#pragma mark Setup
- (void)setupNavigationBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentAddViewController:)];
}


#pragma mark Button Responders
- (void)presentAddViewController:(UIBarButtonItem *)barButton
{
    AddViewController *addViewController = [[AddViewController alloc] init];
    [self.navigationController pushViewController:addViewController animated:YES];
}

@end
