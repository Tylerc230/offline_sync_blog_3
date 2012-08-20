//
//  SyncCell.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 8/15/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "SyncCell.h"
@interface SyncCell ()
@property (nonatomic, weak) IBOutlet UIImageView *syncIndicator;
@end
@implementation SyncCell
- (void)setSynced:(BOOL)synced
{
    self.syncIndicator.hidden = !synced;
    _synced = synced;
}
@end
