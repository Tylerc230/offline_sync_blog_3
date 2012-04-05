//
//  DependencyModule.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 4/4/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "DependencyModule.h"
#import "SyncOperation.h"
@implementation DependencyModule
- (void)configure
{
	[self bindClass:[SyncOperation class] toClass:[SyncOperation class]];
}
@end
