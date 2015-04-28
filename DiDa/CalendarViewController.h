//
//  CalendarViewController.h
//  DiDa
//
//  Created by Bruce Yee on 4/1/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"
#import "PlayTableViewCell.h"

@interface CalendarViewController : UIViewController <TouchActionsDelegate> {
    IBOutlet JTCalendarContentView *calendarView;
    __weak IBOutlet UITableView *mainTableView;
    __weak IBOutlet UIView *bottomView;
    JTCalendar *calendar;
    NSMutableArray *eventsDateArray;
    NSMutableDictionary *eventsForDatesDictionary;
    NSArray *recordsArray;
    
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

@property (nonatomic, assign) NSDate *selectedDate;

@end
