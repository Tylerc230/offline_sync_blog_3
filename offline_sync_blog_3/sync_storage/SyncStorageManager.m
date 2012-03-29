//
//  SyncStorageManager.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncStorageManager.h"
#import "MagicalRecordHelpers.h"
#import "SyncObject.h"
#import "AFHTTPClient.h"

@interface SyncStorageManager ()
@property (nonatomic, strong) AFHTTPClient *httpClient;
@end

@implementation SyncStorageManager
@synthesize httpClient;

- (id)initWithBaseURL:(NSString *)baseURL
{
	if (self = [super init]) {
		[MagicalRecordHelpers setupCoreDataStack];
		self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:baseURL]];
	}
	return self;
}

- (void)dealloc
{
	[MagicalRecordHelpers cleanUp];
}
#pragma mark - public methods
- (void)syncNow
{
	[[NSManagedObjectContext MR_context] MR_save];
	[self syncAllEntities];
}

#pragma mark - private methods

- (NSTimeInterval)lastSyncTime
{
	return [[[SyncObject findAllSortedBy:@"lastModified" ascending:NO] objectAtIndex:0] lastModified];
}

#pragma mark - sync
- (void)syncAllEntities
{
	NSArray *modifiedEntities = [SyncObject findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInt:SONeedsSync]];
	NSTimeInterval lastSyncTime = [self lastSyncTime];
	NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:
							 modifiedEntities, @"modifiedEntities",
							 [NSNumber numberWithDouble:lastSyncTime], @"lastSyncTime",
							 nil];
	[self syncPayload:payload];
	
}

- (void)syncPayload:(NSDictionary *)payload
{
	[self.httpClient postPath:@"/sync" parameters:payload 
					  success:^(AFHTTPRequestOperation *op, id responseObject) {
						  [self syncSucceededWithResponse:responseObject];
					  }
					  failure:^(AFHTTPRequestOperation *op, NSError *error) {

					  }];
}

- (void)syncSucceededWithResponse:(NSDictionary *) responseObject
{
	NSArray *modifiedEntities = [responseObject objectForKey:@"modifiedEntities"];
	[self updateWithJSON:modifiedEntities];
	[[NSNotificationCenter defaultCenter] postNotificationName:kSyncCompleteNotif object:self];
}

#pragma mark - object creation

- (SyncObject *)createManagedObject
{
	return nil;
}

#pragma mark - update
- (void)updateWithJSON:(NSArray *)json
{	
	NSArray *allGuids = [self collectGuids:json];
	NSArray *updatedManagedObjects = [SyncObject findAllByGUID:allGuids];
	NSDictionary *managedObjectsByGuid = [self managedObjectsByGuid:updatedManagedObjects];
	
	for (NSDictionary * jsonObject in json) {
		NSString * guid = [jsonObject objectForKey:@"guid"];
		SyncObject * managedObject = [managedObjectsByGuid objectForKey:guid];
		if (!managedObject) {
			managedObject = [self createManagedObject];
		}
		[managedObject updateWithJSON:jsonObject];
	}
}

- (NSArray *)collectGuids:(NSArray *)modifiedObjects
{
	NSMutableArray * guids = [NSMutableArray arrayWithCapacity:modifiedObjects.count];
	for (NSDictionary * object in modifiedObjects) {
		[guids addObject:[object objectForKey:@"guid"]];
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
