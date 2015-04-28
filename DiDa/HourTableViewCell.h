//
//  HourTableViewCell.h
//  DiDa
//
//  Created by Bruce Yee on 4/9/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HourTableViewCell : UITableViewCell {
    __weak IBOutlet UILabel *timeLabel;
}

- (void)initCell:(NSInteger)row;

@end
