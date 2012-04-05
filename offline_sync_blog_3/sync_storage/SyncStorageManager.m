//
//  SyncStorageManager.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncStorageManager.h"
#import "MagicalRecordHelpers.h"
#import "SyncOperation.h"
@interface SyncStorageManager ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation SyncStorageManager
@synthesize operationQueue;
@synthesize baseURL;

- (id)initWithBaseURL:(NSString *)aBaseURL
{
	if (self = [super init]) {
		[MagicalRecordHelpers setupCoreDataStack];
		self.operationQueue = [[NSOperationQueue alloc] init];
		self.baseURL = aBaseURL;
	}
	return self;
}

- (void)dealloc
{
	[MagicalRecordHelpers cleanUp];
}

#pragma mark - public methods
- (void)syncNow
{
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
	[self syncAllEntities];
}

#pragma mark - sync
- (void)syncAllEntities
{
	SyncOperation *syncOp = [[SyncOperation alloc] initWithBaseURL:self.baseURL];
	[syncOp setCompletionBlock:^{
		[self performSelectorOnMainThread:@selector(syncComplete) withObject:nil waitUntilDone:NO];
	}];
	[self.operationQueue addOperation:syncOp];
	
}

- (void)syncComplete
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSyncCompleteNotif object:self];
}

@end
