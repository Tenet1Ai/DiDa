//
//  RightViewController.h
//  DiDa
//
//  Created by Bruce Yee on 10/18/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "VoiceWaveView.h"
#import <FDWaveformView.h>
#import "AppDelegate.h"

@interface RightViewController : UIViewController <VoiceWaveViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate> {
    __weak IBOutlet UIImageView *micImageView;
    __weak IBOutlet UIButton *playPauseButton;
    __weak IBOutlet UIButton *recButton;
    __weak IBOutlet UIButton *doneButton;
    __weak IBOutlet UIView *recView;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet NSLayoutConstraint *topLayoutConstraint;
    __weak IBOutlet FDWaveformView *waveForm;
    NSTimer *timer;
    float recordTime;
    NSString *promptString;
    NSString *recordFilePath;
    NSURL *audioURL;
    AVAudioPlayer *audioPlayer;
    AppDelegate *appDelegate;
}

@property (nonatomic, retain) VoiceWaveView *voiceWaveView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLGeocoder *localGeocoder;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *unit;

@end
