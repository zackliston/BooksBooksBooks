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
#import "Book.h"
#import "Book+Constants.h"
#import "BookShelf.h"
#import "SearchResultsTableViewCell.h"
#import "BookDetailViewController.h"
#import "UIViewController+ZLBBannerView.h"
#import "ZLBReachability.h"
#import "ZLBZoomHeaderView.h"
#import "ZLBZoomHeaderViewProtocol.h"
#import "ZLBUtilities.h"

static NSString *const kMainScreenTableViewCellIdentifier = @"kMainScreenTableViewCellIdentifer";
static NSString *const kMainScreenSearchTableViewCellIdentifer = @"kMainScreenSearchTableViewCellIdentifer";

@interface MainScreenViewController () <UISearchDisplayDelegate, ZLBZoomHeaderViewProtocol>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *actionBarView;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

@property (nonatomic, strong, getter = getNewBook) Book *newBook;

@end

@implementation MainScreenViewController {
    NSArray *books;
    NSMutableArray *bookShelves;
    NSArray *searchResults;
}

#pragma mark Initializaiton

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    [self setupBooks];
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
    BookShelf *shelfForRow = [bookShelves objectAtIndex:indexPath.row];
    
    MainScreenTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMainScreenTableViewCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.titleLabel.text = shelfForRow.title;
    [cell setupWithArrayOfBooks:shelfForRow.books];
    
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

#pragma mark Setup Bookshelves

- (void)setupBooks
{
    books = [self fetchAllBooks];
    bookShelves = [[NSMutableArray alloc] init];
    
    BookShelf *currentlyReadingShelf = [self setupCurrentlyReadingShelf];
    if (currentlyReadingShelf.books.count > 0) {
        [bookShelves addObject:currentlyReadingShelf];
    }
    
    BookShelf *wantToReadShelf = [self setupWantToReadShelf];
    if (wantToReadShelf.books.count >0) {
        [bookShelves addObject:wantToReadShelf];
    }
    
    BookShelf *wishlistShelf = [self setupWishlistShelf];
    if (wishlistShelf.books.count >0) {
        [bookShelves addObject:wishlistShelf];
    }
    
    BookShelf *libraryShelf = [self setupPersonalLibrary];
    if (libraryShelf.books.count >0) {
        [bookShelves addObject:libraryShelf];
    }
    
    BookShelf *haveReadShelf = [self setupHaveReadShelf];
    if (haveReadShelf.books.count >0) {
        [bookShelves addObject:haveReadShelf];
    }
}

- (BookShelf *)setupBookSelfWithPredicate:(NSPredicate *)predicate title:(NSString *)title
{
    NSArray *filteredArray = [books filteredArrayUsingPredicate:predicate];
    
    NSSortDescriptor *sortByTimeModified = [NSSortDescriptor sortDescriptorWithKey:@"dateModifiedInSecondsSinceEpoch" ascending:NO];
    filteredArray = [filteredArray sortedArrayUsingDescriptors:@[sortByTimeModified]];
    
    BookShelf *shelf = [[BookShelf alloc] init];
    shelf.title = title;
    shelf.books = filteredArray;
    
    return shelf;
}

- (BookShelf *)setupCurrentlyReadingShelf
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"readStatus == %i", BookIsCurrentlyReading];
    
    return [self setupBookSelfWithPredicate:predicate title:@"Books you're currently reading"];
}

- (BookShelf *)setupWantToReadShelf
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"readStatus == %i", BookWantsToRead];
    
    return [self setupBookSelfWithPredicate:predicate title:@"Books you want to read"];
}

- (BookShelf *)setupWishlistShelf
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"doesOwn == %i", BookWantsToOwn];
    
    return [self setupBookSelfWithPredicate:predicate title:@"Your wishlist"];
}

- (BookShelf *)setupPersonalLibrary
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"doesOwn == %i", BookIsOwned];
    
    return [self setupBookSelfWithPredicate:predicate title:@"All the books you own"];
}

- (BookShelf *)setupHaveReadShelf
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"readStatus == %i", BookHasBeenRead];
    
    return [self setupBookSelfWithPredicate:predicate title:@"Books you've read"];
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

- (NSArray *)fetchAllBooks
{
    NSManagedObjectContext *context = [[DataController sharedInstance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Book" inManagedObjectContext:context]];
    
    NSError *fetchError = nil;
    NSArray *fetchedBooks = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    if (fetchError) {
        NSLog(@"Error fetching books in MainViewController %@", fetchError);
        return nil;
    } else {
        return fetchedBooks;
    }
}

- (void)contextDidSave:(NSNotification *)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextDidSave:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    [self setupBooks];
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
        BookShelf *shelf = (BookShelf *)obj;
        return [shelf.books containsObject:book];
    }];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.newBook = nil;
}

#pragma mark - Delegate Methods

- (void)pushViewController:(UIViewController *)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
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
