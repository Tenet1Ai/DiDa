//
//  UIDevice+Resolutions.m
//  DiDa
//
//  Created by Bruce Yee on 10/31/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "UIDevice+Resolutions.h"

@implementation UIDevice (Resolutions)

+ (UIDeviceResolution)currentResolution {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            if (result.height <= 480.0f)
                return UIDevice_iPhone3;
            return (result.height > 960.0f ? UIDevice_iPhone5 : UIDevice_iPhone4);
        } else
            return UIDevice_iPhone3;
    } else {
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPadNew : UIDevice_iPadOld);
    }
}

+ (BOOL)isRunningIniPhone5 {
    if ([self currentResolution] == UIDevice_iPhone5) {
        return YES;
    }
    return NO;
}

+ (BOOL)isRunningIniPhone4 {
    if ([self currentResolution] == UIDevice_iPhone4) {
        return YES;
    }
    return NO;
}

+ (BOOL)isRunningIniPhone3 {
    if ([self currentResolution] == UIDevice_iPhone3) {
        return YES;
    }
    return NO;
}

+ (BOOL)isRunningIniPhone {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

+ (float)iOSVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

@end
