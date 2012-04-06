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

- (id)initWithLocalVersion:(SyncObject *)localVersion serverVersion:(SyncObject *)remoteVersion
{
	if (self = [super init]) {
		self.clientVersion = localVersion;
		self.serverVersion = remoteVersion;
	}
	return self;
}

- (void)resolve
{
	
}
@end
