//
//  AppDelegate.h
//  DiDa
//
//  Created by Bruce Yee on 10/16/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSInteger voiceIndex;
    NSInteger outputDevice;
    NSInteger dataSort;
    BOOL _showingPasscode;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) NSInteger voiceIndex;
@property (nonatomic, assign) NSInteger outputDevice;
@property (nonatomic, assign) NSInteger dataSort;

@end
