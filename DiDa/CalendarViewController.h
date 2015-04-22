//
//  CalendarViewController.h
//  DiDa
//
//  Created by Bruce Yee on 4/1/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@interface CalendarViewController : UIViewController {
    IBOutlet JTCalendarContentView *calendarView;
    JTCalendar *calendar;
}

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
