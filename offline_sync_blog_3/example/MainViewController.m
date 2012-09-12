//
//  MainViewController.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 8/14/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "MainViewController.h"
#import "SyncStorageManager.h"
#import "Post.h"
#import "SyncCell.h"
#import "PostViewController.h"
#import "Conflict.h"

#define kConflictAlertTitle @"Conflict - All your changes were not saved."
#define kConflictAlertMessage @"The post you modified was also modified by another person or device. Fix the coflicts and resync."
@interface MainViewController ()
@property (nonatomic, strong) SyncStorageManager *syncManager;
@property (nonatomic, strong) NSFetchedResultsController * fetchController;
@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.syncManager = [[SyncStorageManager alloc] initWithBaseURL:@"http://192.168.1.59:3000"];
//        self.syncManager = [[SyncStorageManager alloc] initWithBaseURL:@"http://localhost:3000"];
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
        //We don't want to show the conflicted objects because they are duplicates of another row.
        //The conflicted object represents our local changes, the synced object w the same guid represents the server version
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"isGloballyDeleted == NO AND syncStatus != %@", [NSNumber numberWithInt:SOConflicted]];
        request.predicate = predicate;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kLastModifiedKey ascending:YES]];
        self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                   managedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
        self.fetchController.delegate = self;
        NSError * error = nil;
        [self.fetchController performFetch:&error];
        NSAssert(error ==  nil, @"error");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncCompleteCallback:) name:kSyncCompleteNotif object:nil];
        self.syncManager.resolveConflicts = ^(NSArray * conflicts){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kConflictAlertTitle message:kConflictAlertMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Post * post = [self.fetchController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    PostViewController * dest = (PostViewController *)segue.destinationViewController;
    dest.post = post;
}

#pragma mark - IBActions

- (IBAction)syncTapped:(id)sender
{
	[self.syncManager syncNow];
}

- (IBAction)newPostTapped:(id)sender
{
    [Post MR_createEntity];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveNestedContexts];
}

#pragma mark - NSFetchedResultsController delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(SyncCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - UITableView delegate/source methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SyncCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SyncObject *editedObject = [self.fetchController objectAtIndexPath:indexPath];
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [editedObject deleteUnsynced];
            break;
            
        default:
            break;
    }
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveNestedContexts];

}

- (void)configureCell:(SyncCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Post *post = [self.fetchController.fetchedObjects objectAtIndex:indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", post.title, post.guid];
    if (post.isConflicted) {
        cell.conflicted = YES;
    } else if (post.syncStatus == SOSynced)
    {
        cell.synced = YES;
    } else{
        cell.synced = NO;
    }

}


- (void)syncCompleteCallback:(NSNotification *)notif
{
    NSError * error = nil;
    [self.fetchController performFetch:&error];
    NSAssert(error == nil, @"fetch error %@", error);
}

@end
