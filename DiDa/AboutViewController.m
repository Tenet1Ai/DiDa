//
//  AboutViewController.m
//  DiDa
//
//  Created by Bruce Yee on 10/30/13.
//  Copyright (c) 2013 Bruce Yee. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController () <UIWebViewDelegate>

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [webPageView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:filePath]];
    webPageView.delegate = self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *padding = @"document.body.style.margin='0';document.body.style.padding = '0'";
    [webView stringByEvaluatingJavaScriptFromString:padding];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
