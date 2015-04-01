//
//  PasscodeViewController.m
//  DiDa
//
//  Created by Bruce Yee on 3/17/15.
//  Copyright (c) 2015 Bruce Yee. All rights reserved.
//

#import "PasscodeViewController.h"
#import <UIViewController+MMDrawerController.h>
#import "DMPasscode.h"

@interface PasscodeViewController () <UIAlertViewDelegate>

@end

@implementation PasscodeViewController
@synthesize passcodeButton, offButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL passcodeSet = [DMPasscode isPasscodeSet];
    if (passcodeSet == YES) {
        [passcodeButton setTitle:NSLocalizedString(@"Change Passcode", nil) forState:UIControlStateNormal];
        offButton.hidden = NO;
    } else {
        [passcodeButton setTitle:NSLocalizedString(@"Setup Passcode", nil) forState:UIControlStateNormal];
        offButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapBackButton:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (IBAction)tapSetupButton:(id)sender {
    [DMPasscode setupPasscodeInViewController:self completion:^(BOOL success, NSError *error) {
    }];
}

- (IBAction)tapOffButton:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Turn Off Passcode Lock?"
                                                        message:@"Your saved voice can be listened by anyone "
                              "who has access to your iPhone if your turn off passcode lock."
                                                       delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Turn Off", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"%ld", (long)buttonIndex);
    if (buttonIndex == 1) {
        [DMPasscode removePasscode];
        offButton.hidden = YES;
        [passcodeButton setTitle:@"Setup Passcode" forState:UIControlStateNormal];
    }
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
