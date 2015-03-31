//
//  UIDevice+Resolutions.h
//  DiDa
//
//  Created by Bruce Yee on 10/31/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    // 320 x 480
    UIDevice_iPhone3 = 1,
    // 640 x 960
    UIDevice_iPhone4 = 2,
    // 640 x 1136
    UIDevice_iPhone5 = 3,
    // 1024 x 768
    UIDevice_iPadOld = 4,
    // 2048 x 1536
    UIDevice_iPadNew = 5
};

typedef NSUInteger UIDeviceResolution;

@interface UIDevice (Resolutions)

+ (UIDeviceResolution)currentResolution;

+ (BOOL)isRunningIniPhone5;
+ (BOOL)isRunningIniPhone4;
+ (BOOL)isRunningIniPhone3;
+ (BOOL)isRunningIniPhone;
+ (float)iOSVersion;

@end
