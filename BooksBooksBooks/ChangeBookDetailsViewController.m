//
//  ChangeBookDetailsViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/5/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "ChangeBookDetailsViewController.h"
#import "DataController.h"
#import "Book+Constants.h"

NSString *const BookDetailsChangeResultOwnKey = @"ownKey";
NSString *const BookDetailsChangeResultReadKey = @"readKey";

static double const ButtonHeight = 50.0;

@interface ChangeBookDetailsViewController ()

@property (strong, nonatomic) IBOutlet UIView *selectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectionViewHeight;
@property (nonatomic, assign) ChangeBookDetailsOptions option;
@property (nonatomic, strong) NSMutableArray *selectionButtons;

@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;


@property (nonatomic, assign) NSInteger tagSelected;
@property (nonatomic, strong) NSMutableDictionary *results;

@property (nonatomic, weak) Book *book;
@property (nonatomic, weak) id<ChangeBookDetailsResultsProtocol>resultsDelegate;
@property (nonatomic, assign, readonly) BOOL isNewBook;

@end

@implementation ChangeBookDetailsViewController

@synthesize selectionButtons = _selectionButtons;
@synthesize tagSelected = _tagSelected;

#pragma mark Getters/Setters

- (NSMutableArray *)selectionButtons
{
    if (!_selectionButtons) {
        _selectionButtons = [NSMutableArray new];
    }
    return _selectionButtons;
}

- (void)setTagSelected:(NSInteger)tagSelected
{
    _tagSelected = tagSelected;
    
    for (UIButton *selectionButton in self.selectionButtons) {
        if (selectionButton.tag == tagSelected) {
            selectionButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
        } else {
            selectionButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.9];
        }
    }
    
    if (self.option == ChangeBookReadStatusOption) {
        [self.results setObject:[NSNumber numberWithInteger:_tagSelected] forKey:BookDetailsChangeResultReadKey];
    } else if (self.option == ChangeBookOwnershipOption) {
        [self.results setObject:[NSNumber numberWithInteger:_tagSelected] forKey:BookDetailsChangeResultOwnKey];
    }
}

- (NSMutableDictionary *)results
{
    if (!_results) {
        _results = [NSMutableDictionary new];
    }
    return _results;
}
#pragma mark Initialization

- (id)initForExistingBook:(id)book WithOption:(ChangeBookDetailsOptions)option
{
    self = [super init];
    if (self) {
        self.option = option;
        self.book = book;
        _isNewBook = NO;
    }
    return self;
}

- (id)initWithResultsDelegate:(id<ChangeBookDetailsResultsProtocol>)delegate
{
    self = [super init];
    if (self) {
        self.resultsDelegate = delegate;
        self.option = ChangeBookOwnershipOption;
        _isNewBook = YES;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self setupButtons];
}

- (void)remove
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - Setup

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    self.selectionView.backgroundColor = [UIColor clearColor];
    self.selectionView.layer.cornerRadius = 5.0;
    self.selectionView.layer.masksToBounds = YES;
    
    self.saveButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    self.nextButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    self.cancelButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    self.backButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
    
    [self.nextButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [self.saveButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    
    CALayer *middleBorder = [CALayer layer];
    middleBorder.frame = CGRectMake(self.cancelButton.bounds.size.width-0.5, 0.0, 0.5, self.cancelButton.bounds.size.height);
    middleBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.cancelButton.layer addSublayer:middleBorder];
    
    CALayer *backMiddleBorder = [CALayer layer];
    backMiddleBorder.frame = CGRectMake(self.backButton.bounds.size.width-0.5, 0.0, 0.5, self.backButton.bounds.size.height);
    backMiddleBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.backButton.layer addSublayer:backMiddleBorder];
}

- (void)setupButtons
{
    [self removeExistingSelectionButtons];
    [self showSaveOrNextButton];
    [self showCancelOrBackButton];
    self.saveButton.enabled = NO;
    self.nextButton.enabled = NO;
    
    
    switch (self.option) {
        case ChangeBookOwnershipOption:
            [self craftViewForOwnershipChange];
            break;
        case ChangeBookReadStatusOption:
            [self craftViewForReadStatusChange];
            break;
         default:
            break;
    }
    
    [self selectAppropriateButtonIfExistingBook];
}

- (void)removeExistingSelectionButtons
{
    for (UIButton *button in self.selectionButtons) {
        [button removeFromSuperview];
    }
    [self.selectionButtons removeAllObjects];
}

- (void)showSaveOrNextButton
{
    if (self.isNewBook && self.option == ChangeBookOwnershipOption) {
        self.nextButton.hidden = NO;
        self.saveButton.hidden = YES;
    } else {
        self.nextButton.hidden = YES;
        self.saveButton.hidden = NO;
    }
}

- (void)showCancelOrBackButton
{
    if (self.isNewBook && self.option == ChangeBookReadStatusOption) {
        self.backButton.hidden = NO;
        self.cancelButton.hidden = YES;
    } else {
        self.backButton.hidden = YES;
        self.cancelButton.hidden = NO;
    }
}

- (void)selectAppropriateButtonIfExistingBook
{
    if (!self.isNewBook) {
        NSInteger tagToSelect = 0;
        if (self.option == ChangeBookOwnershipOption) {
            tagToSelect = [self.book.doesOwn integerValue];
        } else if (self.option == ChangeBookReadStatusOption) {
            tagToSelect = [self.book.readStatus integerValue];
        }
        self.tagSelected = tagToSelect;
    }
}

- (void)craftViewForOwnershipChange
{
    [self.selectionView addSubview:[self craftButtonWithPlace:0 text:@"I own this book" tag:BookIsOwned]];
    [self.selectionView addSubview:[self craftButtonWithPlace:1 text:@"I want to own this book" tag:BookWantsToOwn]];
    [self.selectionView addSubview:[self craftButtonWithPlace:2 text:@"Neither" tag:BookDoesNotOwn]];
    self.selectionViewHeight.constant = (ButtonHeight*4.0);
}

- (void)craftViewForReadStatusChange
{
    [self.selectionView addSubview:[self craftButtonWithPlace:0 text:@"I have read it" tag:BookHasBeenRead]];
    [self.selectionView addSubview:[self craftButtonWithPlace:1 text:@"I want to read it" tag:BookWantsToRead]];
    [self.selectionView addSubview:[self craftButtonWithPlace:2 text:@"I am currently reading it" tag:BookIsCurrentlyReading]];
    [self.selectionView addSubview:[self craftButtonWithPlace:3 text:@"None of the above" tag:BookDoesNotWantToRead]];
    self.selectionViewHeight.constant = (ButtonHeight*5.0);
}

- (UIButton *)craftButtonWithPlace:(NSInteger)place text:(NSString *)text tag:(NSUInteger)tag
{
    CGRect frame = CGRectMake(0.0, (place*ButtonHeight), self.selectionView.bounds.size.width, ButtonHeight);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    button.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.9];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (place != 0) {
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0, 0.0, button.bounds.size.width, 0.5);
        topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
        [button.layer addSublayer:topBorder];
    }
    
    [self.selectionButtons addObject:button];
    return button;
}

#pragma mark - Save Changes

- (void)saveForBook
{
    switch (self.option) {
        case ChangeBookOwnershipOption:
            self.book.doesOwn = [NSNumber numberWithInteger:self.tagSelected];
            break;
        case ChangeBookReadStatusOption:
            self.book.readStatus = [NSNumber numberWithInteger:self.tagSelected];
            break;
        default:
            break;
    }
    [[DataController sharedInstance] saveContext];
}

#pragma mark - Button Responders

- (void)buttonPressed:(UIButton *)button
{
    self.tagSelected = button.tag;
    self.nextButton.enabled = YES;
    self.saveButton.enabled = YES;
}

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    [self remove];
}

- (IBAction)saveButtonPressed:(UIButton *)sender
{
    if (self.isNewBook) {
        [self.resultsDelegate handleResults:self.results];
    } else {
        [self saveForBook];
    }
    [self remove];
}

- (IBAction)nextButtonPressed:(UIButton *)sender
{
    self.option = ChangeBookReadStatusOption;
    [self setupButtons];
    
    self.saveButton.enabled = NO;
}

- (IBAction)backButtonPressed:(UIButton *)sender
{
    self.option = ChangeBookOwnershipOption;
    [self setupButtons];
    self.tagSelected = [[self.results objectForKey:BookDetailsChangeResultOwnKey] integerValue];
}
@end
