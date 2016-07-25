//
//  SettingWebViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/12.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "SettingWebViewController.h"
#import "SVProgressHUD.h"
#import "TrackingManager.h"
#import "NJKWebViewProgressView.h"

@interface SettingWebViewController ()

@end

@implementation SettingWebViewController
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationItem.titleView.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView.tintColor = [UIColor whiteColor];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _webView.scrollView.scrollsToTop = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationItem.titleView.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationController.navigationItem.backBarButtonItem.title = @"";

    [self.navigationController.navigationBar addSubview:_progressView];

    // web表示
    _webView.scalesPageToFit = YES;
    DLog(@"webURLPath : %@", self.webURLPath);
    NSURL *url = [NSURL URLWithString: self.webURLPath];
    // NSURL *url = [NSURL URLWithString:@"http://pico.flasco.co.jp/term"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    if([_webURLPath rangeOfString:@"policy"].location != NSNotFound)
    {
        [TrackingManager sendScreenTracking:@"Policy"];
    }else if([_webURLPath rangeOfString:@"inquiry"].location != NSNotFound){
        [TrackingManager sendScreenTracking:@"Inquiry"];
    }else if([_webURLPath rangeOfString:@"Terms"].location != NSNotFound){
        [TrackingManager sendScreenTracking:@"Terms"];
    }else if([_webURLPath rangeOfString:@"version"].location != NSNotFound){
        [TrackingManager sendScreenTracking:@"Version"];
    }else if([_webURLPath rangeOfString:@"proaccount"].location != NSNotFound){
        [TrackingManager sendScreenTracking:@"ProAccount"];
    }

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Action Method

#pragma mark - UIWebViewDelegate

// ページ読込開始直後に呼ばれるデリゲートメソッド
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // 2.SVProgressHUDを表示する
    //[SVProgressHUD show];
    // 2'.表示するメッセージに「ロード中です」を指定して、アラートビューを表示したときのようなオーバーレイを表示
    //[SVProgressHUD showWithStatus:@"ロード中です" maskType:SVProgressHUDMaskTypeGradient];
}

// ページ読込終了直後に呼ばれるデリゲートメソッド
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 3.SVProgressHUDを非表示にする
    //[SVProgressHUD dismiss];
    // 3'.読み込みに成功した旨を表示し、SVProgressHUDを非表示にする
    //[SVProgressHUD showSuccessWithStatus:@"ロード完了！"];
}

// ページ読込エラー時に呼ばれるデリゲートメソッド
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DLog(@"webURLPath : %@", self.webURLPath);
    // 4.読み込みに失敗した旨を表示し、SVProgressHUDを非表示にする
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"MsgLoadWebView", nil)];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [title sizeToFit];
    
    self.navigationItem.titleView.alpha = 0;
    self.navigationItem.titleView = title;
    self.navigationItem.titleView.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem.title = @"";
    [UIView animateWithDuration:0.8f animations:^{
        self.navigationItem.titleView.alpha = 0;
        self.navigationItem.titleView.alpha = 1;
    }];
}


@end
