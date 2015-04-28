//
//  SearchTableViewCell.m
//  DiDa
//
//  Created by Bruce Yee on 4/25/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import "SearchTableViewCell.h"
//#import "TTTTimeIntervalFormatter.h"
#import "NSDate+FSExtension.h"

@implementation SearchTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithRecord:(Record *)record {
    NSString *dateString = [record.date fs_stringWithFormat:@"d EEEE"];
    dateLabel.text = dateString;
//    double seconds = [record.length doubleValue];
//    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
//    timeIntervalFormatter.futureDeicticExpression = @"";
//    timeLabel.text = [timeIntervalFormatter stringForTimeInterval:seconds];
    NSString *titleString = record.memo;
    if (titleString && titleString.length > 0) {
        titleLabel.text = titleString;
    } else {
        titleLabel.text = @" ";
    }
}

@end
