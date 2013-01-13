//
//  ConflictView.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 9/25/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "ConflictView.h"
#import "SyncObject.h"
@implementation ConflictView
+ (NSString *)key
{
    return nil;
}

- (void)setConflict:(NSDictionary *)conflict
{
    self.theirVersion = [conflict objectForKey:kOtherKey];
    self.yourVersion = [conflict objectForKey:kReceiverKey];
}

- (id)resolution
{
    return nil;
}

@end
