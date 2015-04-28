//
//  TouchButtonsDelegate.h
//  DiDa
//
//  Created by Bruce Yee on 10/30/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#ifndef DiDa_TouchButtonsDelegate_h
#define DiDa_TouchButtonsDelegate_h

@protocol TouchActionsDelegate <NSObject>

@optional

- (void)touchedPlayButton:(NSString *)pathString sender:(id)sender;
- (void)touchedDeleteButton:(NSString *)title isInView:(BOOL)flag;
- (void)touchedShareButton:(NSString *)title;
- (void)touchedDetailButton:(NSString *)title;
- (BOOL)isPlaying;
- (NSTimeInterval)getCurrentTimeOfPlayer;
- (void)setCurrentTimeOfPlayer:(NSTimeInterval)time;
- (void)changeTitleAction:(NSString *)title;
- (void)changeNoteAction:(NSString *)note;
- (void)showAboutViewController;

@end

#endif
