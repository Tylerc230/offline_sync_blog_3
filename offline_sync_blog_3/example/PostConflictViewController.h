//
//  PostConflictViewController.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 9/11/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Conflict.h"
@interface PostConflictViewController : UIViewController
@property (nonatomic, strong) Conflict *conflict;
@end
