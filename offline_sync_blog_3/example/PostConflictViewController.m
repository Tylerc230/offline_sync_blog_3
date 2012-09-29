//
//  PostConflictViewController.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 9/11/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "PostConflictViewController.h"
#import "TitleConflictView.h"
#import "BodyConflictView.h"
#import "Post.h"
@interface PostConflictViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TitleConflictView *titleEditView;
@property (weak, nonatomic) IBOutlet BodyConflictView *bodyEditView;

@end

@implementation PostConflictViewController
- (void)setConflict:(Conflict *)conflict
{
    _conflict = conflict;
    self.view;
    NSDictionary *conflictedFields = [conflict diffs];
    NSDictionary *bodyConflict = [conflictedFields objectForKey:kBodyKey];
    if (bodyConflict) {
        self.bodyEditView.hidden = NO;
        [self.bodyEditView setConflict:bodyConflict];
    } else
    {
        self.bodyEditView.hidden = YES;
    }
    
    NSDictionary *titleConflict = [conflictedFields objectForKey:kTitleKey];
    if (titleConflict) {
        self.titleEditView.hidden = NO;
        [self.titleEditView setConflict:titleConflict];
    } else
    {
        self.titleEditView.hidden = YES;
    }
    [self updateScrollContentSize];
}

- (IBAction)resolveTapped:(id)sender
{
    
}

- (void)updateScrollContentSize
{
    float scrollHeight = 0;
    scrollHeight += self.titleEditView.hidden ? 0.f : self.titleEditView.frame.size.height;
    if (self.titleEditView.hidden) {
        CGRect frame = self.bodyEditView.frame;
        frame.origin.y = 0.f;
        self.bodyEditView.frame = frame;
    }
    scrollHeight += self.bodyEditView.hidden ? 0.f : self.bodyEditView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(0.f, scrollHeight);
    
}
@end
