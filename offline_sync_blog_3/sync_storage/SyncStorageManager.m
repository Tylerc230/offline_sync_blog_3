//
//  SyncStorageManager.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncStorageManager.h"
#import "MagicalRecordHelpers.h"
@implementation SyncStorageManager

- (id)init
{
	if (self = [super init]) {
		[MagicalRecordHelpers setupCoreDataStack];
	}
	return self;
}

- (void)dealloc
{
	[MagicalRecordHelpers cleanUp];
}

@end
