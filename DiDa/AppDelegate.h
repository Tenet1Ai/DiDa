//
//  AppDelegate.h
//  DiDa
//
//  Created by Bruce Yee on 10/16/13.
//  Copyright (c) 2013-2015 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Record.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSInteger outputDevice;
    NSInteger dataSort;
    BOOL _showingPasscode;
    NSMutableDictionary *memoInfoDictionary;
}

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) NSInteger outputDevice;
@property (nonatomic, assign) NSInteger dataSort;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)switchAudioSessionCategory;
- (void)setMemoInfo:(Record *)record;
- (void)setFileProtectionNone:(NSString *)filePath;

@end
