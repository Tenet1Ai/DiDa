//
//  VoiceWaveView.h
//  DiDa
//
//  Created by Bruce Yee on 10/18/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define HUD_SIZE 300
#define SOUND_METER_COUNT 100
#define WAVE_UPDATE_FREQUENCY 0.05
#define RECORD_MAX_TIME 20.0

@class VoiceWaveView;

@protocol VoiceWaveViewDelegate <NSObject>

@optional

- (void)VoiceWaveView:(VoiceWaveView *)voiceHUD voiceRecorded:(NSString *)recordPath length:(float)recordLength;
- (void)voiceRecordCancelledByUser:(VoiceWaveView *)voiceWaveView;

@end

@interface VoiceWaveView : UIView <AVAudioRecorderDelegate> {
    int soundMeters[SOUND_METER_COUNT];
    CGRect hudRect;
    
    NSDictionary *recordSettings;
	NSString *recorderFilePath;
	AVAudioRecorder *recorder;
	
	SystemSoundID soundID;
	NSTimer *timer;

    float recordTime;
    BOOL isRecording;
    UIImage *recordImage;
}

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, copy) NSString *recorderFilePath;
@property (nonatomic, assign) float recordTime;

- (void)startForFilePath:(NSString *)filePath;
- (void)cancelRecording;
- (void)commitRecording;
- (void)removeVoiceWave;

@property (nonatomic, assign) id<VoiceWaveViewDelegate> delegate;

@end
