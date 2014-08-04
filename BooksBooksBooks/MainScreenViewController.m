//
//  MainScreenViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "MainScreenViewController.h"
#import "AddViewController.h"
#import "MainScreenTableViewCell.h"
#import "DataController.h"
#import "SearchResultsTableViewCell.h"
#import "BookDetailViewController.h"
#import "UIViewController+ZLBBannerView.h"
#import "ZLBReachability.h"
#import "ZLBZoomHeaderView.h"
#import "ZLBZoomHeaderViewProtocol.h"
#import "ZLBUtilities.h"
#import "Shelf+Books.h"
#import "Book+Constants.h"

static NSString *const kMainScreenTableViewCellIdentifier = @"kMainScreenTableViewCellIdentifer";
static NSString *const kMainScreenSearchTableViewCellIdentifer = @"kMainScreenSearchTableViewCellIdentifer";

@interface MainScreenViewController () <UISearchDisplayDelegate, ZLBZoomHeaderViewProtocol>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *actionBarView;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

@property (nonatomic, strong, getter = getNewBook) Book *newBook;

@end

@implementation MainScreenViewController {
    NSArray *bookShelves;
    NSMutableDictionary *booksForBookShelf;
    NSArray *searchResults;
}

#pragma mark Initializaiton

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        booksForBookShelf = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupBookShelves];
    [self setupStatusBar];
    [self setupTableView];
    [self setupActionBarView];
    [self setupNotificationObservers];
    [self setupSearch];
    [self setupHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Main Screen";
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.newBook) {
        [self scrollToWhereNewInsertedObjectIs:self.newBook];
    }
}

#pragma mark - Setup

- (void)setupNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)setupTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"MainScreenTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kMainScreenTableViewCellIdentifier];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 60.0)];
    
}

- (void)setupActionBarView
{
    self.actionBarView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8];
    [self.addButton setTintColor:[UIColor whiteColor]];
}

- (void)setupStatusBar
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)setupNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[[DataController sharedInstance] managedObjectContext]];
}

- (void)setupSearch
{
    self.searchDisplayController.searchBar.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [self.searchDisplayController.searchBar setBarTintColor:[UIColor clearColor]];
    [self.searchDisplayController.searchBar setTintColor:[UIColor whiteColor]];
    
    self.searchDisplayController.searchResultsTableView.tableHeaderView = [UIView new];
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:nil] forCellReuseIdentifier:kMainScreenSearchTableViewCellIdentifer];
}

- (void)setupHeaderView
{
    [self.tableView addHeaderWithRandomImageRandomQuote];
    self.tableView.headerView.delegate = self;
}

- (void)setupBookShelves
{
    bookShelves = [[DataController sharedInstance] fetchAllShelves];
    
    for (Shelf *shelf in bookShelves) {
        [booksForBookShelf setObject:shelf.books forKey:shelf.objectID];
    }
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return bookShelves.count;
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResults.count;
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return [self mainTableViewCellForRowAtIndexPath:indexPath];
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self searchTableViewCellForRowAtIndexPath:indexPath];
    } else {
        return nil;
    }
}

- (UITableViewCell *)mainTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Shelf *shelfForRow = [bookShelves objectAtIndex:indexPath.row];
    NSArray *booksForRow = [booksForBookShelf objectForKey:shelfForRow.objectID];
    
    MainScreenTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMainScreenTableViewCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.titleLabel.text = shelfForRow.title;
    [cell setEditButtonSelected:self.tableView.isEditing];
    [cell setupWithArrayOfBooks:booksForRow];
    
    return cell;
}

- (UITableViewCell *)searchTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchResultsTableViewCell *cell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:kMainScreenSearchTableViewCellIdentifer forIndexPath:indexPath];
    
    Book *book = [searchResults objectAtIndex:indexPath.row];
    [cell setupWithCoreDataBook:book];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        return 225.0;
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 180.0;
    }
    return 10.0;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        Book *book = [searchResults objectAtIndex:indexPath.row];
        BookDetailViewController *bookDetailVC = [[BookDetailViewController alloc] initWithBook:book width:self.view.bounds.size.width];
        [self.navigationController pushViewController:bookDetailVC animated:YES];\
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Shelf *oldShelf = [bookShelves objectAtIndex:sourceIndexPath.row];
    [[DataController sharedInstance] changeSortOrderOfShelf:oldShelf to:destinationIndexPath.row from:sourceIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *mutableShelves = [bookShelves mutableCopy];
        Shelf *shelf = [mutableShelves objectAtIndex:indexPath.row];
        [mutableShelves removeObject:shelf];
        
        [self.tableView beginUpdates];
        bookShelves = [mutableShelves copy];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        [[DataController sharedInstance] performSelector:@selector(deleteShelf:) withObject:shelf afterDelay:0.5];
    }
}

#pragma mark Button Responders

- (IBAction)addButtonPressed:(UIButton *)sender
{
    if ([[ZLBReachability sharedInstance] isReachable]) {
        [self presentAddViewController];
    } else {
        [self showBannerWithMessage:@"You are not connected to the internet. To add books you must have an Internet connection." timeInterval:5.0];
    }
}

- (IBAction)searchButtonPressed:(UIButton *)sender
{
    [self.searchDisplayController setActive:YES animated:YES];
    self.searchDisplayController.searchBar.hidden = NO;
}

- (void)presentAddViewController
{
    AddViewController *addViewController = [[AddViewController alloc] init];
    [self.navigationController pushViewController:addViewController animated:YES];
}

#pragma mark Core Data Stuff

- (void)contextDidSave:(NSNotification *)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextDidSave:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    [self setupBookShelves];
    [self.tableView reloadData];
    
    NSSet *insertedObjects = [notification.userInfo objectForKey:NSInsertedObjectsKey];
    if (insertedObjects.count == 1) {
        id object = [insertedObjects anyObject];
        if ([object isKindOfClass:[Book class]]) {
          self.newBook = [insertedObjects anyObject];   
        }
    }
}

- (void)scrollToWhereNewInsertedObjectIs:(Book *)book
{
    NSInteger index = [bookShelves indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Shelf *shelf = (Shelf *)obj;
        return [shelf.books containsObject:book];
    }];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.newBook = nil;
}

#pragma mark - MainScreenTableViewCell Delegate Methods

- (void)pushViewController:(UIViewController *)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)mainScreenTableViewCell:(MainScreenTableViewCell *)cell enabledEditing:(BOOL)enabled
{
    [self.tableView setEditing:enabled animated:YES];
    
    for (MainScreenTableViewCell *cell in self.tableView.visibleCells) {
        [cell setEditButtonSelected:enabled];
    }
}

#pragma mark - Search 

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [controller.searchBar becomeFirstResponder];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    self.searchDisplayController.searchBar.hidden = YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    searchResults = [[DataController sharedInstance] searchBooksWithSearchText:searchString];
    return YES;
}

#pragma mark - Zoom Header View Delegate

- (void)zoomHeaderView:(ZLBZoomHeaderView *)zoomHeaderView heightShowingChanged:(CGFloat)newHeightShowing
{
    if (newHeightShowing < 20.0) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
}

@end
