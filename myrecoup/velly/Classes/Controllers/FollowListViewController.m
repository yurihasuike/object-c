//
//  FollowListViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FollowListViewController.h"
#import "FollowTableViewCell.h"
#import "FollowManager.h"
#import "Follow.h"
#import "HomeTabPagerViewController.h"
#import "DetailViewController.h"
#import "VYNotification.h"
#import "UINavigationBar+Awesome.h"
#import "SVProgressHUD.h"
#import "UserManager.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "NetworkErrorView.h"
#import "MessagingTableViewController.h"
#import "CommonUtil.h"
#import "Defines.h"

@interface FollowListViewController () <NetworkErrorViewDelete>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FollowManager *followManager;

@property (strong, nonatomic) NSMutableArray *follows;
@property (nonatomic) NSUInteger *followPage;

@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

static CGFloat kLoadingCellHeight = 50.0f;

@implementation FollowListViewController

- (id) initWithUserID:(NSString *)t_userID {
    
    if(!self) {
        self = [[FollowListViewController alloc] init];
    }
    self.userID = t_userID;
    
    return self;
}

- (id) initWithUserPID:(NSNumber *)t_userPID userID:(NSString *)t_userID {
    
    if(!self) {
        self = [[FollowListViewController alloc] init];
    }
    self.userPID = t_userPID;
    self.userID = t_userID;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // ナビゲーションタイトル
    self.navigationItem.titleView = [CommonUtil getNaviTitle:NSLocalizedString(@"PageFollow", nil)];
    
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

//    if(!self.followManager){
//        self.followManager = [[FollowManager alloc]init];
//    }
    if(self.userID){
        NSString *keyPath = [@"follows" stringByAppendingString:self.userID];
        [self.followManager addObserver:self
                                         forKeyPath:keyPath
                                            options:NSKeyValueObservingOptionNew
                                            context:nil];
    }
    
    self.canLoadMore = NO;
    
    // 引っ張って更新.
    //    [self.refreshControl addTarget:self action:@selector(refreshFollows:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.isLoadingApi){
        self.isLoadingApi = YES;
        [self refreshFollows:NO];
    }
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"MyFollowList"];
    
    // network check
    if(![[UserManager sharedManager]checkNetworkStatus]){
        // error network
        NetworkErrorView *networkErrorView = [[NetworkErrorView alloc]init];
        networkErrorView.delegate = self;
        [networkErrorView showInView:self.view];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    //    if(self.categoryID){
    //        NSString *keyPath = [@"follows" stringByAppendingString:self.userID];
    //        [[FollowManager sharedManager] removeObserver:self forKeyPath:keyPath];
    //    }
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
    if (object == self.followManager && [keyPath isEqualToString:@"follows"]) {
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
    [self refreshFollows:YES];
    //[NSThread sleepForTimeInterval:0.5f];
    
    // 更新終了
    //[self.refreshControl endRefreshing];
}

/* 引っぱって更新 */
- (void)refreshFollows:(BOOL)refreshFlg
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
    [self.followManager reloadFollowsWithParams:params aToken:aToken block:^(NSMutableArray *follows, NSUInteger *followPage, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        
        DLog(@"%@", follows);
        
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
            strongSelf.followPage = followPage;
            [strongSelf.tableView reloadData];
            strongSelf.canLoadMore = strongSelf.followManager.canLoadFollowMore;
        }
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLoadingCellHeight;
}

// ヘッター / フッターで余白を作成
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 0)];
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

/* セルの個数を返す */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%lu", [[BDYPicoInfoManager sharedManager].infos count]);
    return [self.followManager.follows count];
}

/* セルを返す*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //UITableViewCell *cell = nil;
    
    FollowTableViewCell *followCell = [tableView dequeueReusableCellWithIdentifier:@"FollowTableViewCell"];

    Follow *jFollow = [self.followManager.follows objectAtIndex:(NSUInteger)indexPath.row];
    
    BOOL isSrvFollow = NO;
    if([jFollow.isFollow isEqualToNumber:[NSNumber numberWithInt:VLISBOOLTRUE]]){
        isSrvFollow = YES;
    }
    NSNumber *myUserPID = [Configuration loadUserPid];
    if(myUserPID){
        jFollow.isFollow = [[UserManager sharedManager] getIsMyFollow:myUserPID userPID:jFollow.userPID isSrvFollow:isSrvFollow loadingDate:jFollow.loadingDate];
    }
    
    [followCell configureCellForAppRecord: jFollow];
    
    if (indexPath.row != 0) {
//        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(10, followCell.frame.origin.y, followCell.bounds.size.width - 20, 1)];
//        line.backgroundColor = COMMON_DEF_GRAY_COLOR;
//        [followCell addSubview:line];
    }
    
    if (followCell.appointmentBtn) {
        
        // 予約ボタンタップ時
        [followCell.appointmentBtn addTarget:self action:@selector(openMessageView:event:) forControlEvents:UIControlEventTouchUpInside];
        [self controlAppointmentBtn:jFollow :followCell.appointmentBtn];
    }

    // ユーザアイコンタップ時
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconFollowTap:)];
    [followCell.userImageView addGestureRecognizer:tapGestureRecognizer];
    followCell.userImageView.userInteractionEnabled = YES;
    followCell.userImageView.tag = [followCell.userPID integerValue];

    // フォローボタンタップ時
    [followCell.followBtn addTarget:self action:@selector(inFollowTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];

    // ハイライトなし
    followCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return followCell;
    
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
            params = @{ @"page" : @(self.followManager.followPage), @"userPID" : [myUserPID stringValue]};
        }else{
            params = @{ @"page" : @(self.followManager.followPage), @"userPID" : [self.userPID stringValue]};
        }
        NSString *aToken = [Configuration loadAccessToken];

        // more page
        __weak typeof(self) weakSelf = self;
        
        [self.followManager loadMoreFollowsWithParams:params aToken:(NSString *)aToken block:^(NSMutableArray *follows, NSUInteger *followPage, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                DLog(@"error = %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                
            }else{
                //strongSelf.follows = follows;
                strongSelf.followPage = followPage;
                [strongSelf.tableView reloadData];
                strongSelf.canLoadMore = strongSelf.followManager.canLoadFollowMore;
                
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


- (void)inFollowTouchButton:(UIButton *)sender event:(UIEvent *)event
{
    // ------------------
    // login check
    // ------------------
    if(![[Configuration checkLogined] length]){
        // 未ログイン
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        
    }else{
        
        NSIndexPath *indexPath = [self indexPathForControlEvent:event];
        FollowTableViewCell* followCell = (FollowTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
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
        NSNumber *targetUserPID = followCell.userPID;
        
        NSNumber *isFollow = followCell.isFollow;
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
                    
                    [followCell.followBtn setImage:[UIImage imageNamed:@"ico_follow.png"] forState:UIControlStateNormal];
                    followCell.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    
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
                    
                    [followCell.followBtn setImage:[UIImage imageNamed:@"ico_follower.png"] forState:UIControlStateNormal];
                    followCell.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    
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

// メッセージ画面を開く.
- (IBAction)openMessageView: (UIButton *)sender event:(UIEvent *)event
{
    //send bird api -> https://sendbird.gitbooks.io/sendbird-server-api/content/en/user.html
    
    // 未ログイン
    if (![self isLoggedin]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification
                                                            object:self];
        return;
    }
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    Follow *follow = [self.followManager.follows objectAtIndex:indexPath.row];
    
    //メッセージに必要な変数をそろえる
    [self enableMsg:follow];
    
    // 必要変数がなければ中止.
    if (![self canOpenMsg]) return;
    
    // 相手ユーザを作成または確認できてから遷移.
    AFHTTPRequestOperationManager *sendBirdApiManager = [AFHTTPRequestOperationManager manager];
    sendBirdApiManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *userInfoParam = @{@"auth" : SEND_BIRD_API_TOKEN,
                                    @"id" : self.userChatToken,
                                    @"nickname" : self.userID,
                                    @"image_url" : self.userIconPath,
                                    @"issue_access_token" : @0,
                                    };
    NSDictionary *vConfig = [ConfigLoader mixIn];
    [sendBirdApiManager
     POST:[NSString stringWithFormat:@"%@%@",
           vConfig[@"ApiPathSendBird"][@"top"],
           vConfig[@"ApiPathSendBird"][@"user"][@"create"]]
     parameters:userInfoParam
     success:^(AFHTTPRequestOperation *operation, id responseObject){
         if (operation.response.statusCode == [API_RESPONSE_CODE_SUCCESS integerValue]) {
             [self goToMessageView];
         }else{
             return;
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         return ;
     }];
}

// メッセージ画面への遷移.
- (void)goToMessageView {
    MessagingTableViewController *messageViewController = [[MessagingTableViewController alloc] init];
    
    [messageViewController setTargetUserId:self.userChatToken];
    [messageViewController setViewMode:kMessagingViewMode];
    [messageViewController initChannelTitle];
    [messageViewController setChannelUrl:SEND_BIRD_CHANNEL_URL];
    [messageViewController setUserName:[Configuration loadUserId]];
    [messageViewController setUserId:self.myChatToken];
    messageViewController.userImageUrl = self.myIconPath;
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENMESSAGE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[SENDER] : [Configuration loadUserPid],
                                      DEFINES_REPROEVENTPROPNAME[RECEIVER] : self.userPID, }];
    
    @try {
        [self.navigationController pushViewController:messageViewController animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Could not open message view. %@",exception);
    }
    @finally {
        return;
    }
}

- (void)userIconFollowTap:(UIGestureRecognizer *)recognizer
{
    NSLog(@"gestureTest[%@]",recognizer);
    NSLog(@"[%@]",recognizer.view);
    
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

// ログインしているかどうか
- (BOOL)isLoggedin {
    return ([Configuration loadAccessToken]);
}

// メッセージを開くのに必要な変数をセットする
- (void)enableMsg: (Follow*) follow {
    NSDictionary *vConfig = [ConfigLoader mixIn];
    [[UserManager sharedManager] getUserInfo:follow.userPID
                                       block:^(NSNumber *result_code, User *user, NSMutableDictionary *responseBody,NSError *error) {
                                           if (!error) {
                                               self.userChatToken = user.chat_token;
                                               self.userID = user.userID;
                                               self.userIconPath = (user.iconPath)? user.iconPath:vConfig[@"UserNoImageIconPath"];
                                           }
                                       }];
    if (![self isLoggedin]) return;
    [[UserManager sharedManager] getUserInfo:nil
                                       block:^(NSNumber *result_code, User *me, NSMutableDictionary *responseBody, NSError *error) {
                                           if (!error) {
                                               self.myChatToken = me.chat_token;
                                               self.myIconPath = (me.iconPath)? me.iconPath:vConfig[@"UserNoImageIconPath"];
                                           }
                                       }];
}

// メッセージを開けることができるか
- (BOOL)canOpenMsg{
    return (self.userChatToken         &&
            self.myChatToken           &&
            self.userID                &&
            [Configuration loadUserId] &&
            self.userIconPath          &&
            self.myIconPath);
}


// 予約するボタンの表示・非表示を制御
// NOTICE:: 引数をFollowTableViewCellにする場合は、メンバ変数followをヘッダに宣言する必要がある
- (void)controlAppointmentBtn: (Follow *) follow : (UIButton *) appointmentBtn {
    
    [self getUserAttr:follow.userPID block:^(NSString *attr) {
        
        if ([self isLoggedin]) {
            
            [self getUserAttr:nil block:^(NSString *myattr) {
                if ([myattr isEqualToString:@"g"] && ![myattr isEqual:attr]) {
                    appointmentBtn.hidden = NO;
                }else{
                    appointmentBtn.hidden = YES;
                }
            }];
        }else if([attr isEqualToString:@"p"]){
            appointmentBtn.hidden = NO;
        }else{
            appointmentBtn.hidden = YES;
        }
    }];
}

// ユーザの一般・プロの属性を取得
- (void)getUserAttr:(NSNumber *)userPid block:(void(^)(NSString *attr))block {
    [[UserManager sharedManager] getUserInfo:userPid
                                       block:^(NSNumber *result_code, User *user, NSMutableDictionary *responseBody, NSError *error) {
                                           if (error) {
                                               NSLog(@"error=%@",error);
                                               block(nil);
                                           } else {
                                               block(user.attribute);
                                           }
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
                [self refreshFollows:NO];
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
