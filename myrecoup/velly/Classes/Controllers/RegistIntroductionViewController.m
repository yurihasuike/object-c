//
//  RegistIntroductionViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/06.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RegistIntroductionViewController.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"

@interface RegistIntroductionViewController ()
{
    UIView *rootView;
}

@property (weak, nonatomic) UIButton *closeBtn;


@end

@implementation RegistIntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 背景色無し
    self.view.backgroundColor = [UIColor clearColor];
    // 背景画像：iPhone/iPadの画面サイズに合わせて画像を拡大・縮小する
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg_login.png"] drawInRect:self.view.bounds];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    // ナビゲーションバー消去
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];

//    _closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    _closeBtn.titleLabel.text = @"閉じる";
//    _closeBtn.titleLabel.tintColor = [UIColor blackColor];
//    _closeBtn.frame = CGRectMake(30, 30, 50, 30);
//    
//    [self.view addSubview:_closeBtn];
//    [_closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchDown];
    
    rootView = self.navigationController.view;

    
//    UIView *bkView = [[UIView alloc] initWithFrame:CGRectMake(30.0f, 30.0f,
//                                            [[UIScreen mainScreen] bounds].size.width - 60.0f,
//                                            [[UIScreen mainScreen] bounds].size.height - 60.0f)];
//    UIView *bkView = [[UIView alloc] initWithFrame:CGRectMake(30.0f, 30.0f, 10.0f, 20.0f)];
//    
//    UIView *bkView = [[UIView alloc] init];
//    bkView.bounds.size = CGSizeMake(300.0f, 200.0f);
//    bkView.opaque = NO;
//    bkView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    
    
    // ページングView設定
    //EAIntroPage *page1 = [EAIntroPage pageWithCustomView:bkView];
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Step 1 of 3";
    page1.titleFont = ENFONT(14);
    page1.titleColor = TXT_REGIST_INTRO_COLOR;
    page1.titlePositionY = self.view.bounds.size.height/4 - 10;
    page1.desc = NSLocalizedString(@"IntroductionPage1Msg", nil);
    page1.descColor = TEXT_EDIT_COLOR;
    page1.descPositionY = 40;
    //page1.navimsg = NSLocalizedString(@"IntroductionNext", nil);
    page1.btnmsg  = NSLocalizedString(@"IntroductionNext", nil);
    page1.navimsgFont = JPFONT(12);
    page1.navimsgColor = TEXT_EDIT_COLOR;
    page1.navimsgPositionY = -50;
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_finish"]];
    page1.titleIconPositionY = 54;
    page1.pageIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_f01"]];
    page1.pageIconPositionY = 220;
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"Step 2 of 3";
    page2.titleFont = ENFONT(14);
    page2.titleColor = TXT_REGIST_INTRO_COLOR;
    page2.titlePositionY = self.view.bounds.size.height/4 - 10;
    page2.desc = NSLocalizedString(@"IntroductionPage2Msg", nil);
    page2.descColor = TEXT_EDIT_COLOR;
    page2.descPositionY = 40;
    //page2.navimsg = NSLocalizedString(@"IntroductionNext", nil);
    page2.btnmsg  = NSLocalizedString(@"IntroductionNext", nil);
    page2.navimsgFont = JPFONT(12);
    page2.navimsgColor = TEXT_EDIT_COLOR;
    page2.navimsgPositionY = -50;
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_finish"]];
    page2.titleIconPositionY = 54;
    page2.pageIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_f02"]];
    page2.pageIconPositionY = 220;
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"Step 3 of 3";
    page3.titleFont = ENFONT(14);
    page3.titleColor = TXT_REGIST_INTRO_COLOR;
    page3.titlePositionY = self.view.bounds.size.height/4 - 10;
    page3.desc = NSLocalizedString(@"IntroductionPage3Msg", nil);
    page3.descColor = TEXT_EDIT_COLOR;
    page3.descPositionY = 40;
    page3.navimsg = NSLocalizedString(@"IntroductionPage3SubMsg", nil);
    page3.btnclosemsg = NSLocalizedString(@"IntroductionPage3SubMsg", nil);
    page3.navimsgFont = JPFONT(12);
    page3.navimsgColor = TEXT_EDIT_COLOR;
    page3.navimsgPositionY = -50;
    //page3.descPositionY = self.view.bounds.size.height/2 - 10;
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_finish"]];
    page3.titleIconPositionY = 54;
    page3.pageIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_f02"]];
    page3.pageIconPositionY = 220;

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3]];
    //intro.bgImage = [UIImage imageNamed:@"bg2"];


    intro.pageControlY = 250.0f;


    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[btn setFrame:CGRectMake((320-230)/2, [UIScreen mainScreen].bounds.size.height - 60, 230, 40)];
    [btn setFrame:CGRectMake(10, self.view.bounds.size.height - 60, 80, 40)];
    [btn setTitle:@"SKIP" forState:UIControlStateNormal];
    [btn setTitleColor:TXT_REGIST_INTRO_COLOR forState:UIControlStateNormal];
    //btn.layer.borderWidth = 2.0f;
    //btn.layer.cornerRadius = 10;
    //btn.layer.borderColor = [[UIColor whiteColor] CGColor];
    intro.skipButton = btn;

    [intro setDelegate:self];
    [intro showInView:rootView animateDuration:0.3];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"SignupIntroduction"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (void) closeAction: (UIButton *)button
{
    DLog(@"RegistIntroductionView onClose");
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)introDidFinish:(EAIntroView *)introView {
    DLog(@"introDidFinish callback");
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
