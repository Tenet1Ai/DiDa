//
//  AppDelegate.m
//  DiDa
//
//  Created by Bruce Yee on 10/16/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftViewController.h"
#import "CenterViewController.h"
#import "RightViewController.h"
#import "NavigationController.h"
#import <MMDrawerController.h>
#import "VisualStateManager.h"
#import "DMPasscode.h"

@interface AppDelegate ()
@property (nonatomic,strong) MMDrawerController *drawerController;
@end

@implementation AppDelegate
@synthesize voiceIndex, outputDevice, dataSort;

static BOOL OSVersionIsAtLeastiOS6() {
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_0);
}

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    voiceIndex = 0;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    LeftViewController *leftUIViewController = [storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];
    CenterViewController *centerUIViewController = [storyboard instantiateViewControllerWithIdentifier:@"CenterViewController"];
    RightViewController *rightUIViewController = [storyboard instantiateViewControllerWithIdentifier:@"RightViewController"];
    rightUIViewController.sharedPSC = centerUIViewController.persistentStoreCoordinator;

    UINavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:centerUIViewController];
    
    [navigationController setRestorationIdentifier:@"CenterNavigationControllerRestorationKey"];
    if(OSVersionIsAtLeastiOS6()){
        UINavigationController * rightSideNavController = [[NavigationController alloc] initWithRootViewController:rightUIViewController];
		[rightSideNavController setRestorationIdentifier:@"RightNavigationControllerRestorationKey"];
        UINavigationController * leftSideNavController = [[NavigationController alloc] initWithRootViewController:leftUIViewController];
		[leftSideNavController setRestorationIdentifier:@"LeftNavigationControllerRestorationKey"];
        self.drawerController = [[MMDrawerController alloc]
                                 initWithCenterViewController:navigationController
                                 leftDrawerViewController:leftSideNavController
                                 rightDrawerViewController:rightSideNavController];
        [self.drawerController setShowsShadow:NO];
    } else {
        self.drawerController = [[MMDrawerController alloc]
                                 initWithCenterViewController:navigationController
                                 leftDrawerViewController:leftUIViewController
                                 rightDrawerViewController:rightUIViewController];
    }
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumLeftDrawerWidth:150.0];
    [self.drawerController setMaximumRightDrawerWidth:320.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];

    [self.drawerController setDrawerVisualStateBlock:[MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:5.0]];
    [self.drawerController setShowsShadow:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if(OSVersionIsAtLeastiOS6()) {
        UIColor *tintColor = [UIColor colorWithRed:29.0/255.0
                                              green:173.0/255.0
                                               blue:234.0/255.0
                                              alpha:1.0];
        [self.window setTintColor:tintColor];
    }
    [self.window setRootViewController:self.drawerController];
    
    outputDevice = 0;
    dataSort = 0;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *appOutputDevice = [userDefaults objectForKey:@"AppOutputDevice"];
    if (appOutputDevice) {
        outputDevice = [appOutputDevice integerValue];
    }
    NSNumber *appDataSort = [userDefaults objectForKey:@"AppDataSort"];
    if (appDataSort) {
        dataSort = [appDataSort integerValue];
    }
    return YES;
}

- (void)switchAudioSessionCategory {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (outputDevice == 0) {
        if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayback]) {
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(audioRouteOverride), &audioRouteOverride);
#endif
        }
    } else {
        if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(audioRouteOverride), &audioRouteOverride);
#endif
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self switchAudioSessionCategory];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    DLog(@"%@", [[UIDevice currentDevice] identifierForVendor]);
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithName:@"DiDa"
                                                                       expirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        DLog(@"Expiration handler called %f", [application backgroundTimeRemaining]);
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do the work associated with the task, preferably in chunks.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    _showingPasscode = NO;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    BOOL passcodeSet = [DMPasscode isPasscodeSet];
    DLog(@"applicationDidBecomeActive: %d", passcodeSet);
    if (passcodeSet == YES && _showingPasscode == NO) {
        _showingPasscode = YES;
        [DMPasscode showPasscodeInViewController:self.drawerController completion:^(BOOL success, NSError *error) {
            if (success) {
            } else {
                if (error) {
                    DLog(@"Failed authentication");
                } else {
                    DLog(@"Cancelled");
                    _showingPasscode = NO;
                }
            }
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    NSString * key = [identifierComponents lastObject];
    if([key isEqualToString:@"MMDrawer"]){
        return self.window.rootViewController;
    } else if ([key isEqualToString:@"NavigationControllerRestorationKey"]) {
        return ((MMDrawerController *)self.window.rootViewController).centerViewController;
    } else if ([key isEqualToString:@"RightNavigationControllerRestorationKey"]) {
        return ((MMDrawerController *)self.window.rootViewController).rightDrawerViewController;
    } else if ([key isEqualToString:@"LeftNavigationControllerRestorationKey"]) {
        return ((MMDrawerController *)self.window.rootViewController).leftDrawerViewController;
    } else if ([key isEqualToString:@"LeftSideDrawerController"]){
        UIViewController * leftVC = ((MMDrawerController *)self.window.rootViewController).leftDrawerViewController;
        if([leftVC isKindOfClass:[UINavigationController class]]){
            return [(UINavigationController*)leftVC topViewController];
        } else {
            return leftVC;
        }
        
    } else if ([key isEqualToString:@"RightSideDrawerController"]){
        UIViewController * rightVC = ((MMDrawerController *)self.window.rootViewController).rightDrawerViewController;
        if([rightVC isKindOfClass:[UINavigationController class]]) {
            return [(UINavigationController*)rightVC topViewController];
        } else {
            return rightVC;
        }
    }
    return nil;
}

@end
