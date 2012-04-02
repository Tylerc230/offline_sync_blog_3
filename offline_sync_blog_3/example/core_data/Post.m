//
//  Post.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "Post.h"


@implementation Post

@dynamic comments;
@dynamic title;
@dynamic body;


- (void)updateWithJSON:(NSDictionary *)jsonObject
{
	[super updateWithJSON:jsonObject];
	self.body = [jsonObject objectForKey:kBodyKey];
	self.title = [jsonObject objectForKey:kTitleKey];
}

- (NSMutableDictionary *)toJson
{
	NSMutableDictionary *object = [super toJson];
	[object setObject:self.title forKey:kTitleKey];
	[object setObject:self.body forKey:kBodyKey];
	return object;
}

@end
