//
//  SyncCell.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 8/15/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "SyncCell.h"
#define kSyncedIconImage @"green_check_mark_button_image_500_clr.png"
#define kConflictedIconImage @"red_c_button_image_500_clr.png"
@interface SyncCell ()
@property (nonatomic, weak) IBOutlet UIImageView *syncIndicator;
@end
@implementation SyncCell
- (void)setSynced:(BOOL)synced
{
    self.syncIndicator.image = [UIImage imageNamed:kSyncedIconImage];
    self.syncIndicator.hidden = !synced;
    _synced = synced;
}

- (void)setConflicted:(BOOL)conflicted
{
    self.syncIndicator.image = [UIImage imageNamed:kConflictedIconImage];
    self.syncIndicator.hidden = NO;
    _conflicted = conflicted;
}
@end
