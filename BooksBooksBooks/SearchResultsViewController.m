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
#import <GTLBooks.h>
#import <FXBlurView/FXBlurView.h>

@interface SearchResultsViewController ()


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
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = [self tableHeaderView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchResultsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:tableCellIdentifier];
    
    [self setupNavigationBar];
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
    cell.titleLabel.text = book.volumeInfo.title;
    
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
    bookDetailVC.book = book;
    
    [self.navigationController presentViewController:bookDetailVC animated:YES completion:NULL];
}

#pragma mark Setup

- (void)setupNavigationBar
{
    // Remove the 'back' text from the navBar
    self.navigationController.navigationBar.topItem.title = @"";
}

#pragma mark Search Stuff

- (void)startSearchWithQuery:(GTLQueryBooks *)query
{
    self.serviceTicket = [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {

        if (error) {
            NSLog(@"Error trying to fetch book %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Problem Searching" message:@"Unfortunatley there was an error with your request. We're on it. Please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.volumes = object;
                [self.tableView reloadData];
            });
        }
    }];
}




- (UIImageView *)tableHeaderView
{
    // Create the frame for the tableHeaderView (which is an imageView
    CGRect imageViewFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 100.0);
    
    // Create the headerView, which is an imageView, which will have the Labels on top of it
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    
    // Load the image and place it in the imageView (headerView)
    UIImage *headerImage = [UIImage imageNamed:@"stacked_books.jpg"];
    headerView.image = headerImage;

    
    // Create the frame for the bottom label, which contains 'Library'
    CGRect bottomLabelFrame = CGRectMake(40.0, 13.0, self.tableView.bounds.size.width-40.0, 60.0);
    
    // Create the bottomLabel and set all the visual properties
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:bottomLabelFrame];
    bottomLabel.text = @"";
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:36.0];
    bottomLabel.textColor = [UIColor whiteColor];
    
    // Add a shadow so the text is a bit more clear
    bottomLabel.layer.masksToBounds = NO;
    bottomLabel.layer.shadowRadius = 10.0;
    bottomLabel.layer.shadowOpacity = 1.0;
    bottomLabel.layer.shadowOffset = CGSizeZero;
    bottomLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    
    // Add the labels to the headerView (the imageView)
    [headerView addSubview:bottomLabel];
    
    return headerView;
}

@end
