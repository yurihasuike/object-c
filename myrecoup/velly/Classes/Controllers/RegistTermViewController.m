//
//  RegistTermViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/06.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RegistTermViewController.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"

@interface RegistTermViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation RegistTermViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 利用規約 web表示
    //_webView.frame = CGRectMake(0, 0, 200, 300);
    _webView.scalesPageToFit = YES;
    
    //NSURL *url = [NSURL URLWithString:@"http://pico.flasco.co.jp/term"];
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *strUrl = vConfig[@"WebViewURLTerms"];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"SignupTerms"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)closeAction:(id)sender {
    
    DLog(@"RegistTermView onClose");
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


@end
