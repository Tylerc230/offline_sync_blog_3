#import "Kiwi.h"
#import "DummySyncOperation.h"
#import "Objection.h"
#import "TestModule.h"

#import "keys.h"
#import "Post.h"
#import "SyncStorageManager.h"

#define kFakeGUID @"21EC2020-3AEA-1069-A2DD-08002B30309D"

@interface TestHelpers : NSObject
+ (void)createConflictServerResponse:(NSString *)clientPostBody serverPostBody:(NSString *)serverPostBody;
@end

SPEC_BEGIN(SyncStoreManagerSpec)
describe(@"SyncStorageManager", ^{
	__block SyncStorageManager *syncStorageManager_ = nil;
	beforeEach(^{ // Occurs before each enclosed "it"
		JSObjectionInjector *testInjector = [JSObjection createInjector:[[TestModule alloc] init]];
		[JSObjection setGlobalInjector:testInjector];
		
		syncStorageManager_ = [[SyncStorageManager alloc] initWithBaseURL:@"http://www.example.com"];
		[SyncObject MR_truncateAll];
		[[NSManagedObjectContext contextForCurrentThread] MR_save];

	});
	
	afterEach(^{ // Occurs after each enclosed "it"
		[SyncObject MR_truncateAll];
		[[NSManagedObjectContext contextForCurrentThread] MR_save];
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
		syncStorageManager_.resolveConflicts = ^(NSArray * empty){};
		[syncStorageManager_ syncNow];

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
		
		[syncStorageManager_ syncNow];
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
		syncStorageManager_.resolveConflicts = ^(NSArray *conflicts){};
		
		
		[syncStorageManager_ syncNow];
		
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
		
		syncStorageManager_.resolveConflicts = ^(NSArray *conflicts)
		{
			serverConflicts = conflicts;
		};
		
		[syncStorageManager_ syncNow];
		
		[[expectFutureValue(serverConflicts) shouldEventually] beNonNil];
		
	});
});

SPEC_END
@implementation TestHelpers

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