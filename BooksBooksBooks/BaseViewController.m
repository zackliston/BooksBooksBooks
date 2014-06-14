//
//  BaseViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/12/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "BaseViewController.h"
#import "AddViewController.h"
#import <FXBlurView/FXBlurView.h>

@interface BaseViewController ()


@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIView *imageDimmingView;

@end

@implementation BaseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hasAddButton = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // If the view controller should show the add rightBarButton (this action is default) then add it
    if (self.hasAddButton) {
        [self addRightBarButton];
    }
    UIImage *originalImage = [UIImage imageNamed:@"books.jpg"];
    self.backgroundImageView.image = [originalImage blurredImageWithRadius:7.5 iterations:10 tintColor:nil];
    self.imageDimmingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Helpers

// Add the 'add' right bar button that's used to add new books
- (void)addRightBarButton
{
    // Create the rightBarButton
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentAddViewController)];
    
    // Set the rightBarButton to the navBar
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

// Present the view controller responsible for looking up and adding new books
- (void)presentAddViewController
{
    AddViewController *addVC = [[AddViewController alloc] init];
    addVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self.navigationController pushViewController:addVC animated:YES];
}


@end
