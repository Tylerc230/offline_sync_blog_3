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

+ (NSArray *)findUnsyncedObjects
{
	return [SyncObject findByAttribute:kSyncStatusKey withValue:[NSNumber numberWithInt:SONeedsSync]];
}

+ (NSArray *)jsonRepresentationOfObjects:(NSArray *)objects
{
	NSMutableArray * jsonObjects = [NSMutableArray arrayWithCapacity:objects.count];
	for (SyncObject *managedObject in objects) {
		[jsonObjects addObject:[managedObject toJson]];
	}
	return jsonObjects;
}

- (void)updateWithJSON:(NSDictionary *)jsonObject
{
	self.guid = [jsonObject objectForKey:kGUIDKey];
	self.lastModified = [[jsonObject objectForKey:kLastModifiedKey] doubleValue];
	self.isGloballyDeleted = [[jsonObject objectForKey:kIsGloballyDeletedKey] boolValue];
}

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	self.guid = [SyncObject createGUID];
}

- (NSMutableDictionary *)toJson
{
	NSMutableDictionary *object = [NSMutableDictionary dictionaryWithCapacity:20];
	[object setObject:self.guid forKey:kGUIDKey];
	[object setObject:[NSNumber numberWithDouble:self.lastModified] forKey:kLastModifiedKey];
	[object setObject:[NSNumber numberWithBool:self.isGloballyDeleted] forKey:kIsGloballyDeletedKey];
	return object;
}



@end
