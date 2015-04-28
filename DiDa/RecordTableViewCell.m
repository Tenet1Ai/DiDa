//
//  RecordTableViewCell.m
//  DiDa
//
//  Created by Bruce Yee on 10/25/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "RecordTableViewCell.h"
#import "AppDelegate.h"

@implementation RecordTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithRecord:(Record *)record {
    self.memoLabel.text = record.memo;
    NSTimeZone *timezone = [NSTimeZone systemTimeZone];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d/MM/YYYY HH:mm:ss"];
    [formatter setTimeZone:timezone];
    NSString *correctDate = [formatter stringFromDate:record.date];
    self.dateLabel.text = correctDate;
    if (record.unit && record.unit.length > 0) {
        self.locationLabel.text = record.unit;
        self.locateImageView.hidden = NO;
    } else {
        self.locationLabel.text = @"";
        self.locateImageView.hidden = YES;
    }
    self.secondsLabel.text = [NSString stringWithFormat:@"%.1f", [record.length floatValue]];
//    DLog(@"%@ %@", [record.length stringValue], record.unit);
}

@end
