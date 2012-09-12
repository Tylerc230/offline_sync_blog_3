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

+ (NSDictionary *)findAllByGUID:(NSArray *)guids inContext:(NSManagedObjectContext *)managedObjectContext
{
	NSPredicate *guidsPredicate = [NSPredicate predicateWithFormat:@"guid IN %@", guids];
	NSArray *managedObjects = [self MR_findAllWithPredicate:guidsPredicate inContext:managedObjectContext];
	return [self keyByGUID:managedObjects];
}

+ (NSDictionary *)findUnconflictedByGUID:(NSArray *)guids
{
	NSPredicate * unconflictedGuidsPredicate = [NSPredicate predicateWithFormat:@"guid IN %@ AND syncStatus != %@",
												guids, [NSNumber numberWithInt:SOConflicted]];
	NSArray *managedObjects = [self MR_findAllWithPredicate:unconflictedGuidsPredicate];
	return [self keyByGUID: managedObjects];
}

+ (NSArray *)findUnsyncedObjects
{
	return [SyncObject MR_findByAttribute:kSyncStatusKey withValue:[NSNumber numberWithInt:SONeedsSync]];
}

+ (NSArray *)findConflictedObjects
{
	return [SyncObject MR_findByAttribute:kSyncStatusKey withValue:[NSNumber numberWithInt:SOConflicted]];
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
	NSArray *allObjects = [SyncObject MR_findAllSortedBy:kLastModifiedKey ascending:NO];
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

+ (NSArray *)collectGUIDSFromJSON:(NSArray *)entities
{
	NSMutableArray * guids = [NSMutableArray arrayWithCapacity:entities.count];
	for (NSDictionary* object in entities) {
        NSDictionary *attributes = [[object allValues] lastObject];
		[guids addObject:[attributes valueForKey:kGUIDKey]];
	}
	return guids;

}

+ (NSArray *)collectGUIDSFromSyncObjects:(NSArray *)entities
{
	NSMutableArray * guids = [NSMutableArray arrayWithCapacity:entities.count];
	for (SyncObject* object in entities) {
		[guids addObject:object.guid];
	}
	return guids;
    
}

- (void)updateWithJSON:(NSDictionary *)jsonObject
{
	self.guid = [jsonObject objectForKey:kJSONGUIDKey];
	self.lastModified = [[jsonObject objectForKey:kJSONLastModifiedKey] doubleValue];
	self.isGloballyDeleted = [[jsonObject objectForKey:kJSONIsGloballyDeletedKey] boolValue];
}

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	self.guid = [SyncObject createGUID];
}

- (NSMutableDictionary *)toJson
{
	NSMutableDictionary *object = [NSMutableDictionary dictionaryWithCapacity:20];
	[object setObject:self.guid forKey:kJSONGUIDKey];
	[object setObject:[NSNumber numberWithDouble:self.lastModified] forKey:kJSONLastModifiedKey];
	[object setObject:[NSNumber numberWithBool:self.isGloballyDeleted] forKey:kJSONIsGloballyDeletedKey];
	return object;
}

- (NSMutableDictionary *)diff:(SyncObject *)other
{
	NSMutableDictionary *diff = [[NSMutableDictionary alloc] initWithCapacity:30];
	return diff;
}

- (void)setKey:(NSString *)key inDict:(NSMutableDictionary *)dict ifDiffers:(NSObject *)other
{
	NSObject *thisValue = [self valueForKey:key];
	NSObject *otherValue = [other valueForKey:key];
	if (![thisValue isEqual:otherValue]) {
		[SyncObject setKey:key withValues:thisValue otherValue:otherValue inDict:dict];
	}
	
}
		 
+ (void)setKey:(NSString *)key withValues:(NSObject *)thisValue otherValue:(NSObject *)otherValue inDict:(NSMutableDictionary *)dict
{
	NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   thisValue, kReceiverKey,
								   otherValue, kOtherKey, nil];
	[dict setObject:attributeDict forKey:key];
}

- (BOOL)isConflicted
{
    return [SyncObject MR_findByAttribute:kGUIDKey withValue:self.guid].count > 1;
}

#pragma mark - Setters
- (void)deleteUnsynced
{
    self.isGloballyDeleted = YES;
    self.syncStatus = SONeedsSync;
}
@end
