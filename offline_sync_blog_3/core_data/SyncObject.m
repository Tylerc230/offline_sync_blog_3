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

+ (NSArray *)findAllByGUID:(NSArray *)guids
{
	NSPredicate *modifiedGuidsPredicate = [NSPredicate predicateWithFormat:@"guid IN %@", guids];
	NSArray *updatedManagedObjects = [self findAllWithPredicate:modifiedGuidsPredicate];
	return updatedManagedObjects;
}

- (void)updateWithJSON:(NSDictionary *)jsonObject
{
	self.guid = [jsonObject objectForKey:@"guid"];
	self.lastModified = [[jsonObject objectForKey:@"lastModified"] doubleValue];
	self.isGloballyDeleted = [[jsonObject objectForKey:@"isGloballyDeleted"] boolValue];
}

- (void) awakeFromInsert
{
	[super awakeFromInsert];
	self.guid = [SyncObject createGUID];
}



@end
