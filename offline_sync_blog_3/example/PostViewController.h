//
//  PostViewController.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 8/14/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostViewController : UIViewController
@property (nonatomic, strong) Post *post;
- (void)setTitle:(NSString *)title andBody:(NSString *)body;
@end
