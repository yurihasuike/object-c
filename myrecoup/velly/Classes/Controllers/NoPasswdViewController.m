//
//  NoPasswdViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/06.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "NoPasswdViewController.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"

@interface NoPasswdViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation NoPasswdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backgroundColor = HEADER_BG_COLOR;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.naviTitle){

        self.navigationItem.title = @"";
        self.headerTitleLabel.text = @"";

        // ---------------------------------------
        // GA
        // ---------------------------------------
        [TrackingManager sendScreenTracking:@"TwAuth"];

    }else{
        

        NSURL *url;
        if([_webURLPath rangeOfString:@"terms"].location != NSNotFound)
        {
            // 利用規約
            self.navigationController.navigationItem.title = NSLocalizedString(@"PageRegistTerms", nil);
            self.navigationItem.title = NSLocalizedString(@"PageRegistTerms", nil);
            self.headerTitleLabel.text = NSLocalizedString(@"PageRegistTerms", nil);
            url = [NSURL URLWithString: self.webURLPath];
            
        }else if([_webURLPath rangeOfString:@"privacy"].location != NSNotFound){
            // プライバシーポリシー
            self.navigationController.navigationItem.title = NSLocalizedString(@"PagePolicy", nil);
            self.navigationItem.title = NSLocalizedString(@"PagePolicy", nil);
            self.headerTitleLabel.text = NSLocalizedString(@"PagePolicy", nil);
            url = [NSURL URLWithString: self.webURLPath];
            
        }else {
            // パスワードを忘れた方
            self.navigationController.navigationItem.title = NSLocalizedString(@"PageNoPasswd", nil);
            self.navigationItem.title = NSLocalizedString(@"PageNoPasswd", nil);
            self.headerTitleLabel.text = NSLocalizedString(@"PageNoPasswd", nil);
            url = [NSURL URLWithString: self.webURLPath];
//            NSDictionary *vConfig   = [ConfigLoader mixIn];
//            NSString *strUrl = vConfig[@"WebViewURLNoPasswd"];
//            url = [NSURL URLWithString:strUrl];
        }
        
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:req];
        _webView.scrollView.scrollsToTop = NO;

        //_webView.frame = CGRectMake(0, 0, 200, 300);
        _webView.scalesPageToFit = YES;
        
        // ---------------------------------------
        // GA
        // ---------------------------------------
        [TrackingManager sendScreenTracking:@"NoPasswd"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)closeAction:(id)sender {
    DLog(@"NoPasswdView onClose");
    //[self dismissViewControllerAnimated:YES completion:NULL];
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
