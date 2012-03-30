//
//  ExampleSyncManager.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/29/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "ExampleSyncManager.h"
#import "SyncObject.h"

@implementation ExampleSyncManager
- (SyncObject *)createManagedObject:(NSString *)classString
{
	Class managedObjectClass = NSClassFromString(classString);
	return [managedObjectClass MR_createEntity];
}

@end
