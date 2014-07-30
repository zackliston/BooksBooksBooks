//
//  ZLBUtilities.m
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/29/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import "ZLBUtilities.h"

@implementation ZLBUtilities

@end

@implementation UIImage (Utilities)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end