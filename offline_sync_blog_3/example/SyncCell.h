//
//  SyncCell.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 8/15/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncCell : UITableViewCell
@property (nonatomic, assign) BOOL synced;
@property (nonatomic, assign) BOOL conflicted;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@end
