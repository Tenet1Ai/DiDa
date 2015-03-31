//
//  PlayTableViewCell.h
//  DiDa
//
//  Created by Bruce Yee on 10/29/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Record.h"
#import "TouchActionsDelegate.h"
#import "AppDelegate.h"

@interface PlayTableViewCell : UITableViewCell {
    __weak IBOutlet UISlider *playSlider;
    __weak IBOutlet UIButton *playButton;
    __weak IBOutlet UILabel *memoLabel;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UILabel *locationLabel;
    __weak IBOutlet UILabel *secondsLabel;
    __weak IBOutlet UIImageView *locateImageView;
    __weak IBOutlet UILabel *startLabel;
    __weak IBOutlet UILabel *endLabel;
    NSTimer *timer;
    NSString *pathString;
    NSTimeInterval audioDuration;
    __unsafe_unretained id<TouchActionsDelegate> delegate;
}

@property (nonatomic, assign) id<TouchActionsDelegate> delegate;

- (void)configureWithRecord:(Record *)record;

@end
