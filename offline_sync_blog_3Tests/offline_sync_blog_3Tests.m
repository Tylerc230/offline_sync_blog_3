//
//  offline_sync_blog_3Tests.m
//  offline_sync_blog_3Tests
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "offline_sync_blog_3Tests.h"
#import "Post.h"

@implementation offline_sync_blog_3Tests

- (void)setUp
{
    [super setUp];
    syncStorageManager_ = [[SyncStorageManager alloc] init];
}

- (void)tearDown
{
	syncStorageManager_ = nil;
    [super tearDown];
}

- (void)testGUIDCreation
{
	Post *newPost = [Post MR_createEntity];
	STAssertNotNil(newPost.guid, @"GUID should be created when entity created");

	Post *newPost2 = [Post MR_createEntity];
	STAssertTrue(![newPost.guid isEqualToString: newPost2.guid], @"GUIDs should be unique");

}

- (void)testEntityInitialState
{
	Post *newPost = [Post MR_createEntity];
	STAssertEquals((SyncObjectStatus)newPost.syncStatus, SONeedsSync, @"New entities should be in a needs sync state");

	STAssertFalse(newPost.isGloballyDeleted, @"New entities should not be in a deleted state");

	STAssertEquals((int)newPost.lastModified, 0, @"New entities should not have a last modified date");

}



@end
