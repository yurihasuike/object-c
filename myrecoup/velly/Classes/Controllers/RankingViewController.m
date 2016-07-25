//
//  RankingViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/23.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RankingViewController.h"
#import "RankingTabPagerViewController.h"
#import "RankingTableViewCell.h"
#import "FollowManager.h"
#import "Ranking.h"
#import "HomeTabPagerViewController.h"
#import "UserViewController.h"
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

@interface RankingViewController () <NetworkErrorViewDelete>    // RankingTabPagerViewDelegate

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *sortProBtn;
@property (weak, nonatomic) IBOutlet UIButton *sortGeneralBtn;

@property (strong, nonatomic) NSMutableArray *rankings;
@property (weak, nonatomic) NSNumber *userPID;

@property (nonatomic) NSUInteger *rankingPage;

@property (nonatomic) BOOL isTapAction;

@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

static CGFloat kLoadingCellHeight = 152.0f;
//static CGFloat kLoadingCellMinHeight = 66.0f;


@implementation RankingViewController

//@synthesize categoryID;
@synthesize categoryID = _categoryID;


// かならず、カテゴリIDを指定して呼び出すこと : TabPager側より

- (id) initWithCategoryID:(NSNumber *)t_categoryID {

    if(!self) {
        self = [[RankingViewController alloc] init];
    }
    self.categoryID = t_categoryID;
    if(!self.rankingManager){
        self.rankingManager = [[RankingManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem.title = @"";
    [self.navigationItem setBackBarButtonItem:[CommonUtil getBackNaviBtn]];

    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 30.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.transform = CGAffineTransformMakeScale(0.8, 0.8);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    
    // touchesBeganが遅い対処
    _tableView.delaysContentTouches = false;
    
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //_tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 150);
    
    self.tableView = _tableView;
    [self.view addSubview:_tableView];

    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setColor:[UIColor darkGrayColor]];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator stopAnimating];
    
    
// TODO これが原因で　アプリがおちてるくさい
    
//    if(self.categoryID){
//        NSString *keyPath = [@"rankings" stringByAppendingString:[self.categoryID stringValue]];
//        [self.rankingManager addObserver:self
//                                     forKeyPath:keyPath
//                                        options:NSKeyValueObservingOptionNew
//                                        context:nil];
//    }

    // 引っ張って更新.
//    [self.refreshControl addTarget:self action:@selector(refreshRankings:) forControlEvents:UIControlEventValueChanged];

    // プロユーザ選択
    //[_sortProBtn addTarget:self action:@selector(sortProAction:) forControlEvents:UIControlEventTouchUpInside];
    _sortProBtn.hidden = YES;
    // 一般ユーザ選択
    //[_sortGeneralBtn addTarget:self action:@selector(sortGeneralAction:) forControlEvents:UIControlEventTouchUpInside];
    _sortGeneralBtn.hidden = YES;
    
    // 並び替え プロ：一般 -> default:プロ
    if(!self.sortType){
        self.sortType = VLRANKINGSORTPRO;
    }

    self.canLoadMore = NO;
    self.isLoadingApi = NO;
    self.isTapAction = NO;
    
    // ------------------
    // ranking list -> TabPagerView loading
    // ------------------
    //[self refreshRankings:NO sortedFlg:NO];
}

- (void)dealloc
{
//    if(self.categoryID){
//        NSString *keyPath = [@"rankings" stringByAppendingString:self.categoryID];
//        [self.rankingManager removeObserver:self forKeyPath:keyPath];
//    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"RankingPage"];
    
    // network check
    if(![[UserManager sharedManager]checkNetworkStatus]){
        // error network
        //[NetworkErrorView showInView:self.view];
        NetworkErrorView *networkErrorView = [[NetworkErrorView alloc]init];
        networkErrorView.delegate = self;
        [networkErrorView showInView:self.view];
    }
    
    if( ![self.loginUserPID isEqualToNumber: [Configuration loadUserPid]] || self.isLoadingApi ){
        // reload posts
        if(self.isLoadingApi) self.isLoadingApi = NO;
        
        self.loginUserPID = [Configuration loadUserPid];
        
        self.rankingManager = [RankingManager new];
        [self.tableView reloadData];
        [self refreshRankings:NO sortedFlg:NO];
        
    }

    //投稿後の場合新規投稿を読み込み.
    if (self.isAfterPost) {
        [self refreshRankings:YES sortedFlg:YES];
        self.isAfterPost = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // ここを表示すると、スライドでナビが表示
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


/* KVO で変更があったとき呼ばれる */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *checkPath = [@"rankings" stringByAppendingString:[self.categoryID stringValue]];
    if (object == self.rankingManager && [keyPath isEqualToString:checkPath]) {
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
        //[self.tableView endUpdates]; // 更新終了.
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
    //[self refreshRankings:YES sortedFlg:YES];
// zantei
    //[self refreshRankings:YES sortedFlg:NO];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:VYRankingReloadUserNotification object:self userInfo:nil];

    //[NSThread sleepForTimeInterval:0.5f];

    // 更新終了
    //[self.refreshControl endRefreshing];
}


/* 引っぱって更新 */
- (void)refreshRankings:(BOOL)refreshFlg sortedFlg:(BOOL)sortedFlg
{
    //[self.refreshControl beginRefreshing];

    NSString *sortVal;
    if(sortedFlg){
        //[self.tableView beginUpdates];
//        int cnt = 0;
//        for(Ranking *ranking in self.rankingManager.rankings){
//        }
        //[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        self.rankingManager = [RankingManager new];
        //[self.tableView reloadSections:0 withRowAnimation:UITableViewRowAnimationNone];

        //[self.tableView endUpdates];
        //[self.tableView reloadData];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    if(self.sortType && self.sortType == VLRANKINGSORTNORMAL){
        // Normal
        sortVal = @"g";
    }else{
        // Pro
        sortVal = @"p";
    }
    
    if(self.rankingManager == nil){
        self.rankingManager = [RankingManager new];
    }
    if(refreshFlg){
        [self.refreshControl beginRefreshing];
    }

    NSDictionary *params;
    if(self.categoryID && [self.categoryID isKindOfClass:[NSNumber class]] && self.categoryID != 0){
        params = @{ @"category" : self.categoryID, @"attribute" : sortVal, @"page" : @(1),};
    }else{
        params = @{ @"attribute" : sortVal, @"page" : @(1),};
    }

    DLog(@"%@", params);
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:VYShowLoadingNotification object:self];
    
    __weak typeof(self) weakSelf = self;
    
    [self.rankingManager reloadRankingsWithParams:params block:^(NSMutableArray *rankings, NSUInteger *rankingPage, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:VYHideLoadingNotification object:self];
        if(refreshFlg){
            // 更新終了
            [self.refreshControl endRefreshing];
        }
        
        if (error) {
            DLog(@"error = %@", error);

            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                    initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }else{
        
            strongSelf.rankingPage = rankingPage;
            //[strongSelf.tableView reloadData];
            [strongSelf.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
            strongSelf.canLoadMore = strongSelf.rankingManager.canLoadRankingMore;
            
        }

        //[self.refreshControl endRefreshing];
        //dispatch_async(dispatch_get_main_queue(), ^{
        //    [self.tableView reloadData];
        //});
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [strongSelf.tableView reloadData];
//        });
        
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Ranking *jRanking = [self.rankingManager.rankings objectAtIndex:(NSUInteger)indexPath.row];
    if(jRanking && [jRanking.posts isKindOfClass:[NSArray class]] && [jRanking.posts count] > 0){
        CGFloat cellPostWidth = [[UIScreen mainScreen]bounds].size.width / 4;
        // 64 + 150 + 8 = 222
        CGFloat cellHeight = 64 + cellPostWidth + 8;
        return cellHeight;
    }
    
    return kLoadingCellHeight;

//    CGFloat rowHeight = 0.0;
//    RankingTableViewCell *cell = (RankingTableViewCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
//    if(cell.hasPosts){
//        // has posts
//        rowHeight = kLoadingCellHeight;
//    }else{
//        // no has posts
//        //rowHeight = kLoadingCellMinHeight;
//        rowHeight = kLoadingCellHeight;
//    }
//    return rowHeight;

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%lu", [[BDYPicoInfoManager sharedManager].infos count]);
    //DLog(@"%lu", (unsigned long)[self.rankings count]);
    
    return [self.rankingManager.rankings count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 4.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    CGRect footerFrame = self.tableView.tableFooterView.frame;
    footerFrame.size.height = 4.0;
    footerFrame.size.width = self.view.bounds.size.width;
    
    //DLog(@"%@", footerFrame);
    
    UIView *view = [[UIView alloc] initWithFrame:footerFrame];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RankingTableViewCell *rankingCell = [tableView dequeueReusableCellWithIdentifier:@"RankingTableViewCell"];

    if(!self.userPID){
        self.userPID = [Configuration loadUserPid];
    }
    
    if([self.rankingManager.rankings count] > 0){
    
        Ranking *jRanking = [self.rankingManager.rankings objectAtIndex:(NSUInteger)indexPath.row];
    
        BOOL isSrvFollow = NO;
        if([jRanking.isFollow isEqualToNumber:[NSNumber numberWithInt:VLISBOOLTRUE]]){
            isSrvFollow = YES;
        }
        if(self.userPID){
            jRanking.isFollow = [[UserManager sharedManager] getIsMyFollow:self.userPID userPID:jRanking.userPID isSrvFollow:isSrvFollow loadingDate:jRanking.loadingDate];
        }
    
        [rankingCell configureCellForAppRecord:jRanking myUserPID:self.userPID];
    
        // ユーザアイコンタップ時
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rankingUserIconTap:)];
        rankingCell.userIconImageView.userInteractionEnabled = YES;
        [rankingCell.userIconImageView addGestureRecognizer:tapGestureRecognizer];
        rankingCell.userIconImageView.tag = indexPath.row;
    
        // ユーザ表示タップ時
        // フォローボタンタップ時
        [rankingCell.followBtn addTarget:self action:@selector(inFollowTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
        [rankingCell.userNameBtn addTarget:self action:@selector(rankingUserButton:event:) forControlEvents:UIControlEventTouchUpInside];
        [rankingCell.userIdBtn addTarget:self action:@selector(rankingUserButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
    
        // 投稿画像タップ時
        UITapGestureRecognizer *tapPost1GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rankingPostIconTap:)];
        rankingCell.post1ImageView.userInteractionEnabled = YES;
        [rankingCell.post1ImageView addGestureRecognizer:tapPost1GestureRecognizer];

        UITapGestureRecognizer *tapPost2GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rankingPostIconTap:)];
        rankingCell.post2ImageView.userInteractionEnabled = YES;
        [rankingCell.post2ImageView addGestureRecognizer:tapPost2GestureRecognizer];

        UITapGestureRecognizer *tapPost3GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rankingPostIconTap:)];
        rankingCell.post3ImageView.userInteractionEnabled = YES;
        [rankingCell.post3ImageView addGestureRecognizer:tapPost3GestureRecognizer];

        UITapGestureRecognizer *tapPost4GestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rankingPostIconTap:)];
        rankingCell.post4ImageView.userInteractionEnabled = YES;
        [rankingCell.post4ImageView addGestureRecognizer:tapPost4GestureRecognizer];
    
    
        // ハイライトなし
        rankingCell.selectionStyle = UITableViewCellSelectionStyleNone;

        [rankingCell setNeedsLayout];
        [rankingCell layoutIfNeeded];
        
    }
    
    return rankingCell;
    
}


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
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) &&
       self.canLoadMore){
        
        [self startIndicator];
        
        // more page
        NSString *sortVal;
        if(self.sortType && self.sortType == VLRANKINGSORTNORMAL){
            // Normal
            sortVal = @"g";
        }else{
            // Pro
            sortVal = @"p";
        }
        NSDictionary *params;
        if(self.categoryID && [self.categoryID isKindOfClass:[NSNumber class]] && self.categoryID != 0){
            params = @{ @"category" : self.categoryID, @"attribute" : sortVal, @"page" : @(self.rankingManager.rankingPage),};
        }else{
            params = @{ @"attribute" : sortVal, @"page" : @(self.rankingManager.rankingPage),};
        }
        
        __weak typeof(self) weakSelf = self;
        [self.rankingManager loadMoreRankingsWithParams:params block:^(NSMutableArray *rankings, NSUInteger *rankingPage, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                DLog(@"error = %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }else{
                //strongSelf.populars = populars;
                strongSelf.rankingPage = rankingPage;
                [strongSelf.tableView reloadData];
                strongSelf.canLoadMore = strongSelf.rankingManager.canLoadRankingMore;
            }
            [self endIndicator];
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
    
    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    //view.backgroundColor = [UIColor clearColor];
    //[self.tableView setTableFooterView:view];
}


// 並び替えアクション
- (void)sortProAction: (id)sender
{
    DLog(@"RankingView sortProAction");
    if(self.sortType == 1){
        
        // プロユーザボタン
        [_sortProBtn setBackgroundImage:[UIImage imageNamed:@"bg_righttab-on.png"] forState:UIControlStateNormal];
        [_sortProBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sortProBtn setFrame:CGRectMake(_sortProBtn.frame.origin.x, _sortProBtn.frame.origin.y, _sortProBtn.frame.size.width, 35)];
        // 一般ユーザボタン
        [_sortGeneralBtn setBackgroundImage:[UIImage imageNamed:@"bg_righttab-off.png"] forState:UIControlStateNormal];
        [_sortGeneralBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_sortGeneralBtn setFrame:CGRectMake(_sortGeneralBtn.frame.origin.x, _sortGeneralBtn.frame.origin.y, _sortGeneralBtn.frame.size.width, 30)];

        
        self.sortType = 0;
        
        [self refreshRankings:YES sortedFlg:NO];
    }
    
}

// 並び替えアクション
- (void)sortGeneralAction: (id)sender
{
    DLog(@"RankingView sortGeneralAction");

    if(self.sortType == 0){
        
        // プロユーザボタン
        [_sortProBtn setBackgroundImage:[UIImage imageNamed:@"bg_righttab-off.png"] forState:UIControlStateNormal];
        [_sortProBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_sortProBtn setFrame:CGRectMake(_sortProBtn.frame.origin.x, _sortGeneralBtn.frame.origin.y, _sortProBtn.frame.size.width, 30)];
        // 一般ユーザボタン
        [_sortGeneralBtn setBackgroundImage:[UIImage imageNamed:@"bg_righttab-on.png"] forState:UIControlStateNormal];
        [_sortGeneralBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sortGeneralBtn setFrame:CGRectMake(_sortGeneralBtn.frame.origin.x, _sortGeneralBtn.frame.origin.y, _sortGeneralBtn.frame.size.width, 35)];
        
        self.sortType = 1;
        [self refreshRankings:YES sortedFlg:NO];
    }

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
    RankingTableViewCell* rankingCell = (RankingTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[FOLLOWTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW] : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[SENDER] : [Configuration loadUserPid],
                                      DEFINES_REPROEVENTPROPNAME[TARGET] : rankingCell.userPID}];
    
    
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
        NSNumber *targetUserPID = rankingCell.userPID;
        
        NSNumber *isFollow = rankingCell.isFollow;
        NSComparisonResult result;
        result = [isFollow compare:[NSNumber numberWithInt:0]];
        
        if(isFollow && [isFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
            // followed -> no follow
            
            [[FollowManager sharedManager] deleteFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
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
                    
                    [rankingCell.followBtn setImage:[UIImage imageNamed:@"ico_follow.png"] forState:UIControlStateNormal];
                    rankingCell.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    
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
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorFollow", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    
                    [rankingCell.followBtn setImage:[UIImage imageNamed:@"ico_follower.png"] forState:UIControlStateNormal];
                    rankingCell.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    
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
- (void)rankingUserButton:(UIButton *)sender event:(UIEvent *)event {
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENPROFILE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]:
                                          NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[TAPPED]:
                                          DEFINES_REPROEVENTPROPITEM[NAME]}];
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    Ranking *tRanking = [self.rankingManager.rankings objectAtIndex:indexPath.row];
    
    // 画面内遷移の場合
    UserViewController *userViewController = nil;
    userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
    // 他人画面
    userViewController.isMmine = false;
    userViewController = [userViewController initWithUserPID:tRanking.userPID userID:tRanking.userID];
    [userViewController preloadingPosts];
    
    self.navigationItem.backBarButtonItem.title = @"";
    // 画面遷移実行後に、ナビゲーション表示へ
    //self.navigationController.navigationBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    userViewController.navigationController.navigationBarHidden = NO;
    self.navigationItem.backBarButtonItem.title = @"";
    
    [self.navigationController pushViewController:userViewController animated:YES];
    userViewController = nil;
}


// ユーザアイコンアクション
- (void)rankingUserIconTap:(UIGestureRecognizer *)recognizer
{
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENPROFILE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]:
                                          NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[TAPPED]:
                                          DEFINES_REPROEVENTPROPITEM[IMG]}];
    
    NSInteger recognizerRow = [recognizer view].tag;
    Ranking *tRanking = [self.rankingManager.rankings objectAtIndex:recognizerRow];

    // 画面内遷移の場合
    UserViewController *userViewController = nil;
    userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
    // 他人画面
    userViewController.isMmine = false;
    
    userViewController = [userViewController initWithUserPID:tRanking.userPID userID:tRanking.userID];
    [userViewController preloadingPosts];
    
    self.navigationItem.backBarButtonItem.title = @"";
    // 画面遷移実行後に、ナビゲーション表示へ
    //self.navigationController.navigationBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    userViewController.navigationController.navigationBarHidden = NO;
    self.navigationItem.backBarButtonItem.title = @"";
    
    [self.navigationController pushViewController:userViewController animated:YES];
    
    userViewController = nil;
    
    
//    HomeTabPagerViewController *homeTabPagerViewController = (HomeTabPagerViewController *)self.tabBarController.childViewControllers[0];
//    
//    // タブを選択済みにする
//    //self.tabBarController.selectedViewController = vc;
//    // UINavigationControllerに追加済みのViewを一旦取り除く
//    //[homeTabPagerViewController.navigationController popToRootViewControllerAnimated:NO];
//    [UIView transitionFromView:self.view
//                        toView:homeTabPagerViewController.view
//                      duration:0.1
//     //options:UIViewAnimationOptionTransitionCrossDissolve
//                       options:UIViewAnimationOptionTransitionNone
//                    completion:
//     ^(BOOL finished) {
//    // tab背景
//    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"bg_nav-on01.png"];
//
//         // ---------------------
//         // Notification : sent
//         // ---------------------
//         VYNotificationParameters *parameters = [[VYNotificationParameters alloc] init];
//         // test
//         parameters.userId = [NSNumber numberWithInt:1];
//         NSDictionary *userInfo = @{@"parameters": parameters};
//         NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//         [notificationCenter postNotificationName:VYUserRankingToHomeNotification object:self userInfo:userInfo];
//         
//         self.tabBarController.selectedViewController = homeTabPagerViewController;
//         
//     }];
    
}

// 投稿画像タップ
- (void) rankingPostIconTap:(UIGestureRecognizer *)recognizer
{
    
//    UITableViewCell *cell = (UITableViewCell *)[[[recognizer view] superview] superview];
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    DLog(@"Pushed :: [%ld]",(unsigned long)path.row);
    
    //Ranking *tRanking = [self.rankings objectAtIndex:(NSUInteger)path.row];
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENDETAIL]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]: NSStringFromClass([self class])}];
    
    // 同一画面遷移の場合
    DetailViewController *detailController = nil;
    detailController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    UIImageView *postImageView = (UIImageView *)recognizer.view;
    NSNumber *postID = [NSNumber numberWithInteger:postImageView.tag];
    if(![postID isKindOfClass:[NSNull class]] && ![postID isEqualToNumber:[NSNumber numberWithInt:0]]){
        
        if(!self.isTapAction){
            
            
            [[PostManager sharedManager] getPostInfo:postID aToken:[Configuration loadAccessToken] block:^(NSNumber *result_code, Post *post, NSMutableDictionary *responseBody, NSError *error) {
                self.isTapAction = YES;
                
                if (error) {
                    DLog("Get Post failed in Ranking -> Detail :%@ , code :%@ , body :%@",error,result_code,responseBody);
                    // エラー
                    UIAlertView *alert = [[UIAlertView alloc]init];
                    alert = [[UIAlertView alloc]
                                          initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil)
                             message: nil
                             delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)
                             otherButtonTitles:nil];
                    [alert show];
                }
                else{
                    
                    //動画の場合はタップした画像をdetailviewにはめておく
                    if ([post.transcodedPath hasSuffix:@".mov"] || [post.transcodedPath hasSuffix:@".mp4"]) {
                        detailController.postImageTempView = postImageView;
                    }
                    else{
                        [detailController loadingPostWidthPostID:postID];
                    }
                    detailController.post = post;
                    detailController.postID = postID;
                    
                    [self.navigationController setNavigationBarHidden:NO animated:NO];
                    detailController.navigationController.navigationBarHidden = NO;
                    
                    //動画の場合は遅延させない
                    if ([post.transcodedPath hasSuffix:@".mov"] || [post.transcodedPath hasSuffix:@".mp4"]) {
                        [self.navigationController pushViewController:detailController animated:YES];
                    }
                    else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4f * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                            [self.navigationController pushViewController:detailController animated:YES];
                        });
                    }
                    
                }
                
                self.isTapAction = NO;
            }];
            
        }
        
            
    }
    
//    HomeTabPagerViewController *homeTabPagerViewController = (HomeTabPagerViewController *)self.tabBarController.childViewControllers[0];
//    [homeTabPagerViewController.navigationController popToRootViewControllerAnimated:NO];
//
//    [UIView transitionFromView:self.view
//                        toView:homeTabPagerViewController.view
//                      duration:0.1
//                        //options:UIViewAnimationOptionTransitionCrossDissolve
//                       options:UIViewAnimationOptionTransitionNone
//                    completion:
//     ^(BOOL finished) {
//    // tab背景
//    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"bg_nav-on01.png"];
//
//         // ---------------------
//         // Notification : sent
//         // ---------------------
//         VYNotificationParameters *parameters = [[VYNotificationParameters alloc] init];
//         // test
//         parameters.postId = [NSNumber numberWithInt:1];
//         NSDictionary *userInfo = @{@"parameters": parameters};
//         NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//         [notificationCenter postNotificationName:VYPostRankingToHomeNotification object:self userInfo:userInfo];
//         
//         self.tabBarController.selectedViewController = homeTabPagerViewController;
//         
//     }];
//    
    
}


#pragma mark - RankingTabPagerViewDelegate
- (void) sortAction:(NSNumber *)sortIndex
{
    DLog(@"RankingTabPagerViewDelegate sortAction:");
    
    self.sortType = [sortIndex intValue];
    
    DLog(@"%@", sortIndex);
    
    DLog(@"%@", self.categoryID);
    DLog(@"%d", self.sortType);
    
    // reloading
//    [self refreshRankings:YES sortedFlg:YES];
    
//    self.rankingManager = [RankingManager new];
//    [self.tableView reloadData];
//    [self refreshRankings:NO sortedFlg:NO];
    
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
                [self refreshRankings:NO sortedFlg:NO];
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
