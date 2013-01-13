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

#define kAreYouSure @"Are you sure?"
#define kAreYouSureBody @"Are you sure you want to replace the server version with this version?"
@interface PostConflictViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *conflictViews;
@end

@implementation PostConflictViewController
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.conflictViews = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupUI];
}
- (IBAction)resolveTapped:(id)sender
{
    NSString *body = kAreYouSureBody;
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:kAreYouSure message:body delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Resolve Conflict", nil];
    [alert show];
}

- (NSDictionary *)resolutionDictionary
{
    NSDictionary *clientJson = [[self.conflict.clientVersion toJson] objectForKey:kPostKey];
    NSMutableDictionary * json = [NSMutableDictionary dictionaryWithDictionary:clientJson];
    for (ConflictView *conflictView in self.conflictViews) {
        NSString *conflictKey = [[conflictView class] key];
        NSDictionary *conflictResolution = [conflictView resolution];
        [json setObject:conflictResolution forKey:conflictKey];        
    }
    return json;
}

#pragma mark - UIAlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.conflict resolve:[self resolutionDictionary]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Private methods

- (void)setupUI
{
    NSDictionary *conflictedFields = [self.conflict diffs];
    ConflictView *conflictView = nil;
    
    NSDictionary *titleConflict = [conflictedFields objectForKey:[TitleConflictView key]];
    if (titleConflict) {
        conflictView = [TitleConflictView titleConflictView];
        [conflictView setConflict:titleConflict];
        [self addSubviewToScroller:conflictView];
    }
    NSDictionary *bodyConflict = [conflictedFields objectForKey:[BodyConflictView key]];
    if (bodyConflict) {
        conflictView = [BodyConflictView bodyConflictView];
        [conflictView setConflict:bodyConflict];
        [self addSubviewToScroller:conflictView];
    }
    UIView *lastView = [self.conflictViews lastObject];
    NSDictionary *views = NSDictionaryOfVariableBindings(lastView);
    NSArray *bottomConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastView]|" options:0 metrics:0 views:views];
    [self.view addConstraints:bottomConstraint];
    NSLog(@"%i", [self.view hasAmbiguousLayout]);
    [self.view setNeedsUpdateConstraints];
}

- (void)addSubviewToScroller:(UIView *)newView
{
    ConflictView *previousView = [self.conflictViews lastObject];
    [newView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:newView];
    NSDictionary *views = nil;
    NSString *layoutString = nil;
    if (previousView) {
        views = NSDictionaryOfVariableBindings(previousView, newView);
        layoutString = @"V:[previousView][newView]";
    } else {
        views = NSDictionaryOfVariableBindings(newView);
        layoutString = @"V:|[newView]";
    }
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:layoutString options:0 metrics:nil views:views];
    [self.view addConstraints:constraints];
    layoutString = @"H:|[newView]|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:layoutString options:0 metrics:nil views:views];
    [self.view addConstraints:constraints];
    [self.conflictViews addObject:newView];
}

@end
