//
//  Comment.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "Comment.h"
#import "Post.h"


@implementation Comment

@dynamic post;
@dynamic comment;

- (NSMutableDictionary *)diff:(Comment *)other
{
	NSMutableDictionary *diff = [super diff:other];
	[self setKey:kCommentKey inDict:diff ifDiffers:other];
	return diff;
}

@end
