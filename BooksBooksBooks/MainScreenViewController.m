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

static NSString *const MainScreenTableViewCellIdentifier = @"MainScreenTableViewCellIdentifer";

@interface MainScreenViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainScreenViewController {
    NSArray *books;
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
    [self setupBooks];
    [self setupNavigationBar];
    [self setupTableView];
}

#pragma mark TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainScreenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainScreenTableViewCellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = @"This is a cell";
    [cell setupWithArrayOfBooks:books];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0;
}

#pragma mark Setup
- (void)setupNavigationBar
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentAddViewController:)];
}

- (void)setupTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"MainScreenTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:MainScreenTableViewCellIdentifier];
    self.tableView.tableFooterView = [UIView new];
}

- (void)setupBooks
{
    books = [self fetchAllBooks];
    Book *book = [books lastObject];
    NSLog(@"We have book %@ ", book.title);

}
#pragma mark Button Responders
- (void)presentAddViewController:(UIBarButtonItem *)barButton
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
    NSArray *books = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    if (fetchError) {
        NSLog(@"Error fetching books in MainViewController %@", fetchError);
        return nil;
    } else {
        return books;
    }
}

@end
