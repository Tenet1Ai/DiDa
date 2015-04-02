//
//  DetailViewController.m
//  DiDa
//
//  Created by Bruce Yee on 10/30/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "UIDevice+Resolutions.h"
#import "DetailViewController.h"
#import "MapAnnotation.h"
#import "AppDelegate.h"

@interface DetailViewController () <UIGestureRecognizerDelegate, MKMapViewDelegate, AVAudioPlayerDelegate>
@property (strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation DetailViewController
@synthesize record, audioPlayer, tag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    long ti = (long)interval;
    long seconds = ti % 60;
    if (ti < 60) {
        return [NSString stringWithFormat:@"0:%02li", seconds];
    }
    long minutes = (ti / 60) % 60;
    if (ti < 60 * 60) {
        return [NSString stringWithFormat:@"%02li:%02li", minutes, seconds];
    }
    long hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02li:%02li:%02li", hours, minutes, seconds];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DLog(@"%@", audioPlayer);
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            if ([audioPlayer isPlaying]) {
                playButton.selected = YES;
            } else {
                playButton.selected = NO;
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    willUpdateRecord = YES;
    DLog(@"record: %ld", (long)self.tag);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    DLog(@"viewWillDisappear: %d", willUpdateRecord);
    if (willUpdateRecord == YES) {
        [self updateMemo];
        [self updateNote];
    }
    willUpdateRecord = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    willUpdateRecord = NO;

    memoTextField.text = record.memo;
    locationTextView.text = record.note;

    playButton.selected = NO;
    UIImage *img = [UIImage imageNamed:@"mark"];
    [playSlider setThumbImage:img forState:UIControlStateNormal];

    audioPlayer.delegate = self;
    playSlider.minimumValue = 0.0;
    playSlider.maximumValue = audioPlayer.duration;
    playSlider.value = audioPlayer.currentTime;
    if (playSlider.value > 0.0) {
        playButton.selected = YES;
    } else {
        playButton.selected = NO;
    }
    NSString *endTimeString = [self stringFromTimeInterval:(audioPlayer.duration - audioPlayer.currentTime)];
    endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
    NSString *startTimeString = [self stringFromTimeInterval:audioPlayer.currentTime];
    startLabel.text = startTimeString;
    [playSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];

    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    [self.view addGestureRecognizer:tapRec];
    tapRec.delegate = self;
    
    mkMapView.delegate = self;
    mkMapView.mapType = MKMapTypeStandard;
    mkMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mkMapView.showsUserLocation = YES;
    CLLocationCoordinate2D location;
    location.latitude = [record.latitude doubleValue];
    location.longitude = [record.longitude doubleValue];
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.05;
    theSpan.longitudeDelta = 0.05;
    MKCoordinateRegion theRegion;
    theRegion.center = location;
    theRegion.span = theSpan;
    [mkMapView setRegion:theRegion];
    
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithCoordinates:location title:record.memo subTitle:record.location];
    annotation.pinColor = MKPinAnnotationColorPurple;
    [mkMapView addAnnotation:annotation];
    
    // Creating context in main function here make sure the context is tied to current thread.
    // init: use thread confine model to make things simpler.
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = self.sharedPSC;
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    session = [AVAudioSession sharedInstance];
    if ([UIDevice isRunningIniPhone4]) {
        startLabel.hidden = YES;
        endLabel.hidden = YES;
    } else {
        startLabel.hidden = NO;
        endLabel.hidden = NO;
    }
}

- (IBAction)sliderChanged:(id)sender {
    NSString *endTimeString = [self stringFromTimeInterval:(audioPlayer.duration - playSlider.value)];
    endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
    NSString *startTimeString = [self stringFromTimeInterval:playSlider.value];
    startLabel.text = startTimeString;
    if ([audioPlayer isPlaying]) {
        [audioPlayer stop];
        [audioPlayer setCurrentTime:playSlider.value];
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    } else {
        [audioPlayer setCurrentTime:playSlider.value];
        [audioPlayer prepareToPlay];
    }
}

- (void)updateSlider {
    if (audioPlayer) {
        if ([audioPlayer isPlaying]) {
            if (appDelegate.outputDevice == 0) {
                if (![session.category isEqualToString:AVAudioSessionCategoryPlayback]) {
                    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
                    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
                    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
                    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
                    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(audioRouteOverride), &audioRouteOverride);
#endif
                }
            } else {
                if (![session.category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
                    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
                    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
                    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
                    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
                    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(audioRouteOverride), &audioRouteOverride);
#endif
                }
            }
            
            // Updates the slider about the music time
            playSlider.value = audioPlayer.currentTime;
            NSString *endTimeString = [self stringFromTimeInterval:(audioPlayer.duration - audioPlayer.currentTime)];
            endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
            NSString *startTimeString = [self stringFromTimeInterval:audioPlayer.currentTime];
            startLabel.text = startTimeString;
            playButton.selected = YES;
        } else {
            [audioPlayer stop];
            [audioPlayer prepareToPlay];
            playButton.selected = NO;
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        playButton.selected = NO;
        [playSlider setValue:0.0];
        NSString *endTimeString = [self stringFromTimeInterval:audioPlayer.duration];
        endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
        startLabel.text = @"0:00";
    }
    [audioPlayer stop];
    [audioPlayer prepareToPlay];
}

//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
//    DLog(@"%@ %@", userLocation.title, userLocation.subtitle);
//    DLog(@"%@", [userLocation.location description]);
//    CLGeocoder *localGeocoder = [[CLGeocoder alloc] init];
//    [localGeocoder reverseGeocodeLocation:userLocation.location
//                        completionHandler:^(NSArray *placemarks, NSError *error) {
//        if (error == nil &&[placemarks count] > 0){
//            CLPlacemark *placemark = [placemarks objectAtIndex:0];
//            NSArray *formattedAddressLines = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
//            DLog(@"%@ %@", placemark.name, formattedAddressLines);
//            if (placemark.name && (placemark.name.length > 0)) {
////                self.unit = placemark.name;
//            } else {
////                self.unit = [formattedAddressLines objectAtIndex:0];
//            }
////            self.location = [formattedAddressLines componentsJoinedByString:@", "];
//        } else if (error == nil && [placemarks count] == 0) {
//            DLog(@"No results were returned.");
//        } else if (error != nil) {
//            DLog(@"An error occurred: %@", error);
//        }
//    }];
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *result = nil;
    if ([annotation isKindOfClass:[MapAnnotation class]] == NO) {
        return result;
    }
    if ([mapView isEqual:mkMapView] == NO) {
        return result;
    }

    MapAnnotation *senderAnnotation = (MapAnnotation *)annotation;

    NSString *pinReusableIdentifier =
    [MapAnnotation reusableIdentifierforPinColor:senderAnnotation.pinColor];
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)
    [mapView dequeueReusableAnnotationViewWithIdentifier:pinReusableIdentifier];
    
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:senderAnnotation reuseIdentifier:pinReusableIdentifier];
        [annotationView setCanShowCallout:YES];
    }
    annotationView.pinColor = senderAnnotation.pinColor;
    
    result = annotationView;
    return result;
}

- (void)resignViewResponder {
    [memoTextField resignFirstResponder];
    [locationTextView resignFirstResponder];
}

- (void)updateMemo {
    [memoTextField resignFirstResponder];
    DLog(@"1: %@ 2: %@", memoTextField.text, record.memo);
    if (![record.memo isEqualToString:memoTextField.text]) {
        [self.delegate changeTitleAction:self.tag title:memoTextField.text];
    }
}

- (void)updateNote {
    [locationTextView resignFirstResponder];
    DLog(@"1: %@ 2: %@", locationTextView.text, record.note);
    if (![record.location isEqualToString:locationTextView.text]) {
        [self.delegate changeNoteAction:self.tag text:locationTextView.text];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    DLog(@"%@", NSStringFromClass([touch.view class]));
    NSString *classString = NSStringFromClass([touch.view class]);
    if ([classString isEqualToString:@"UITextField"]
        || [classString isEqualToString:@"UITextView"]
        || [classString isEqualToString:@"MKNewAnnotationContainerView"]
        || [classString isEqualToString:@"MKPinAnnotationView"]) {
        [self resignViewResponder];
        return NO;
    } else if ([classString isEqualToString:@"UIButton"]) {
        return NO;
    } else {
        [self resignViewResponder];
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchPlayButton:(id)sender {
    if (playButton.selected == YES) {
        playButton.selected = NO;
        [audioPlayer pause];
    } else {
        playButton.selected = YES;
        [audioPlayer play];
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    }
}

- (IBAction)touchBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)touchDoneButton:(id)sender {
    [audioPlayer stop];
    [audioPlayer prepareToPlay];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    playButton.selected = NO;
    [playSlider setValue:0.0];
    NSString *endTimeString = [self stringFromTimeInterval:audioPlayer.duration];
    endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
    startLabel.text = @"0:00";
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)touchShareButton:(id)sender {
    NSString *titleString = nil;
    if (memoTextField.text && memoTextField.text.length > 0) {
        titleString = memoTextField.text;
    } else {
        titleString = @"Voice Memo";
    }
    [self.delegate touchedShareButton:self.tag title:titleString];
}

- (IBAction)touchDeleteButton:(id)sender {
    NSString *titleString = nil;
    if (memoTextField.text && memoTextField.text.length > 0) {
        titleString = [NSString stringWithFormat:NSLocalizedString(@"Delete “%@”", nil), memoTextField.text];
    } else {
        titleString = [NSString stringWithFormat:NSLocalizedString(@"Delete", nil)];
    }
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                destructiveButtonTitle:titleString otherButtonTitles:nil, nil];
    [myActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        //        DLog(@"%d", buttonIndex);
        if (audioPlayer) {
            [audioPlayer stop];
            [audioPlayer prepareToPlay];
            audioPlayer = nil;
        }
        willUpdateRecord = NO;
        [self.delegate touchedDeleteButton:self.tag title:record.memo isInView:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
