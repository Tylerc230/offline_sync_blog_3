//
//  TitleConflictView.m
//  offline_sync_blog_3
//
//  Created by Tyler Casselman on 9/25/12.
//  Copyright (c) 2012 Casselman Consulting. All rights reserved.
//

#import "TitleConflictView.h"
@interface TitleConflictView ()
@property (nonatomic, weak) IBOutlet UILabel *theirTitle;
@property (nonatomic, weak) IBOutlet UILabel *yourTitle;
@property (nonatomic, weak) IBOutlet UITextField *resolutionField;
@end

@implementation TitleConflictView
+ (NSString *)key
{
    return kTitleKey;
}

+ (TitleConflictView *)titleConflictView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TitleConflictView" owner:nil options:nil] lastObject];
}

- (void)setTheirVersion:(id)theirVersion
{
    self.theirTitle.text = theirVersion;
}

- (void)setYourVersion:(id)yourVersion
{
    self.yourTitle.text = yourVersion;
    self.resolutionField.text = yourVersion;
}

- (id)resolution
{
    return self.resolutionField.text;
}

- (IBAction)useTheirTitle:(id)sender
{
    self.resolutionField.text = self.theirTitle.text;
}

- (IBAction)useYourTitle:(id)sender
{
    self.resolutionField.text = self.yourTitle.text;
}

- (IBAction)useBothTitles:(id)sender
{
    self.resolutionField.text = [NSString stringWithFormat:@"%@ %@", self.theirTitle.text, self.yourTitle.text];
}

@end
