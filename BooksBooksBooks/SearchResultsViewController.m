//
//  SearchResultsViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/13/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "SearchResultsTableViewCell.h"
#import "Constants.h"
#import "BookDetailViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <GTLBooks.h>
#import <FXBlurView/FXBlurView.h>

@interface SearchResultsViewController ()

@property (strong, nonatomic) IBOutlet UIView *navigationView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) GTLServiceBooks *service;
@property (nonatomic, strong) GTLBooksVolumes *volumes;
@property (nonatomic, strong) GTLServiceTicket *serviceTicket;

@end

@implementation SearchResultsViewController

@synthesize service = _service;
@synthesize serviceTicket = _serviceTicket;

static NSString *tableCellIdentifier = @"tableCellIdentifer";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self setupNavigationBar];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"";
}
- (GTLServiceBooks *)service
{
    if (!_service) {
        _service  = [[GTLServiceBooks alloc] init];
        _service.shouldFetchNextPages = NO;
        _service.retryEnabled = YES;
        _service.shouldFetchInBackground = YES;
    }
    return _service;
}

#pragma mark Collection Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.volumes.items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchResultsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
    if (!cell) {
        cell = [[SearchResultsTableViewCell alloc] init];
    }
    
    GTLBooksVolume *book = [self.volumes objectAtIndexedSubscript:indexPath.row];
    cell.imageURL = book.volumeInfo.imageLinks.thumbnail;
    cell.title = book.volumeInfo.title;
    cell.author = [book.volumeInfo.authors firstObject];
    cell.rating = [book.volumeInfo.averageRating floatValue];
    cell.numberOfRatings = [book.volumeInfo.ratingsCount integerValue];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180.0;
}

#pragma mark Collection View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTLBooksVolume *book = [self.volumes objectAtIndexedSubscript:indexPath.row];
    BookDetailViewController *bookDetailVC = [[BookDetailViewController alloc] init];
    [bookDetailVC setupWithGTLBook:book];
    
    [self.navigationController presentViewController:bookDetailVC animated:YES completion:NULL];
}

#pragma mark Setup

- (void)setupNavigationBar
{
    // Remove the 'back' text from the navBar
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];

    self.navigationItem.title = @"Search Results";
}

- (void)setupTableView
{
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:tableCellIdentifier];

}

- (UIView *)activityIdicatorFooterView
{
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, self.tableView.bounds.size.width/2.0)];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityView startAnimating];
    return activityView;
}
#pragma mark Search Stuff

- (void)startSearchWithQuery:(GTLQueryBooks *)query
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.serviceTicket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {

        if (error) {
            NSLog(@"Error trying to fetch book %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Problem Searching" message:@"Unfortunatley there was an error with your request. We're on it. Please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.volumes = object;
                
                if ([self.volumes.totalItems integerValue] > 10) {
                    self.tableView.tableFooterView = [self activityIdicatorFooterView];
                }
                
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    }];
}


@end
