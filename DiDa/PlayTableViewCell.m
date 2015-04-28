//
//  PlayTableViewCell.m
//  DiDa
//
//  Created by Bruce Yee on 10/29/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "PlayTableViewCell.h"
#import "AppDelegate.h"

#define kBlue [UIColor colorWithRed:16/255.0 green:109/255.0 blue:255/255.0 alpha:1.0]

@implementation PlayTableViewCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)touchDeleteButton:(id)sender {
//    DLog(@"%@ %d", [sender class], self.tag);
    [delegate touchedDeleteButton:memoLabel.text isInView:YES];
}

- (IBAction)touchShareButton:(id)sender {
    [delegate touchedShareButton:memoLabel.text];
}

- (IBAction)touchDetailButton:(id)sender {
    [delegate touchedDetailButton:memoLabel.text];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
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

- (void)configureWithRecord:(Record *)record {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.outputDevice == 0) {
        [speakerButton setTintColor:kBlue];
    } else {
        [speakerButton setTintColor:[UIColor lightGrayColor]];
    }
    UIImage *img = [UIImage imageNamed:@"mark"];
    [playSlider setThumbImage:img forState:UIControlStateNormal];
    pathString = record.path;
    audioDuration = [record.length doubleValue];
    playSlider.minimumValue = 0.0;
    playSlider.maximumValue = audioDuration;
    playSlider.value = 0.0;
//    [delegate setCurrentTimeOfPlayer:playSlider.value];
    NSString *endTimeString = [self stringFromTimeInterval:audioDuration];
    endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
    startLabel.text = @"0:00";
    [playSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    memoLabel.text = record.memo;
    NSTimeZone *timezone = [NSTimeZone systemTimeZone];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d/MM/YYYY HH:mm:ss"];
    [formatter setTimeZone:timezone];
    NSString *correctDate = [formatter stringFromDate:record.date];
    dateLabel.text = correctDate;
    if (record.unit && record.unit.length != 0) {
        locationLabel.text = record.unit;
        locateImageView.hidden = NO;
    } else {
        locationLabel.text = @"";
        locateImageView.hidden = YES;
    }
    secondsLabel.text = [NSString stringWithFormat:@"%.1f", [record.length floatValue]];
}

- (IBAction)touchPlayButton:(id)sender {
    [self.delegate touchedPlayButton:pathString sender:sender];
    if (playButton.selected == YES) {
        playButton.selected = NO;
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    } else {
        playButton.selected = YES;
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    }
}

- (IBAction)tapSpeakerButton:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.outputDevice == 0) {
        appDelegate.outputDevice = 1;
        [speakerButton setTintColor:[UIColor lightGrayColor]];
    } else {
        appDelegate.outputDevice = 0;
        [speakerButton setTintColor:kBlue];
    }
    [appDelegate switchAudioSessionCategory];
}

- (IBAction)sliderChanged:(id)sender {
    [delegate setCurrentTimeOfPlayer:playSlider.value];
    NSTimeInterval timeValue = audioDuration - playSlider.value;
    if (timeValue < 0) {
        timeValue = 0.0;
    }
    NSString *endTimeString = [self stringFromTimeInterval:timeValue];
    endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
    NSString *startTimeString = [self stringFromTimeInterval:playSlider.value];
    startLabel.text = startTimeString;
}

- (void)updateSlider {
    if (self.superview) {
        if (delegate && [delegate performSelector:@selector(getCurrentTimeOfPlayer)]) {
            NSTimeInterval currentTime = [delegate getCurrentTimeOfPlayer];
            BOOL isPlaying = [delegate isPlaying];
            playSlider.value = currentTime;
            NSTimeInterval timeValue = audioDuration - currentTime;
            if (timeValue < 0) {
                timeValue = 0.0;
            }
            NSString *endTimeString = [self stringFromTimeInterval:timeValue];
            endLabel.text = [NSString stringWithFormat:@"-%@", endTimeString];
            NSString *startTimeString = [self stringFromTimeInterval:currentTime];
            startLabel.text = startTimeString;
            if (isPlaying) {
                playButton.selected = YES;
            } else {
                playButton.selected = NO;
            }
        }
    } else {
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    }
}

@end
