//
//  HomeTabPagerViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "HomeTabPagerViewController.h"
#import "GUITabPagerViewController.h"
#import "HomeViewController.h"
#import "UserViewController.h"
#import "DetailViewController.h"
#import "VYNotification.h"
#import "NSNotification+Parameters.h"
#import "TrackingManager.h"
#import "SVProgressHUD.h"
#import "MasterManager.h"
#import "ConfigLoader.h"
#import "NetworkErrorView.h"
#import "NaviViewController.h"
#import "InfoWebViewController.h"
#import "SearchViewController.h"
#import "RssNewsViewController.h"
#import "MessagingTableViewController.h"
#import "Defines.h"
#import "Appirater.h"
#import "CommonUtil.h"
#import "CategoryManager.h"
#import "Category.h"
#import "UIViewController+NoNetWork.h"
#import "UIViewController+Categories.h"

#import <SendBirdSDK/SendBirdSDK.h>

@interface HomeTabPagerViewController () <GUITabPagerDataSource, UIPageViewControllerDelegate,UIWebViewDelegate>

@property (nonatomic) UIWebView* WebView;
@end

//@implementation UINavigationBar (customNav)
//- (CGSize)sizeThatFits:(CGSize)size {
//    CGSize newSize = CGSizeMake(self.frame.size.width,30);
//    return newSize;
//}
//@end

@implementation HomeTabPagerViewController

@synthesize userId = _userId;
@synthesize postId = _postId;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDataSource:self];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    
    // navigationbar underline hide
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    // 配下のナビゲーション戻るボタンカスタマイズ
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    

    // ----------------------
    // Notification Recieve
    // ----------------------
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleReceivedMoveUserPageNotificationObject:) name:VYUserRankingToHomeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(handleReceivedMovePostPageNotificationObject:) name:VYPostRankingToHomeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(handleReceivedMoveUserPageNotificationObject:) name:VYUserInfoToHomeNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tappedNotification:) name:VYInfoDetailNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(handleHomeReloadPostNotificationObject:) name:VYHomeReloadPostNotification object:nil];

    
    DLog(@"height : %f)", self.view.frame.size.height);
    
    [self doTaskAsynchronously:^{
        // ----------------
        // 投稿カテゴリ更新＋投稿一覧取得
        // ----------------
        
        if (self.noNetwork) {
            [self showNetWorkErrorView];
            return;
        }
        [self loadCategories:^{
            [self reloadData];
        } fail:^(NSNumber *code) {
            [self showNetWorkErrorView:[NSString stringWithFormat:@"Can not get categories. status code: %@",code]];
        }];
    }];
    


    // ----------------
    // 並び順設定
    // ----------------
    // sortSegmentedControl
    self.sortSegmentedControl.tintColor = [UIColor whiteColor];
    //NSArray *sortItems = [NSArray arrayWithObjects:NSLocalizedString(@"PageHomeSortNew", nil), NSLocalizedString(@"PageHomeSortPop", nil), nil];
    //self.sortSegmentedControl = [[UISegmentedControl alloc]initWithItems:sortItems];
    
    [self.sortSegmentedControl setTitle:NSLocalizedString(@"PageHomeSortNew", nil) forSegmentAtIndex:1];
    [self.sortSegmentedControl setTitle:NSLocalizedString(@"PageHomeSortPop", nil) forSegmentAtIndex:0];
    // init selected
    self.sortSegmentedControl.selectedSegmentIndex = 0;
    // segment action
    [self.sortSegmentedControl addTarget:self action:@selector(selctedSort:) forControlEvents:UIControlEventValueChanged];

    self.navigationItem.titleView = _sortSegmentedControl;
    
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [searchBtn setImage:[UIImage imageNamed:@"ico_search.png"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(openSearchView:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    //メッセージボタン設置
    self.messageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 22)];
    [self.messageBtn setImage:[UIImage imageNamed:@"ico_message.png"] forState:UIControlStateNormal];
    self.barMessageBtn = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:self.messageBtn];
    self.navigationItem.leftBarButtonItem = self.barMessageBtn;
    
    [self setUpForNavigationItemChange];
    
     DLog(@"height : %f)", self.view.frame.size.height);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

// --------------------------
// ここでHomeのバー消したりが可能
// --------------------------
    // ナビは表示
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    //self.navigationItem.titleView = _sortSegmentedControl;
    
    // postIdの指定があれば、投稿詳細へ
    // いらないかも : back_ranking back_info back_profile があれば、各ナビへ移動
    
    
//    DLog(@"height : %f", super.view.frame.size.height);
//    CGRect frame = super.view.frame;
//    frame.size.height = frame.size.height + 20;
//    [super.view setFrame:frame];
//    super.view.frame = frame;
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"Home"];
    
    
    DLog(@"height : %f", self.view.frame.size.height);
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [CommonUtil delay:3.0f block:^{
        //レビューのプロンプト
        [Appirater appLaunched:YES];
    }];
    
    // 投稿IDの指定がある場合には、画面遷移する
    if(self.postId){

        DLog(@"HomeTabPagerView autoMovePost");

        DetailViewController *detailController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
        detailController = [detailController initWithPostID:self.postId];
        [detailController loadPost];
        
        // 画面遷移実行後に、ナビゲーション表示へ
        [self.navigationController setNavigationBarHidden:NO animated:NO];

        //double delayInSeconds = 0.1;
        //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        //dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController pushViewController:detailController animated:YES];
            // reset
            self.postId = 0;
        //});
    }
    
    // アカウントIDの指定がある場合には、画面遷移する
    if(self.userId){

        DLog(@"HomeTabPagerView autoMoveUser");
        
        UserViewController *userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
        // 他人画面
        userViewController.isMmine = false;
        userViewController.userPID = self.userId;
        [userViewController preloadingPosts];
        
        // 画面遷移実行後に、ナビゲーション表示へ
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        
        [self.navigationController pushViewController:userViewController animated:YES];
        // reset
        self.userId = 0;
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //[notificationCenter removeObserver:self];

    // 画面を離れる場合は、ナビ表示
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

//ナビゲーションのタイトルをカテゴリーによって変えるときのため
-(void)setUpForNavigationItemChange{
    
    //ナビゲーションのタイトル
    self.superMyrecoTitleView = [[UILabel alloc] initWithFrame:CGRectZero];
    self.superMyrecoTitleView.font = JPBFONT(17);
    self.superMyrecoTitleView.textColor = [UIColor whiteColor];
    self.superMyrecoTitleView.text = @"MyReco";
    [self.superMyrecoTitleView sizeToFit];
    self.navigationItem.titleView.alpha = 0;
    self.navigationItem.titleView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:1.0f animations:^{
        self.navigationItem.titleView.alpha = 0;
        self.navigationItem.titleView.alpha = 1;
    }];
    //スーパークラスのアイテムを初期化
    self.superSortSegmentControl = _sortSegmentedControl;
}

//ナビゲーションのタイトルをカテゴリーによって変える
-(void)changeNavinationItem:(UIWebView *)nextViewController
{
    //change navigation item.
    if(![nextViewController isKindOfClass:[UICollectionView class]]){
        if ([self.navigationItem.titleView isKindOfClass:[UISegmentedControl class]]) {
            
            self.navigationItem.titleView = self.superMyrecoTitleView;
            [UIView animateWithDuration:1.0f animations:^{
                self.navigationItem.titleView.alpha = 0;
                self.navigationItem.titleView.alpha = 1;
            }];
        }
        else{
            self.navigationItem.titleView = self.superMyrecoTitleView;
        }
    }
    else{
        if ([self.navigationItem.titleView isKindOfClass:[UILabel class]]) {
            
            self.navigationItem.titleView = self.sortSegmentedControl;
            [UIView animateWithDuration:1.0f animations:^{
                self.navigationItem.titleView.alpha = 0;
                self.navigationItem.titleView.alpha = 1;
            }];
        }
        else{
            self.navigationItem.titleView = self.sortSegmentedControl;
        }
    }
}
- (void)backWebView:(UITapGestureRecognizer *)recognizer
{
    //現在のWebViewを取得し戻る
    if ([[self.currentPageController.view subviews][0] isKindOfClass:[UIWebView class]]) {
        UIWebView *currentWebView = [self.currentPageController.view subviews][0];
        [currentWebView goBack];
    }
    
}

#pragma mark - Page View Delegate

// スクロール時に並び替えの順番を渡す
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    //NSInteger index = [[self viewControllers] indexOfObject:pendingViewControllers[0]];
    //[[self header] animateToTabAtIndex:index];
    
    
    if([pendingViewControllers[0] isKindOfClass:[HomeViewController class]]){
        HomeViewController *nextHomeView = (HomeViewController *)pendingViewControllers[0];
        if(nextHomeView.sortType != self.sortType){
            nextHomeView.isLoadingApi = YES;
        }
        nextHomeView.sortType = (int)self.sortSegmentedControl.selectedSegmentIndex;
        self.currentPageController = nextHomeView;
    }
}

- (NSInteger)numberOfViewControllers {
    // カテゴリー個数取得し判定
    return [CategoryManager sharedManager].parentCategories.count;
}

- (UIViewController *)changeViewControllerForIndex:(UIViewController *)targetViewController {
    if([targetViewController isKindOfClass:[HomeViewController class]]){
        HomeViewController *nextHomeView = (HomeViewController *)targetViewController;
        if(nextHomeView.sortType != self.sortType){
            nextHomeView.isLoadingApi = YES;
        }
        nextHomeView.sortType = (int)self.sortSegmentedControl.selectedSegmentIndex;
        self.currentPageController = nextHomeView;
        
        //タブタップ時にナビゲーションのタイトルをカテゴリーによって変える.
        [self changeNavinationItem:[nextHomeView.view subviews][0]];
        
        return nextHomeView;
    }
    
    return nil;
}

- (UIViewController *)viewControllerForIndex:(NSInteger)index {
    UIViewController *vc = [UIViewController new];
    [[vc view] setBackgroundColor:[UIColor colorWithRed:arc4random_uniform(255) / 255.0f
                                                  green:arc4random_uniform(255) / 255.0f
                                                   blue:arc4random_uniform(255) / 255.0f alpha:1]];
    
    HomeViewController *homeView    = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
    
    
    //if homeview is nil,set network error view.
    if(homeView == nil){
        HomeViewController*errorbaseView = [HomeViewController alloc];
        NetworkErrorView *errorView = [[NetworkErrorView alloc] init];
        [errorbaseView.view addSubview:errorView ];
        homeView = errorbaseView;
    }
    homeView.categoryID = 0;

    // category を設定
    Category_ *category;
    if ([CategoryManager sharedManager].parentCategories.count) {
        category = [[CategoryManager sharedManager].parentCategories objectAtIndex:index];
        homeView.categoryID = category.pk;
    }
    
    // Pre loading -> Post List : 並び替えで意味なくなるのでやらない
    //[homeView refreshPosts:NO sortedFlg:YES];
    //初期Viewを最初のcurrentViewへ設定
    if (index == 0) {
        self.currentPageController = homeView;
    }
    //以下MyRecoの記事設定
    else if(category.isRSS){
        //RSS
        HomeViewController *homeViewController = [[HomeViewController alloc] init];
        homeViewController.isRss = YES;
        self.rssNewsViewController = [[RssNewsViewController alloc] initWithCategory:category];
        [homeViewController.view addSubview:self.rssNewsViewController.view];
        homeView = homeViewController;
    }
    return homeView;
}
/**
 * Webページのロード時にインジケータを動かす
 */
- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


/**
 * Webページのロード完了時にインジケータを非表示にする
 */
- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if(webView.canGoBack){
        self.navigationItem.leftBarButtonItems = @[self.navigationItem.backBarButtonItem];
    }else{
        self.navigationItem.leftBarButtonItem = nil;
    }
}

//homeviewをベースに与えられたwebviewを返す
- (id) getWebView:(HomeTabPagerViewController*)selfi :(NSString*)URL
{
    
    HomeViewController*WebViewC = [HomeViewController alloc];
    //-25で下までスクロールできない問題解決
    self.WebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 25)];
    
    self.WebView.scalesPageToFit = YES;
    self.WebView.delegate = selfi;
    
    NSURL *url = [NSURL URLWithString:URL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [self.WebView loadRequest:req];
    
    [WebViewC.view addSubview:self.WebView ];
    
    
    return WebViewC;
}

- (NSString *)titleForTabAtIndex:(NSInteger)index {
    
    if ([CategoryManager sharedManager].parentCategories.count) {
        Category_ *category = [[CategoryManager sharedManager].parentCategories objectAtIndex:index];
        return category.label;
    }
    return @"";
}

- (CGFloat)tabHeight {
    // Default: 44.0f
    //return 26;
    return 26.0f;
}

- (UIColor *)tabColor {
    // Default: [UIColor orangeColor];
    //return [UIColor clearColor];
    //return HEADER_BG_COLOR;
    //return [UIColor whiteColor];
    return HEADER_BG_COLOR;

}

-(IBAction)openSearchView:(id)sender{
    
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    // 自身に移動してからpush viewしないと変な遷移になる。
    [UIView transitionFromView:self.view
                        toView:searchViewController.view
                      duration:0.1
                       options:UIViewAnimationOptionTransitionNone
                    completion:
     ^(BOOL finished) {
         [self.currentPageController.navigationController pushViewController:searchViewController animated:YES];
     }];
}

//push 通知をタップするとお知らせ一覧へ飛ぶ
- (void) tappedNotification:(NSNotification *)notification
{
    DLog("tappedNotification");
    
    //現在開いているView
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    VYReceivedMessageNotificationParameters *parameters = notification.parameters;
    
    //SendBirdのメッセージの場合はInfoに移動しないので分けた.
    if (parameters.is_sendbird_message) {
        @try {
            HomeViewController *homeView = (HomeViewController*)[self.childViewControllers[0] childViewControllers][0];
            if ([homeView isKindOfClass:[HomeViewController class]]) {
                
                // tab背景(homeを選択させる)
                UIImage *tabBarHomeImg = [UIImage imageNamed:@"bg_nav-on01.png"];
                UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
                [tabBarHomeImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
                tabBarHomeImg = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                self.tabBarController.tabBar.backgroundImage = tabBarHomeImg;
                self.tabBarController.selectedViewController = self.navigationController;
                
                //メッセージリストを開く.
                [homeView openMessageListView:nil];
            }
        }
        @catch (NSException *exception) {
            return;
        }
        return;
    }
    
    //お知らせタブを取得
    UINavigationController *infoViewNavi = self.tabBarController.viewControllers[3];
    
    
    //お知らせタブを選択状態に
    self.tabBarController.selectedViewController = infoViewNavi;
    
    //お知らせを更新しておく
    InfoViewController * infoView = infoViewNavi.childViewControllers[0];
    [infoView refreshInfos:YES];
    
    //おしらせタブのnavigationcontroller内をRootViewへ戻す
    [infoViewNavi popToRootViewControllerAnimated:NO];
    
    //戻るボタンのタイトルをなくすために作り直し
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    infoViewNavi.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    infoViewNavi.navigationItem.backBarButtonItem.title = @"";
    
    // tab背景
    UIImage *tabBarInfoImg = [UIImage imageNamed:@"bg_nav-on04.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
    [tabBarInfoImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
    tabBarInfoImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.tabBarController.tabBar.backgroundImage = tabBarInfoImg;
    
    //投稿画面を開いている場合はモーダルを閉じてから遷移
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UINavigationController * postViewNavi = (UINavigationController *)topController;
        PostViewController *postView = postViewNavi.childViewControllers[0];
        
        // flash状態を保持してしまうようなので、リセット
        if(postView.flashBtn.selected){
            [postView.cameraManager lightToggle];
        }
        [postView dismissViewControllerAnimated:YES completion:^{
        }];
    }
    
    if (parameters.url) {
        
        //公式ニュースの場合URL先へ飛ばす
        InfoWebViewController * infoWebView = [[InfoWebViewController alloc] initWithURL:parameters.url];
        [infoViewNavi pushViewController:infoWebView animated:YES];
        
    }
    else if(parameters.user_id && parameters.user_pid){
        
        //フォローされた時はフォローしたユーザー画面へ飛ばす
        UserViewController *userView = nil;
        userView = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
        
        userView = [userView initWithUserPID:[NSNumber numberWithInt:[parameters.user_id intValue]] userID:parameters.user_pid];
        
        [userView preloadingPosts];
        
        [infoViewNavi pushViewController:userView animated:YES];
        
    }
    else if(parameters.post_id){
        
        //いいねのときはいいねされた投稿へ
        DetailViewController *detailView = nil;
        detailView = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
        
        [detailView initWithPostID:[NSNumber numberWithInt:[parameters.post_id intValue]]];
        
        //投稿を読み込んでおく
        [detailView loadingPostWidthPostID:[NSNumber numberWithInt:[parameters.post_id intValue]]];
        
        
        //投稿画像読み込みが遅れる場合のために遅延
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [infoViewNavi pushViewController:detailView animated:YES];
        });
        
    }
    else if(parameters.category_id){
        
        //順位変動の時はそのカテゴリーのランキングへ
        RankingViewController *rankingView = nil;
        rankingView = [[UIStoryboard storyboardWithName:@"Ranking" bundle:nil ] instantiateViewControllerWithIdentifier:@"RankingViewController"];
        
        [rankingView initWithCategoryID:[NSNumber numberWithInt:[parameters.category_id intValue]]];
        
        NSMutableString * category_name = [[NSMutableString alloc] init];
        for (Category_ *category in [CategoryManager sharedManager].parentCategories) {
            if ([[category.pk stringValue] isEqualToString:parameters.category_id]) {
                [category_name appendString:category.label];
            }
        }
        
        [rankingView.navigationItem setTitleView:[CommonUtil getNaviTitle:category_name]];
        
        [infoViewNavi pushViewController:rankingView animated:YES];
        
    }else{
        //その他のおしらせ
    }

}

// ---------------------
// Notification Metod
// ---------------------
// ユーザID 投稿IDによる画面切替処理
- (void)handleReceivedMoveUserPageNotificationObject:(NSNotification *)notification
{
    VYNotificationParameters *parameters = notification.parameters;
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENPROFILE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]:
                                          NSStringFromClass([notification.object class]),
                                      DEFINES_REPROEVENTPROPNAME[TAPPED]:
                                          DEFINES_REPROEVENTPROPITEM[NAME]}];
    
    if(parameters.userId) {
        // reset
        self.userId = 0;
        DLog(@"HomeTabPagerView autoMoveUser");

        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController.navigationBar setHidden:NO];
        
        UserViewController *userViewController = nil;
        userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
        // 他人画面
        userViewController.isMmine = false;
        userViewController.userPID = parameters.userId;
        [userViewController preloadingPosts];
        
        [self.navigationController pushViewController:userViewController animated:YES];

    }
}

- (void)handleReceivedMovePostPageNotificationObject:(NSNotification *)notification
{
    VYNotificationParametersInfo *parameters = notification.parameters;
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENDETAIL]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]:
                                          NSStringFromClass([notification.object class])}];
    
    if(parameters.postId) {
        // reset
        self.postId = 0;
        DLog(@"HomeTabPagerView autoMovePost");
        
        // TODO ナビゲーションバーが消えてしまう
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.navigationController.navigationBar setHidden:NO];

        // 画面遷移実行後に、ナビゲーション表示へ
        self.navigationController.navigationBarHidden = NO;
        
        DetailViewController *detailController = nil;
        detailController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
        
        [[PostManager sharedManager] getPostInfo:parameters.postId aToken:[Configuration loadAccessToken] block:^(NSNumber *result_code, Post *post, NSMutableDictionary *responseBody, NSError *error) {
            //動画のために画像をセットしておく
            detailController.post = post;
            detailController.postID = parameters.postId;
            [detailController loadPost];
            if (post.isMovie) detailController.postImageTempView = parameters.postImgView;
            [self.navigationController pushViewController:detailController animated:YES];
        }];
    }
}

// Home再読み込み
- (void)handleHomeReloadPostNotificationObject:(NSNotification *)notification
{
    self.currentPageController.sortType = self.sortType;
    self.currentPageController.postManager = [PostManager new];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.currentPageController refreshPosts:YES sortedFlg:NO];
    });
    //[self.currentPageController refreshPosts:YES sortedFlg:NO];
}

// 並び変えAction
-(void)selctedSort:(UISegmentedControl*)sender{
    DLog(@"HomeTabPagerView selectedSort");
    
    // sender.selectedSegmentIndex
    DLog(@"%ld", (long)sender.selectedSegmentIndex);
    
    if(sender.selectedSegmentIndex == VLHOMESORTNEW){
        // selected : NEW
        self.sortType = VLHOMESORTNEW;
    }else{
        // selected : POP
        self.sortType = VLHOMESORTPOP;
    }
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[HOMESORT]
                         properties:@{DEFINES_REPROEVENTPROPNAME[TYPE] :
                                          [NSNumber numberWithInteger:self.sortType]}];
    
    // selected category and sort_id send
    
//    if ([self.delegate respondsToSelector:@selector(sortAction:)]) {
//        NSNumber *sortIndexNum = [NSNumber numberWithInteger:sender.selectedSegmentIndex];
//        
//        [self.delegate sortAction:sortIndexNum];
//    }

    self.currentPageController.sortType = self.sortType;
    [self.currentPageController.cv setContentOffset:self.currentPageController.cv.contentOffset animated:NO];
    
    [self.currentPageController refreshPosts:YES sortedFlg:YES];
    
    
}

//投稿の一番上へスクロール.
-(void)toTop
{
    //投稿がなければ抜ける
    if ([self.currentPageController shouldShowMessage]) {
        return;
    }
    
    for (UIView * subview in self.currentPageController.view.subviews) {
        
        //投稿一覧の場合
        if ([subview isKindOfClass:[UICollectionView class]] && [((UICollectionView * )subview) numberOfItemsInSection:HOME_POSTS_SECTION]) {
            [(UICollectionView * )subview scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                 atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                         animated:YES];
            return;
        }
        
        //Rssの場合
        if ([subview.nextResponder isKindOfClass:[RssNewsViewController class]]) {
            for (UIView * subsubview in subview.subviews) {
                if ([subsubview isKindOfClass:[UITableView class]]) {
                    [(UITableView * )subsubview setContentOffset:CGPointZero animated:YES];
                    return;
                }
            }
        }
        
    }
}

///非同期処理
- (void)doTaskAsynchronously:(void(^)())block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        block();
    });
}

#pragma mark - NetworkErrorViewDelete

- (void)noNetworkRetry
{
    DLog(@"HomeView no Network Retry");
    [self retry:^{
        [self loadCategories:^{
            [self reloadData];
        } fail:^(NSNumber *code) {
            [self showNetWorkErrorView:[NSString stringWithFormat:@"Can not get categories. status code: %@",code]];
        }];
    } fail:^{
    }];
}

@end
