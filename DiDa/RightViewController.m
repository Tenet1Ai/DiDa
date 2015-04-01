//
//  RightViewController.m
//  DiDa
//
//  Created by Bruce Yee on 10/18/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "RightViewController.h"
#import <UIViewController+MMDrawerController.h>
#import "FileSHA1Hash.h"
#import "Record.h"
#import "AppDelegate.h"
#import <FDWaveformView.h>

#define TagAlertLocation 1001
#define TagAlertSave 1002
#define TagAlertDelete 1003

@interface RightViewController () <FDWaveformViewDelegate, AVAudioPlayerDelegate>

@property (strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *hashString;

@end

@implementation RightViewController

static double a = 6378245.0;
static double ee = 0.00669342162296594323;

- (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc {
    CLLocationCoordinate2D adjustLoc;
    if ([self isLocationOutOfChina:wgsLoc]) {
        adjustLoc = wgsLoc;
    } else {
        double adjustLat = [self transformLatWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        double adjustLon = [self transformLonWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
        double radLat = wgsLoc.latitude / 180.0 * M_PI;
        double magic = sin(radLat);
        magic = 1 - ee * magic * magic;
        double sqrtMagic = sqrt(magic);
        adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
        adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
        adjustLoc.latitude = wgsLoc.latitude + adjustLat;
        adjustLoc.longitude = wgsLoc.longitude + adjustLon;
    }
    return adjustLoc;
}

- (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location {
    if (location.longitude < 72.004 || location.longitude > 137.8347
        || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

- (double)transformLatWithX:(double)x withY:(double)y {
    double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    lat += (20.0 * sin(6.0 * x * M_PI) + 20.0 *sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    lat += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    lat += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return lat;
}

- (double)transformLonWithX:(double)x withY:(double)y {
    double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    lon += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    lon += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    lon += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return lon;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([UIDevice iOSVersion] < 7.0f) {
        topLayoutConstraint.constant = 33;
    } else {
        topLayoutConstraint.constant = 55;
        if ([UIDevice isRunningIniPhone5]) {
            DLog(@"This device is Running In iPhone5/5s/6/6+");
            topLayoutConstraint.constant = 88;
        }
    }

    playPauseButton.layer.cornerRadius = 20.0f;
    playPauseButton.layer.borderWidth = 2;
    playPauseButton.layer.borderColor = [[UIColor colorWithRed:219.f/255.0
                                                         green:219.f/255.0 blue:219.f/255.0 alpha:0.7] CGColor];
    playPauseButton.layer.shadowOffset = CGSizeMake(2, 2);
    playPauseButton.layer.shadowColor = [[UIColor grayColor] CGColor];
    playPauseButton.layer.shadowOpacity = 0.80;
    playPauseButton.layer.shadowRadius = 4;

    doneButton.layer.cornerRadius = 5.0f;
    doneButton.layer.shadowOffset = CGSizeMake(2, 2);
    doneButton.layer.shadowColor = [[UIColor grayColor] CGColor];
    doneButton.layer.shadowOpacity = 0.80;
    doneButton.layer.shadowRadius = 4;
    
    recButton.selected = NO;
    doneButton.hidden = YES;
    micImageView.hidden = NO;
    playPauseButton.hidden = YES;

//    UIImage *img = [UIImage imageNamed:@"back.png"];
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:img]];

    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    } else {
        DLog(@"Location Services not Enabled");
    }
    self.latitude = 0.0;
    self.longitude = 0.0;
    self.location = nil;

    // Creating context in main function here make sure the context is tied to current thread.
    // init: use thread confine model to make things simpler.
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    promptString = nil;
    
    if (self.voiceWaveView) {
        [self.voiceWaveView removeVoiceWave];
        [self.voiceWaveView removeFromSuperview];
        self.voiceWaveView = nil;
    }
    self.voiceWaveView = [[VoiceWaveView alloc] initWithFrame:CGRectMake(0,
                                                                         recView.frame.origin.y - HUD_SIZE / 2 + 30, 320, HUD_SIZE)];
    [self.voiceWaveView setDelegate:self];
    [self.view addSubview:self.voiceWaveView];
    
    waveForm.delegate = self;
    waveForm.alpha = 0.0f;
    waveForm.progressSamples = 10000;
    waveForm.doesAllowScrubbing = YES;
    waveForm.doesAllowStretch = YES;
    waveForm.doesAllowScroll = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
#ifdef __IPHONE_8_0
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code < kCLAuthorizationStatusAuthorizedAlways) {
        if (code == kCLAuthorizationStatusNotDetermined) {
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]
                || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                // choose one request according to your business.
                if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                    [self.locationManager requestWhenInUseAuthorization];
                } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]) {
                    [self.locationManager requestAlwaysAuthorization];
                } else {
                    DLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
                }
            }
        } else {
            DLog(@"%ld", (unsigned long)code);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Turn On Location Services to "
                                      "Allow DiDa to Determine Your Location" message:nil
                                                               delegate:self cancelButtonTitle:@"Settings" otherButtonTitles:@"Cancel", nil];
            alertView.tag = TagAlertLocation;
            [alertView show];
        }
    }
#endif
    
    [self.locationManager startUpdatingLocation];
    self.localGeocoder = [[CLGeocoder alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    DLog(@"viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)waveformViewDidRender:(FDWaveformView *)waveformView {
    DLog(@"FDWaveformView rendering done");
    [UIView animateWithDuration:0.25f animations:^{
        waveformView.alpha = 1.0f;
        playPauseButton.hidden = NO;
        micImageView.hidden = YES;
        timeLabel.hidden = YES;
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
        DLog(@"new alloc");
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations lastObject];
    CLLocationCoordinate2D coordinate2D = currentLocation.coordinate;
    DLog(@"%@", currentLocation);
    if ([self isLocationOutOfChina:coordinate2D] == NO) {
        DLog(@"This device is in China.")
        CLLocationCoordinate2D newCoordinate2D = [self transformFromWGSToGCJ:coordinate2D];
        self.latitude = newCoordinate2D.latitude;
        self.longitude = newCoordinate2D.longitude;
        currentLocation = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    } else {
        self.latitude = coordinate2D.latitude;
        self.longitude = coordinate2D.longitude;
    }

    [self.localGeocoder reverseGeocodeLocation:currentLocation
                             completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil &&[placemarks count] > 0){
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSArray *formattedAddressLines = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
            DLog(@"%@ %@ %@", currentLocation, placemark.name, placemark.addressDictionary);
            if (placemark.subLocality && placemark.subLocality.length > 0) {
                self.unit = placemark.subLocality;
            } else if (placemark.thoroughfare && placemark.thoroughfare.length > 0) {
                self.unit = placemark.thoroughfare;
            } else if (placemark.name && (placemark.name.length > 0)) {
                self.unit = placemark.name;
            } else {
                self.unit = [formattedAddressLines objectAtIndex:0];
            }
            self.location = [formattedAddressLines componentsJoinedByString:@", "];
        } else if (error == nil && [placemarks count] == 0) {
            DLog(@"No results were returned.");
        } else if (error != nil) {
            DLog(@"An error occurred: %@", error);
        }
    }];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        self.longitude = 0.0;
        self.latitude = 0.0;
        self.unit = nil;
        self.location = nil;
    }
}

- (IBAction)touchRecButton:(id)sender {
    [self.locationManager startUpdatingLocation];
    if (recButton.selected == NO) {
        AudioSessionInitialize(NULL, NULL,nil,(__bridge  void *)(self));
        UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                sizeof(sessionCategory),
                                &sessionCategory
                                );
        AudioSessionSetActive(true);
        
        waveForm.alpha = 0.0f;
        playPauseButton.hidden = YES;
        micImageView.hidden = NO;
        timeLabel.hidden = NO;
        
        doneButton.hidden = YES;
        recButton.selected = YES;
        [self.voiceWaveView startForFilePath:[NSString stringWithFormat:@"%@/Documents/MySound.m4a", NSHomeDirectory()]];
        recordTime = 0.0f;
        timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY
                                                 target:self selector:@selector(refreshTimeLabel) userInfo:nil repeats:YES];
    } else {
        recButton.selected = NO;
        [self.voiceWaveView commitRecording];
        if (self.voiceWaveView.isRecording == NO) {
            doneButton.hidden = NO;
        }
        [timer invalidate];
        timer = nil;
        waveForm.audioURL = audioURL;
    }
}

- (void)refreshProgress {
    if ([audioPlayer isPlaying]) {
        NSTimeInterval progress = audioPlayer.currentTime / audioPlayer.duration;
        waveForm.progressSamples = progress * waveForm.totalSamples;
    } else {
        [timer invalidate];
        timer = nil;
    }
}

- (IBAction)tapPlayButton:(id)sender {
    if (playPauseButton.selected == NO) {
        if (audioPlayer) {
            if (![audioPlayer isPlaying]) {
                [audioPlayer play];
                playPauseButton.selected = YES;
                timer = [NSTimer scheduledTimerWithTimeInterval:.1f
                                                         target:self selector:@selector(refreshProgress) userInfo:nil repeats:YES];
            }
        }
    } else {
        if (audioPlayer) {
            if ([audioPlayer isPlaying]) {
                [audioPlayer pause];
                playPauseButton.selected = NO;
            }
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    playPauseButton.selected = NO;
    [audioPlayer stop];
    [audioPlayer prepareToPlay];
}

- (IBAction)touchBackButton:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (IBAction)touchDoneButton:(id)sender {
//    NSString *executablePath = [[NSBundle mainBundle] executablePath];
//    DLog(@"executablePath: %@", executablePath);
    NSString *filePath = self.voiceWaveView.recorderFilePath;
    if (filePath != nil) {
        CFStringRef executableFileSHA1Hash =
        FileSHA1HashCreateWithPath((__bridge CFStringRef)filePath,
                                   FileHashDefaultChunkSizeForReadingData);
        if (executableFileSHA1Hash) {
            NSString *hashString = (__bridge NSString *)executableFileSHA1Hash;
            DLog(@"sha1 string: %@ length: %lu", hashString, (unsigned long)hashString.length);
            if (hashString.length > 0) {
                NSString *destFilePath = [NSString stringWithFormat:@"%@/Documents/%@.m4a", NSHomeDirectory(), hashString];
                DLog(@"new file path: %@", destFilePath);
                NSFileManager *fm = [NSFileManager defaultManager];
                NSError *error = nil;
                if ([fm moveItemAtPath:filePath toPath:destFilePath error:&error] == YES) {
                    DLog(@"error: %@", error);
                    error = nil;
                    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:destFilePath error:&error];
                    NSDate *creationDate = [fileAttributes objectForKey:NSFileCreationDate];
                    NSTimeZone *timezone = [NSTimeZone systemTimeZone];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"YYYY-MM-d HH:mm:ss"];
                    [formatter setTimeZone:timezone];
                    self.creationDate = creationDate;
                    self.hashString = hashString;
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Save Memo", nil)
                                                                                                  message:nil delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"Delete", nil)
                                                              otherButtonTitles:NSLocalizedString(@"Save", nil), nil];

                    alertView.tag = TagAlertSave;
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                    promptString = [NSString stringWithFormat:@"New Voice %ld", (long)appDelegate.voiceIndex];
                    textField.text = promptString;
                    [alertView show];
                }
            }
            CFRelease(executableFileSHA1Hash);
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL doneRecording = NO;
    if (alertView.tag == TagAlertDelete) {
        if (buttonIndex == 0) {
            NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@.m4a", NSHomeDirectory(), self.hashString];
            NSLog(@"audio file path: %@", filePath);
            NSFileManager *fm = [NSFileManager defaultManager];
            NSError *error = nil;
            if ([fm fileExistsAtPath:filePath]) {
                [fm removeItemAtPath:filePath error:&error];
                DLog(@"error: %@", error);
            }
            [timer invalidate];
            timer = nil;
            recordTime = 0.0f;
            timeLabel.text = @"";
            doneButton.hidden = YES;
            playPauseButton.hidden = YES;
            waveForm.alpha = 0.0f;
            micImageView.hidden = NO;
            if (audioPlayer) {
                if ([audioPlayer isPlaying]) {
                    [audioPlayer stop];
                    [audioPlayer prepareToPlay];
                }
                audioPlayer = nil;
            }
        } else {
            doneRecording = YES;
        }
    } else if (alertView.tag == TagAlertLocation) {
        if (buttonIndex == 0) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    } else if (alertView.tag == TagAlertSave) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        promptString = textField.text;
        DLog(@"prompt: %@", promptString);
        if (buttonIndex == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Memo", nil)
                                                                message:NSLocalizedString(@"Are you sure you want to delete this memo?", nil)
                                                               delegate:self cancelButtonTitle:NSLocalizedString(@"Delete", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
            alertView.tag = TagAlertDelete;
            [alertView show];
        } else if (buttonIndex == 1) {
            if (audioPlayer) {
                if ([audioPlayer isPlaying]) {
                    [audioPlayer stop];
                    [audioPlayer prepareToPlay];
                }
                audioPlayer = nil;
            }
            doneRecording = YES;
        }
    }
    
    if (doneRecording == YES) {
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Record" inManagedObjectContext:self.managedObjectContext];
        // create an Record managed object, but don't insert it in our moc yet
        Record *record = [[Record alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
        record.date = self.creationDate;
        NSTimeZone *timezone = [NSTimeZone systemTimeZone];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-d HH:mm:ss"];
        [formatter setTimeZone:timezone];
        record.path = self.hashString;
        record.memo = promptString;
        DLog(@"%@ %ld", record.memo, (long)buttonIndex);
        record.length = [NSNumber numberWithFloat:self.voiceWaveView.recordTime];
        record.latitude = [NSNumber numberWithDouble:self.latitude];
        record.longitude = [NSNumber numberWithDouble:self.longitude];
        record.location = self.location;
        record.note = self.location;
        record.unit = self.unit;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = ent;
        
        // narrow the fetch to these two properties
        fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"date", nil];
        [fetchRequest setResultType:NSDictionaryResultType];
        
        NSError *error = nil;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date = %@", record.date];
        DLog("date = %@", record.date);
        
        NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (fetchedItems.count == 0) {
            [self.managedObjectContext insertObject:record];
        }
        
        if ([self.managedObjectContext hasChanges]) {
            if (![self.managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful
                // during development. If it is not possible to recover from the error, display an alert
                // panel that instructs the user to quit the application by pressing the Home button.
                //
                DLog("Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
    }
}

#pragma mark - VoiceWaveView Delegate

- (void)VoiceWaveView:(VoiceWaveView *)voiceWaveView voiceRecorded:(NSString *)recordPath length:(float)recordLength {
    DLog(@"Sound recorded with file %@ for %.5f seconds", [recordPath lastPathComponent], recordLength);
    recordFilePath = recordPath;
    audioURL = [NSURL fileURLWithPath:recordFilePath];
    recButton.selected = NO;
    doneButton.hidden = NO;
}

- (void)voiceRecordCancelledByUser:(VoiceWaveView *)voiceWaveView {
    DLog(@"Voice recording cancelled for HUD: %@", voiceWaveView);
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    long ti = (long)interval;
    double remain = (interval - ti) * 10;
    long decimal = (long)remain;
    long seconds = ti % 60;
    if (ti < 60) {
        return [NSString stringWithFormat:@"%li.%ld", seconds, decimal];
    }
    long minutes = (ti / 60) % 60;
    if (ti < 60 * 60) {
        return [NSString stringWithFormat:@"%li:%li.%ld", minutes, seconds, decimal];
    }
    long hours = (ti / 3600);
    return [NSString stringWithFormat:@"%li:%li:%li.%ld", hours, minutes, seconds, decimal];
}

- (void)refreshTimeLabel {
    recordTime += WAVE_UPDATE_FREQUENCY;
    NSString *timeString = [self stringFromTimeInterval:recordTime];
    timeLabel.text = timeString;
}

@end
