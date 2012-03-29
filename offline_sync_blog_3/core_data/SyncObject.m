//
//  SyncObject.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "SyncObject.h"


@implementation SyncObject

@dynamic guid;
@dynamic syncStatus;
@dynamic lastModified;
@dynamic isGloballyDeleted;

+ (NSString *)createGUID
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return (__bridge_transfer NSString *)string;
}

- (void) awakeFromInsert
{
	[super awakeFromInsert];
	self.guid = [SyncObject createGUID];
}

@end
