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
#import "Objection.h"

#define kExecutingKey @"isExecuting"
#define kFinishedKey @"isFinished"

@interface SyncOperation ()
{
	BOOL finished_;
	BOOL executing_;
	NSManagedObjectContext *managedObjectContext_;
}
@property (nonatomic, strong) AFHTTPClient *httpClient;
@end


@implementation SyncOperation
objection_register(SyncOperation)
objection_requires(@"baseURL")
@synthesize httpClient;
@dynamic baseURL;
- (id)init
{
	if (self = [super init]) {
		executing_ = NO;
		finished_ = NO;
	}
	return self;
}

- (void)setBaseURL:(NSString *)baseURL
{
	self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:baseURL]];
	self.httpClient.parameterEncoding = AFJSONParameterEncoding;
}

- (void)main
{
	[self willChangeValueForKey:kExecutingKey];
	executing_ = YES;
	[self didChangeValueForKey:kExecutingKey];
	managedObjectContext_ = [NSManagedObjectContext MR_context];
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
	
	NSArray *conflictedEntities = [responseObject objectForKey:kConflictedEntitiesKey];
	[self markConflictedAndNotify:conflictedEntities];
	[managedObjectContext_ MR_save];
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
#pragma mark - conflict resolution
- (void)markConflictedAndNotify:(NSArray *)conflictedEntities
{
	for (NSDictionary *conflictedEntity in conflictedEntities) {
		NSString *className = [conflictedEntity objectForKey:kClassNameKey];
		SyncObject *conflictedObject = [self createManagedObject:className];
		[conflictedObject updateWithJSON:conflictedEntity];
		conflictedObject.syncStatus = SOConflicted;
	}

}

#pragma mark - object creation

- (SyncObject *)createManagedObject:(NSString *)className
{
	Class managedObjectClass = NSClassFromString(className);
	return [managedObjectClass MR_createInContext:managedObjectContext_];
}

#pragma mark - update
- (void)updateWithJSON:(NSArray *)json
{	
	NSArray *allGuids = [SyncObject collectGUIDS:json];
	NSDictionary *managedObjectsByGuid = [SyncObject findAllByGUID:allGuids inContext:managedObjectContext_];
	
	for (NSDictionary * jsonObject in json) 
	{
		NSString * guid = [jsonObject objectForKey:kGUIDKey];
		SyncObject * managedObject = [managedObjectsByGuid objectForKey:guid];
		if (!managedObject) {
			NSString * className = [jsonObject objectForKey:kClassNameKey];
			managedObject = [self createManagedObject:className];
		}
		[managedObject updateWithJSON:jsonObject];
		managedObject.syncStatus = SOSynced;
	}
}

@end
