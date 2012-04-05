//
//  TestModule.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 4/4/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "TestModule.h"
#import "SyncOperation.h"
#import "DummySyncOperation.h"
@implementation TestModule

- (void)configure
{
	[self bindClass:[DummySyncOperation class] toClass:[SyncOperation class]];
}

@end
