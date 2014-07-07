//
//  ChangeBookDetailsResultsProtocol.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/6/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChangeBookDetailsResultsProtocol <NSObject>

- (void)handleResults:(NSDictionary *)results;

@end
