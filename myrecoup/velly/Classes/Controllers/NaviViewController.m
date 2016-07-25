//
//  TabViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/02/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "NaviViewController.h"



@interface NaviViewController ()
{
    BOOL hiddenTabBar;
}

@end

@implementation NaviViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //appDelegateにデリゲートを設定しているので、こちらは使用していない模様 @hyokozeki
    self.delegate = self;
    
//    float offset = 10.0;
//    CGRect tabFrame = self.tabBar.frame;
//    tabFrame.origin.y += offset;
//    tabFrame.size.height -= offset;
//    self.tabBar.frame = tabFrame;
//    self.view.bounds = self.tabBar.bounds;
    //self.tabBar.backgroundColor = [UIColor clearColor];

    self.view.backgroundColor = [UIColor clearColor];

    DLog(@"navi bar width : %f", self.tabBar.backgroundImage.size.width);
    
//    [self.tabBar setFrame:CGRectMake(
//                                     self.tabBar.frame.origin.x,
//                                     self.view.frame.size.height-45,
//                                     self.tabBar.frame.size.width,
//                                     self.tabBar.frame.size.height)];
    
    UIImage *tabBarFirstImg = [UIImage imageNamed:@"bg_nav-on01.png"];
    //UIGraphicsBeginImageContext(CGSizeMake(itemWidth, kItemButtnHeight * imgScale));
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
    [tabBarFirstImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
    tabBarFirstImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.tabBar.backgroundImage = tabBarFirstImg; // [UIImage imageNamed:@"bg_nav-on01.png"];
    
    DLog(@"tabbar width %f", self.tabBar.frame.size.width);
    
    self.tabBar.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    //self.tabBar.hidden = YES;
    
//    DLog(@" frame.size : %f", [UIScreen mainScreen].bounds.size.height);
//    DLog(@" tab backimage. size : %f", self.tabBar.backgroundImage.size.height);
//    [UITabBar appearance].barTintColor = [UIColor clearColor];
//    
//    [self.tabBar setFrame:CGRectMake(self.tabBar.frame.origin.x,
//                                     [UIScreen mainScreen].bounds.size.height - self.tabBar.backgroundImage.size.height - 25,
//                                     self.tabBar.frame.size.width,
//                                     self.tabBar.backgroundImage.size.height)];
    
    
    //[self.view setBounds: self.tabBar.bounds];
    //[self.view setFrame: CGRectZero];


//    // ----------------------------------------------
//    // Notification
//    // ----------------------------------------------
//    // ユーザ未ログイン時会員登録画面呼び出し
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showUserRegist:) name:VYShowUserRegistNotification object:nil];

    
    [self setUpViewControllers];
    
    //DLog(@"frame size height : %f", self.view.frame.size.height);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // 初回表示時 2番目
    // 元タブ表示時 1番目
    //NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];

}   

- (void)viewDidAppear:(BOOL)animated
{
    // 初回起動時 3番目
    // 元タブ表示時 2番目
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    // 他タブ切替時 1番目
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpViewControllers
{
    // test
    //    hiddenTabBar = YES;
    //    [self hideTabBar];
    
    // 画面背景
    UIImage *tabBarFirstImg = [UIImage imageNamed:@"bg_nav-on01.png"];
    //UIGraphicsBeginImageContext(CGSizeMake(itemWidth, kItemButtnHeight * imgScale));
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
    [tabBarFirstImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
    tabBarFirstImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.tabBar.backgroundImage = tabBarFirstImg; // [UIImage imageNamed:@"bg_nav-on01.png"];

    UIStoryboard *stb_home    = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    UIStoryboard *stb_ranking = [UIStoryboard storyboardWithName:@"Ranking" bundle:nil];
    
    UIStoryboard *stb_post    = [UIStoryboard storyboardWithName:@"Post" bundle:nil];
    UIStoryboard *stb_info    = [UIStoryboard storyboardWithName:@"Info" bundle:nil];
    UIStoryboard *stb_profile = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
    

    // タブの背景画像と選択時の背景画像を設定
    // [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tab_background_001.png"]];
    // 選択時のタブ背景
    //[[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab_selection_indicator.png"]];
    
    // タブメニュー選択時のビュー生成
//    HomeViewController *tabHomeVC    = [stb_home instantiateViewControllerWithIdentifier:@"HomeTabPagerViewController"];
    UINavigationController *tabHomeVC = (UINavigationController *)[stb_home instantiateInitialViewController];

    //InfoViewController *tabRankingVC = [[InfoViewController alloc] init];
    
    
    
    //UIStoryboard *stb_post = [UIStoryboard storyboardWithName:@"Post" bundle:nil];
    
//    PostViewController *tabRankingVC = [stb_detail instantiateViewControllerWithIdentifier:@"DetailViewController"];
    // stb_ranking
//    RankingTabPagerViewController *tabRankingVC = [stb_ranking instantiateViewControllerWithIdentifier:@"RankingTabPagerViewController"];
    UINavigationController *tabRankingVC = (UINavigationController *)[stb_ranking instantiateInitialViewController];


    PostViewController *tabRecordVC = [stb_post instantiateViewControllerWithIdentifier:@"PostViewController"];
    
    //PostViewController *tabRecordVC = [[PostViewController alloc] init];
    
    //UINavigationController *tabRecordVC = [[UINavigationController alloc] initWithRootViewController:nc_post];
    //PostViewController *tabRecordVC  = nc_post;
    //PostViewController *tabRecordVC  = [[InfoViewController alloc] init];
    
    //InfoViewController *tabInfoVC    = [[InfoViewController alloc] init];
    InfoViewController *tabInfoVC = [stb_info instantiateViewControllerWithIdentifier:@"InfoViewController"];
    // error InfoViewController *tabInfoVC = [stb_info instantiateInitialViewController];

    
    //InfoViewController *tabProfileVC = [[InfoViewController alloc] init];
    ProfileViewController *tabProfileVC = [stb_profile instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    tabProfileVC.isMmine = YES;
//    UINavigationController *tabProfileVC = (UINavigationController *)[stb_profile instantiateInitialViewController];

    
    if ([self isIOS7]) { // iOS 7用のタブバー生成
        // タブのアイコン指定
        // initWithTitle:NSLocalizedString(@"NavTabHome", nil)
        tabHomeVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                             image:[[UIImage imageNamed:@"btn_home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                     selectedImage:[[UIImage imageNamed:@"btn_home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        tabRankingVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                image:[[UIImage imageNamed:@"btn_rank.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"btn_rank.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        tabRecordVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                image:[[UIImage imageNamed:@"btn_camera.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"btn_camera.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        tabInfoVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                             image:[[UIImage imageNamed:@"btn_notice.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                     selectedImage:[[UIImage imageNamed:@"btn_notice.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        tabProfileVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil
                                                                image:[[UIImage imageNamed:@"btn_user.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                        selectedImage:[[UIImage imageNamed:@"btn_user.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        // タブのフォント指定
        UIFont *tabFont = [UIFont fontWithName:@"HelveticaNeue" size:9.0f];
        // タブのタイトル色指定
        NSDictionary *attributesNormal = @{NSFontAttributeName:tabFont, NSForegroundColorAttributeName:[UIColor colorWithRed:0.733f green:0.733f blue:0.733f alpha:1.0f]};
        [[UITabBarItem appearance] setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
        // タブのタイトル色指定 (選択中)
        NSDictionary *selectedAttributes = @{NSFontAttributeName:tabFont, NSForegroundColorAttributeName:[UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.0f]};
        [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        
    }else{ // iOS 6.1以下用のタブバー生成


#if __IPHONE_OS_VERSION_MAX_ALLOWED <= __IPHONE_6_0
        //タブのタイトル指定
//        [tabHomeVC setTitle:NSLocalizedString(@"NavTabHome", nil)];
//        [tabRankingVC setTitle:NSLocalizedString(@"NavTabRanking", nil)];
//        [tabRecordVC setTitle:NSLocalizedString(@"NavTabRecord", nil)];
//        [tabInfoVC setTitle:NSLocalizedString(@"NavTabInfo", nil)];
//        [tabProfileVC setTitle:NSLocalizedString(@"NavTabProfile", nil)];
        //タブのアイコン指定
        [tabHomeVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"btn_home.png"]
                           withFinishedUnselectedImage:[UIImage imageNamed:@"btn_home.png"]];
        [tabRankingVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"btn_rank.png"]
                              withFinishedUnselectedImage:[UIImage imageNamed:@"btn_rank.png"]];
        [tabRecordVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"btn_camera.png"]
                              withFinishedUnselectedImage:[UIImage imageNamed:@"btn_camera.png"]];
        [tabInfoVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"btn_notice.png"]
                           withFinishedUnselectedImage:[UIImage imageNamed:@"btn_notice.png"]];
        [tabProfileVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"btn_user.png"]
                              withFinishedUnselectedImage:[UIImage imageNamed:@"btn_user.png"]];
//        //タブのタイトル色指定
//        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
//        //タブのタイトル色指定(選択中)
//        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.0f], UITextAttributeTextColor,nil] forState:UIControlStateSelected];

#endif


    }
    
  
    // タブのフォント指定
    // UIFont *tabFont = [UIFont fontWithName:@"HelveticaNeue" size:9.0f];
    //タブのタイトル位置設定
    //[[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -4)];


    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
//    UINavigationController *firstNavi = [[UINavigationController alloc] initWithRootViewController:tabHomeVC];
//    [firstNavi setNavigationBarHidden:NO];
//    [viewControllers addObject:firstNavi];
    
    [tabHomeVC setNavigationBarHidden:NO];
    [viewControllers addObject:tabHomeVC];
    
    
    
//    UINavigationController *secondNavi = [[UINavigationController alloc] initWithRootViewController:tabRankingVC];
//    [secondNavi setNavigationBarHidden:NO];
//    [viewControllers addObject:secondNavi];
    
    [tabRankingVC setNavigationBarHidden:NO];
    [viewControllers addObject:tabRankingVC];
    
//    UINavigationController *thirdNavi = [[UINavigationController alloc] initWithRootViewController:tabRecordVC];
//    [thirdNavi setNavigationBarHidden:YES];
//    [viewControllers addObject:thirdNavi];
    
    [viewControllers addObject:tabRecordVC];

    UINavigationController *fourthNavi = [[UINavigationController alloc] initWithRootViewController:tabInfoVC];
    //fourthNavi.navigationItem.backBarButtonItem = nil;
    [fourthNavi setNavigationBarHidden:NO];
    [viewControllers addObject:fourthNavi];

    UINavigationController *fifthNavi = [[UINavigationController alloc] initWithRootViewController:tabProfileVC];
    [fifthNavi setNavigationBarHidden:NO];
    [viewControllers addObject:fifthNavi];
    
    //[viewControllers addObject:tabProfileVC];
    
//    [tabProfileVC setNavigationBarHidden:NO];
//    [viewControllers addObject:tabProfileVC];
    
    [self setViewControllers:viewControllers animated:NO];
    
//    self.viewControllers = [NSArray arrayWithObjects:
//                            tabHomeVC,
//                            tabRankingVC,
//                            tabRecordVC,
//                            tabInfoVC,
//                            tabProfileVC,
//                            nil];
    
    // お知らせタブ：バッジ表示
    NSNumber *badgeNum = [Configuration loadInfoBadge];
    if([badgeNum isKindOfClass:[NSNumber class]] && [badgeNum intValue] > 0){
        [tabInfoVC.tabBarItem setBadgeValue:[badgeNum stringValue]];
    }
    
    // ダミーのタブバー背景
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    // タブバーの下線を消す
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];

    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    [[UITabBar appearance] setTintColor:[UIColor clearColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor clearColor]];
    
    
//    hiddenTabBar = 1;
//    [self hideTabBarAction];
    
    
    // 起動タブを変更したい場合
    self.selectedIndex = 0;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    //self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
}


#pragma mark UITabBarControllerDelegate Methods
//appDelegateにデリゲートを設定しているので、こちらは使用していない模様 @hyokozeki
// タブが切替られたときに呼び出されるデリゲートメソッド
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
     NSLog(@"test");
//    // プロトコルを実装しているかのチェック
//    if ([viewController conformsToProtocol:@protocol(NaviTabBarViewControllerDelegate)]) {
//        // 各UIViewControllerのデリゲートメソッドを呼ぶ
//        [(UIViewController<NaviTabBarViewControllerDelegate>*)viewController didSelect:self];
//    }
    
    //AudioServicesPlaySystemSound(sound_menu);
    
    //DLog(@"selcted002 : %ld@", (unsigned long)self.selectedIndex);
    if(self.selectedIndex == 0){
        // home
        //self.tabBar.backgroundImage = [UIImage imageNamed:@"tab_background_001.png"];
        //UITabBarItem *tbi = [self.tabBar.items objectAtIndex:0];
        //tbi.image = [UIImage imageNamed:@"btn_tab_ranking.png"];
        
    }else if (self.selectedIndex == 1){
        // ranking
        //self.tabBar.backgroundImage = [UIImage imageNamed:@"tab_background_002.png"];
    }else if (self.selectedIndex == 2){
        
        NSLog(@"test");

        // record
        //self.tabBar.backgroundImage = [UIImage imageNamed:@"tab_background_003.png"];
        //self.tabBar.hidden = YES;
        //self.navigationController.navigationBarHidden = YES;

        hiddenTabBar = 1;
        //[self hideTabBarAction];
        
        //[self.navigationController setNavigationBarHidden:YES animated:YES];
        
    }else if (self.selectedIndex == 3){
        // info
        //self.tabBar.backgroundImage = [UIImage imageNamed:@"tab_background_004.png"];
    }else if (self.selectedIndex == 4){
        // profile
        //self.tabBar.backgroundImage = [UIImage imageNamed:@"tab_background_004.png"];
    }else{
        // other
        //self.tabBar.backgroundImage = [UIImage imageNamed:@"tab_background.png"];
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        [navigationController popToRootViewControllerAnimated:YES];
    }
}



// iOS7 check
- (BOOL)isIOS7
{
    NSString *osversion = [UIDevice currentDevice].systemVersion;
    NSArray *a = [osversion componentsSeparatedByString:@"."];
    return ([(NSString*)[a objectAtIndex:0] intValue] >= 7);
}

// hidden tabbar
- (void) hideTabBarAction {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    for(UIView *view in self.view.subviews)
    {

        NSLog(@"%d@", hiddenTabBar);
        
        CGRect _rect = view.frame;
        if([view isKindOfClass:[UITabBar class]])
        {
            if (hiddenTabBar) {
                //_rect.origin.y = 431;
                _rect.origin.y = view.frame.origin.y + 49;
                
                [view setFrame:_rect];
            } else {
                //_rect.origin.y = 480;
                _rect.origin.y = view.frame.origin.y;
                
                [view setFrame:_rect];
            }
        } else {
            if (hiddenTabBar) {
                //_rect.size.height = 431;
                _rect.size.height = view.frame.origin.y + 49;
                
                [view setFrame:_rect];
            } else {
                //_rect.size.height = 480;
                _rect.size.height = view.frame.origin.y;
                
                [view setFrame:_rect];
            }
        }
    }
    [UIView commitAnimations];
    
    hiddenTabBar = !hiddenTabBar;
}

// setting status bar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
