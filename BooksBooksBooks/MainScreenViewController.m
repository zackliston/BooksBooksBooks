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
#import "MainScreenHeaderView.h"

static NSString *const MainScreenTableViewCellIdentifier = @"MainScreenTableViewCellIdentifer";

@interface MainScreenViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *actionBarView;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

@property (nonatomic, strong, getter = getNewBook) Book *newBook;

@end

@implementation MainScreenViewController {
    NSArray *books;
    NSMutableArray *bookShelves;
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

#pragma mark Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupBooks];
    [self setupNavigationBar];
    [self setupStatusBar];
    [self setupTableView];
    [self setupActionBarView];
    [self setupNotificationObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Main Screen";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.newBook) {
        [self scrollToWhereNewInsertedObjectIs:self.newBook];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return bookShelves.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookShelf *shelfForRow = [bookShelves objectAtIndex:indexPath.row];
    
    
    MainScreenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainScreenTableViewCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.titleLabel.text = shelfForRow.title;
    [cell setupWithArrayOfBooks:shelfForRow.books];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 225.0;
}

#pragma mark - Setup
- (void)setupNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)setupTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"MainScreenTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MainScreenTableViewCellIdentifier];
    
    self.tableView.tableHeaderView = [self headerView];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 60.0)];
    
}

- (UIView *)headerView
{
    MainScreenHeaderView *header = [[MainScreenHeaderView alloc] initWithRandomImageRandomQuoteWidth:320.0];

    return header;
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
    [self presentAddViewController];
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

- (void)presentViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController animated:YES completion:NULL];
}


@end
