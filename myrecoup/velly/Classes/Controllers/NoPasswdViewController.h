//
//  NoPasswdViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/06.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoPasswdViewController : UIViewController

@property (strong, nonatomic) NSString *webURLPath;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) NSString *naviTitle;
@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;

@end
