//
//  SyncStorageManager.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kSyncCompleteNotif @"SyncCompleteNotif"

@interface SyncStorageManager : NSObject
- (id)initWithBaseURL:(NSString *)baseURL;
- (void)syncNow;
@end
