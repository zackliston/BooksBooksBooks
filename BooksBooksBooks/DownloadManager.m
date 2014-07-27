//
//  DownloadManager.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/25/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "DownloadManager.h"
#import <AFNetworking.h>

static NSString *const ImageDirectory = @"localImageDirectory";

@implementation DownloadManager

+ (NSString *)getImageDirectoryLocation
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", cachesDirectory, ImageDirectory]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", cachesDirectory, ImageDirectory] withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"ERROR: Image directory could not be created: %@", error);
        }
    }
    
    return [NSString stringWithFormat:@"%@/%@", cachesDirectory, ImageDirectory];
}

+ (void)downloadImageFrom:(NSString *)fromURLString to:(NSString *)toURLString
{
    NSURL *url = [NSURL URLWithString:fromURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DownloadManager saveImage:image to:toURLString];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error downloading image at %@: %@",fromURLString, error);
    }];
    
    [operation start];
}

+ (void)saveImage:(UIImage *)image to:(NSString *)fileLocation
{
    [UIImagePNGRepresentation(image) writeToFile:fileLocation atomically:NO];
    
}

+ (BOOL)doesImageExistAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

@end
