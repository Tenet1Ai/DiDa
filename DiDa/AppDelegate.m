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
#import "DMPasscode.h"
#import "CalendarViewController.h"
#import "Event.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize voiceIndex, outputDevice, dataSort;

#pragma mark - CoreData Helpers

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"YearCalendarModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSAssert([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error],
             @"NSPersistentStoreCoordinator error: %@", [error userInfo]);
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Sample Helpers

- (void)createTestEvents {
    
    const NSUInteger secondsInSingleYear = 31556926;
    const NSUInteger yearsToPopulate     = 50;
    const NSUInteger eventsCount         = 1000;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    NSInteger count = [self.managedObjectContext countForFetchRequest:request error:nil];
    
    if (count < eventsCount) {
        for (NSUInteger i = count; i < eventsCount; i++) {
            
            Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
            
            [event setEventCategory:@(arc4random() % 4)];
            [event setEventDate:[NSDate dateWithTimeIntervalSinceNow:arc4random() % (secondsInSingleYear * yearsToPopulate)]];
            
            NSError *error = nil;
            [event.managedObjectContext save:&error];
            NSAssert(!error, @"Error while saving event: %@", [error userInfo]);
        }
    }
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    voiceIndex = 0;
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
    DLog(@"%@", NSHomeDirectory());
    [self managedObjectContext];
//    [self createTestEvents];

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
        [DMPasscode showPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
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

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
