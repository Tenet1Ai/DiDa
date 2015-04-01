//
//  LeftViewController.m
//  DiDa
//
//  Created by Bruce Yee on 10/18/13.
//  Copyright (c) 2013-2015 Bruce Yee. All rights reserved.
//

#import "LeftViewController.h"
#import "AppDelegate.h"
#import <UIViewController+MMDrawerController.h>

@interface LeftViewController ()

@end

@implementation LeftViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//    self.tableView.layer.borderWidth = 1.0;
//    self.tableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 2;
        case 2:
            return 2;
        default:
            return 0;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Output", nil);
        case 1:
            return NSLocalizedString(@"View", nil);
        case 2:
            return NSLocalizedString(@"Settings", nil);
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 44.0;
        case 1:
            return 50.0;
        case 2:
            return 50.0;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    static NSString *CellIdentifier = @"MenuCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    UIColor * selectedColor = [UIColor colorWithRed:1.0/255.0 green:15.0/255.0 blue:25.0/255.0 alpha:1.0];
    UIColor * unselectedColor = [UIColor colorWithRed:79.0/255.0 green:93.0/255.0 blue:102.0/255.0 alpha:1.0];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:NSLocalizedString(@"Speaker", nil)];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedString(@"Headset", nil)];
                    break;
                default:
                    break;
            }
            if (indexPath.row == appDelegate.outputDevice) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [cell.textLabel setTextColor:selectedColor];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setTextColor:unselectedColor];
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:NSLocalizedString(@"Descending", nil)];
                    break;
                case 1:
                    [cell.textLabel setText:NSLocalizedString(@"Ascending", nil)];
                    break;
                default:
                    break;
            }
            if (indexPath.row == appDelegate.dataSort) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [cell.textLabel setTextColor:selectedColor];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setTextColor:unselectedColor];
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:NSLocalizedString(@"Passcode", nil)];
                    break;
                case 1: {
                    if (&UIApplicationOpenSettingsURLString != nil) {
                        [cell.textLabel setText:NSLocalizedString(@"System", nil)];
                    } else {
                        [cell.textLabel setText:NSLocalizedString(@"About", nil)];
                    }
                    break;
                }
//                case 2:
//                    [cell.textLabel setText:@"About"];
//                    break;
                default:
                    break;
            }
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell.textLabel setTextColor:unselectedColor];
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.section) {
        case 0: {
            appDelegate.outputDevice = indexPath.row;
            [userDefaults setObject:[NSNumber numberWithLong:indexPath.row] forKey:@"AppOutputDevice"];
            [userDefaults synchronize];
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:0];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:1 inSection:0];
            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath1, indexPath2, nil];
            [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            return;
        }
        case 1: {
            appDelegate.dataSort = indexPath.row;
            [userDefaults setObject:[NSNumber numberWithLong:indexPath.row] forKey:@"AppDataSort"];
            [userDefaults synchronize];
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:1];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:1 inSection:1];
            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath1, indexPath2, nil];
            [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTableData" object:self userInfo:nil];
            return;
        }
        case 2: {
            [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
            if (indexPath.row == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showPasscodeViewController" object:self userInfo:nil];
            } else if (indexPath.row == 1) {
                if (&UIApplicationOpenSettingsURLString != nil) {
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAboutViewController" object:self userInfo:nil];
                }
            }
            return;
        }
        default:
            return;
    }
}

@end
