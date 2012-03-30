//
//  SyncStoreManagerTests.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "SyncStoreManagerTests.h"
#import "ExampleSyncManager.h"
#import "Post.h"

@implementation SyncStoreManagerTests
- (void)setUp
{
    [super setUp];
    syncStorageManager_ = [[ExampleSyncManager alloc] initWithBaseURL:@"http://www.example.com"];
}

- (void)tearDown
{
	syncStorageManager_ = nil;
    [super tearDown];
}

- (void)testSync
{
	Post *newPost = [Post MR_createEntity];
	[syncStorageManager_ syncNow];
	
	STAssertEquals(newPost.syncStatus, SOSynced, @"Entity should have a status of 'synced' after doing a sync");
	
	STAssertTrue(newPost.lastModified > 0, @"Entity last modified date should be set");
					
}


@end
