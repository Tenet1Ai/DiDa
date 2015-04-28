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
#import "MonthViewController.h"
#import "SearchTableViewCell.h"
#import "NSDate+FSExtension.h"
#import "DetailViewController.h"

static NSUInteger const kCellsCount = 20;
static NSUInteger const kHalfCellsCount = kCellsCount >> 1;

@interface INOYearTableController () <UITableViewDataSource, UITableViewDelegate,
MonthViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate,
AVAudioPlayerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) INOYearModel *model;

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSUInteger integerCellHeight; // is used for fast division
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation INOYearTableController

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Record"
                                                  inManagedObjectContext:appDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memo CONTAINS[cd] %@", memoSearchBar.text];
        DLog(@"memo CONTAINS[cd] %@", memoSearchBar.text);
        [fetchRequest setPredicate:predicate];
        
        BOOL flag = NO;
        if (appDelegate.dataSort == 0) {
            flag = YES;
        } else {
            flag = NO;
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:flag];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:appDelegate.managedObjectContext
                                              sectionNameKeyPath:@"section"
                                                       cacheName:nil];
        self.fetchedResultsController = aFetchedResultsController;
        self.fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        
        if (![self.fetchedResultsController performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during development. If it is not possible to recover from the error, display an alert
            // panel that instructs the user to quit the application by pressing the Home button.
            //
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _fetchedResultsController;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchTableView.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DLog(@"%@", searchBar.text);
    _fetchedResultsController = nil;
    [searchTableView reloadData];
}

- (IBAction)tapSearchButton:(id)sender {
    memoSearchBar.hidden = memoSearchBar.hidden ? NO : YES;
    if (memoSearchBar.hidden == YES) {
        [memoSearchBar resignFirstResponder];
        searchTableView.hidden = YES;
    }
}

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
    searchTableView.hidden = YES;
    memoSearchBar.hidden = YES;
    _offset = 0;
    _model = [[INOYearModel alloc] init];
    _integerCellHeight = ceilf([INOYearTableCell cellHeight]);
    [yearTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [yearTableView setShowsVerticalScrollIndicator:NO];
    [yearTableView reloadData];
    [yearTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kHalfCellsCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)tapMonthView:(NSInteger)tag {
    DLog(@"%ld", (long)tag);
    tagSelected = tag;
    [self performSegueWithIdentifier:@"pushToMonth" sender:@"pushToMonth"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    memoSearchBar.hidden = YES;
    searchTableView.hidden = YES;
    
    _model = [[INOYearModel alloc] init];
    
    _integerCellHeight = ceilf([INOYearTableCell cellHeight]);
    
    [yearTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [yearTableView setShowsVerticalScrollIndicator:NO];
    [yearTableView reloadData];
    [yearTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:kHalfCellsCount inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [bottomView addTopBorderWithHeight:1.f andColor:[UIColor lightGrayColor]];
    tagSelected = 0;
    appDelegate = [[UIApplication sharedApplication] delegate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.title = NSLocalizedString(@"DiDa Calendar", nil);
    [yearTableView reloadData];
    if (appDelegate.audioPlayer) {
        [appDelegate.audioPlayer stop];
        appDelegate.audioPlayer = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [memoSearchBar resignFirstResponder];
    memoSearchBar.hidden = YES;
    searchTableView.hidden = YES;
}

#pragma mark - UITableViewDatasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger count = 1;
    if (tableView == searchTableView) {
        count = [[self.fetchedResultsController sections] count];
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    DLog(@"%ld", kCellsCount);
    if (tableView == searchTableView) {
        NSInteger numberOfRows = 0;
        if ([[self.fetchedResultsController sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            numberOfRows = [sectionInfo numberOfObjects];
        }
        return numberOfRows;
    } else {
        return kCellsCount;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == searchTableView) {
        id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
        NSString *sectionName = [theSection name];
        NSInteger sectionInteger = [sectionName integerValue];
        if (sectionInteger > 0) {
            NSInteger year = sectionInteger / 1000;
            NSInteger month = sectionInteger - year * 1000;
            NSDate *date = [NSDate fs_dateWithYear:year month:month day:1];
            NSString *dateString = [date fs_stringWithFormat:@"MMMM yyyy"];
            return dateString;
        } else {
            return @" ";
        }
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == searchTableView) {
        static NSString *tableCellId = @"SearchTableViewCell";
        SearchTableViewCell *cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableCellId];
        Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [cell configureWithRecord:record];
        return cell;
    } else {
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
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == searchTableView) {
        return 44;
    } else {
        return [INOYearTableCell cellHeight];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [appDelegate setMemoInfo:record];
    [self performSegueWithIdentifier:@"pushToDetail" sender:@"pushToDetail"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == yearTableView) {
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
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == yearTableView) {
        [_model proceedLoadingOperations];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == yearTableView) {
        [_model suspendLoadingOperations];
    }
}

#pragma mark - common functions

- (void)loadAudioFile:(NSString *)pathString {
    if (![filePathString isEqualToString:pathString]) {
        if (audioPlayer) {
            [audioPlayer stop];
            [audioPlayer prepareToPlay];
            audioPlayer = nil;
        }
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@.m4a", NSHomeDirectory(), pathString];
        DLog(@"%@", filePath);
        NSURL *pathURL = [NSURL fileURLWithPath:filePath];
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:pathURL error:&error];
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
        filePathString = pathString;
        [appDelegate setFileProtectionNone:filePath];
    }
}

- (BOOL)isPlaying {
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            [appDelegate switchAudioSessionCategory];
            return YES;
        }
    }
    return NO;
}

- (void)touchedDetailButton:(NSString *)title {
    [self performSegueWithIdentifier:@"pushToDetail" sender:@"pushToDetail"];
}

- (void)repalceRecord:(NSInteger)type string:(NSString *)string {
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Record" inManagedObjectContext:appDelegate.managedObjectContext];
    // create an earthquake managed object, but don't insert it in our moc yet
    Record *newRecord = [[Record alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
    newRecord.memo = record.memo;
    newRecord.note = record.note;
    newRecord.date = record.date;
    newRecord.latitude = record.latitude;
    newRecord.length = record.length;
    newRecord.location = record.location;
    newRecord.longitude = record.longitude;
    newRecord.path = record.path;
    newRecord.unit = record.unit;
    newRecord.category = record.category;
    newRecord.section = record.section;
    if (type == 1) {
        newRecord.memo = string;
    } else if (type == 2) {
        newRecord.note = string;
    }
    
    if (newRecord) {
        [appDelegate.managedObjectContext insertObject:newRecord];
    }
    if (record) {
        [appDelegate.managedObjectContext deleteObject:record];
    }
    
    NSError *error = nil;
    if ([appDelegate.managedObjectContext hasChanges]) {
        if (![appDelegate.managedObjectContext save:&error]) {
            DLog("Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)changeTitleAction:(NSString *)title {
    [self repalceRecord:1 string:title];
}

- (void)changeNoteAction:(NSString *)note {
    [self repalceRecord:2 string:note];
}

- (void)touchedDeleteButton:(NSString *)title isInView:(BOOL)flag {
    DLog(@"%d", flag);
    if (flag) {
        NSString *titleString = nil;
        if (title && title.length > 0) {
            titleString = [NSString stringWithFormat:@"Delete “%@”", title];
        } else {
            titleString = [NSString stringWithFormat:@"Delete"];
        }
        UIActionSheet *myActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:titleString otherButtonTitles:nil, nil];
        [myActionSheet showInView:self.view];
    } else {
        [self deleteAnRecord];
    }
}

- (void)touchedShareButton:(NSString *)title {
    NSArray *activityItems;
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
    if (record) {
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@.m4a", NSHomeDirectory(), record.path];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSString *newFilePath = [NSString stringWithFormat:@"%@/Documents/voice.m4a", NSHomeDirectory()];
        NSData *audioData = [NSData dataWithContentsOfFile:newFilePath options:0 error:&error];
        if (audioData) {
            [fm removeItemAtPath:newFilePath error:&error];
            DLog(@"error: %@", error);
        }
        [fm copyItemAtPath:filePath toPath:newFilePath error:&error];
        NSURL *fileURL = [NSURL fileURLWithPath:newFilePath];
        if (fileURL) {
            activityItems = @[title, fileURL];
        } else {
            activityItems = @[title];
        }
    } else {
        activityItems = @[title];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [activityViewController setValue:title forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[
                                                     UIActivityTypePostToFacebook,
                                                     UIActivityTypePostToTwitter,
                                                     UIActivityTypePostToWeibo,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypeAssignToContact];
    [activityViewController setCompletionHandler:^(NSString *act, BOOL done) {
        DLog(@"%@ %d", act, done);
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/voice.m4a", NSHomeDirectory()];
        if ([fm fileExistsAtPath:filePath]) {
            [fm removeItemAtPath:filePath error:&error];
            DLog(@"error: %@", error);
        }
    }];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    static UIActivityViewController *shareController;
    static int itemNo;
    if (shareController == activityViewController && itemNo < numberOfSharedItems - 1) {
        itemNo++;
    } else {
        itemNo = 0;
        shareController = activityViewController;
    }
    
    switch (itemNo) {
        case 0: return @""; // intro in email
        case 1: return @""; // email text
        case 2: return [NSURL new]; // link
        case 3: return [UIImage new]; // picture
        case 4: return @""; // extra text (via in twitter, signature in email)
        default: return nil;
    }
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    static UIActivityViewController *shareController;
    static int itemNo;
    if (shareController == activityViewController && itemNo < numberOfSharedItems - 1) {
        itemNo++;
    } else {
        itemNo = 0;
        shareController = activityViewController;
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/audio.m4a", NSHomeDirectory()];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        switch (itemNo) {
            case 0: return @"Hi!\r\n\r\nI used a iPhone App SpeakOut\r\n";
            case 1: return shareText;
            case 2: return fileURL;
            case 3: return nil;
            case 4: return [@"\r\nCheck it out.\r\n\r\nCheers\r\n" stringByAppendingString:@"test"];
            default: return nil;
        }
    } else if ([activityType isEqualToString:UIActivityTypeMessage]) {
        switch (itemNo) {
            case 0: return nil;
            case 1: return shareText;
            case 2: return fileURL;
            case 3: return nil;
            case 4: return nil;
            default: return nil;
        }
    } else {
        switch (itemNo) {
            case 0: return nil;
            case 1: return shareText;
            case 2: return shareURL;
            case 3: return nil;
            case 4: return nil;
            default: return nil;
        }
    }
}

- (void)deleteAnRecord {
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
    if (record) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@.m4a", NSHomeDirectory(), record.path];
        [fm removeItemAtPath:filePath error:&error];
        DLog(@"delete a file %@, error: %@", filePath, error);
        [appDelegate.managedObjectContext deleteObject:record];
        if ([appDelegate.managedObjectContext hasChanges]) {
            if (![appDelegate.managedObjectContext save:&error]) {
                DLog("Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        //        DLog(@"%d", buttonIndex);
        if (audioPlayer) {
            [audioPlayer stop];
            [audioPlayer prepareToPlay];
            audioPlayer = nil;
            filePathString = nil;
        }
        [self deleteAnRecord];
    }
}

// called after fetched results controller received a content change notification
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    //    NSInteger numberOfRows = 0;
    //    NSInteger flag = 0;
    //    if ([[self.fetchedResultsController sections] count] > 0) {
    //        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    //        numberOfRows = [sectionInfo numberOfObjects];
    //        if (numberOfRows > originalRows) {
    //            flag = 1;
    //        }
    //    }
    [searchTableView reloadData];
    //    if (flag == 1) {
    //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //        [mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    //    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = segue.destinationViewController;
    if ([sender isEqualToString:@"pushToMonth"]) {
        if ([viewController respondsToSelector:@selector(setDateTag:)]) {
            [viewController setValue:[NSNumber numberWithInteger:tagSelected] forKey:@"dateTag"];
        }
        self.title = [NSString stringWithFormat:@"%ld", (long)tagSelected / 1000];
    }
    if ([sender isEqualToString:@"pushToDetail"]) {
        Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        if (record) {
            [self loadAudioFile:record.path];
            if ([viewController respondsToSelector:@selector(setRecord:)]) {
                [viewController setValue:record forKey:@"record"];
            }
        }
        if (audioPlayer) {
            if ([viewController respondsToSelector:@selector(setAudioPlayer:)]) {
                [viewController setValue:audioPlayer forKey:@"audioPlayer"];
            }
        }
        if ([viewController respondsToSelector:@selector(setDelegate:)]) {
            [viewController setValue:self forKey:@"delegate"];
        }
    }
}

@end
