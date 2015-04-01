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

- (void)touchedPlayButton:(NSInteger)tag path:(NSString *)pathString sender:(id)sender;
- (void)touchedDeleteButton:(NSInteger)tag title:(NSString *)title isInView:(BOOL)flag;
- (void)touchedShareButton:(NSInteger)tag title:(NSString *)title;
- (void)touchedDetailButton:(NSInteger)tag title:(NSString *)title;
- (BOOL)isPlaying;
- (NSTimeInterval)getCurrentTimeOfPlayer;
- (void)setCurrentTimeOfPlayer:(NSTimeInterval)time;
- (void)changeTitleAction:(NSInteger)tag title:(NSString *)title;
- (void)changeNoteAction:(NSInteger)tag text:(NSString *)locationText;
- (void)showAboutViewController;

@end

#endif
