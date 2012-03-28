//
//  SyncObject.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SyncObject : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic) int16_t syncStatus;
@property (nonatomic) NSTimeInterval lastModified;
@property (nonatomic) BOOL isGloballyDeleted;

@end
