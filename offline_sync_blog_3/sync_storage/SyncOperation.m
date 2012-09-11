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
#import "AFJSONRequestOperation.h"
#import "keys.h"
#import "Objection.h"

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
	[self.httpClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
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
							 jsonRepresentation, kJSONModifiedEntitiesKey,
							 [NSNumber numberWithDouble:lastSyncTime], kJSONLastSyncTimeKey,
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
	NSURLRequest *request = [self.httpClient requestWithMethod:@"POST" path:@"/sync" parameters:payload];
	AFHTTPRequestOperation *operation = [self.httpClient HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *op, id responseObject) {
                                                                          [self syncSucceededWithResponse:responseObject];
    }
                                                                      failure:^(AFHTTPRequestOperation *op, NSError *error) {
                                                                          [self syncFailedWithResponse:error];
					  }];
//    operation.successCallbackQueue = dispatch_get_current_queue();
//    operation.failureCallbackQueue = dispatch_get_current_queue();
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

#pragma mark - sync response
- (void)syncSucceededWithResponse:(NSDictionary *) responseObject
{
	NSArray *modifiedEntities = [responseObject objectForKey:kJSONModifiedEntitiesKey];
	[self updateWithJSON:modifiedEntities];
	
	NSArray *conflictedEntities = [responseObject objectForKey:kJSONConflictedEntitiesKey];
    NSLog(@"conf: %@", conflictedEntities);
	[self markConflictedAndNotify:conflictedEntities];
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveNestedContexts];
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
		NSString *className = [[conflictedEntity allKeys] lastObject];
        NSDictionary *attributes = [conflictedEntity objectForKey:className];
		SyncObject *conflictedObject = [self createManagedObject:[className capitalizedString]];
		[conflictedObject updateWithJSON:attributes];
		conflictedObject.syncStatus = SOConflicted;
	}

}

#pragma mark - object creation

- (SyncObject *)createManagedObject:(NSString *)className
{
	Class managedObjectClass = NSClassFromString(className);
	return [managedObjectClass MR_createInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

#pragma mark - update
- (void)updateWithJSON:(NSArray *)json
{	
	NSArray *allGuids = [SyncObject collectGUIDSFromJSON:json];
	NSDictionary *managedObjectsByGuid = [SyncObject findAllByGUID:allGuids inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
	
	for (NSDictionary * jsonObject in json) 
	{
        NSString *className = [[jsonObject allKeys] lastObject];
        NSDictionary *attributes = [jsonObject valueForKey:className];
		NSString * guid = [attributes objectForKey:kGUIDKey];
		SyncObject * managedObject = [managedObjectsByGuid objectForKey:guid];
		if (!managedObject) {
			managedObject = [self createManagedObject:[className capitalizedString]];
		}
		[managedObject updateWithJSON:attributes];
		managedObject.syncStatus = SOSynced;
	}
}

@end
