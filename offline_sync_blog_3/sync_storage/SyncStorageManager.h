//
//  SyncStorageManager.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kSyncCompleteNotif @"SyncCompleteNotif"

typedef void(^ConflictResolutionBlock)(NSArray *);


@interface SyncStorageManager : NSObject
/**
 * @param baseURL The url where the sync server is located.
 * @returns A new instance of a SyncStorageManager.
 */
- (id)initWithBaseURL:(NSString *)baseURL;
/**
 * Synchronizes local modifications to the server and merges servers modifications back 
 * into local store.
 */
- (void)syncNow;

/**
 * Will search the local database for existing conflicts and inform
 * the caller via the resolveConflicts block.
 */
- (void)resolveExistingConflicts;

/**
 * baseURL can be set at any time. Subsequent syncs will be done with the new url.
 */
@property (nonatomic, strong) NSString *baseURL;

/**
 * This callback is called when conflicts have been detected in the 
 * local database. An array of Conflict objects are passed into the 
 * block. Once all the conflicts have been resolved. The caller 
 * must call syncNow to sync the conflicts resolutions back to the server.
 */
@property (nonatomic, copy) ConflictResolutionBlock resolveConflicts;
@end
