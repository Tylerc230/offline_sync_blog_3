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

+ (NSDictionary *)findAllByGUID:(NSArray *)guids
{
	NSPredicate *guidsPredicate = [NSPredicate predicateWithFormat:@"guid IN %@", guids];
	NSArray *managedObjects = [self findAllWithPredicate:guidsPredicate];
	return [self keyByGUID:managedObjects];
}

+ (NSDictionary *)findUnconflictedByGUID:(NSArray *)guids
{
	NSPredicate * unconflictedGuidsPredicate = [NSPredicate predicateWithFormat:@"guid IN %@ AND syncStatus != %@",
												guids, [NSNumber numberWithInt:SOConflicted]];
	NSArray *managedObjects = [self findAllWithPredicate:unconflictedGuidsPredicate];
	return [self keyByGUID: managedObjects];
}

+ (NSArray *)findUnsyncedObjects
{
	return [SyncObject findByAttribute:kSyncStatusKey withValue:[NSNumber numberWithInt:SONeedsSync]];
}

+ (NSArray *)findConflictedObjects
{
	return [SyncObject findByAttribute:kSyncStatusKey withValue:[NSNumber numberWithInt:SOConflicted]];
}

+ (NSArray *)jsonRepresentationOfObjects:(NSArray *)objects
{
	NSMutableArray * jsonObjects = [NSMutableArray arrayWithCapacity:objects.count];
	for (SyncObject *managedObject in objects) {
		[jsonObjects addObject:[managedObject toJson]];
	}
	return jsonObjects;
}

+ (NSTimeInterval)lastSyncTime
{
	NSArray *allObjects = [SyncObject findAllSortedBy:kLastModifiedKey ascending:NO];
	if (allObjects.count == 0) {
		return 0;
	}
	return [[allObjects objectAtIndex:0] lastModified];
}

+ (NSDictionary *)keyByGUID:(NSArray *)entities
{
	NSMutableDictionary *entitiesByGuid = [NSMutableDictionary dictionaryWithCapacity:entities.count];
	for (id entity in entities) {
		[entitiesByGuid setObject:entity forKey:[entity valueForKey:kGUIDKey]];
	}
	return entitiesByGuid;
}

+ (NSArray *)collectGUIDS:(NSArray *)entities
{
	NSMutableArray * guids = [NSMutableArray arrayWithCapacity:entities.count];
	for (id object in entities) {
		[guids addObject:[object valueForKey:kGUIDKey]];
	}
	return guids;

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

- (void)deleteGlobalEntity
{
	self.isGloballyDeleted = YES;
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
