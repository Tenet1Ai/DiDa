//
// Copyright 2014 Inostudio Solutions
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "INOYearTableController.h"
#import "INOYearTableCell.h"
#import "INOYearModel.h"
#import "UIView+Borders.h"

static NSUInteger const kCellsCount = 20;
static NSUInteger const kHalfCellsCount = kCellsCount >> 1;

@interface INOYearTableController () <UITableViewDataSource, UITableViewDelegate, MonthViewDelegate>

@property (nonatomic, strong) INOYearModel *model;

@property (nonatomic, assign) NSInteger  offset;
@property (nonatomic, assign) NSUInteger integerCellHeight; // is used for fast division

@end

@implementation INOYearTableController

- (IBAction)tapAddButton:(id)sender {
    [self performSegueWithIdentifier:@"pushToAdd" sender:@"pushToAdd"];
}

- (IBAction)tapSettingsButton:(id)sender {
    [self performSegueWithIdentifier:@"pushToSettings" sender:@"pushToSettings"];
}

- (IBAction)tapMemosButton:(id)sender {
    [self performSegueWithIdentifier:@"pushToList" sender:@"pushToList"];
}

- (IBAction)tapTodayButton:(id)sender {
    _offset = 0;
    _model = [[INOYearModel alloc] init];
    _integerCellHeight = ceilf([INOYearTableCell cellHeight]);
    [yearTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [yearTableView setShowsVerticalScrollIndicator:NO];
    [yearTableView reloadData];
    [yearTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kHalfCellsCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)tapMonthView:(NSInteger)tag {
    DLog(@"%ld", tag);
    tagSelected = tag;
    [self performSegueWithIdentifier:@"pushToMonth" sender:@"pushToMonth"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _model = [[INOYearModel alloc] init];
    
    _integerCellHeight = ceilf([INOYearTableCell cellHeight]);
    
    [yearTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [yearTableView setShowsVerticalScrollIndicator:NO];
    [yearTableView reloadData];
    [yearTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kHalfCellsCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [bottomView addTopBorderWithHeight:1.f andColor:[UIColor lightGrayColor]];
    tagSelected = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.title = NSLocalizedString(@"DiDa Calendar", nil);
}

#pragma mark - UITableViewDatasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    DLog(@"%ld", kCellsCount);
    return kCellsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *yearTableCellId = @"yearTableCellId";
    INOYearTableCell *cell = [tableView dequeueReusableCellWithIdentifier:yearTableCellId];
    if (!cell) {
        cell = [[INOYearTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:yearTableCellId];
        cell.delegate = self;
    }
    [cell setTag:indexPath.row];
    
    NSDate *yearDate = [_model yearWithOffsetFromCurrentDate:indexPath.row + kHalfCellsCount * (_offset -  1)];
    [cell setupWithYearDate:yearDate];
    [_model makeMonthsImagesWithDate:yearDate
                              ofSize:[INOYearTableCell monthViewSize] cancelTag:[cell tag]
                          completion: ^(BOOL success, NSArray *monthsImages) {
                              if (success && [monthsImages count] > 0) {
                                  [cell setupWithMonthsImages:monthsImages];
                              }
                          }];
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [INOYearTableCell cellHeight];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint contentOffset  = scrollView.contentOffset;
    
    if (contentOffset.y <= _integerCellHeight) {
        contentOffset.y = scrollView.contentSize.height / 2 + _integerCellHeight;
        _offset--;
    } else if (contentOffset.y >= scrollView.contentSize.height - (_integerCellHeight << 1)) {
        contentOffset.y = scrollView.contentSize.height / 2 - (_integerCellHeight << 1);
        _offset++;
    }
    
    [scrollView setContentOffset:contentOffset];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [_model proceedLoadingOperations];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_model suspendLoadingOperations];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = segue.destinationViewController;
    if ([sender isEqualToString:@"pushToMonth"]) {
        if ([viewController respondsToSelector:@selector(setTag:)]) {
            [viewController setValue:[NSNumber numberWithInteger:tagSelected] forKey:@"tag"];
        }
        self.title = [NSString stringWithFormat:@"%ld", tagSelected / 1000];
    }
}

@end
