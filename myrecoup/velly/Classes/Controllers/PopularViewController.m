//
//  PopularViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/28.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PopularViewController.h"
#import "PopularTableViewCell.h"
#import "UserManager.h"
#import "FollowManager.h"
#import "Popular.h"
#import "HomeTabPagerViewController.h"
#import "DetailViewController.h"
#import "NoPasswdViewController.h"
#import "VYNotification.h"
#import "UINavigationBar+Awesome.h"
#import "SVProgressHUD.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "NetworkErrorView.h"
#import "UserViewController.h"
#import "MasterManager.h"
#import "CommonUtil.h"

#import "STTwitter.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface PopularViewController () <NetworkErrorViewDelete>

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (weak, nonatomic) IBOutlet UIImageView *twImageView;
@property (weak, nonatomic) IBOutlet UIImageView *twLoginedImageView;
@property (weak, nonatomic) IBOutlet UIButton *twBtn;
@property (weak, nonatomic) IBOutlet UIImageView *fbImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fbLoginedImageView;
@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
@property (weak, nonatomic) IBOutlet UIView *twView;
@property (weak, nonatomic) IBOutlet UIView *fbView;
@property (weak, nonatomic) IBOutlet UIImageView *ttl_snsImageView;
@property (weak, nonatomic) IBOutlet UILabel *snsTitleView;
@property (weak, nonatomic) IBOutlet UILabel *recommTitleView;
@property (weak, nonatomic) IBOutlet UIImageView *recommTitleUserImgView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *populars;
//@property (strong, nonatomic) NSMutableDictionary *popularIdList;

@property (nonatomic, strong) NSString *userID;
@property (nonatomic) NSUInteger *popularPage;

@property (nonatomic, assign) int isTw;
@property (nonatomic, assign) int isFb;

@property (nonatomic) BOOL isTapAction;

@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

static CGFloat kLoadingCellHeight = 152.0f;

@implementation PopularViewController

@synthesize userID;

- (id) initWithUserID:(NSString *)t_userID {
    if(!self) {
        self = [[PopularViewController alloc] init];
    }
    self.userID = t_userID;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigation
    [self.navigationItem setTitleView:[CommonUtil getNaviTitle:NSLocalizedString(@"Recommend", nil)]];
    self.navigationItem.titleView.backgroundColor = [UIColor clearColor];

    // -----------------------
    // social login tw / fb
    // -----------------------
    // init
    _twImageView.image = [UIImage imageNamed:@"ico_twitter.png"];
    _fbImageView.image = [UIImage imageNamed:@"ico_facebook.png"];
    _twLoginedImageView.hidden = YES;
    _fbLoginedImageView.hidden = YES;
    // check
    NSString *twToken = [Configuration loadTWAccessToken];
    if(![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0){
        _twImageView.image = [UIImage imageNamed:@"ico_twitter_on.png"];
        _twLoginedImageView.hidden = NO;
        self.isTw = 1;
    }
    NSString *fbToken = [Configuration loadFBAccessToken];
    if(![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0){
        _fbImageView.image = [UIImage imageNamed:@"ico_facebook_on.png"];
        _fbLoginedImageView.hidden = NO;
        self.isFb = 1;
    }
    // action
    [_twBtn addTarget:self action:@selector(twPopLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [_fbBtn addTarget:self action:@selector(fbPopLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 30.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    // touchesBeganが遅い対処
    _tableView.delaysContentTouches = false;
    
    //_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = COMMON_DEF_GRAY_COLOR;
    //_tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 150);
    //_tableView.estimatedRowHeight = kLoadingCellHeight;
    
    //self.populars  = [NSMutableArray array];
    self.tableView = _tableView;
    [self.view addSubview:_tableView];
    
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setColor:[UIColor darkGrayColor]];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator stopAnimating];

    
//    if(self.rankingManager == nil){
//        self.rankingManager = [[RankingManager alloc]init];
//    }
    //self.rankingManager = [[RankingManager alloc]init];
    
//    NSString *keyPath = @"populars";
//    [self addObserver:self.rankingManager forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    
    // get popular list
    self.canLoadMore = NO;
    self.isTapAction = NO;

    if (self.isAfterRegistration) {
        [self configureNavigationBar];
        [self hideSNS];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.isLoadingApi){
        self.isLoadingApi = YES;
        [self refreshPopulars:NO];
    }
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"Popular"];
    
    // network check
    if(![[UserManager sharedManager]checkNetworkStatus]){
        // error network
        NetworkErrorView *networkErrorView = [[NetworkErrorView alloc]init];
        networkErrorView.delegate = self;
        [networkErrorView showInView:self.view];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    //[_tableView setDelegate:nil];
    //[_tableView setDataSource:nil];

//    NSString *keyPath = @"populars";
//    [self removeObserver:self forKeyPath:keyPath];
    
}

- (void)dealloc
{

    //    if(self.categoryID){
    //        NSString *keyPath = [@"rankings" stringByAppendingString:self.categoryID];
    //        [[RankingManager sharedManager] removeObserver:self forKeyPath:keyPath];
    //    }
    //self.populars = nil;
    //self.rankingManager.populars = nil;
    
//    [self.tableView beginUpdates]; // 更新開始.
//    self.tableView
//    [self.tableView endUpdates];
    
//self.tableView.delegate = nil;
//self.rankingManager = nil;
    //[_tableView setDelegate:nil];
    //[_tableView setDataSource:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// スクロールによりナビゲーションバーの表示非表示制御
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    UIColor * color = HEADER_BG_COLOR;
//    
//    CGFloat offsetY = scrollView.contentOffset.y;
//    if (offsetY > 0) {
//        if (offsetY >= 44) {
//            [self setNavigationBarTransformProgress:1];
//            [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0.2]];
//        } else {
//            [self setNavigationBarTransformProgress:(offsetY / 44)];
//            CGFloat alpha = ((44 - offsetY) / 44) + 0.2;
//            NSLog(@"offset : %f", offsetY);
//            NSLog(@"alfa : %f", alpha);
//            [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
//        }
//    } else {
//        [self setNavigationBarTransformProgress:0];
//        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:1]];
//        
//        self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
//    }
//}
//- (void)setNavigationBarTransformProgress:(CGFloat)progress
//{
//    [self.navigationController.navigationBar lt_setTranslationY:(-44 * progress)];
//    [self.navigationController.navigationBar lt_setContentAlpha:(1-progress)];
//}



/* KVO で変更があったとき呼ばれる */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *checkPath = @"populars";
    if (object == self && [keyPath isEqualToString:checkPath]) {
        // 配列が変更された場所のインデックス.
        NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
        // 変更の種類.
        NSKeyValueChange changeKind = (NSKeyValueChange)[change[NSKeyValueChangeKindKey] integerValue];
        
        // 配列に詰め替え.
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }];
        
        // `populars` の変更の種類に合わせて TableView を更新.
        [self.tableView beginUpdates]; // 更新開始.
        if (changeKind == NSKeyValueChangeInsertion) {
            // 新しく追加されたとき.
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (changeKind == NSKeyValueChangeRemoval) {
            // 取り除かれたとき.
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (changeKind == NSKeyValueChangeReplacement) {
            // 値が更新されたとき.
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates]; // 更新終了.
    }
}

- (void)reload:(__unused id)sender {
    //self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //    NSURLSessionTask *task = [Post globalTimelinePostsWithBlock:^(NSArray *posts, NSError *error) {
    //        if (!error) {
    //            self.posts = posts;
    //            [self.tableView reloadData];
    //        }
    //    }];
    //
    //    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    //    [self.refreshControl setRefreshingWithStateOfTask:task];
    
    // 更新開始
    //[self.refreshControl beginRefreshing];
    
    // action
    //self.rankingManager.populars = [NSMutableArray array];
    //[self.rankingManager.populars removeAllObjects];
    [self refreshPopulars:YES];
    
    //[NSThread sleepForTimeInterval:0.5f];
    
    // 更新終了
    //[self.refreshControl endRefreshing];
}

- (void)refreshPopulars:(BOOL)refreshFlg
{
    //[self.refreshControl beginRefreshing];
    
    if(self.rankingManager == nil){
        self.rankingManager = [RankingManager new];
    }
    if(refreshFlg){
        self.rankingManager = [RankingManager new];
        [self.tableView reloadData];
        [self.refreshControl beginRefreshing];
    }
    
    NSDictionary *params = @{ @"page" : @(1),
                              @"categories" : [[NSMutableArray alloc] init]};
    
    //hairとnailのカテゴリを入れる
    [self addCatParams:params];

    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }

    __weak typeof(self) weakSelf = self;
    [self.rankingManager reloadPopularsWithParams:params block:^(NSMutableArray *populars, NSUInteger *popularPage, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        if(refreshFlg){
            // 更新終了
            [self.refreshControl endRefreshing];
        }

        if (error) {
            DLog(@"error = %@", error);

            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
        }else{
            
            DLog(@"%@", populars);
            
            //strongSelf.populars = [populars mutableCopy];
            //strongSelf.popularIdList = [popularIdList mutableCopy];
            strongSelf.popularPage = popularPage;
            [strongSelf.tableView reloadData];
            strongSelf.canLoadMore = strongSelf.rankingManager.canLoadPopularMore;
        }
        
//        [[self mutableArrayValueForKey:@"populars"]
//         replaceObjectsInRange:NSMakeRange(0, [self.populars count])
//         withObjectsFromArray:api_populars];
        
        //self.populars = [api_populars mutableCopy];
        
        //[self.refreshControl endRefreshing];
        

    }];
}

#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Popular *jPopular = [self.rankingManager.populars objectAtIndex:(NSUInteger)indexPath.row];
    if(jPopular && [jPopular.posts isKindOfClass:[NSArray class]] && [jPopular.posts count] > 0){
        CGFloat cellPostWidth = [[UIScreen mainScreen]bounds].size.width / 4;
        // 64 + 150 + 8 = 222
        CGFloat cellHeight = 64 + cellPostWidth + 8;
        return cellHeight;
    }
    
    return kLoadingCellHeight;

}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 6.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    CGRect footerFrame = self.tableView.tableFooterView.frame;
    footerFrame.size.height = 6.0f;
    footerFrame.size.width = self.view.bounds.size.width;
    
    //DLog(@"%@", footerFrame);
    
    UIView *view = [[UIView alloc] initWithFrame:footerFrame];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [self.populars count];
    //DLog(@"%lu", (unsigned long)[self.populars count]);
    //return [self.populars count];
    return [self.rankingManager.populars count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PopularTableViewCell *popularCell = [tableView dequeueReusableCellWithIdentifier:@"PopularTableViewCell"];
    
    Popular *popular = [self.rankingManager.populars objectAtIndex:(NSUInteger)indexPath.row];
    
    
    BOOL isSrvFollow = NO;
    if([popular.isFollow isEqualToNumber:[NSNumber numberWithInt:VLISBOOLTRUE]]){
        isSrvFollow = YES;
    }
    NSNumber *myUserPID = [Configuration loadUserPid];
    if(myUserPID){
        popular.isFollow = [[UserManager sharedManager] getIsMyFollow:myUserPID userPID:popular.userPID isSrvFollow:isSrvFollow loadingDate:popular.loadingDate];
    }
    
    [popularCell configureCellForAppRecord: popular];
    
    // ハイライトなし
    popularCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // フォローボタンタップ時
    [popularCell.followBtn addTarget:self action:@selector(inFollowTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
    // ユーザアイコンタップ時
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconTap:)];
    [popularCell.userIconImageView addGestureRecognizer:tapGestureRecognizer];
    popularCell.userIconImageView.tag = [popularCell.userPID integerValue];
    
    // ユーザ表示タップ時
    
    [popularCell.userNameBtn addTarget:self action:@selector(popularUserButton:event:) forControlEvents:UIControlEventTouchUpInside];
    [popularCell.userIdBtn addTarget:self action:@selector(popularUserButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
    // 投稿画像タップ時
    UITapGestureRecognizer *tapPost1GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postIconTap:)];
    [popularCell.post1ImageView addGestureRecognizer:tapPost1GestureRecognizer];
    
    UITapGestureRecognizer *tapPost2GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postIconTap:)];
    [popularCell.post2ImageView addGestureRecognizer:tapPost2GestureRecognizer];
    
    UITapGestureRecognizer *tapPost3GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postIconTap:)];
    [popularCell.post3ImageView addGestureRecognizer:tapPost3GestureRecognizer];
    
    UITapGestureRecognizer *tapPost4GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postIconTap:)];
    [popularCell.post4ImageView addGestureRecognizer:tapPost4GestureRecognizer];

    if (self.isAfterRegistration) {
        [popularCell.post1ImageView setUserInteractionEnabled:NO];
        [popularCell.post2ImageView setUserInteractionEnabled:NO];
        [popularCell.post3ImageView setUserInteractionEnabled:NO];
        [popularCell.post4ImageView setUserInteractionEnabled:NO];
        [popularCell.userIconImageView setUserInteractionEnabled:NO];
        [popularCell.userNameBtn setUserInteractionEnabled:NO];
        [popularCell.userIdBtn setUserInteractionEnabled:NO];
    }else{
        [popularCell.post1ImageView setUserInteractionEnabled:YES];
        [popularCell.post2ImageView setUserInteractionEnabled:YES];
        [popularCell.post3ImageView setUserInteractionEnabled:YES];
        [popularCell.post4ImageView setUserInteractionEnabled:YES];
        [popularCell.userIconImageView setUserInteractionEnabled:YES];
        [popularCell.userNameBtn setUserInteractionEnabled:YES];
        [popularCell.userIdBtn setUserInteractionEnabled:YES];
    }
    
    //[popularCell setNeedsLayout];
    //[popularCell layoutIfNeeded];
    //[popularCell layoutSubviews];
    
    return popularCell;
}

//- (void)updateTableSize:(UITableView *)tableView
//{
//    tableView.frame =
//    CGRectMake(tableView.frame.origin.x,
//               tableView.frame.origin.y,
//               tableView.contentSize.width,
//               MIN(tableView.contentSize.height,
//                   tableView.bounds.size.height));
//}


#pragma mark - UIScrollViewDelegate

/* Scroll View のスクロール状態に合わせて */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if([_indicator isAnimating]) {
        return;
    }
    
    if(self.rankingManager == nil){
        self.rankingManager = [RankingManager new];
    }

    // offset は表示領域の上端なので, 下端にするため `tableView` の高さを付け足す. このとき 1.0 引くことであとで必ずセルのある座標になるようにしている.
    CGPoint offset = *targetContentOffset;
    offset.y += self.tableView.bounds.size.height - 1.0;
    // offset 位置のセルの `NSIndexPath`.
    //NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:offset];
    //if(indexPath.row >= self.rankingManager.populars.count - 1 && self.rankingManager.canLoadPopularMore){
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) && self.canLoadMore){

        [self startIndicator];
        
        // more page
        NSDictionary *params = @{ @"page" : @(self.rankingManager.popularPage),};
        __weak typeof(self) weakSelf = self;
        [self.rankingManager loadMorePopularsWithParams:params block:^(NSMutableArray *populars, NSUInteger *popularPage, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                DLog(@"error = %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                
            }else{
                //strongSelf.populars = populars;
                strongSelf.popularPage = popularPage;
                [strongSelf.tableView reloadData];
                strongSelf.canLoadMore = strongSelf.rankingManager.canLoadPopularMore;

                [self endIndicator];
            }
        }];
    }
}


- (void)startIndicator
{
    [_indicator startAnimating];
    
    _indicator.backgroundColor = [UIColor clearColor];
    CGRect indicatorFrame = _indicator.frame;
    indicatorFrame.size.height = 22.0;
    [_indicator setFrame:indicatorFrame];
    
    [self.tableView setTableFooterView:nil];
    [self.tableView setTableFooterView:_indicator];
}


- (void)endIndicator
{
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 6)];
//    view.backgroundColor = [UIColor clearColor];
//    [self.tableView setTableFooterView:view];
}


// UIControlEventからタッチ位置のindexPathを取得する
// ----------------------
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

#pragma mark UIButton Action

// follow action
// ----------------------
- (void)inFollowTouchButton:(UIButton *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    PopularTableViewCell* popularCell = (PopularTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    // ------------------
    // login check
    // ------------------
    DLog(@"%@", [Configuration loadAccessToken]);
    if(![[Configuration checkLogined] length]){
        // 未ログイン
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        
    }else{
        
        // **********
        // send Follow
        // **********
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoding = vConfig[@"LoadingPostDisplay"];
        if( isLoding && [isLoding boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        
        NSString *vellyToken = [Configuration loadAccessToken];
        NSNumber *targetUserPID = popularCell.userPID;
        
        NSNumber *isFollow = popularCell.isFollow;
        NSComparisonResult result;
        result = [isFollow compare:[NSNumber numberWithInt:VLPOSTLIKENO]];
        
        if(isFollow && [isFollow isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
            // followed -> no follow
            
            [[FollowManager sharedManager] deleteFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);

                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorNoFollow", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                    
                }else{
                    
                    [popularCell.followBtn setImage:[UIImage imageNamed:@"ico_follow.png"] forState:UIControlStateNormal];
                    popularCell.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[UserManager sharedManager] updateMyFollow:myUserPID userPID:targetUserPID isFollow:VLISBOOLFALSE];
                    }
                    
                    UIAlertView *alert = [[UIAlertView alloc] init];
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"MsgNoFollowed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    
                    
                    [alert show];
                    
                }
            }];
            
        }else{
            // no follow -> follow
            
            [[FollowManager sharedManager] putFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);

                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorFollow", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    
                    [popularCell.followBtn setImage:[UIImage imageNamed:@"ico_follower.png"] forState:UIControlStateNormal];
                    popularCell.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[UserManager sharedManager] updateMyFollow:myUserPID userPID:targetUserPID isFollow:VLISBOOLTRUE];
                    }
                    
                    UIAlertView *alert = [[UIAlertView alloc] init];
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"MsgFollowed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    
                    [alert show];
                    
                }
            }];
            
        }
        
    }
    
}

// ユーザID、ニックネームボタンアクション
- (void)popularUserButton:(UIButton *)sender event:(UIEvent *)event {
    
    if(!self.isTapAction){
        
        self.isTapAction = YES;
    
        NSIndexPath *indexPath = [self indexPathForControlEvent:event];
        Popular *tPopular = [self.rankingManager.populars objectAtIndex:indexPath.row];
        NSNumber *userPID = tPopular.userPID;
    
        UserViewController *userViewController = nil;
        userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
        // 他人画面
        userViewController.isMmine = false;
        userViewController.userPID = userPID;
        [userViewController preloadingPosts];
        //self.tabBarController.selectedViewController = vc;
        // UINavigationControllerに追加済みのViewを一旦取り除く
        //[homeTabPagerViewController.navigationController popToRootViewControllerAnimated:NO];
        [UIView transitionFromView:self.view
                        toView:userViewController.view
                      duration:0.1
         //options:UIViewAnimationOptionTransitionCrossDissolve
                       options:UIViewAnimationOptionTransitionNone
                    completion:
         ^(BOOL finished) {
             [self.navigationController pushViewController:userViewController animated:YES];
             self.isTapAction = NO;
         }];
    
    }
    
}


- (void)userIconTap:(UIGestureRecognizer *)recognizer
{

    if(!self.isTapAction){
        
        self.isTapAction = YES;
    
        UIImageView *userImageView = (UIImageView *)recognizer.view;
        NSNumber *userPID = [NSNumber numberWithInteger:userImageView.tag];
    
        UserViewController *userViewController = nil;
        userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
        // 他人画面
        userViewController.isMmine = false;
        userViewController.userPID = userPID;
        [userViewController preloadingPosts];
        //self.tabBarController.selectedViewController = vc;
        // UINavigationControllerに追加済みのViewを一旦取り除く
        //[homeTabPagerViewController.navigationController popToRootViewControllerAnimated:NO];
        [UIView transitionFromView:self.view
                        toView:userViewController.view
                      duration:0.1
         //options:UIViewAnimationOptionTransitionCrossDissolve
                       options:UIViewAnimationOptionTransitionNone
                    completion:
         ^(BOOL finished) {
             [self.navigationController pushViewController:userViewController animated:YES];
             self.isTapAction = NO;
         }];
    
    }
    
}

///投稿タップアクション
- (void) postIconTap:(UIGestureRecognizer *)recognizer
{

    if(!self.isTapAction){
        
        self.isTapAction = YES;
    
        HomeTabPagerViewController *homeTabPagerViewController = (HomeTabPagerViewController *)self.tabBarController.childViewControllers[0];
        [homeTabPagerViewController.navigationController popToRootViewControllerAnimated:NO];
    
        UIImageView *postImageView = (UIImageView *)recognizer.view;
        NSNumber *postID = [NSNumber numberWithInteger:postImageView.tag];
        if(![postID isKindOfClass:[NSNull class]] && ![postID isEqualToNumber:[NSNumber numberWithInt:0]]){
            DetailViewController *detailController = nil;
            detailController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
            
            [[PostManager sharedManager] getPostInfo:postID
                                              aToken:[Configuration loadAccessToken]
                block:^(NSNumber *result_code, Post *post, NSMutableDictionary *responseBody, NSError *error) {
                    
                //動画のために画像をセットしておく
                detailController.post = post;
                detailController.postID = postID;
                [detailController loadPost];
                if (post.isMovie) detailController.postImageTempView = postImageView ;
                [self.navigationController pushViewController:detailController animated:YES];
                self.isTapAction = NO;
            }];
        
        }
        
    }

}


// TW連携ボタンアクション
- (void)twPopLoginAction:(id)sender
{
    
    NSString *alertTwTitle = nil;
    NSString *alertTwExecTitle = nil;
    if(_isTw == 0) {
        alertTwTitle = NSLocalizedString(@"MsgActionSocialTwAuth", nil);
        alertTwExecTitle = NSLocalizedString(@"MsgActionSocialAuth", nil);
    }else{
        alertTwTitle = NSLocalizedString(@"MsgActionSocialTwAuth", nil);
        alertTwExecTitle = NSLocalizedString(@"MsgActionSocialNoAuth", nil);
    }
    
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS8
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:alertTwTitle
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        // Cancel用のアクションを生成
        UIAlertAction * cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                   // ボタンタップ時の処理
                                   DLog(@"Cancel button tapped.");
                               }];
        UIAlertAction * okAction =
        [UIAlertAction actionWithTitle:alertTwExecTitle
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   // ボタンタップ時の処理
                                   DLog(@"OK button tapped.");
                                   
                                   [self twitterConnect];
                                   
                               }];
        // コントローラにアクションを追加
        [ac addAction:cancelAction];
        //[ac addAction:destructiveAction];
        [ac addAction:okAction];
        // アクションシート表示処理
        [self presentViewController:ac animated:YES completion:nil];
        
    }else{
        // iOS7 under
        // UIActionSheetを使ってアクションシートを表示
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = alertTwTitle;
        [as addButtonWithTitle:alertTwExecTitle];
        [as addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        //as.destructiveButtonIndex = 0;
        as.cancelButtonIndex = 1;
        as.tag = 1;
        [as showInView:self.view];
    }
    
}

// FB連携ボタンアクション
- (void)fbPopLoginAction:(id)sender
{

    NSString *alertFbTitle = nil;
    NSString *alertFbExecTitle = nil;
    if(_isFb == 0) {
        alertFbTitle = NSLocalizedString(@"MsgActionSocialFbAuth", nil);
        alertFbExecTitle = NSLocalizedString(@"MsgActionSocialAuth", nil);
    }else{
        alertFbTitle = NSLocalizedString(@"MsgActionSocialFbAuth", nil);
        alertFbExecTitle = NSLocalizedString(@"MsgActionSocialNoAuth", nil);
    }
    
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS8
        // 連携実施の確認
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:alertFbTitle
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        // Cancel用のアクションを生成
        UIAlertAction * cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {
                                   // ボタンタップ時の処理
                                   DLog(@"Cancel button tapped.");
                               }];
        UIAlertAction * okAction =
        [UIAlertAction actionWithTitle:alertFbExecTitle
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   // ボタンタップ時の処理
                                   DLog(@"OK button tapped.");
                                   
                                   [self facebookConnect];
                                   
                               }];
        // コントローラにアクションを追加
        [ac addAction:cancelAction];
        //[ac addAction:destructiveAction];
        [ac addAction:okAction];
        // アクションシート表示処理
        [self presentViewController:ac animated:YES completion:nil];
        
    }else{
        // iOS7 under
        // UIActionSheetを使ってアクションシートを表示
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = alertFbTitle;
        [as addButtonWithTitle:alertFbExecTitle];
        [as addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        //as.destructiveButtonIndex = 0;
        as.cancelButtonIndex = 1;
        as.tag = 2;
        [as showInView:self.view];
        
    }

}

///新規登録後の完了アクション
- (void)compAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [SVProgressHUD showSuccessWithStatus: NSLocalizedString(@"ApiSuccessRegistCompUser", nil)];
}

#pragma mark UIActionSheet Delegate

// iOS 7でアクションシートのボタンが押された時の処理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 1){
        // Tw連携
        switch (buttonIndex) {
            case 0:
                // Twitter連携 / 解除
                [self twitterConnect];
                break;
        }
    }else if(actionSheet.tag == 2){
        // Fb連携
        switch (buttonIndex) {
            case 0:
                // Facebook連携 / 解除
                [self facebookConnect];
                break;
        }
    }
}


- (void)twitterConnect
{

    if(_isTw == 0) {
        
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:OAUTH_TW_API_KEY
                                                     consumerSecret:OAUTH_TW_API_SECRET];
        
        [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
            DLog(@"-- url: %@", url);
            DLog(@"-- oauthToken: %@", oauthToken);
            
            //[[UIApplication sharedApplication] openURL:url];
            
            NoPasswdViewController *webView = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"NoPasswdViewController"];
            webView.naviTitle = @"twitter login";
            [self presentViewController:webView animated:YES completion:^{
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [webView.webView loadRequest:request];
            }];
            
        } authenticateInsteadOfAuthorize:NO
                        forceLogin:@(YES)
                        screenName:nil
         //oauthCallback:@"me.myrecoup://twitter_access_tokens/"    // no reback -> NG
                     oauthCallback:TW_CALLBACK_URL
                        errorBlock:^(NSError *error) {
                            DLog(@"-- error: %@", error);
                            //
                            
                        }];
        
    }else{

        // 解除完了
        
        NSString *twToken = @"";
        NSString *twTokenSecret = @"";
        // --------------------
        // send API
        // --------------------
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoading = vConfig[@"LoadingPostDisplay"];
        // must
        isLoading = @"YES";
        if( isLoading && [isLoading boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        NSString *aToken = [Configuration loadAccessToken];
        [[UserManager sharedManager] deleteTwToken:aToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
            
            if( isLoading && [isLoading boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }
            
            if(error){
                
                DLog(@"%@", error);
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_CONFLICT]){
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocialConflict", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }else{
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocial", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }
                [alert show];
                
            }else{
                
                // 解除完了
                NSString *alertTwClearTitle = NSLocalizedString(@"MsgSocialClear", nil);
                self.isTw = 0;
                _twLoginedImageView.hidden = YES;
                _twImageView.image = [UIImage imageNamed:@"ico_twitter.png"];

                [Configuration saveTWAccessToken:twToken];
                [Configuration saveTWAccessTokenSecret:twTokenSecret];
                
                // login認証トークンは、残す
                //[Configuration saveLoginTWAccessToken:twToken];
                //[Configuration saveLoginTWAccessTokenSecret:twTokenSecret];
                
                [SVProgressHUD showSuccessWithStatus: alertTwClearTitle];
            }
            
        }];
        
    }
    
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebView
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        DLog(@"-- screenName: %@", screenName);
        
        //NSString *twEmail = @"";
        //NSString *twName  = screenName;
        NSString *twToken = oauthToken;
        NSString *twTokenSecret = oauthTokenSecret;
        
        // --------------------
        // send API
        // --------------------
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoading = vConfig[@"LoadingPostDisplay"];
        // must
        isLoading = @"YES";
        if( isLoading && [isLoading boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        NSString *aToken = [Configuration loadAccessToken];
        [[UserManager sharedManager] postTwToken:aToken twToken:twToken twTokenSecret:twTokenSecret block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
            
            if( isLoading && [isLoading boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }
            
            if(error){
                
                DLog(@"%@", error);
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_CONFLICT]){
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocialConflict", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }else{
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocial", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }
                [alert show];
                
            }else{
                
                if(twToken){
                    [Configuration saveTWAccessToken:twToken];
                    [Configuration saveLoginTWAccessToken:twToken];
                }
                if(twTokenSecret){
                    [Configuration saveTWAccessTokenSecret:twTokenSecret];
                    [Configuration saveLoginTWAccessTokenSecret:twTokenSecret];
                }
                
                // 連携完了
                NSString *alertTwCompTitle = NSLocalizedString(@"MsgSocialComp", nil);
                self.isTw = 1;
                _twLoginedImageView.hidden = NO;
                _twImageView.image = [UIImage imageNamed:@"ico_twitter_on.png"];
                
                [SVProgressHUD showSuccessWithStatus: alertTwCompTitle];
                
            }
            
        }];
        
    } errorBlock:^(NSError *error) {
        DLog(@"-- %@", [error localizedDescription]);
    }];
}

- (void)facebookConnect
{
    
    if(_isFb == 0) {
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                DLog(@"errror:%@", error);
                // Process error -> no action
                
            } else if (result.isCancelled) {
                DLog(@"login is cancelled.");
                // Handle cancellations -> no action
                
            } else {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                if ([result.grantedPermissions containsObject:@"email"]) {
                    
                    // FB申請＋投稿時FB送信を行なう際に解除
                    //[login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {

                        // -----------------
                        // facebook Do work
                        // -----------------
                        DLog(@"login with read email permission succeeded.");
                        NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
                        if(fbToken){
                            [Configuration saveFBAccessToken:fbToken];
                        }
                    
                        // --------------------
                        // send API
                        // --------------------
                        NSDictionary *vConfig   = [ConfigLoader mixIn];
                        NSString *isLoading = vConfig[@"LoadingPostDisplay"];
                        // must
                        isLoading = @"YES";
                        if( isLoading && [isLoading boolValue] == YES ){
                            // Loading
                            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
                        }
                        NSString *aToken = [Configuration loadAccessToken];
                        [[UserManager sharedManager] postFbToken:aToken fbToken:fbToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
                        
                            if( isLoading && [isLoading boolValue] == YES ){
                                // clear loading
                                [SVProgressHUD dismiss];
                            }
                        
                            if(error){
                            
                                DLog(@"%@", error);
                            
                                UIAlertView *alert = [[UIAlertView alloc]init];
                                if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_CONFLICT]){
                                    alert = [[UIAlertView alloc]
                                         initWithTitle:NSLocalizedString(@"ApiErrorSocialConflict", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                }else{
                                    alert = [[UIAlertView alloc]
                                         initWithTitle:NSLocalizedString(@"ApiErrorSocial", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                }
                                [alert show];
                            
                            }else{
                            
                                if(fbToken){
                                    [Configuration saveFBAccessToken:fbToken];
                                    [Configuration saveLoginFBAccessToken:fbToken];
                                }
                            
                                // 連携完了
                                NSString *alertFbCompTitle = NSLocalizedString(@"MsgSocialComp", nil);
                                self.isFb = 1;
                                _fbLoginedImageView.hidden = NO;
                                _fbImageView.image = [UIImage imageNamed:@"ico_facebook_on.png"];
                            
                                [SVProgressHUD showSuccessWithStatus: alertFbCompTitle];
                            }

                        }];

                    //}];
                    
                }
            }
        }];
        
    }else{
        
        NSString *fbToken = @"";
        // --------------------
        // send API
        // --------------------
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoading = vConfig[@"LoadingPostDisplay"];
        // must
        isLoading = @"YES";
        if( isLoading && [isLoading boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        NSString *aToken = [Configuration loadAccessToken];
        [[UserManager sharedManager] deleteFbToken:aToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
            if(error){
            }else{
                
                if( isLoading && [isLoading boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }

                if(error){
                    DLog(@"%@", error);
                    
                    UIAlertView *alert = [[UIAlertView alloc]init];
                    if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_CONFLICT]){
                        alert = [[UIAlertView alloc]
                                 initWithTitle:NSLocalizedString(@"ApiErrorSocialConflict", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    }else{
                        alert = [[UIAlertView alloc]
                                 initWithTitle:NSLocalizedString(@"ApiErrorSocial", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    }
                    [alert show];
                    
                }else{
                
                    // 解除完了
                    NSString *alertFbCompTitle = NSLocalizedString(@"MsgSocialClear", nil);
                    self.isFb = 0;
                    _fbLoginedImageView.hidden = YES;
                    _fbImageView.image = [UIImage imageNamed:@"ico_facebook.png"];
                
                    [Configuration saveFBAccessToken:fbToken];
                
                    // login認証トークンは、残す
                    //[Configuration saveLoginFBAccessToken:fbToken];
                
                    [SVProgressHUD showSuccessWithStatus: alertFbCompTitle];
                    
                }
            }

        }];

    }
    
}

///戻るボタンを消して、完了ボタンをつける
- (void)configureNavigationBar {
    
    UIButton *compBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [compBtn setTitle:NSLocalizedString(@"Comp", nil) forState:UIControlStateNormal];
    [compBtn.titleLabel setFont:JPFONT(16)];
    [compBtn addTarget:self
                action:@selector(compAction:)
      forControlEvents:UIControlEventTouchUpInside];
    [compBtn sizeToFit];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:compBtn]];
    [self.navigationItem setHidesBackButton:YES];
    
}

///SNS連携のセルを隠す
- (void)hideSNS {
    [self.twView setHidden:YES];
    [self.fbView setHidden:YES];
    [self.ttl_snsImageView setHidden:YES];
    [self.snsTitleView setHidden:YES];
    
    [self.twView setFrame:CGRectZero];
    [self.fbView setFrame:CGRectZero];
    [self.ttl_snsImageView setFrame:CGRectZero];
    [self.snsTitleView setFrame:CGRectZero];
    
    for (UIView *v in self.tableView.tableHeaderView.subviews) {
        if (![v isEqual:self.recommTitleUserImgView] && ![v isEqual:self.recommTitleView]) {
            [v removeFromSuperview];
        }
    }
    for (NSLayoutConstraint *c in self.tableView.tableHeaderView.constraints) {
        if (![c.firstItem isEqual:self.recommTitleView] && ![c.firstItem isEqual:self.recommTitleUserImgView]) {
            [self.tableView.tableHeaderView removeConstraint:c];
        }
    }
    [self.tableView.tableHeaderView setFrame:CGRectMake(0, 0,
                                                        self.recommTitleView.bounds.size.width,
                                                        self.recommTitleView.bounds.size.height)];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint
                                                   constraintWithItem:self.recommTitleUserImgView
                                                   attribute:NSLayoutAttributeCenterYWithinMargins
                                                   relatedBy:NSLayoutRelationEqual
                                                   toItem:self.recommTitleView
                                                   attribute:NSLayoutAttributeCenterYWithinMargins
                                                   multiplier:1
                                                   constant:0]];
    [self.recommTitleUserImgView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

///hairとnailのカテゴリをパラメーターに入れる
- (void)addCatParams:(NSDictionary *)params {
    if (!params[@"categories"] || ![params[@"categories"] isKindOfClass:[NSMutableArray class]]) {
        return;
    }
    for (id val in [[MasterManager sharedManager].categories objectEnumerator]) {
        if ([val[@"key"] isEqualToString:@"hair"] || [val[@"key"] isEqualToString:@"nail"]) {
            [(NSMutableArray *)params[@"categories"] addObject:val[@"id"]];
        }
    }
}

#pragma mark - NetworkErrorViewDelete
- (void)noNetworkRetry
{
    DLog(@"HomeView no Network Retry");
    
    // network retry check
    if([[UserManager sharedManager]checkNetworkStatus]){
        // display hide
        for(UIView *v in self.view.subviews){
            if(v.tag == 99999999){
                [self refreshPopulars:NO];
                [UIView animateWithDuration:0.8f animations:^{
                    v.alpha = 1.0f;
                    v.alpha = 0.0f;
                }completion:^(BOOL finished){
                    [v removeFromSuperview];
                }];
            }
        }
    }else{
        // keep
    }
}



@end
