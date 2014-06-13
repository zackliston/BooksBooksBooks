//
//  AddViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/12/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "AddViewController.h"

@interface AddViewController ()

@end

@implementation AddViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Responders
- (IBAction)dismissSelf:(UIBarButtonItem *)sender
{
    [self.dismissDelegate dismissPresentedViewController];
}

@end
