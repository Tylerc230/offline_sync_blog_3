//
//  SyncOperation.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 4/4/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "SyncOperation.h"
#import "SyncObject.h"
#import "AFHTTPClient.h"
#import "keys.h"

#define kExecutingKey @"isExecuting"
#define kFinishedKey @"isFinished"

@interface SyncOperation ()
{
	BOOL finished_;
	BOOL executing_;
}
@property (nonatomic, strong) AFHTTPClient *httpClient;
@end


@implementation SyncOperation
@synthesize httpClient;

- (id)initWithBaseURL:(NSString *)baseURL
{
	if (self = [super init]) {
		executing_ = NO;
		finished_ = NO;
		self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:baseURL]];
		self.httpClient.parameterEncoding = AFJSONParameterEncoding;

	}
	return self;
}

- (void)main
{
	[self willChangeValueForKey:kExecutingKey];
	executing_ = YES;
	[self didChangeValueForKey:kExecutingKey];
	
	NSArray *modifiedEntities = [SyncObject findUnsyncedObjects];
	NSArray *jsonRepresentation = [SyncObject jsonRepresentationOfObjects:modifiedEntities];
	NSTimeInterval lastSyncTime = [SyncObject lastSyncTime];
	NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:
							 jsonRepresentation, kModifiedEntitiesKey,
							 [NSNumber numberWithDouble:lastSyncTime], kLastSyncTimeKey,
							 nil];
	[self syncPayload:payload];
}

- (BOOL)isConcurrent
{
	return YES;
}

- (BOOL)isExecuting
{
	return executing_;
}

- (BOOL)isFinished
{
	return finished_;
}

- (void)syncPayload:(NSDictionary *)payload
{
	[self.httpClient postPath:@"/sync" parameters:payload 
					  success:^(AFHTTPRequestOperation *op, id responseObject) {
						  [self syncSucceededWithResponse:responseObject];
					  }
					  failure:^(AFHTTPRequestOperation *op, NSError *error) {
						  [self syncFailedWithResponse:error];
					  }];
}

#pragma mark - sync response
- (void)syncSucceededWithResponse:(id) responseObject
{
	NSArray *modifiedEntities = [responseObject objectForKey:kModifiedEntitiesKey];
	[self updateWithJSON:modifiedEntities];
	[self completeOperation];
}

- (void)syncFailedWithResponse:(NSError *)error
{
	[self completeOperation];
}

- (void)completeOperation
{
	[self willChangeValueForKey:kExecutingKey];
	[self willChangeValueForKey:kFinishedKey];
	finished_ = YES;
	executing_ = NO;
	[self didChangeValueForKey:kFinishedKey];
	[self didChangeValueForKey:kExecutingKey];
}

#pragma mark - private methods
#pragma mark - object creation

- (SyncObject *)createManagedObject:(NSString *)className
{
	Class managedObjectClass = NSClassFromString(className);
	return [managedObjectClass MR_createEntity];
}

#pragma mark - update
- (void)updateWithJSON:(NSArray *)json
{	
	NSArray *allGuids = [self collectGuids:json];
	NSArray *updatedManagedObjects = [SyncObject findAllByGUID:allGuids];
	NSDictionary *managedObjectsByGuid = [self managedObjectsByGuid:updatedManagedObjects];
	
	for (NSDictionary * jsonObject in json) {
		NSString * guid = [jsonObject objectForKey:kGUIDKey];
		SyncObject * managedObject = [managedObjectsByGuid objectForKey:guid];
		if (!managedObject) {
			NSString * className = [jsonObject objectForKey:kClassNameKey];
			managedObject = [self createManagedObject:className];
		}
		[managedObject updateWithJSON:jsonObject];
		managedObject.syncStatus = SOSynced;
	}
	[[NSManagedObjectContext MR_contextForCurrentThread] save];
}

- (NSArray *)collectGuids:(NSArray *)modifiedObjects
{
	NSMutableArray * guids = [NSMutableArray arrayWithCapacity:modifiedObjects.count];
	for (NSDictionary * object in modifiedObjects) {
		[guids addObject:[object objectForKey:kGUIDKey]];
	}
	return guids;
}

- (NSDictionary *)managedObjectsByGuid:(NSArray *)entities
{
	NSMutableDictionary *entitiesByGuid = [NSMutableDictionary dictionaryWithCapacity:entities.count];
	for (SyncObject *entity in entities) {
		[entitiesByGuid setObject:entity forKey:entity.guid];
	}
	return entitiesByGuid;
}




@end
