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
#define kReceiverKey @"receiver"
#define kOtherKey @"other"

#define kJSONGUIDKey @"guid"
#define kJSONSyncStatusKey @"sync_status"
#define kJSONLastModifiedKey @"updated_at"
#define kJSONIsGloballyDeletedKey @"is_deleted"


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
 * @param the context you would like to query
 * @returns all SyncObjects whos guids are found in _guids_ keyed by guid
 */
+ (NSDictionary *)findAllByGUID:(NSArray *)guids inContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)findUnsyncedObjects;
+ (NSDictionary *)findUnconflictedByGUID:(NSArray *)guids;

/**
 * @param entities an NSArray of objects which are KV complient
 * for the key 'guid'.
 */
+ (NSArray *)collectGUIDS:(NSArray *)entities;

/**
 * @returns an array of SyncObjects which have the syncStatus 
 * set to SOConflicted. This represents the version that the
 * server has in its database;
 */
+ (NSArray *)findConflictedObjects;
+ (NSTimeInterval)lastSyncTime;
+ (NSArray *)jsonRepresentationOfObjects:(NSArray *)objects;
- (void)updateWithJSON:(NSDictionary *)json;
- (void)deleteGlobalEntity;
- (NSMutableDictionary *)toJson;
/**
 * This method is meant to be overridden by all subclasses. This method will compute
 * the differences between 2 objects of the same type; returning a hash of the differences.
 * This method should be used to resolve conflicts from the server. Comparisons are done with
 * the equal: methods. The format of the returned hash is:
 * 'attributeName' => 'other' => <value>
 *				 => 'receiver' => <value>
 * @param other an object of the same type which this object will be compared with
 * @return a hash containing keys of all attributes who's values differ from that of other
 */
- (NSMutableDictionary *)diff:(SyncObject *)other;

- (void)setKey:(NSString *)key inDict:(NSMutableDictionary *)dict ifDiffers:(NSObject *)other;
@end
