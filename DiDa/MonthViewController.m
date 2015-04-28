//
//  MonthViewController.m
//  DiDa
//
//  Created by Bruce Yee on 4/23/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import "MonthViewController.h"
#import "NSDate+FSExtension.h"
#import "INOOperationQueue.h"
#import "AppDelegate.h"
#import "Record.h"
#import "PlayTableViewCell.h"
#import "RecordTableViewCell.h"
#import "DetailViewController.h"
#import "UIView+Borders.h"

#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]
#define kBlue [UIColor colorWithRed:31/255.0 green:119/255.0 blue:219/255.0 alpha:1.0]
#define kBlueText [UIColor colorWithRed:14/255.0 green:69/255.0 blue:221/255.0 alpha:1.0]

@interface MonthViewController () <FSCalendarDataSource, FSCalendarDelegate,
UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate,
AVAudioPlayerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation MonthViewController
@synthesize dateTag;

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Record"
                                                  inManagedObjectContext:appDelegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSDate *fromDate = nil;
        NSDate *toDate = nil;
        if (daySelected == NO) {
            fromDate = [selectedDate beginningOfMonth];
            toDate = [selectedDate endOfMonth];
        } else {
            fromDate = [selectedDate beginningOfDay];
            toDate = [selectedDate endOfDay];
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date <= %@", fromDate, toDate];
        [fetchRequest setPredicate:predicate];
        
        BOOL flag = NO;
        if (appDelegate.dataSort == 0) {
            flag = NO;
        } else {
            flag = YES;
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:flag];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:appDelegate.managedObjectContext
                                              sectionNameKeyPath:nil
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *firstItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self action:@selector(goToRecorder)];
    UIBarButtonItem *secondItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"burger"]
                                                                   style:UIBarButtonItemStyleBordered target:self action:@selector(goToWeek)];
    NSArray *itemsArray = @[firstItem, secondItem];
    self.navigationItem.rightBarButtonItems = itemsArray;
    
    [bottomView addTopBorderWithHeight:1.f andColor:[UIColor lightGrayColor]];
    
    daySelected = NO;
    NSInteger year = dateTag / 1000;
    NSInteger month = dateTag - year * 1000;
    NSString *dateString;
    if (month < 10) {
        dateString = [NSString stringWithFormat:@"%ld0%ld", (long)year, (long)month];
    } else {
        dateString = [NSString stringWithFormat:@"%ld%ld", (long)year, (long)month];
    }
    selectedDate = [NSDate fs_dateFromString:dateString format:@"yyyyMM"];
    NSString *monthString = [selectedDate fs_stringWithFormat:@"MMMM yyyy"];
    self.navigationItem.title = monthString;
    DLog(@"choosed date: %@", selectedDate);
    monthCalendar.flow = FSCalendarFlowVertical;
    [monthCalendar setWeekdayTextColor:kBlueText];
    [monthCalendar setHeaderTitleColor:kBlueText];
    [monthCalendar setEventColor:[kBlueText colorWithAlphaComponent:0.75]];
    [monthCalendar setSelectionColor:kBlue];
    [monthCalendar setHeaderDateFormat:@"MMMM yyyy"];
    [monthCalendar setMinDissolvedAlpha:0.2];
    [monthCalendar setTodayColor:kPink];
    [monthCalendar setCellStyle:FSCalendarCellStyleCircle];
    [monthCalendar setCurrentMonth:selectedDate];

    selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [mainTableView addGestureRecognizer:tapRec];
    tapRec.delegate = self;
    
    numberOfSharedItems = 5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [monthCalendar reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)goToWeek {
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            [audioPlayer pause];
        }
        [audioPlayer stop];
        [audioPlayer prepareToPlay];
    }
    [self performSegueWithIdentifier:@"pushToWeek" sender:@"pushToWeek"];
}

- (void)goToRecorder {
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            [audioPlayer pause];
        }
        [audioPlayer stop];
        [audioPlayer prepareToPlay];
    }
    [self performSegueWithIdentifier:@"pushToRec" sender:@"pushToRec"];
}

- (BOOL)calendar:(FSCalendar *)calendarView hasEventForDate:(NSDate *)date {
    NSArray *objectsArray = [self.fetchedResultsController fetchedObjects];
    for (Record *record in objectsArray) {
        if ([record.date fs_isEqualToDateForDay:date]) {
            return YES;
        }
    }
    return NO;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    daySelected = YES;
    selectedDate = date;
    _fetchedResultsController = nil;
    [mainTableView reloadData];
    UIBarButtonItem* newItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self action:@selector(goToRecorder)];
    self.navigationItem.rightBarButtonItem = newItem;
}

- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar {
    NSDate *date = calendar.currentMonth;
    NSString *monthString = [date fs_stringWithFormat:@"MMMM yyyy"];
    self.navigationItem.title = monthString;
    daySelected = NO;
    selectedDate = date;
    _fetchedResultsController = nil;
    [mainTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapSettingsButton:(id)sender {
    [self performSegueWithIdentifier:@"pushToSettings" sender:@"pushToSettings"];
}

- (IBAction)tapMemosButton:(id)sender {
    [self performSegueWithIdentifier:@"pushToList" sender:@"pushToList"];
}

- (IBAction)tapTodayButton:(id)sender {
    [monthCalendar setSelectedDate:[NSDate date]];
}

#pragma mark - common functions

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //    DLog(@"%@", NSStringFromClass([touch.view class]));
    NSString *classString = NSStringFromClass([touch.view class]);
    if ([classString isEqualToString:@"UITableViewCellContentView"]
        || [classString isEqualToString:@"UIButton"]
        || [classString isEqualToString:@"UISlider"]
        || [classString isEqualToString:@"UITableViewCellDeleteConfirmationButton"]
        || [classString isEqualToString:@"UITableViewCellContentView"]
        || [classString isEqualToString:@"_UITableViewCellActionButton"]) {
        return NO;
    } else {
        selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
        [mainTableView reloadData];
        return YES;
    }
}

- (void)loadAudioFile:(NSString *)pathString {
    if (![filePathString isEqualToString:pathString]) {
        if (audioPlayer) {
            [audioPlayer stop];
            [audioPlayer prepareToPlay];
            audioPlayer = nil;
            currentTime = 0.0;
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

- (NSTimeInterval)getCurrentTimeOfPlayer {
    if (audioPlayer) {
        return audioPlayer.currentTime;
    }
    return 0.0;
}

- (void)setCurrentTimeOfPlayer:(NSTimeInterval)time {
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            [audioPlayer stop];
            [audioPlayer setCurrentTime:time];
            [audioPlayer prepareToPlay];
            [audioPlayer play];
        } else {
            [audioPlayer setCurrentTime:time];
            [audioPlayer prepareToPlay];
        }
    } else {
        currentTime = time;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        currentTime = 0.0;
    }
    [audioPlayer stop];
    [audioPlayer prepareToPlay];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == selectedIndexPath.row && indexPath.section == selectedIndexPath.section) {
        return 144;
    }
    return 49;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    if (numberOfRows == 0) {
        selectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    }
    originalRows = numberOfRows;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == selectedIndexPath.row && indexPath.section == selectedIndexPath.section) {
        static NSString *kPlayCellID = @"PlayCellID";
        PlayTableViewCell *cell = (PlayTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kPlayCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        // Configure the cell...
        [cell configureWithRecord:record];
        cell.delegate = self;
        cell.tag = indexPath.row;
        return cell;
    } else {
        static NSString *kRecordCellID = @"RecordCellID";
        RecordTableViewCell *cell = (RecordTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kRecordCellID];
        Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        // Configure the cell...
        [cell configureWithRecord:record];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedIndexPath.row == indexPath.row && selectedIndexPath.section == indexPath.section) {
        return;
    }
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            [audioPlayer stop];
            [audioPlayer prepareToPlay];
        }
        currentTime = 0.0;
    }
    
    NSIndexPath *origIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row
                                                    inSection:selectedIndexPath.section];
    NSArray *indexPaths = nil;
    if (selectedIndexPath.row == -1) {
        indexPaths = [NSArray arrayWithObjects:indexPath, nil];
    } else {
        indexPaths = [NSArray arrayWithObjects:indexPath, origIndexPath, nil];
    }
    selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [appDelegate setMemoInfo:record];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row == selectedIndexPath.row && indexPath.section == selectedIndexPath.section) {
        return NO;
    }
    return YES;
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleNone;
//}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        NSString *memoString = record.memo;
        NSString *titleString = nil;
        if (memoString && memoString.length > 0) {
            titleString = [NSString stringWithFormat:@"Delete “%@”", memoString];
        } else {
            titleString = [NSString stringWithFormat:@"Delete"];
        }
        UIActionSheet *myActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:titleString otherButtonTitles:nil, nil];
        [myActionSheet showInView:self.view];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)touchedPlayButton:(NSString *)pathString sender:(id)sender {
    UIButton *playButton = (UIButton *)sender;
    if (playButton.selected == NO) {
        if (appDelegate.audioPlayer) {
            [appDelegate.audioPlayer stop];
            appDelegate.audioPlayer = nil;
        }
        [self loadAudioFile:pathString];
        if ((currentTime > 0.0) && (currentTime < audioPlayer.duration)) {
            [audioPlayer setCurrentTime:currentTime];
        }
        [audioPlayer play];
    } else {
        [audioPlayer stop];
    }
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
            currentTime = 0.0;
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
    [mainTableView reloadData];
//    if (flag == 1) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        [mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *viewController = segue.destinationViewController;
    if ([sender isEqualToString:@"pushToRec"]) {
        if ([viewController respondsToSelector:@selector(setSelectedDate:)]) {
            if (daySelected == YES) {
                [viewController setValue:selectedDate forKey:@"selectedDate"];
            } else {
                [viewController setValue:nil forKey:@"selectedDate"];
            }
        }
    }
    if ([sender isEqualToString:@"pushToWeek"]) {
        [viewController setValue:selectedDate forKey:@"selectedDate"];
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
