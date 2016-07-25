//
//  SettingWebViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/12.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"

@interface SettingWebViewController : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (strong, nonatomic) NSString *webURLPath;
@property (weak,nonatomic) IBOutlet UIWebView *webView;

@end
