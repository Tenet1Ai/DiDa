//
//  CenterViewController.h
//  DiDa
//
//  Created by Bruce Yee on 10/18/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayTableViewCell.h"

@interface CenterViewController : UITableViewController <TouchActionsDelegate> {
    NSIndexPath *selectedIndexPath;
    NSInteger originalRows;
    AVAudioPlayer *audioPlayer;
    NSTimeInterval currentTime;
    AppDelegate *appDelegate;
    NSString *filePathString;
    NSString *shareText;
    NSString *shareURL;
    NSInteger numberOfSharedItems;
}

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end
