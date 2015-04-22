//
//  AppDelegate.m
//  DiDa
//
//  Created by Bruce Yee on 10/16/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "AppDelegate.h"
#import "CenterViewController.h"
#import "RightViewController.h"
#import "NavigationController.h"
#import "DMPasscode.h"
#import "CalendarViewController.h"
#import "Record.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize voiceIndex, outputDevice, dataSort;

#pragma mark -

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectoryString {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

# pragma mark - memo core data

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContext:(NSNotification *)notification {
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    // observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
//
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Records" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // find the Record data in our Documents folder
    NSString *storePath = [[self applicationDocumentsDirectoryString] stringByAppendingPathComponent:@"Records.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle error
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Sample Helpers

//- (void)createTestEvents {
//    const NSUInteger secondsInSingleYear = 31556926;
//    const NSUInteger yearsToPopulate     = 50;
//    const NSUInteger eventsCount         = 100;
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
//    NSInteger count = [self.managedObjectContext countForFetchRequest:request error:nil];
//    
//    if (count < eventsCount) {
//        for (NSUInteger i = count; i < eventsCount; i++) {
//            Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
//            
//            NSNumber *randomNumber =@(arc4random() % 4);
//            NSDecimalNumber *newNumber = [[NSDecimalNumber alloc] initWithInt:[randomNumber intValue]];
//            [event setEventCategory:newNumber];
//            [event setEventDate:[NSDate dateWithTimeIntervalSinceNow:arc4random() % (secondsInSingleYear * yearsToPopulate)]];
//            
//            NSError *error = nil;
//            [event.managedObjectContext save:&error];
//            NSAssert(!error, @"Error while saving event: %@", [error userInfo]);
//        }
//    }
//}

//- (void)createMemoEvents {
//    NSArray *memoArray = self.memoFetchedResultsController.fetchedObjects;
//    for (Record *record in memoArray) {
//        NSDate *date = record.date;
//        NSArray *eventArray = self.fetchedResultsController.fetchedObjects;
//        BOOL hasEvent = NO;
//        for (Event *event in eventArray) {
//            if ([date isEqualToDate:event.eventDate]) {
//                hasEvent = YES;
//                break;
//            }
//        }
//        if (hasEvent == NO) {
//            Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
//                                                         inManagedObjectContext:self.managedObjectContext];
//            NSDecimalNumber *newNumber = [[NSDecimalNumber alloc] initWithInt:1];
//            [event setEventCategory:newNumber];
//            [event setEventDate:date];
//            NSError *error = nil;
//            [event.managedObjectContext save:&error];
//            NSAssert(!error, @"Error while saving event: %@", [error userInfo]);
//        }
//        DLog(@"%@ %@ %d", [record class], record.memo, hasEvent);
//    }
//}

//- (void)createMemoEvents {
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Record"];
//    NSArray *memoArray = [self.managedObjectContext executeFetchRequest:request error:nil];
//    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
//    for (Record *record in memoArray) {
//        [dateArray addObject:record.date];
//    }
//
//    
//        for (NSUInteger i = 0; i < [dateArray count]; i++) {
//            NSDate *date = [NSDate date];
//            Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
//                                                         inManagedObjectContext:self.managedObjectContext];
//            NSDecimalNumber *newNumber = [[NSDecimalNumber alloc] initWithInt:1];
//            [event setEventCategory:newNumber];
//            [event setEventDate:date];
//            NSError *error = nil;
//            [event.managedObjectContext save:&error];
//        }
////        DLog(@"Error while saving event: %@", [error userInfo]);
////        DLog(@"%@ %@", [record class], record.memo);
//}

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
//    [self createMemoEvents];

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
        [DMPasscode showPasscodeInViewController:self.window.rootViewController completion:^(BOOL success, NSError *error) {
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
