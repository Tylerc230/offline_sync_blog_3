//
//  SyncStorageManager.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncStorageManager.h"
#import "MagicalRecord.h"
#import "SyncOperation.h"
#import "SyncObject.h"
#import "Conflict.h"
#import "JSObjection.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;
@interface SyncStorageManager ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation SyncStorageManager
@synthesize operationQueue;
@synthesize baseURL;
@synthesize resolveConflicts;

- (id)initWithBaseURL:(NSString *)aBaseURL
{
	if (self = [super init]) {
		[MagicalRecord setupCoreDataStack];
		self.operationQueue = [[NSOperationQueue alloc] init];
		self.baseURL = aBaseURL;
        DDLogInfo(@"Use server at %@", self.baseURL);
	}
	return self;
}

- (void)cleanup
{
	[MagicalRecord cleanUp];
}

#pragma mark - public methods
- (void)syncNow
{
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveNestedContexts];
	[self syncAllEntities];
}

- (void)resolveExistingConflicts
{
	NSArray * conflicts = [self createConflictObjects];
	if (conflicts.count > 0) {
		self.resolveConflicts(conflicts);
	}
}

#pragma mark - sync
- (void)syncAllEntities
{
	SyncOperation *syncOp = [[JSObjection defaultInjector] getObject:[SyncOperation class]];
	syncOp.baseURL = self.baseURL;
	[syncOp setCompletionBlock:^{
		[self performSelectorOnMainThread:@selector(syncComplete) withObject:nil waitUntilDone:NO];
	}];
	[self.operationQueue addOperation:syncOp];
	
}

- (void)syncComplete
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSyncCompleteNotif object:self];
	[self resolveExistingConflicts];
}

#pragma mark - Private methods
- (NSArray *)createConflictObjects
{
	NSArray *serverVersions = [SyncObject findConflictedObjects];
	NSArray *guids = [SyncObject collectGUIDSFromSyncObjects:serverVersions];
	NSDictionary *localVersions = [SyncObject findUnconflictedByGUID:guids];
	
	NSMutableArray *conflicts = [NSMutableArray arrayWithCapacity:serverVersions.count];
	for (SyncObject * serverVersion in serverVersions) {
		SyncObject *localVersion = [localVersions objectForKey:serverVersion.guid];
		Conflict *conflict = [[Conflict alloc] initWithLocalVersion:localVersion serverVersion:serverVersion];
		[conflicts addObject:conflict];
	}
	return conflicts;
}
@end
