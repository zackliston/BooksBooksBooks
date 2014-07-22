//
//  ZLBSearchViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/21/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "ZLBSearchViewController.h"

@interface ZLBSearchViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ZLBSearchViewController

#pragma mark - Public Methods

- (void)presentFromViewController:(UIViewController *)parentViewController
{
    [parentViewController addChildViewController:self];
    
    CGRect frame = parentViewController.view.bounds;
    frame.origin.y = frame.size.height;
    self.view.frame = frame;
    
    [parentViewController.view addSubview:self.view];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        [self.searchBar becomeFirstResponder];
    }];
}

#pragma mark - Initialization

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupUI
{
    [self.searchBar setTintColor:[UIColor darkGrayColor]];
    [self.searchBar setBackgroundColor:[UIColor darkGrayColor]];
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8];
}

#pragma mark - Search Bar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = frame.size.height;
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
@end
