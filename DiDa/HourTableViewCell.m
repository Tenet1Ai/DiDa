//
//  HourTableViewCell.m
//  DiDa
//
//  Created by Bruce Yee on 4/9/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import "HourTableViewCell.h"

@implementation HourTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initCell:(NSInteger)row {
    if (row < 10) {
        timeLabel.text = [NSString stringWithFormat:@"0%ld:00", (long)row];
    } else {
        timeLabel.text = [NSString stringWithFormat:@"%ld:00", (long)row];
    }
}

@end
