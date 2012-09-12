//
//  Conflict.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 4/5/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncObject.h"

@interface Conflict : NSObject
@property (nonatomic, strong) SyncObject *clientVersion;
@property (nonatomic, strong) SyncObject *serverVersion;

+ (Conflict *)conflictForGuid:(NSString *)guid;
- (id)initWithLocalVersion:(SyncObject *)localVersion serverVersion:(SyncObject *)serverVersion;
- (NSDictionary *)diffs;
- (void)resolve:(NSDictionary *)resolution;
@end
