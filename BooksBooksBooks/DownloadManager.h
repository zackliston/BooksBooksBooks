//
//  DownloadManager.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/25/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject

+ (NSString *)getImageDirectoryLocation;

+ (void)downloadImageFrom:(NSString *)fromURLString to:(NSString *)toURLString;

+ (BOOL)doesImageExistAtPath:(NSString *)path;

@end
