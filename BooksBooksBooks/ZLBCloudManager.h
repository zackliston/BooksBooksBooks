//
//  ZLBCloudManager.h
//  BooksBooksBooks
//
//  Created by Zack Liston on 7/19/14.
//  Copyright (c) 2014 zackliston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZLBCloudManager : NSObject

+ (ZLBCloudManager *)sharedInstance;

- (void)setupCloudUser;
- (void)setupSyncZoneAndSubscription:(BOOL)shouldStartSubscription fetchChanges:(BOOL)shouldFetchChanges;

- (void)updateCloudWithInsertedObjects:(NSSet *)insertedObjects updatedObjects:(NSSet *)updatedObjects deletedObjects:(NSSet *)deletedObjects;
- (void)fetchChanges;
@end
