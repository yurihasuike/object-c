//
//  InfoWebViewController.m
//  myrecoup
//
//  Created by aoponaopon on 2015/12/04.
//  Copyright © 2015年 mamoru.saruwatari. All rights reserved.
//

#import "InfoWebViewController.h"
#import "ConfigLoader.h"
#import "CommonUtil.h"

@interface InfoWebViewController ()

@end

@implementation InfoWebViewController

- (id)initWithURL:(NSString*)url
{
    if(!self) {
        self = [[InfoWebViewController alloc] init];
    }
    //空白＆改行削除
    self.url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //該当WebView作成
    self.newsView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-112)];
    self.newsView.delegate = self;
    self.newsView.scalesPageToFit = YES;
    NSURL * Url = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    [self.newsView loadRequest:request];
    
    //戻るボタン
    UITapGestureRecognizer *backAction = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(backWebView:)];
    [self.navigationItem setBackBarButtonItem:[CommonUtil getBackNaviBtn]];
    [self.navigationItem.backBarButtonItem.customView addGestureRecognizer:backAction];
    [self.navigationItem setLeftBarButtonItem:self.navigationItem.backBarButtonItem];
    [self.view addSubview:self.newsView];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    //nav
    //タイトル等
    self.navigationItem.titleView.alpha = 0;
    self.navigationItem.titleView = [CommonUtil getNaviTitle:[NSString stringWithFormat:@"MyReco"]];
    
    [UIView animateWithDuration:1.2f animations:^{
        self.navigationItem.titleView.alpha = 0;
        self.navigationItem.titleView.alpha = 1;
    }];
    //nav
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// ページ読込開始時にインジケータをくるくるさせる
-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// ページ読込完了時にインジケータを非表示にする
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.navigationItem.leftBarButtonItems = @[self.navigationItem.backBarButtonItem];
}

//ロード開始前に呼ばれる.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // リンクがクリックされたか否かを判定.
    if (navigationType == UIWebViewNavigationTypeLinkClicked ||
        navigationType == UIWebViewNavigationTypeFormSubmitted ) {
        
        NSURL *url = [request URL];
        // クリックされたリンクが i-mobile の広告か否かを判定.
        if ([[url host] hasSuffix:@"i-mobile.co.jp"] ||
            [[url host] hasSuffix:@"admovie.jswfplayer.jp"] ||
            [[url host] hasSuffix:@"send-guile.sonicmoov.com"]) {
            
            // i-mobile の広告がクリックされた場合、ブラウザを起動.
            [[UIApplication sharedApplication] openURL:url];
            
            return NO;
        }
        NSDictionary *vConfig = [ConfigLoader mixIn];
        if ([vConfig[@"MyReco"][@"top"] hasSuffix:[url host]]) {
            NSURLRequest *req = [NSURLRequest
                                 requestWithURL:[self getMyRecoURLWithSuffix:url]];
            [webView loadRequest:req];
            return NO;
        }
    }
    return YES;
}

///接尾辞にパラメーターをつけてダウンロードバナーが出ないように
- (NSURL *)getMyRecoURLWithSuffix:(NSURL *)URL {
    
    NSDictionary *vConfig = [ConfigLoader mixIn];
    NSString *format = @"";
    NSString *fragment = @"";
    
    if ([[URL absoluteString] hasSuffix:vConfig[@"MyReco"][@"suffix"]]) {
        return URL;
    }
    if ([URL fragment]) {
        fragment = [NSString stringWithFormat:@"#%@", [URL fragment]];
        URL = [NSURL
               URLWithString:
               [[URL absoluteString]
                stringByReplacingOccurrencesOfString:fragment
                withString:@""]];
    }
    if ([URL query]) {
        format = @"%@&%@%@";
    }else{
        format = @"%@%@%@";
    }
    return [NSURL
            URLWithString:
            [NSString
             stringWithFormat:format,
             [URL absoluteString],
             vConfig[@"MyReco"][@"suffix"],
             fragment]];
}

- (void)backWebView:(UITapGestureRecognizer *)recognizer
{
    if (self.newsView.canGoBack) {
        [self.newsView goBack];
    }
    else{
        [self.navigationController popToRootViewControllerAnimated:YES];
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
