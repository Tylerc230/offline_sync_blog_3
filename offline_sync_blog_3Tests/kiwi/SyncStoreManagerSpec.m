#import "Kiwi.h"
#import "DummySyncOperation.h"
#import "Objection.h"
#import "TestModule.h"

#import "keys.h"
#import "Post.h"
#import "SyncStorageManager.h"

SPEC_BEGIN(SyncStoreManagerSpec)
describe(@"SyncStorageManager", ^{
	__block SyncStorageManager *syncStorageManager_ = nil;
	beforeEach(^{ // Occurs before each enclosed "it"
		JSObjectionInjector *testInjector = [JSObjection createInjector:[[TestModule alloc] init]];
		[JSObjection setGlobalInjector:testInjector];
		
		syncStorageManager_ = [[SyncStorageManager alloc] initWithBaseURL:@"http://www.example.com"];
		[SyncObject MR_truncateAll];

	});
	
	afterEach(^{ // Occurs after each enclosed "it"
		syncStorageManager_ = nil;
	});
	
    it(@"should sync newly created objects to server", ^{
		Post *newPost = [Post MR_createEntity];
		
		[[theValue(newPost.lastModified) should] equal:theValue(0)];//New objects created on the client should not have a last modified time
		SyncObjectStatus preSyncStatus = newPost.syncStatus;
		
		[[theValue(preSyncStatus) should] equal:theValue(SONeedsSync)];//New Objects should be in a needs sync state

		
		NSMutableDictionary *mockEntity = [NSMutableDictionary dictionaryWithDictionary:[newPost toJson]];
		[mockEntity setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:kLastModifiedKey];
		NSDictionary *mockServerResponse = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:mockEntity], kModifiedEntitiesKey, nil];
		[DummySyncOperation setResponseObject:mockServerResponse];
		
		[syncStorageManager_ syncNow];
		
		[[NSManagedObjectContext MR_contextForCurrentThread] refreshObject:newPost mergeChanges:YES];
		SyncObjectStatus postSyncStatus = newPost.syncStatus;
		
		[[theValue(postSyncStatus) should] equal:theValue(SOSynced)];//Entity should have a status of 'synced' after doing a sync
		
		[[theValue(newPost.lastModified) should] beGreaterThan:theValue(0)];//Entity last modified date should be set
    });
});

SPEC_END