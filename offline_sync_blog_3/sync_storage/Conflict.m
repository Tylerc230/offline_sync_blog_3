//
//  Conflict.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 4/5/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "Conflict.h"

@implementation Conflict
@synthesize clientVersion;
@synthesize serverVersion;

+ (Conflict *)conflictForGuid:(NSString *)guid
{
    NSArray *objects = [SyncObject MR_findByAttribute:kGUIDKey withValue:guid];
    if (objects.count == 2) {
        SyncObject *firstObject = [objects objectAtIndex:0];
        SyncObject *lastObject = [objects lastObject];
        SyncObject *localVersion = lastObject.syncStatus == SOConflicted ? lastObject : firstObject;
        SyncObject *serverVersion = lastObject.syncStatus != SOConflicted ? lastObject : firstObject;
        return [[Conflict alloc] initWithLocalVersion:localVersion serverVersion:serverVersion];
    }
    return nil;
}

- (id)initWithLocalVersion:(SyncObject *)localVersion serverVersion:(SyncObject *)remoteVersion
{
	if (self = [super init]) {
		self.clientVersion = localVersion;
		self.serverVersion = remoteVersion;
	}
	return self;
}

- (NSDictionary *)diffs
{
	return [self.clientVersion diff:self.serverVersion];
}

- (void)resolve:(NSDictionary *)resolution
{
	[self.clientVersion updateWithJSON:resolution];
	self.clientVersion.lastModified = self.serverVersion.lastModified;
	self.clientVersion.syncStatus = SONeedsSync;
	[self.serverVersion MR_deleteEntity];
}
@end
