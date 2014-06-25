//
//  BookDetailViewController.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/22/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "BookDetailViewController.h"
#import "Book+Constants.h"
#import "DataController.h"

static NSInteger const ownActionSheetTag = 111;
static NSInteger const readActionSheetTag = 112;

@interface BookDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIButton *addToLibraryButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, assign) BOOL doesOwn;
@property (nonatomic, assign) NSInteger readStatus;

@end

@implementation BookDetailViewController

@synthesize book = _book;

#pragma mark Getters and setters

- (void)setBook:(GTLBooksVolume *)book
{
    if (_book != book) {
        _book = book;
        [self setupWithBook];
    }
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self setupWithBook];
}

- (IBAction)addToLibraryClicked:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I own this book", @"I want to own this book", nil];
    actionSheet.tag = ownActionSheetTag;
    [actionSheet showInView:self.view];
}

#pragma mark Setup

- (void)setupWithBook
{
    if (self.book) {
        self.authorLabel.text = [self.book.volumeInfo.authors lastObject];
        self.titleLabel.text = self.book.volumeInfo.title;
    }
}

- (void)setupUI
{
    self.addToLibraryButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
}

#pragma mark Add to library Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ownActionSheetTag) {
        if (buttonIndex < 2) {
            [self clickedOwnOption:buttonIndex];
        }
    } else if (actionSheet.tag == readActionSheetTag) {
        if (buttonIndex < 4) {
            [self clickedReadOption:buttonIndex];
        }
    }
}

- (void)clickedOwnOption:(NSInteger)ownOption
{
    NSString *thirdButtonOption = @"";
    if (ownOption == 0) {
        self.doesOwn = YES;
        thirdButtonOption = @"Neither, I just own it";
    } else {
        self.doesOwn = NO;
        thirdButtonOption = @"Neither, I just want to own it";
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I have read it", @"I want to read it", @"I am currently reading it", thirdButtonOption, nil];
    actionSheet.tag = readActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)clickedReadOption:(NSInteger)readOption
{
    if (readOption == 0) {
        self.readStatus = BookHasBeenRead;
    } else if (readOption == 1) {
        self.readStatus = BookWantsToRead;
    } else if (readOption == 2) {
        self.readStatus = BookIsCurrentlyReading;
    } else if (readOption == 3) {
        self.readStatus = BookDoesNotWantToRead;
    }
    
    [self addBookToCoreData];
}

- (void)addBookToCoreData
{
    NSManagedObjectContext *context = [[DataController sharedInstance] managedObjectContext];
    Book *newBook = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
    newBook.authors = self.book.volumeInfo.authors;
    newBook.averageRating = self.book.volumeInfo.averageRating;
    newBook.bookDescription = self.book.volumeInfo.descriptionProperty;
    newBook.bookID = self.book.identifier;
    newBook.categories = self.book.volumeInfo.categories;
    newBook.imageURLs = [self convertImageLinksPropertyToDictionary:self.book.volumeInfo.imageLinks];
    newBook.mainAuthor = [self.book.volumeInfo.authors firstObject];
    newBook.mainCategory = self.book.volumeInfo.mainCategory;
    newBook.pageCount = self.book.volumeInfo.pageCount;
    newBook.publisher = self.book.volumeInfo.publisher;
    newBook.publishDate = self.book.volumeInfo.publishedDate;
    newBook.ratingsCount = self.book.volumeInfo.ratingsCount;
    newBook.subtitle = self.book.volumeInfo.subtitle;
    newBook.title = self.book.volumeInfo.title;
    newBook.doesOwn = [NSNumber numberWithBool:self.doesOwn];
    newBook.readStatus = [NSNumber numberWithInteger:self.readStatus];
    
    NSError *saveError;
    
    [context save:&saveError];
    if (saveError) {
        NSLog(@"Error saving context after adding book. %@", saveError);
    } else {
        NSLog(@"Successfully added a book to CoreData!");
    }
}

#pragma mark Helpers

- (NSDictionary *)convertImageLinksPropertyToDictionary:(GTLBooksVolumeVolumeInfoImageLinks *)imageLinks
{
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    if (imageLinks.large) [tempDictionary setObject:imageLinks.large forKey:largeImageKey];
    if (imageLinks.medium) [tempDictionary setObject:imageLinks.medium forKey:mediumImageKey];
    if (imageLinks.small) [tempDictionary setObject:imageLinks.small forKey:smallImageKey];
    if (imageLinks.thumbnail) [tempDictionary setObject:imageLinks.thumbnail forKey:thumbnailImageKey];
    
    return [NSDictionary dictionaryWithDictionary:tempDictionary];
}

@end
