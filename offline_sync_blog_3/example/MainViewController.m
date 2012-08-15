//
//  MainViewController.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 8/14/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "MainViewController.h"
#import "SyncStorageManager.h"
#import "Post.h"
@interface MainViewController ()
@property (nonatomic, strong) SyncStorageManager *syncManager;
@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.syncManager = [[SyncStorageManager alloc] initWithBaseURL:@"http://localhost:3000"];
    }
    return self;
}

- (IBAction)syncTapped:(id)sender
{
    [Post MR_createEntity];
	[self.syncManager syncNow];
}
@end
