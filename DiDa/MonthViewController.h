//
//  MonthViewController.h
//  DiDa
//
//  Created by Bruce Yee on 4/23/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"
#import "PlayTableViewCell.h"

@interface MonthViewController : UIViewController <TouchActionsDelegate> {
    __weak IBOutlet FSCalendar *monthCalendar;
    __weak IBOutlet FSCalendarHeader *monthCalendarHeader;
    NSDate *selectedDate;
    __weak IBOutlet UITableView *mainTableView;
    __weak IBOutlet UIView *bottomView;

    AppDelegate *appDelegate;
    BOOL daySelected;
    
    NSIndexPath *selectedIndexPath;
    NSInteger originalRows;
    AVAudioPlayer *audioPlayer;
    NSTimeInterval currentTime;
    NSString *filePathString;
    NSString *shareText;
    NSString *shareURL;
    
    NSInteger numberOfSharedItems;
}

@property (nonatomic, assign) NSInteger dateTag;

@end
