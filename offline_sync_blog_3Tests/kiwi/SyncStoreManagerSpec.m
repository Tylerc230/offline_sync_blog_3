#import "Kiwi.h"
#import "DummySyncOperation.h"
#import "Objection.h"
#import "TestModule.h"

#import "keys.h"
#import "Post.h"
#import "SyncStorageManager.h"
#import "Conflict.h"

#define kFakeGUID @"21EC2020-3AEA-1069-A2DD-08002B30309D"

@interface TestHelpers : NSObject
+ (void)createConflictServerResponse:(NSString *)clientPostBody serverPostBody:(NSString *)serverPostBody;
+ (SyncStorageManager *)startTest;
+ (void)endTest:(SyncStorageManager *)manager;
@end

SPEC_BEGIN(SyncStoreManagerSpec)
__block SyncStorageManager *syncStorageManager = nil;
beforeEach(^{
	syncStorageManager = [TestHelpers startTest];	
});

afterEach(^{
	[TestHelpers endTest:syncStorageManager];	
});

describe(@"SyncStorageManager", ^{
    it(@"should sync newly created objects to server", ^{
		Post *newPost = [Post MR_createEntity];
		
		[[theValue(newPost.lastModified) should] equal:theValue(0)];//New objects created on the client should not have a last modified time
		SyncObjectStatus preSyncStatus = newPost.syncStatus;
		
		[[theValue(preSyncStatus) should] equal:theValue(SONeedsSync)];//New Objects should be in a needs sync state

		
		NSMutableDictionary *mockEntity = [NSMutableDictionary dictionaryWithDictionary:[newPost toJson]];
		[mockEntity setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:kLastModifiedKey];
		NSDictionary *mockServerResponse = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:mockEntity], kModifiedEntitiesKey, nil];
		[DummySyncOperation setResponseObject:mockServerResponse];
		syncStorageManager.resolveConflicts = ^(NSArray * empty){};
		[syncStorageManager syncNow];

		[[theReturnValueOfBlock(^{ 
			[[NSManagedObjectContext MR_contextForCurrentThread] refreshObject:newPost mergeChanges:YES];
			SyncObjectStatus postSyncStatus = newPost.syncStatus;
			return [NSNumber numberWithInt:postSyncStatus];
			
		}) shouldEventually] equal:[NSNumber numberWithInt: SOSynced]];//Entity should have a status of 'synced' after doing a sync
		
		[[theValue(newPost.lastModified) should] beGreaterThan:theValue(0)];//Entity last modified date should be set
    });
	
	it(@"should sync newly created objects from the server", ^{
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
		
		[syncStorageManager syncNow];
		[[theReturnValueOfBlock(^{
			NSArray *posts = [Post MR_findAll];
			int postCount = posts.count;
			return [NSNumber numberWithInt:postCount];
		}) shouldEventuallyBeforeTimingOutAfter(3.0)] equal:[NSNumber numberWithInt:1]];//Should have 1 post created by the server

		NSArray *posts = [Post MR_findAll];
		Post *newPost = [posts objectAtIndex:0];
		[newPost.guid shouldNotBeNil];//New entities should have a guid
		[[theValue(newPost.lastModified) should] beGreaterThan:theValue(0)];//New entities should have a modified date
		[[newPost.body should] equal:postBody];//Should have updated data from server

	});
	
	it(@"should store a conflicted object when server sends conflict", ^{
		NSString *myPostBody = @"Post body my version";
		NSString *serverPostBody = @"Post body server version";

		[TestHelpers createConflictServerResponse:myPostBody serverPostBody:serverPostBody];
		syncStorageManager.resolveConflicts = ^(NSArray *conflicts){};
		
		
		[syncStorageManager syncNow];
		
		[[theReturnValueOfBlock(^{
			NSArray *conflictedEntities = [SyncObject findConflictedObjects];
			return [NSNumber numberWithInt: conflictedEntities.count];
		}) shouldEventuallyBeforeTimingOutAfter(3.0)] equal:[NSNumber numberWithInt:1]];
		
		Post *serverConflictedPost = [[SyncObject findConflictedObjects] objectAtIndex:0];

		[[serverConflictedPost.body should] equal:serverPostBody];
		
	});
	
	it(@"should call conflict resolution callback when conflict detected", ^{
		NSString *myPostBody = @"Post body my version";
		NSString *serverPostBody = @"Post body server version";
		
		[TestHelpers createConflictServerResponse:myPostBody serverPostBody:serverPostBody];
		__block NSArray *serverConflicts = nil;
		
		syncStorageManager.resolveConflicts = ^(NSArray *conflicts)
		{
			serverConflicts = conflicts;
		};
		
		[syncStorageManager syncNow];
		
		[[expectFutureValue(serverConflicts) shouldEventually] beNonNil];
		[[theValue(serverConflicts.count) should] equal:theValue(1)];
		
	});
	
	it(@"should not leave any conflicts after resolution", ^{
		[TestHelpers createConflictServerResponse:@"A" serverPostBody:@"B"];
		__block NSArray *serverConflicts = nil;
		syncStorageManager.resolveConflicts = ^(NSArray *conflicts){
			serverConflicts = conflicts;
		};
		[syncStorageManager syncNow];
		
		[[expectFutureValue(serverConflicts) shouldEventually] beNonNil];

		Conflict *conflict = [serverConflicts objectAtIndex:0];
		[conflict resolve:[NSDictionary dictionaryWithObjectsAndKeys:@"C", kBodyKey, nil]];
		
		
		
		NSArray *postResolutionConflicts = [SyncObject findConflictedObjects];
		[[theValue(postResolutionConflicts.count) should] equal:theValue(0)];
		
		Post *resolvedPost = [[Post MR_findAll] lastObject];
		[[resolvedPost.body should] equal:@"C"];
		[[theValue(resolvedPost.syncStatus) should] equal:theValue(SONeedsSync)];
	});
});

SPEC_END
@implementation TestHelpers

+ (SyncStorageManager *)startTest
{
	JSObjectionInjector *testInjector = [JSObjection createInjector:[[TestModule alloc] init]];
	[JSObjection setGlobalInjector:testInjector];
	
	SyncStorageManager *syncStorageManager = [[SyncStorageManager alloc] initWithBaseURL:@"http://www.example.com"];
	[SyncObject MR_truncateAll];
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
	return  syncStorageManager;
}

+ (void)endTest:(SyncStorageManager *)manager
{
	[SyncObject MR_truncateAll];
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
	[manager cleanup];
}

+ (void)createConflictServerResponse:(NSString *)clientPostBody serverPostBody:(NSString *)serverPostBody
{
	Post *conflictedPost = [Post MR_createEntity];
	NSString *postTitle = @"Post title";
	
	NSNumber *localLastModifiedTime = [NSNumber numberWithDouble:1.0];
	NSNumber *serverLastModifiedTime = [NSNumber numberWithDouble:2.0];
	
	conflictedPost.title = postTitle;
	conflictedPost.body = clientPostBody;
	conflictedPost.lastModified = [localLastModifiedTime doubleValue];
	
	
	NSDictionary *conflictedEntity = [NSDictionary dictionaryWithObjectsAndKeys:
									  @"Post", kClassNameKey,
									  serverPostBody, kBodyKey,
									  postTitle, kTitleKey,
									  conflictedPost.guid, kGUIDKey,
									  serverLastModifiedTime, kLastModifiedKey,
									  [NSNumber numberWithBool:NO], kIsGloballyDeletedKey,
									  nil];
	
	NSDictionary *serverResponse = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:conflictedEntity] forKey:kConflictedEntitiesKey];
	[DummySyncOperation setResponseObject:serverResponse];
}

@end