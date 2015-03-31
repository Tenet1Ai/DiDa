//
//  Record.h
//  DiDa
//
//  Created by Bruce Yee on 11/11/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Record : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * unit;

@end
