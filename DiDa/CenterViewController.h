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
    NSInteger selectedRow;
    NSInteger tagSelected;
    NSInteger originalRows;
    NSTimer *aTimer;
    AVAudioPlayer *audioPlayer;
    NSTimeInterval currentTime;
    AVAudioSession *session;
    AppDelegate *appDelegate;
    NSString *filePathString;
    NSString *shareText;
    NSString *shareURL;
}

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end
