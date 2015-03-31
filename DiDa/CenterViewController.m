//
//  CenterViewController.m
//  DiDa
//
//  Created by Bruce Yee on 10/18/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "CenterViewController.h"
#import "RecordTableViewCell.h"
#import "PlayTableViewCell.h"
#import "VisualStateManager.h"
#import <UIViewController+MMDrawerController.h>
#import "AboutViewController.h"
#import "PasscodeViewController.h"
#import "NavigationController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "DetailViewController.h"
#import "Record.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AppDelegate.h"

@interface CenterViewController () <NSFetchedResultsControllerDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) UIBarButtonItem *activityIndicator;

@end

@implementation CenterViewController
@synthesize audioPlayer;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self setRestorationIdentifier:@"CenterControllerRestorationKey"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog("Path: %@", [self applicationDocumentsDirectory]);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"didamemos.png"]];
//    self.navigationItem.titleView = imageView;
    
    originalRows = 0;
    selectedRow = -1;
    tagSelected = -1;
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.voiceIndex = 0;
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [self.tableView addGestureRecognizer:tapRec];
    tapRec.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAbout)
                                                 name:@"showAboutViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPasscode)
                                                 name:@"showPasscodeViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableData)
                                                 name:@"refreshTableData" object:nil];
    currentTime = 0.0;
    filePathString = nil;
    audioPlayer = nil;
    DLog(@"");
}

- (void)refreshTableData {
    DLog(@"");
    _fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (void)showAbout {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                             target:self selector:@selector(showAboutViewController) userInfo:nil repeats:NO];
}

- (void)showPasscode {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                             target:self selector:@selector(showPasscodeViewController) userInfo:nil repeats:NO];
}

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
        selectedRow = -1;
        tagSelected = -1;
        DLog(@"");
        [self.tableView reloadData];
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAboutViewController {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    AboutViewController *aboutViewController = [storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    UINavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:aboutViewController];
    [self.mm_drawerController setRightDrawerViewController:navigationController];
    [self.mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)showPasscodeViewController {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    PasscodeViewController *aboutViewController = [storyboard instantiateViewControllerWithIdentifier:@"PasscodeViewController"];
    UINavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:aboutViewController];
    [self.mm_drawerController setRightDrawerViewController:navigationController];
    [self.mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (IBAction)touchMenuButton:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)touchAddButton:(id)sender {
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            [audioPlayer pause];
        }
        [audioPlayer stop];
        [audioPlayer prepareToPlay];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    RightViewController *rightUIViewController = [storyboard instantiateViewControllerWithIdentifier:@"RightViewController"];
    rightUIViewController.sharedPSC = self.persistentStoreCoordinator;
    UINavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:rightUIViewController];
    [self.mm_drawerController setRightDrawerViewController:navigationController];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

#pragma mark - Player Control

- (void)switchAudioSessionCategory {
//    DLog(@"min: %d", __IPHONE_OS_VERSION_MIN_REQUIRED);
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (appDelegate.outputDevice == 0) {
        if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayback]) {
            DLog(@"__IPHONE_OS_VERSION_MIN_REQUIRED");
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(audioRouteOverride), &audioRouteOverride);
#endif
        }
    } else {
        if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
            DLog(@"");
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(audioRouteOverride), &audioRouteOverride);
#endif
        }
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
        DLog(@"new alloc");
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
        filePathString = pathString;
    }
}

- (BOOL)isPlaying {
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            [self switchAudioSessionCategory];
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

- (void)touchedPlayButton:(NSInteger)tag path:(NSString *)pathString sender:(id)sender {
    UIButton *playButton = (UIButton *)sender;
    if (playButton.selected == NO) {
        [self loadAudioFile:pathString];
        if ((currentTime > 0.0) && (currentTime < audioPlayer.duration)) {
            [audioPlayer setCurrentTime:currentTime];
        }
        [audioPlayer play];
    } else {
        [audioPlayer stop];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        currentTime = 0.0;
    }
    [audioPlayer stop];
    [audioPlayer prepareToPlay];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == selectedRow) {
        return 144;
    }
    return 49;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
//    DLog(@"");
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
        selectedRow = -1;
        tagSelected = -1;
    }
    appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.voiceIndex = numberOfRows + 1;
    originalRows = numberOfRows;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == selectedRow) {
        DLog(@"");
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
    if (selectedRow == indexPath.row) {
        return;
    }
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            [audioPlayer stop];
            [audioPlayer prepareToPlay];
        }
        currentTime = 0.0;
    }

    NSIndexPath *origIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, origIndexPath, nil];
    selectedRow = indexPath.row;
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row == selectedRow) {
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
        DLog(@"%ld", (long)indexPath.row);
        tagSelected = indexPath.row;
        Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
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

- (void)touchedDetailButton:(NSInteger)tag title:(NSString *)title {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    DetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if (record) {
        detailViewController.record = record;
    }
    [self loadAudioFile:record.path];
    detailViewController.delegate = self;
    detailViewController.tag = tag;
    detailViewController.sharedPSC = self.persistentStoreCoordinator;
    detailViewController.audioPlayer = self.audioPlayer;
    UINavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:detailViewController];
    [self.mm_drawerController setRightDrawerViewController:navigationController];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

//@property (nonatomic, retain) NSDate * date;
//@property (nonatomic, retain) NSNumber * latitude;
//@property (nonatomic, retain) NSNumber * length;
//@property (nonatomic, retain) NSString * location;
//@property (nonatomic, retain) NSNumber * longitude;
//@property (nonatomic, retain) NSString * memo;
//@property (nonatomic, retain) NSString * path;
//@property (nonatomic, retain) NSString * unit;

- (void)changeTitleAction:(NSInteger)tag title:(NSString *)title {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Record" inManagedObjectContext:self.managedObjectContext];
    // create an earthquake managed object, but don't insert it in our moc yet
    Record *newRecord = [[Record alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
    newRecord.memo = title;
    newRecord.date = record.date;
    newRecord.latitude = record.latitude;
    newRecord.length = record.length;
    newRecord.location = record.location;
    newRecord.note = record.note;
    newRecord.longitude = record.longitude;
    newRecord.path = record.path;
    newRecord.unit = record.unit;
    
    if (newRecord) {
        [self.managedObjectContext insertObject:newRecord];
    }
    if (record) {
        [self.managedObjectContext deleteObject:record];
    }

    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            DLog("Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)changeNoteAction:(NSInteger)tag text:(NSString *)locationText {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"Record" inManagedObjectContext:self.managedObjectContext];
    // create an earthquake managed object, but don't insert it in our moc yet
    Record *newRecord = [[Record alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
    newRecord.memo = record.memo;
    newRecord.date = record.date;
    newRecord.latitude = record.latitude;
    newRecord.length = record.length;
    newRecord.location = record.location;
    newRecord.note = locationText;
    newRecord.longitude = record.longitude;
    newRecord.path = record.path;
    newRecord.unit = record.unit;
    
    if (newRecord) {
        [self.managedObjectContext insertObject:newRecord];
    }
    if (record) {
        [self.managedObjectContext deleteObject:record];
    }
    
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            DLog("Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)touchedDeleteButton:(NSInteger)tag title:(NSString *)title isInView:(BOOL)flag {
    DLog(@"%d", flag);
    tagSelected = tag;
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        RightViewController *rightUIViewController = [storyboard instantiateViewControllerWithIdentifier:@"RightViewController"];
        rightUIViewController.sharedPSC = self.persistentStoreCoordinator;
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:rightUIViewController];
        [self.mm_drawerController setRightDrawerViewController:navigationController];
        [self.mm_drawerController closeDrawerAnimated:NO completion:nil];
    }
}

const int numberOfSharedItems = 5;

- (void)touchedShareButton:(NSInteger)tag title:(NSString *)title {
    DLog(@"%ld", (long)tag);
    NSArray *activityItems;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
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
            DLog(@"");
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
    //    DLog(@"");
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
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tagSelected inSection:0];
    tagSelected = -1;
    Record *record = (Record *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if (record) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@.m4a", NSHomeDirectory(), record.path];
        [fm removeItemAtPath:filePath error:&error];
        DLog(@"delete a file %@, error: %@", filePath, error);
        [self.managedObjectContext deleteObject:record];
        if ([self.managedObjectContext hasChanges]) {
            if (![self.managedObjectContext save:&error]) {
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
    selectedRow = -1;
    tagSelected = -1;
    NSInteger numberOfRows = 0;
    NSInteger flag = 0;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        numberOfRows = [sectionInfo numberOfObjects];
        if (numberOfRows > originalRows) {
//            DLog(@"");
            flag = 1;
        }
    }
    [self.tableView reloadData];
    if (flag == 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Record"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
    
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
                                            managedObjectContext:self.managedObjectContext
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
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
	
	return _fetchedResultsController;
}

#pragma mark - Core Data stack

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    // observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
//
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Records" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // find the Record data in our Documents folder
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Records.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    return _persistentStoreCoordinator;
}

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContext:(NSNotification *)notification {
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

@end
