//
//  DummySyncOperation.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 4/4/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "DummySyncOperation.h"
#import "Objection.h"
static NSDictionary *responseObject = nil;
@implementation DummySyncOperation
objection_register(DummySyncOperation)
+ (void)setResponseObject:(NSDictionary *)response
{
	responseObject = response;
}

- (void)syncPayload:(NSDictionary *)payload
{
	[self performSelector:@selector(syncSucceededWithResponse:) withObject:responseObject];
}

@end
