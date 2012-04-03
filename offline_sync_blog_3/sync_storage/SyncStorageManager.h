//
//  SyncStorageManager.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kSyncCompleteNotif @"SyncCompleteNotif"
#define kModifiedEntitiesKey @"modifiedEntities"
#define kLastSyncTimeKey @"lastSyncTime"
#define kClassNameKey @"className"



@interface SyncStorageManager : NSObject
/**
 * @param baseURL The url where the sync server is located.
 * @returns A new instance of a SyncStorageManager
 */
- (id)initWithBaseURL:(NSString *)baseURL;
/**
 * Synchronizes local modifications to the server and merges servers modifications back 
 * into local store.
 */
- (void)syncNow;
@end
