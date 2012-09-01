//
//  PostViewController.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 8/14/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "PostViewController.h"

@interface PostViewController ()
@property (nonatomic, weak) IBOutlet UITextField *textTitleInput;
@property (nonatomic, weak) IBOutlet UITextView *textBodyInput;
@end

@implementation PostViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setTitle:self.post.title andBody:self.post.body];
}
- (void)setTitle:(NSString *)title andBody:(NSString *)body
{
    self.textTitleInput.text = title;
    self.textBodyInput.text = body;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [self.post setTitleUnsynced:self.textTitleInput.text];
        [self.post setBodyUnsynced:self.textBodyInput.text];
        [[NSManagedObjectContext defaultContext] save];
    }
}

@end
