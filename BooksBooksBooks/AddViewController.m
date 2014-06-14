//
//  AddViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/12/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "AddViewController.h"
#import "UIView+Borders.h"
#import <FXBlurView/FXBlurView.h>
#import <QuartzCore/QuartzCore.h>

@interface AddViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) IBOutlet UIView *authorView;
@property (strong, nonatomic) IBOutlet UIView *isbnView;
@property (strong, nonatomic) IBOutlet UIView *titleView;

@property (strong, nonatomic) IBOutlet UITextField *isbnTextField;
@property (strong, nonatomic) IBOutlet UITextField *authorTextField;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
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
    
    UIImage *originalImage = [UIImage imageNamed:@"books.jpg"];
    self.backgroundImageView.image = [originalImage blurredImageWithRadius:7.5 iterations:10 tintColor:nil];
    
    self.mainView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];

    [self setupSearchButton];
    [self setupLabels];
    [self setupNavigationBar];
    [self setupTextFields];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Barcode Stuff

- (void)barcodeWasScanned:(NSSet *)barcodes
{
    TFBarcode *barcode = [barcodes anyObject];
    self.isbnTextField.text = barcode.string;
    [self stop];
}

#pragma mark Start Search

- (void)startSearchWithISBN:(NSString *)isnb author:(NSString *)author title:(NSString *)title
{
    
}

#pragma mark TextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self stop];
}

#pragma mark Setup 

- (void)setupSearchButton
{
    self.searchButton.backgroundColor = [UIColor clearColor];
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

}

- (void)setupLabels
{
    // Set the background color of the input views. Make each one succesively darker
    self.titleView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    self.authorView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    self.isbnView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    self.searchButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    
    // The color of the borders
    UIColor *borderColor = [UIColor lightGrayColor];
    
    // Add the borders in between the text fields and search button
    [self.titleView addTopBorderWithHeight:0.5 andColor:borderColor];
    [self.authorView addTopBorderWithHeight:0.5 andColor:borderColor];
    [self.isbnView addTopBorderWithHeight:0.5 andColor:borderColor];
    [self.isbnView addBottomBorderWithHeight:1.0 andColor:borderColor];
}

- (void)setupTextFields
{
    // Set the color of the placeholder texts in all the placeholders
    UIColor *color = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Into the Wild" attributes:@{NSForegroundColorAttributeName: color}];
    self.authorTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Jon Krakauer" attributes:@{NSForegroundColorAttributeName: color}];
    self.isbnTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"938409837" attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)setupNavigationBar
{
    // Make the nav bar transparent
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    // Make the navBar items white
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // Remove the 'back' text from the navBar
    self.navigationController.navigationBar.topItem.title = @"";
}
@end
