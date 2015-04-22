//
//  Record.m
//  DiDa
//
//  Created by Bruce Yee on 11/11/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "Record.h"


@implementation Record

@dynamic date;
@dynamic latitude;
@dynamic length;
@dynamic location;
@dynamic longitude;
@dynamic memo;
@dynamic note;
@dynamic path;
@dynamic unit;
@dynamic category;

+ (NSArray *)eventsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate inContext:(NSManagedObjectContext *)context {
    
    NSEntityDescription *eventEntity = [NSEntityDescription entityForName:NSStringFromClass([Record class]) inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:eventEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date <= %@", fromDate, toDate];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *events = [context executeFetchRequest:request error:&error];
    
    if (error) {
        DLog(@"Error during %@ objects fetch: %@", [Record class], [error userInfo]);
    }
    
    return events;
}

@end
