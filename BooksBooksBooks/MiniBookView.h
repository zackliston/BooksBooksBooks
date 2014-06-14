//
//  MiniBookView.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 6/13/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniBookView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *thumbnailAddress;

@property (nonatomic, strong) NSDictionary *jsonData;

- (instancetype)initWithJSONData:(NSDictionary *)jsonData;

@end
