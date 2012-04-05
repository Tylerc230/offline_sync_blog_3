//
//  SyncObject.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kGUIDKey @"guid"
#define kSyncStatusKey @"syncStatus"
#define kLastModifiedKey @"lastModified"
#define kIsGloballyDeletedKey @"isGloballyDeleted"

@interface SyncObject : NSManagedObject

typedef enum {
	SOSynced,
	SONeedsSync,
	SOConflicted
}SyncObjectStatus;

@property (nonatomic, retain) NSString * guid;
@property (nonatomic) int16_t syncStatus;
@property (nonatomic) NSTimeInterval lastModified;
@property (nonatomic) BOOL isGloballyDeleted;

/**
 * @param guids an array of guid strings of format 8-4-4-4-12
 * @returns all SyncObjects whos guids are found in _guids_
 */
+ (NSArray *)findAllByGUID:(NSArray *)guids;
+ (NSArray *)findUnsyncedObjects;
+ (NSArray *)findConflictedObjects;
+ (NSTimeInterval)lastSyncTime;
+ (NSArray *)jsonRepresentationOfObjects:(NSArray *)objects;
- (void)updateWithJSON:(NSDictionary *)json;
- (void)deleteGlobalEntity;
- (NSMutableDictionary *)toJson;

@end
