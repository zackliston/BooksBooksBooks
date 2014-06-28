//
//  AddViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/12/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "AddViewController.h"
#import "UIView+Borders.h"
#import "SearchResultsViewController.h"
#import <GTLBooks.h>
#import <FXBlurView/FXBlurView.h>
#import <QuartzCore/QuartzCore.h>

@interface AddViewController ()

@property (strong, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) IBOutlet UIView *authorView;
@property (strong, nonatomic) IBOutlet UIView *isbnView;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UIView *navigationView;

@property (strong, nonatomic) IBOutlet UITextField *isbnTextField;
@property (strong, nonatomic) IBOutlet UITextField *authorTextField;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;

@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *isbnLabel;


@property (nonatomic, strong) SearchResultsViewController *searchResultsViewController;

@end

@implementation AddViewController


@synthesize searchResultsViewController = _searchResultsViewController;

#pragma mark Initiation

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark Getters Setters

- (SearchResultsViewController *)searchResultsViewController
{
    if (!_searchResultsViewController) {
        _searchResultsViewController = [[SearchResultsViewController alloc] init];
    }
    return _searchResultsViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupSearchButton];
    [self setupLabels];
    [self setupNavigationBar];
    [self setupTextFields];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupNavigationBar];
}

#pragma mark Barcode Stuff

- (void)barcodeWasScanned:(NSSet *)barcodes
{
    TFBarcode *barcode = [barcodes anyObject];
    self.isbnTextField.text = barcode.string;
    [self stop];
    [self startSearchWithISBN:barcode.string author:nil title:nil];
  
}

#pragma mark Start Search
- (IBAction)searchButtonClicked:(UIButton *)sender
{
    [self startSearch];
}

- (void)startSearch
{
    NSString *isbn = self.isbnTextField.text;
    NSString *errorTitle = @"";
    NSString *errorText = @"";
    BOOL error = NO;
    if (!(isbn.length == 0 || isbn.length == 10 || isbn.length == 13)) {
        error = YES;
        errorTitle = @"Invalid ISBN";
        errorText = @"An ISBN can only be 10 or 13 numbers";
    } else {
        if (self.titleTextField.text.length + self.authorTextField.text.length + self.isbnTextField.text.length < 1) {
            error = YES;
            errorTitle = @"What're you searching for?";
            errorText = @"To search for a book you need to enter at least one of the three (author, title, ISBN) or scan the barcode on a book.";
        }
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorTitle message:errorText delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    } else {
        [self startSearchWithISBN:self.isbnTextField.text author:self.authorTextField.text title:self.titleTextField.text];
    }
}
- (void)startSearchWithISBN:(NSString *)isbn author:(NSString *)author title:(NSString *)title
{
    
    NSString *queryText = @"";
    if (isbn.length >0) {
        queryText = [queryText stringByAppendingFormat:@"isbn:%@", isbn];
    }
    
    if (author.length>0) {
        if (queryText.length >0) {
            queryText = [queryText stringByAppendingFormat:@"&inauthor:%@", author];
        } else {
            queryText = [queryText stringByAppendingFormat:@"inauthor:%@", author];
        }
    }
    
    if (title.length >0) {
        if (queryText.length >0) {
            queryText = [queryText stringByAppendingFormat:@" intitle:%@", title];
        } else {
            queryText = [queryText stringByAppendingFormat:@"intitle:%@", title];
        }
    }
    
    GTLQueryBooks *query = [GTLQueryBooks queryForVolumesListWithQ:queryText];
    query.shouldSkipAuthorization = YES;
    query.orderBy = kGTLBooksOrderByRelevance;
    query.maxResults = 10;
    query.startIndex = 0;
    
    SearchResultsViewController *searchResultsVC = [[SearchResultsViewController alloc] init];
    
    [self.navigationController pushViewController:searchResultsVC animated:YES];
    [searchResultsVC startSearchWithQuery:query];
}

#pragma mark TextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self stop];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self startSearch];
    return YES;
}

- (void)textFieldTextDidChange:(UITextField *)textField
{
    UIColor *textColor;
    
    if (textField.text.length > 0) {
        textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    } else {
        textColor = [UIColor whiteColor];
    }
    
    if (textField == self.titleTextField) {
        self.titleLabel.textColor = textColor;
    } else if (textField == self.authorTextField) {
        self.authorLabel.textColor = textColor;
    } else if (textField == self.isbnTextField) {
        self.isbnLabel.textColor = textColor;
    }
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
    self.titleView.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
    self.authorView.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    self.isbnView.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    self.searchButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    
    // The color of the borders
    UIColor *borderColor = [UIColor lightGrayColor];
    
    // Add the borders in between the text fields and search button
    [self.titleView addTopBorderWithHeight:0.5 andColor:borderColor];
    [self.authorView addTopBorderWithHeight:0.5 andColor:borderColor];
    [self.isbnView addTopBorderWithHeight:0.5 andColor:borderColor];
    [self.searchButton addTopBorderWithHeight:0.5 andColor:borderColor];
}

- (void)setupTextFields
{
    // Set the color of the placeholder texts in all the placeholders
    UIColor *color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20.0];
    
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Into the Wild" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:font}];
    self.authorTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Jon Krakauer" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:font}];
    self.isbnTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"938409837" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:font}];
    
    self.titleTextField.textColor = [UIColor whiteColor];
    self.authorTextField.textColor = [UIColor whiteColor];
    self.isbnTextField.textColor = [UIColor whiteColor];
    
    [self.titleTextField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.authorTextField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.isbnTextField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setupNavigationBar
{
    self.navigationView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    // Set up the navigationBar title attributes
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:36.0], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:7.5 forBarMetrics:UIBarMetricsDefault];
    
    // Remove the 'back' text from the navBar
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = @"Find a Book";
}

@end
