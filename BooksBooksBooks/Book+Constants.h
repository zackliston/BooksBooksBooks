//
//  Book+Constants.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/23/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "Book.h"

typedef enum {
    BookHasBeenRead = 0,
    BookWantsToRead,
    BookIsCurrentlyReading,
    BookDoesNotWantToRead
} BookReadStatus;

typedef enum {
    BookIsOwned =0,
    BookWantsToOwn,
    BookDoesNotOwn
} BookOwnStatus;

extern NSString *const largeImageKey;
extern NSString *const mediumImageKey;
extern NSString *const smallImageKey;
extern NSString *const thumbnailImageKey;

@interface Book (Constants)

@end
