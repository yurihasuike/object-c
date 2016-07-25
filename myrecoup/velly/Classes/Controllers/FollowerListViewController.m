//
//  FollowerListViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FollowerListViewController.h"
#import "FollowerTableViewCell.h"
#import "FollowManager.h"
#import "Follower.h"
#import "HomeTabPagerViewController.h"
#import "DetailViewController.h"
#import "VYNotification.h"
#import "UINavigationBar+Awesome.h"
#import "SVProgressHUD.h"
#import "UserManager.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "NetworkErrorView.h"
#import "Defines.h"
#import "CommonUtil.h"

@interface FollowerListViewController () <NetworkErrorViewDelete>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FollowManager *followManager;
@property (strong, nonatomic) NSMutableArray *followers;
@property (nonatomic) NSUInteger *followerPage;
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

static CGFloat kLoadingCellHeight = 50.0f;

@implementation FollowerListViewController

- (id) initWithUserID:(NSString *)t_userID
{
    if(!self) {
        self = [[FollowerListViewController alloc] init];
    }
    self.userID = t_userID;
    return self;
}

- (id) initWithUserPID:(NSNumber *)t_userPID userID:(NSString *)t_userID {
    
    if(!self) {
        self = [[FollowerListViewController alloc] init];
    }
    self.userPID = t_userPID;
    self.userID = t_userID;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [CommonUtil getNaviTitle:NSLocalizedString(@"PageFollower", nil)];
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 30.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    // touchesBeganが遅い対処
    _tableView.delaysContentTouches = false;
    
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = [UIColor clearColor];
    //_tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.backgroundColor = [UIColor whiteColor];
    //_tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 150);
    
    self.tableView = _tableView;
    [self.view addSubview:_tableView];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setColor:[UIColor darkGrayColor]];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator stopAnimating];
    
    if(self.userID){
        NSString *keyPath = [@"followers" stringByAppendingString:self.userID];
        [self.followManager addObserver:self
                                        forKeyPath:keyPath
                                           options:NSKeyValueObservingOptionNew
                                           context:nil];
    }

    self.canLoadMore = NO;
    
    // 引っ張って更新.
    //    [self.refreshControl addTarget:self action:@selector(refreshFollowers:) forControlEvents:UIControlEventValueChanged];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.isLoadingApi){
        self.isLoadingApi = YES;
        [self refreshFollowers:NO];
    }

    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"MyFollowerList"];
    
    // network check
    if(![[UserManager sharedManager]checkNetworkStatus]){
        // error network
        NetworkErrorView *networkErrorView = [[NetworkErrorView alloc]init];
        networkErrorView.delegate = self;
        [networkErrorView showInView:self.view];
    }
    
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
    if (object == self.followManager && [keyPath isEqualToString:@"followers"]) {
        // 配列が変更された場所のインデックス.
        NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
        // 変更の種類.
        NSKeyValueChange changeKind = (NSKeyValueChange)[change[NSKeyValueChangeKindKey] integerValue];
        
        // 配列に詰め替え.
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }];
        
        // `rankings` の変更の種類に合わせて TableView を更新.
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
    [self refreshFollowers:YES];
    //[NSThread sleepForTimeInterval:0.5f];
    
    // 更新終了
    //[self.refreshControl endRefreshing];
}


- (void)refreshFollowers:(BOOL)refreshFlg
{
    //[self.refreshControl beginRefreshing];
    
    if(self.followManager == nil){
        self.followManager = [FollowManager new];
    }
    if(refreshFlg){
        self.followManager = [FollowManager new];
        [self.tableView reloadData];
        [self.refreshControl beginRefreshing];
    }
    
    NSDictionary *params;
    if(!self.userPID || [self.userPID isEqual: [NSNull null]]){
        // 自分のuserPIDを取得
        NSNumber *myUserPID = [Configuration loadUserPid];
        // test
        myUserPID = [NSNumber numberWithInt:14];
        params = @{ @"page" : @(1), @"userPID" : [myUserPID stringValue]};
    }else{
        params = @{ @"page" : @(1), @"userPID" : [self.userPID stringValue]};
    }
    
    NSString *aToken = [Configuration loadAccessToken];
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.followManager reloadFollowersWithParams:params aToken:aToken block:^(NSMutableArray *followers, NSUInteger *followerPage, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        if(refreshFlg){
            [self.refreshControl endRefreshing];
        }
        if (error) {
            DLog(@"error = %@", error);
            
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
        }else{
            strongSelf.followerPage = followerPage;
            [strongSelf.tableView reloadData];
            strongSelf.canLoadMore = strongSelf.followManager.canLoadFollowerMore;
        }

    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLoadingCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 64)];
    view.backgroundColor = [UIColor clearColor];
    return view;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 40)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@"%lu", (unsigned long)[self.followManager.followers count]);
    return [self.followManager.followers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FollowerTableViewCell *followerCell = [tableView dequeueReusableCellWithIdentifier:@"FollowerTableViewCell"];
    
    Follower *jFollower = [self.followManager.followers objectAtIndex:(NSUInteger)indexPath.row];
    
    BOOL isSrvFollower = NO;
    if([jFollower.isFollow isEqualToNumber:[NSNumber numberWithInt:VLISBOOLTRUE]]){
        isSrvFollower = YES;
    }
    NSNumber *myUserPID = [Configuration loadUserPid];
    if(myUserPID){
        jFollower.isFollow = [[UserManager sharedManager] getIsMyFollow:myUserPID userPID:jFollower.userPID isSrvFollow:isSrvFollower loadingDate:jFollower.loadingDate];
    }
    
    [followerCell configureCellForAppRecord: jFollower];
    
    if (indexPath.row != 0) {
        //        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(10, followCell.frame.origin.y, followCell.bounds.size.width - 20, 1)];
        //        line.backgroundColor = COMMON_DEF_GRAY_COLOR;
        //        [followCell addSubview:line];
    }
    
    // 自分自身の場合には、フォローボタンは非表示
    NSNumber *targetUserPID = followerCell.userPID;
    if(targetUserPID && [targetUserPID isEqualToNumber:myUserPID]){
        // no display
        followerCell.followBtn.hidden = YES;
    }else{
        // フォローボタンタップ時
        [followerCell.followBtn addTarget:self action:@selector(inFollowTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // ユーザアイコンタップ時
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconFollowerTap:)];
    [followerCell.userImageView addGestureRecognizer:tapGestureRecognizer];
    followerCell.userImageView.userInteractionEnabled = YES;
    followerCell.userImageView.tag = [followerCell.userPID integerValue];
    
    // ハイライトなし
    followerCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return followerCell;
    
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
    
    if(self.followManager == nil){
        self.followManager = [FollowManager new];
    }
    
    CGPoint offset = *targetContentOffset;
    offset.y += self.tableView.bounds.size.height - 1.0;
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) &&
       self.canLoadMore){
        
        [self startIndicator];
        
        NSDictionary *params;
        if(!self.userPID || [self.userPID isEqual: [NSNull null]]){
            // 自分のuserPIDを取得
            NSNumber *myUserPID = [Configuration loadUserPid];
            params = @{ @"page" : @(self.followManager.followerPage), @"userPID" : [myUserPID stringValue]};
        }else{
            params = @{ @"page" : @(self.followManager.followerPage), @"userPID" : [self.userPID stringValue]};
        }
        NSString *aToken = [Configuration loadAccessToken];
        
        // more page
        __weak typeof(self) weakSelf = self;
        
        [self.followManager loadMoreFollowersWithParams:params aToken:(NSString *)aToken block:^(NSMutableArray *followers, NSUInteger *followerPage, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                DLog(@"error = %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];

            }else{
                //strongSelf.follows = follows;
                strongSelf.followerPage = followerPage;
                [strongSelf.tableView reloadData];
                strongSelf.canLoadMore = strongSelf.followManager.canLoadFollowerMore;
                
                [strongSelf endIndicator];
            }
        }];
        
    }
    
}


- (void)startIndicator
{
    [_indicator startAnimating];
    
    _indicator.backgroundColor = [UIColor clearColor];
    CGRect indicatorFrame = _indicator.frame;
    indicatorFrame.size.height = 36.0;
    [_indicator setFrame:indicatorFrame];
    
    [self.tableView setTableFooterView:nil];
    [self.tableView setTableFooterView:_indicator];
}

- (void)endIndicator
{
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
}



// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

// フォローボタンアクション
- (void)inFollowTouchButton:(UIButton *)sender event:(UIEvent *)event {
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    FollowerTableViewCell* followwerCell = (FollowerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[FOLLOWTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW] : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[SENDER] : [Configuration loadUserPid],
                                      DEFINES_REPROEVENTPROPNAME[TARGET] : followwerCell.userPID}];
    
    // ------------------
    // login check
    // ------------------
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
        NSNumber *targetUserPID = followwerCell.userPID;
        
        NSNumber *isFollow = followwerCell.isFollow;
        NSComparisonResult result;
        result = [isFollow compare:[NSNumber numberWithInt:0]];
        
        if(isFollow && [isFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
            // followed -> no follow
            
            [self.followManager deleteFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorNoFollow", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                    
                }else{
                    
                    [followwerCell.followBtn setImage:[UIImage imageNamed:@"ico_follow.png"] forState:UIControlStateNormal];
                    followwerCell.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    
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
            
            [self.followManager putFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorFollow", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    
                    [followwerCell.followBtn setImage:[UIImage imageNamed:@"ico_follower.png"] forState:UIControlStateNormal];
                    followwerCell.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    
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


// ユーザアイコンアクション
- (void)userIconFollowerTap:(UIGestureRecognizer *)recognizer
{
    DLog(@"gestureTest[%@]",recognizer);
    DLog(@"[%@]",recognizer.view);
    
    //UITableViewCell *cell = (UITableViewCell *)[[[recognizer view] superview] superview];
    //NSIndexPath *path = [self.tableView indexPathForCell:cell];
    //NSLog(@"Pushed :: [%d]",path.row);
    
    UIImageView *userImageView = (UIImageView *)recognizer.view;
    NSNumber *userPID = [NSNumber numberWithInteger:userImageView.tag];
    
    HomeTabPagerViewController *homeTabPagerViewController = (HomeTabPagerViewController *)self.tabBarController.childViewControllers[0];
    
    // タブを選択済みにする
    //self.tabBarController.selectedViewController = vc;
    // UINavigationControllerに追加済みのViewを一旦取り除く
    //[homeTabPagerViewController.navigationController popToRootViewControllerAnimated:NO];
    [UIView transitionFromView:self.view
                        toView:homeTabPagerViewController.view
                      duration:0.1
     //options:UIViewAnimationOptionTransitionCrossDissolve
                       options:UIViewAnimationOptionTransitionNone
                    completion:
     ^(BOOL finished) {
         
         // tab背景
         UIImage *tabBarHomeImg = [UIImage imageNamed:@"bg_nav-on01.png"];
         UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
         [tabBarHomeImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
         tabBarHomeImg = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         
         self.tabBarController.tabBar.backgroundImage = tabBarHomeImg; // [UIImage imageNamed:@"bg_nav-on01.png"];
         
         // ---------------------
         // Notification : sent
         // ---------------------
         VYNotificationParameters *parameters = [[VYNotificationParameters alloc] init];
         parameters.userId = userPID;

         NSDictionary *userInfo = @{@"parameters": parameters};
         NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
         [notificationCenter postNotificationName:VYUserRankingToHomeNotification object:self userInfo:userInfo];
         
         self.tabBarController.selectedViewController = homeTabPagerViewController;
         
     }];
    
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
                [self refreshFollowers:NO];
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
