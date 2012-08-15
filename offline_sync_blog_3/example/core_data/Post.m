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
	NSMutableDictionary *parentObject = [super toJson];
	[parentObject setObject:self.title forKey:kJSONTitleKey];
	[parentObject setObject:self.body forKey:kJSONBodyKey];
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:parentObject, kJSONPostKey, nil];
}

- (NSMutableDictionary *)diff:(Post *)other
{
	NSMutableDictionary *diff = [super diff:other];
	[self setKey:kJSONTitleKey inDict:diff ifDiffers:other];
	[self setKey:kJSONBodyKey inDict:diff ifDiffers:other];
	return diff;
}

@end
