//
//  RecordTableViewCell.h
//  DiDa
//
//  Created by Bruce Yee on 10/25/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"

@interface RecordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locateImageView;

- (void)configureWithRecord:(Record *)record;

@end
