//
//  CalendarViewController.m
//  DiDa
//
//  Created by Bruce Yee on 4/1/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import "CalendarViewController.h"

@interface CalendarViewController () <JTCalendarDataSource>

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    calendar = [JTCalendar new];
    
    
    calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
    calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
    calendar.calendarAppearance.ratioContentMenu = 3.;
    calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
    
    // Customize the text for each month
    calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar) {
        NSCalendar *aCalendar = jt_calendar.calendarAppearance.calendar;
        NSDateComponents *comps = [aCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
        NSInteger currentMonthIndex = comps.month;
        
        static NSDateFormatter *dateFormatter;
        if (!dateFormatter) {
            dateFormatter = [NSDateFormatter new];
            dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
        }
        
        while(currentMonthIndex <= 0) {
            currentMonthIndex += 12;
        }
        
        NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
        
        return [NSString stringWithFormat:@"%ld\n%@", comps.year, monthText];
    };

    [calendar setMenuMonthsView:menuView];
    [calendar setContentView:calendarView];
    [calendar setDataSource:self];

    [calendar reloadData];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date {
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date {
    DLog(@"Date: %@", date);
}

- (void)calendarDidLoadPreviousPage {
    DLog(@"Previous page loaded");
}

- (void)calendarDidLoadNextPage {
    DLog(@"Next page loaded");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
