//
//  ConflictView.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 9/25/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@interface ConflictView : UIView
@property (nonatomic, strong) id theirVersion;
@property (nonatomic, strong) id yourVersion;
+ (NSString *)key;
- (void)setConflict:(NSDictionary *)conflict;
- (id)resolution;
@end
