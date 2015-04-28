//
//  VoiceWaveView.m
//  DiDa
//
//  Created by Bruce Yee on 10/18/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "VoiceWaveView.h"
#import "AppDelegate.h"

@implementation VoiceWaveView
@synthesize isRecording, recorderFilePath, recordTime;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        DLog(@"init a voice wave view...");
        self.contentMode = UIViewContentModeRedraw;
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.alpha = 0.0f;
        hudRect = CGRectMake(self.center.x - (HUD_SIZE / 2), self.center.y - (HUD_SIZE / 2), HUD_SIZE, HUD_SIZE);
        for(int i=0; i< SOUND_METER_COUNT; i++) {
            soundMeters[i] = 0;
        }
        isRecording = NO;
        recorderFilePath = nil;
        recordTime = 0.0;
    }
    return self;
}

- (void)dealloc {
    DLog(@"dealloc");
    [self removeVoiceWave];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    DLog(@"DidFinishRecording");
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void)startForFilePath:(NSString *)filePath {
    recordTime = 0.0;
    self.alpha = 1.0f;
    
    NSError *error = nil;
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    DLog(@"%@", audioSession.category);
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        DLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
	}
	[audioSession setActive:YES error:&error];
	error = nil;
	if (error){
        DLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
	}
    
    recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                      [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                      [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                      nil];
	
    DLog(@"Recording at: %@", filePath);
	recorderFilePath = filePath;
	
	NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
	
	error = nil;
	
	NSData *audioData = [NSData dataWithContentsOfFile:[url path] options:0 error:&error];
	if (audioData) {
		NSFileManager *fm = [NSFileManager defaultManager];
		[fm removeItemAtPath:[url path] error:&error];
        DLog(@"error: %@", error);
	}
	
	error = nil;
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    if (error) {
        DLog(@"Error occured during audio recorder initialization. Error code - %ld, description - \"%@\".",
              (long)[error code], [error localizedDescription]);
    }
    
	if(!recorder) {
        DLog(@"recorder: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: [error localizedDescription]
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [alert show];
        return;
	}
	
	[recorder setDelegate:self];
	[recorder prepareToRecord];
	recorder.meteringEnabled = YES;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setFileProtectionNone:filePath];
	
	BOOL audioHWAvailable = audioSession.inputAvailable;
	if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: @"Audio input hardware not available"
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
	}
	
//	[recorder recordForDuration:(NSTimeInterval)RECORD_MAX_TIME * 2];
    [recorder record];
    isRecording = [recorder isRecording];
    [self setNeedsDisplay];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    long ti = (long)interval;
    double remain = (interval - ti) * 10;
    long decimal = (long)remain;
    long seconds = ti % 60;
    if (ti < 60) {
        return [NSString stringWithFormat:@"0:%02li.%ld", seconds, decimal];
    }
    long minutes = (ti / 60) % 60;
    if (ti < 60 * 60) {
        return [NSString stringWithFormat:@"0:%02li:%02li.%ld", minutes, seconds, decimal];
    }
    long hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02li:%02li:%02li.%ld", hours, minutes, seconds, decimal];
}

- (void)updateMeters {
    [recorder updateMeters];
    
//    NSLog(@"meter:%5f", [recorder averagePowerForChannel:0]);
//    if (([recorder averagePowerForChannel:0] < -60.0) && (recordTime > 3.0)) {
//        [self commitRecording];
//        return;
//    }
    
//    if (recordTime > RECORD_MAX_TIME) {
//        [self commitRecording];
//        return;
//    }
    
    recordTime += WAVE_UPDATE_FREQUENCY;
    [self addSoundMeterItem:[recorder averagePowerForChannel:0]];
}

- (void)cancelRecording {
    if ([self.delegate respondsToSelector:@selector(voiceRecordCancelledByUser:)]) {
        [self.delegate voiceRecordCancelledByUser:self];
    }
    
    [recorder stop];
    isRecording = [recorder isRecording];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate switchAudioSessionCategory];
}

- (void)commitRecording {
    [recorder stop];
    isRecording = [recorder isRecording];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate switchAudioSessionCategory];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    if ([self.delegate respondsToSelector:@selector(VoiceWaveView:voiceRecorded:length:)]) {
        [self.delegate VoiceWaveView:self voiceRecorded:recorderFilePath length:recordTime];
    }
    self.alpha = 0.0;
    [self setNeedsDisplay];
}

- (void)cancelled:(id)sender {
    self.alpha = 0.0;
    [self setNeedsDisplay];
    
    [timer invalidate];
    [self cancelRecording];
}

#pragma mark - Sound meter operations

- (void)shiftSoundMeterLeft {
    for(int i = 0; i < SOUND_METER_COUNT - 1; i++) {
        soundMeters[i] = soundMeters[i + 1];
    }
}

- (void)addSoundMeterItem:(int)lastValue {
    [self shiftSoundMeterLeft];
    [self shiftSoundMeterLeft];
    soundMeters[SOUND_METER_COUNT - 1] = lastValue;
    soundMeters[SOUND_METER_COUNT - 2] = lastValue;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Draw sound meter wave
    [[UIColor colorWithRed:0.0f/255.0 green:122.0f/255.0 blue:255.0f/255.0 alpha:0.7] set];
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    int baseLine = self.frame.size.height / 2;
    int multiplier = 1;
    int maxLengthOfWave = 50;
    int maxValueOfMeter = 50;
    for(CGFloat x = SOUND_METER_COUNT - 1; x >= 0; x--) {
        multiplier = ((int)x % 2) == 0 ? 1 : -1;
        CGFloat y = 0.0;
        if (soundMeters[(int)x] != 0) {
            y = baseLine + ((maxValueOfMeter * (maxLengthOfWave - abs(soundMeters[(int)x]))) / maxLengthOfWave) * multiplier;
        } else {
            y = baseLine;
        }
        if(x == SOUND_METER_COUNT - 1) {
            CGContextMoveToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 2, y);
            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 1, y);
        } else {
            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 2, y);
            CGContextAddLineToPoint(context, x * (HUD_SIZE / SOUND_METER_COUNT) + hudRect.origin.x + 1, y);
        }
    }
    CGContextStrokePath(context);
//    UIGraphicsPushContext(context);
//    UIGraphicsBeginImageContext(self.bounds.size);
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    recordImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    NSData *imageData = UIImagePNGRepresentation(recordImage);
//    [imageData writeToFile:[NSString stringWithFormat:@"%@/Documents/MySound%d.png", NSHomeDirectory(), indexValue] atomically:YES];
//    indexValue++;
}

- (void)removeVoiceWave {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    self.delegate = nil;
}

@end
