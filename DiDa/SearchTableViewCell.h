//
//  SearchTableViewCell.h
//  DiDa
//
//  Created by Bruce Yee on 4/25/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"

@interface SearchTableViewCell : UITableViewCell {
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UILabel *titleLabel;
}

- (void)configureWithRecord:(Record *)record;

@end
