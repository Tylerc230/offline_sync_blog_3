//
//  BodyConflictView.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 9/25/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "BodyConflictView.h"

@interface BodyConflictView ()
@property (nonatomic, weak) IBOutlet UITextView *theirBody;
@property (nonatomic, weak) IBOutlet UITextView *yourBody;
@property (nonatomic, weak) IBOutlet UITextView *resolutionField;
@end

@implementation BodyConflictView

- (void)setTheirVersion:(id)theirVersion
{
    self.theirBody.text = theirVersion;
}

- (void)setYourVersion:(id)yourVersion
{
    self.yourBody.text = yourVersion;
    self.resolutionField.text = yourVersion;
}

- (id)resolution
{
    return self.resolutionField.text;
}

- (IBAction)useTheirBody:(id)sender
{
    self.resolutionField.text = self.theirBody.text;
}

- (IBAction)useYourBody:(id)sender
{
    self.resolutionField.text = self.yourBody.text;
}

- (IBAction)useBothBodies:(id)sender
{
    self.resolutionField.text = [NSString stringWithFormat:@"%@ %@", self.theirBody.text, self.yourBody.text];
}


@end
