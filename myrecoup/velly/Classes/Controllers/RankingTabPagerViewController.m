//
//  RankingTabPagerViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/23.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RankingTabPagerViewController.h"
#import "RankingViewController.h"
#import "VYNotification.h"
#import "NSNotification+Parameters.h"
#import "TrackingManager.h"
#import "SVProgressHUD.h"
#import "MasterManager.h"
#import "ConfigLoader.h"
#import "CommonUtil.h"
#import "Defines.h"
#import "Category.h"
#import "CategoryManager.h"
#import "UIViewController+NoNetWork.h"
#import "UIViewController+Categories.h"

@interface RankingTabPagerViewController () <GUITabPagerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray* categories;

@end

@implementation RankingTabPagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
    [self setDataSource:self];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // ----------------
    // sort setting
    // ----------------
    // sortSegmentedControl
    self.sortSegmentedControl.tintColor = [UIColor whiteColor];
    //NSArray *sortItems = [NSArray arrayWithObjects:NSLocalizedString(@"PageHomeSortNew", nil), NSLocalizedString(@"PageHomeSortPop", nil), nil];
    //self.sortSegmentedControl = [[UISegmentedControl alloc]initWithItems:sortItems];
    
    [self.sortSegmentedControl setTitle:NSLocalizedString(@"PageRankingSortPro", nil) forSegmentAtIndex:0];
    [self.sortSegmentedControl setTitle:NSLocalizedString(@"PageRankingSortNormal", nil) forSegmentAtIndex:1];
    // init selected
    self.sortSegmentedControl.selectedSegmentIndex = 0;
    // segment action
    [self.sortSegmentedControl addTarget:self action:@selector(selctedSort:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _sortSegmentedControl;
    
    // ----------------------
    // Notification Recieve
    // ----------------------
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleRankingReloadPostNotificationObject:) name:VYRankingReloadUserNotification object:nil];
    if(self.noNetwork) {
        [self showNetWorkErrorView];
        return;
    }
    [self loadCategories:^{
        [self reloadData];
    } fail:^(NSNumber *code) {
        [self showNetWorkErrorView:[NSString stringWithFormat:@"Can not get categories. status code: %@",code]];
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self reloadData];

    [self.navigationController setNavigationBarHidden:NO animated:NO];

    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"Ranking"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

#pragma mark - Page View Delegate

// スクロール時に並び替えの順番を渡す
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {

    //NSInteger index = [[self viewControllers] indexOfObject:pendingViewControllers[0]];
    //[[self header] animateToTabAtIndex:index];

    if([pendingViewControllers[0] isKindOfClass:[RankingViewController class]]){
        RankingViewController *nextRankingView = (RankingViewController *)pendingViewControllers[0];
        if(nextRankingView.sortType != self.sortType){
            nextRankingView.isLoadingApi = YES;
        }
        nextRankingView.sortType = (int)self.sortSegmentedControl.selectedSegmentIndex;
        self.currentPageController = nextRankingView;
    }

}


- (NSInteger)numberOfViewControllers {

    // カテゴリー個数取得し判定
    return self.categories.count;
}

- (UIViewController *)changeViewControllerForIndex:(UIViewController *)targetViewController {
    if([targetViewController isKindOfClass:[RankingViewController class]]){
        RankingViewController *nextRankingView = (RankingViewController *)targetViewController;
        if(nextRankingView.sortType != self.sortType){
            nextRankingView.isLoadingApi = YES;
        }
        nextRankingView.sortType = (int)self.sortSegmentedControl.selectedSegmentIndex;
        self.currentPageController = nextRankingView;
        return nextRankingView;
    }
    return nil;
}

- (UIViewController *)viewControllerForIndex:(NSInteger)index {
    UIViewController *vc = [UIViewController new];
    [[vc view] setBackgroundColor:[UIColor colorWithRed:arc4random_uniform(255) / 255.0f
                                                  green:arc4random_uniform(255) / 255.0f
                                                   blue:arc4random_uniform(255) / 255.0f alpha:1]];
    
    RankingViewController *rankingView    = [[UIStoryboard storyboardWithName:@"Ranking" bundle:nil ] instantiateViewControllerWithIdentifier:@"RankingViewController"];

//    [rankingView initWithCategoryID:[[NSString alloc]initWithFormat:@"%d", index]];
//    RankingViewController *rankingView = [[RankingViewController alloc]initWithCategoryID:[[NSString alloc]initWithFormat:@"%d", index]];

    
    // category を設定
    Category_ *category = [_categories objectAtIndex:index];
    if(category && ![category isKindOfClass:[NSNull class]]){
        // set categoy id
        NSNumber *jCategoryID = 0;
        jCategoryID = category.pk;
        rankingView.categoryID = jCategoryID;
        //[rankingView refreshRankings:YES sortedFlg:NO];
    }
    //self.delegate = (id)rankingView.self;
    // Pre loading -> Ranking List : 並び替えで意味なくなるのでやらない
    //[rankingView refreshRankings:NO sortedFlg:NO];
    
    if(index == 0){
        // init default page
        self.currentPageController = rankingView;
    }
    
    return rankingView;
}

- (NSString *)titleForTabAtIndex:(NSInteger)index {
    // ヘアアレンジ、ヘアスタイル、ネイル、メイク、コスメ、ダイエット、スキンケア、ボディケア、エクササイズ、その他
    Category_ *category = [self.categories objectAtIndex:index];
    return category.label;
}

- (CGFloat)tabHeight {
    // Default: 44.0f
    return 26.0f;
}

- (UIColor *)tabColor {
    // Default: [UIColor orangeColor];
    //return [UIColor clearColor];
    return HEADER_BG_COLOR;
    
}


// Ranking再読み込み
- (void)handleRankingReloadPostNotificationObject:(NSNotification *)notification
{
    self.currentPageController.sortType = self.sortType;
    //self.currentPageController.rankingManager = [RankingManager new];
    [self.currentPageController refreshRankings:YES sortedFlg:YES];
}

#pragma custom method

///未定義ならカテゴリをセットして返す
- (NSMutableArray *)categories {
    if (!_categories) {
        @synchronized(_categories){
            _categories = [[NSMutableArray alloc] init];
            for (Category_ *category in [CategoryManager sharedManager].parentCategories) {
                if (category.allow_post) {
                    [_categories addObject:category];
                }
            }
        }
    }
    return _categories;
}

#pragma mark controller action

// ---------------
// sort Action
// ---------------
-(void)selctedSort:(UISegmentedControl*)sender{
    DLog(@"RankingTabPagerView selectedSort");
    
    // sender.selectedSegmentIndex
    DLog(@"%ld", (long)sender.selectedSegmentIndex);
    
    if(sender.selectedSegmentIndex == VLRANKINGSORTPRO){
        // selected : PRO
        self.sortType = VLRANKINGSORTPRO;
    }else{
        // selected : NORMAL
        self.sortType = VLRANKINGSORTNORMAL;
    }
    
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[RANKINGSORT]
                         properties:@{DEFINES_REPROEVENTPROPNAME[TYPE] :
                                          [NSNumber numberWithInteger:self.sortType]}];

    // selected category and sort_id send
    
//    if ([self.delegate respondsToSelector:@selector(sortAction:)]) {
//        NSNumber *sortIndexNum = [NSNumber numberWithInteger:sender.selectedSegmentIndex];
//
//        [self.delegate sortAction:sortIndexNum];
//    }

    self.currentPageController.sortType = self.sortType;
    [self.currentPageController refreshRankings:YES sortedFlg:YES];
    
}

- (void)noNetworkRetry
{
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
