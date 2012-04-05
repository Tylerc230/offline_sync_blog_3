//
//  SyncStoreManagerTests.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "SyncStoreManagerTests.h"
#import "OCMock.h"
#import "Objection.h"
#import "TestModule.h"
#import "DummySyncOperation.h"
#import "ExampleSyncManager.h"
#import "Post.h"
#import "keys.h"

#define kFakeGUID @"21EC2020-3AEA-1069-A2DD-08002B30309D"

@interface ExampleSyncManager (Test_methods)
- (void)syncPayload:(NSDictionary *)payload;
- (void)syncSucceededWithResponse:(id) responseObject;
@end

@implementation SyncStoreManagerTests
- (void)setUp
{
    [super setUp];
	JSObjectionInjector *testInjector = [JSObjection createInjector:[[TestModule alloc] init]];
	[JSObjection setGlobalInjector:testInjector];
	
	syncStorageManager_ = [[ExampleSyncManager alloc] initWithBaseURL:@"http://www.example.com"];
	[SyncObject MR_truncateAll];
}

- (void)tearDown
{
	syncStorageManager_ = nil;
    [super tearDown];
}
#pragma mark - tests
- (void)testSyncNewObjectToServer
{
	Post *newPost = [Post MR_createEntity];
	
	STAssertTrue(newPost.lastModified == 0, @"New objects created on the client should not have a last modified time");
	SyncObjectStatus preSyncStatus = newPost.syncStatus;
	STAssertEquals(preSyncStatus, SONeedsSync, @"New Objects should be in a needs sync state");
	
	NSMutableDictionary *mockEntity = [NSMutableDictionary dictionaryWithDictionary:[newPost toJson]];
	[mockEntity setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:kLastModifiedKey];
	NSDictionary *mockServerResponse = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:mockEntity], kModifiedEntitiesKey, nil];
	[DummySyncOperation setResponseObject:mockServerResponse];

	[syncStorageManager_ syncNow];
	
	[[NSManagedObjectContext MR_contextForCurrentThread] refreshObject:newPost mergeChanges:YES];
	SyncObjectStatus postSyncStatus = newPost.syncStatus;
	
	STAssertEquals(postSyncStatus, SOSynced, @"Entity should have a status of 'synced' after doing a sync");
	
	STAssertTrue(newPost.lastModified > 0, @"Entity last modified date should be set");
					
}

- (void)testSyncNewObjectFromServer
{
	NSString *postBody = @"post body from another device";
	NSMutableDictionary * serverPost = [NSDictionary dictionaryWithObjectsAndKeys:
										  @"Post", kClassNameKey,
										  postBody, kBodyKey,
										  @"post title", kTitleKey,
										  kFakeGUID, kGUIDKey,
										  [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], kLastModifiedKey,
										  [NSNumber numberWithBool:NO], kIsGloballyDeletedKey,
										  nil];
	NSDictionary *serverResponse = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:serverPost] forKey:kModifiedEntitiesKey];
	[DummySyncOperation setResponseObject:serverResponse];
	
	[syncStorageManager_ syncNow];
	
	NSArray *posts = [Post MR_findAll];
	int postCount = posts.count;
	STAssertEquals(postCount, 1, @"Should have 1 post created by the server");
	
	Post *newPost = [posts objectAtIndex:0];
	STAssertNotNil(newPost.guid, @"New entities should have a guid");
	STAssertTrue(newPost.lastModified > 0, @"New entities should have a modified date");
	STAssertEqualObjects(newPost.body, postBody, @"Should have updated data from server");
	
}


#pragma mark - Helper methods
- (void)mockStorageManager:(SyncStorageManager *)storageManager withResponse:(NSDictionary *)mockServerResponse
{
	id storageMock = [OCMockObject partialMockForObject:storageManager];
	[[[storageMock expect] andDo:^(NSInvocation *invocation){
		[invocation.target syncSucceededWithResponse:mockServerResponse];
	}] syncPayload:OCMOCK_ANY];
}

@end
