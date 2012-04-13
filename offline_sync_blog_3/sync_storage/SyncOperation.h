//
//  SyncOperation.h
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 4/4/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncOperation : NSOperation
@property (nonatomic, strong) NSString *baseURL;
@end
