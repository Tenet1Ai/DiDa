//
//  DetailViewController.h
//  DiDa
//
//  Created by Bruce Yee on 10/30/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TouchActionsDelegate.h"
#import "AppDelegate.h"

@interface DetailViewController : UIViewController <UIActionSheetDelegate> {
    __weak IBOutlet UITextField *memoTextField;
    __weak IBOutlet UITextView *locationTextView;
    __weak IBOutlet MKMapView *mkMapView;
    __weak IBOutlet UISlider *playSlider;
    __weak IBOutlet UIButton *playButton;
    __weak IBOutlet UILabel *startLabel;
    __weak IBOutlet UILabel *endLabel;
    Record *record;
    AVAudioPlayer *audioPlayer;
    NSTimer *timer;
    NSInteger tag;
    AVAudioSession *session;
    AppDelegate *appDelegate;
    BOOL willUpdateRecord;
}

@property (nonatomic, strong) Record *record;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) id<TouchActionsDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;
@property (strong) NSPersistentStoreCoordinator *sharedPSC;

@end
