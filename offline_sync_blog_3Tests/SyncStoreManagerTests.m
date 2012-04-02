//
//  SyncStoreManagerTests.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "SyncStoreManagerTests.h"
#import "OCMock.h"
#import "ExampleSyncManager.h"
#import "Post.h"
@interface ExampleSyncManager (Test_methods)
- (void)syncPayload:(NSDictionary *)payload;
- (void)syncSucceededWithResponse:(id) responseObject;
@end

@implementation SyncStoreManagerTests
- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSync
{
	SyncStorageManager *storageManager = [[ExampleSyncManager alloc] initWithBaseURL:@"http://www.example.com"];
	Post *newPost = [Post MR_createEntity];
	
	NSMutableDictionary *mockEntity = [NSMutableDictionary dictionaryWithDictionary:[newPost toJson]];
	[mockEntity setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:kLastModifiedKey];
	NSDictionary *mockServerResponse = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:mockEntity], @"modifiedEntities", nil];

	id storageMock = [OCMockObject partialMockForObject:storageManager];
	[[[storageMock expect] andDo:^(NSInvocation *invocation){
		[invocation.target syncSucceededWithResponse:mockServerResponse];
	}] syncPayload:OCMOCK_ANY];

	[storageMock syncNow];
	
	[[NSManagedObjectContext MR_contextForCurrentThread] refreshObject:newPost mergeChanges:YES];
	SyncObjectStatus syncStatus = newPost.syncStatus;
	
	STAssertEquals(syncStatus, SOSynced, @"Entity should have a status of 'synced' after doing a sync");
	
	STAssertTrue(newPost.lastModified > 0, @"Entity last modified date should be set");
					
}


@end
