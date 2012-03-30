//
//  Comment.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 3/28/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SyncObject.h"

@class Post;

@interface Comment : SyncObject

@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) Post *post;

@end
