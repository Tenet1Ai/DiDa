//
//  SettingsViewController.m
//  DiDa
//
//  Created by Bruce Yee on 4/3/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIView+Borders.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [setupButton addBottomBorderWithHeight:1.f andColor:[UIColor lightGrayColor]];
    [offButton addBottomBorderWithHeight:1.f andColor:[UIColor lightGrayColor]];
    [aboutButton addBottomBorderWithHeight:1.f andColor:[UIColor lightGrayColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL passcodeSet = [DMPasscode isPasscodeSet];
    if (passcodeSet == YES) {
        [setupButton setTitle:NSLocalizedString(@"Change Passcode", nil) forState:UIControlStateNormal];
        offButton.hidden = NO;
    } else {
        [setupButton setTitle:NSLocalizedString(@"Setup Passcode", nil) forState:UIControlStateNormal];
        offButton.hidden = YES;
    }
}

- (IBAction)tapAboutButton:(id)sender {
    if (&UIApplicationOpenSettingsURLString != nil) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        [self performSegueWithIdentifier:@"pushToAbout" sender:@"pushToAbout"];
    }
}

- (IBAction)tapSetupButton:(id)sender {
    [DMPasscode setupPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
    }];
}

- (IBAction)tapOffButton:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Turn Off Passcode Lock?", nil)
                                                        message:NSLocalizedString(@"Your saved memo can be listened and viewed by anyone "
                                                                                  "who has access to your iPhone if your turn off passcode lock.", nil)
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"Turn Off", nil), nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"%ld", (long)buttonIndex);
    if (buttonIndex == 1) {
        [DMPasscode removePasscode];
        offButton.hidden = YES;
        [setupButton setTitle:NSLocalizedString(@"Setup Passcode", nil) forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
