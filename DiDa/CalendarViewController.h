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
    __weak IBOutlet JTCalendarMenuView *menuView;
    __weak IBOutlet JTCalendarContentView *calendarView;
    JTCalendar *calendar;
    NSTimer *aTimer;
}

@end
