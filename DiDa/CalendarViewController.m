//
//  CalendarViewController.m
//  DiDa
//
//  Created by Bruce Yee on 4/1/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import "CalendarViewController.h"
#import "NavigationController.h"
#import "AboutViewController.h"
#import "HourTableViewCell.h"

@interface CalendarViewController () <JTCalendarDataSource, UITableViewDataSource, UITableViewDelegate>

@end

@implementation CalendarViewController
@synthesize tag;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DLog(@"%ld", tag);
    calendar = [JTCalendar new];

    calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
    calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
    calendar.calendarAppearance.ratioContentMenu = 2.;
    calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
    
    // Customize the text for each month
    calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
        NSCalendar *nowCalendar = jt_calendar.calendarAppearance.calendar;
        NSDateComponents *comps = [nowCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
        NSInteger currentMonthIndex = comps.month;
        
        static NSDateFormatter *dateFormatter;
        if(!dateFormatter){
            dateFormatter = [NSDateFormatter new];
            dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
        }
        while(currentMonthIndex <= 0){
            currentMonthIndex += 12;
        }
        NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
        return [NSString stringWithFormat:@"%ld\n%@", comps.year, monthText];
    };

    [calendar setContentView:calendarView];
    [calendar setDataSource:self];
    calendar.calendarAppearance.isWeekMode = YES;
    [calendar setCurrentDate:[NSDate date]];
    [calendar reloadAppearance];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date {
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date {
    DLog(@"Date: %@", date);
}

- (IBAction)tapMenuButton:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 24;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellID = @"hourCell";
    HourTableViewCell *cell = (HourTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellID];
    return cell;
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
