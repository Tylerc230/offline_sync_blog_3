//
//  DummySyncOperation.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 4/4/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "SyncOperation.h"

@interface DummySyncOperation : SyncOperation
+ (void)setResponseObject:(NSDictionary *)response;
@end
