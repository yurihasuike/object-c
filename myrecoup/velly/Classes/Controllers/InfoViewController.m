//
//  InfoViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/02/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoFollowTableViewCell.h"
#import "InfoManager.h"
#import "FollowManager.h"
#import "Info.h"
#import "HomeTabPagerViewController.h"
#import "DetailViewController.h"
#import "VYNotification.h"
#import "UINavigationBar+Awesome.h"
#import "SVProgressHUD.h"
#import "UserManager.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "NetworkErrorView.h"
#import "InfoWebViewController.h"
#import "TTTAttributedLabel.h"
#import "Defines.h"
#import "CommonUtil.h"
#import "UserViewController.h"

static NSString * const FormatInfoType_toString[] = {
    [VLINFOTYPEFOLLOWED]    = @"f",
    [VLINFOTYPERANKUP]      = @"r",
    [VLINFOTYPELIKED]       = @"l",
    [VLINFOTYPECOMMENTED]   = @"c",
    [VLINFOTYPEOFFICIALNEWS] = @"n",
    [VLINFOTYPEOFFICIALIMPORTANTNEWS] = @"i",
    
};

@interface InfoViewController () <NetworkErrorViewDelete,TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) InfoManager *infoManager;
@property (strong, nonatomic) NSMutableArray *infos;
@property (nonatomic) NSUInteger *infoPage;
@property (nonatomic) BOOL isTapAction;
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) InfoFollowTableViewCell *infoFollowCell;
@property (nonatomic) UILabel *NoElementMessageLabel;

@end

static CGFloat kLoadingCellHeight = 64.0f;

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //ソートタブ初期化.
    self.segmentItems = [NSArray arrayWithObjects:NSLocalizedString(@"InfoSegmentTitleNews", nil), NSLocalizedString(@"InfoSegmentTitleInfo", nil), nil];
    self.infoTypeSegmentControl = [[UISegmentedControl alloc] initWithItems:self.segmentItems];
    self.infoTypeSegmentControl.selectedSegmentIndex = INFOTYPENEWS;
    [self.infoTypeSegmentControl addTarget:self action:@selector(infoTypeChangeAction:)forControlEvents:UIControlEventValueChanged];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //「戻る」、「RootviewController」を消す
    [self.navigationItem setTitle:@""];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    else {
        // ios6
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    self.navigationItem.backBarButtonItem.enabled = NO;

    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 30.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [self.tableView.tableHeaderView addSubview:self.refreshControl];
    

    // Uncomment the following line to preserve selection between presentations.
//     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // touchesBeganが遅い対処
    self.tableView.delaysContentTouches = false;
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    if ([self.tableView respondsToSelector:@selector(separatorInset)]) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setColor:[UIColor darkGrayColor]];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator stopAnimating];
    
    self.canLoadMore = NO;
    self.isTapAction = NO;
    
    [self setNoElementMessageLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    // 初回表示時 2番目
    // 元タブ表示時 1番目
    [super viewWillAppear:animated];
    
    // 未ログイン時.
    if(![Configuration loadAccessToken]){
        
        //self.refreshControl 非表示(くるくる)
        self.refreshControl.hidden = YES;
        [self.tableView.tableHeaderView addSubview:nil];
        
        //ソート機能なし.
        self.infoTypeSegmentControl.selectedSegmentIndex = INFOTYPENEWS;
        //ソートタブなし時とお知らせのViewのタイトル初期化.
        self.infoTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.infoTitle.font = JPBFONT(17);
        self.infoTitle.textColor = [UIColor whiteColor];
        self.infoTitle.text = @"お知らせ";
        [self.infoTitle sizeToFit];
        self.navigationItem.titleView = self.infoTitle;
        
    }
    else{
        self.refreshControl.hidden = NO;
        [self.tableView.tableHeaderView addSubview:self.refreshControl];
        self.navigationItem.titleView = self.infoTypeSegmentControl;
    }
    BOOL isLoadingApi = NO;
    if(self.userPID && ![self.userPID isEqualToNumber:[Configuration loadUserPid]]){
        isLoadingApi = YES;
    }
    self.userPID = [Configuration loadUserPid];
    
    if(isLoadingApi){
        self.infoManager = [InfoManager new];
    }
    //お知らせ初期化
    if (!self.infoManager.infos) {
        [self refreshInfos:NO];
    }
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"Info"];

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

- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];

    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0); // UIEdgeInsetsZero;
    }
}

- (void)dealloc
{
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
//            DLog(@"offset : %f", offsetY);
//            DLog(@"alfa : %f", alpha);
//            [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
//        }
//    } else {
//        [self setNavigationBarTransformProgress:0];
//        [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:1]];
//        
//        //self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
//    }
//    self.navigationController.navigationItem.backBarButtonItem = nil;
//
//}
//- (void)setNavigationBarTransformProgress:(CGFloat)progress
//{
//    [self.navigationController.navigationBar lt_setTranslationY:(-44 * progress)];
//    // 以下の処理でiphone5以下だと戻るボタンが表示されてしまう
//    //[self.navigationController.navigationBar lt_setContentAlpha:(1-progress)];
//}



#pragma mark - Table view data source


/* KVO で変更があったとき呼ばれる */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *checkPath = @"infos";
    if (object == [InfoManager sharedManager] && [keyPath isEqualToString:checkPath]) {
        // 配列が変更された場所のインデックス.
        NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
        // 変更の種類.
        NSKeyValueChange changeKind = (NSKeyValueChange)[change[NSKeyValueChangeKindKey] integerValue];
        
        // 配列に詰め替え.
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }];
        
        // `infos` の変更の種類に合わせて TableView を更新.
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
    // action
    [self refreshInfos:YES];
}


/* 引っぱって更新 */
- (void)refreshInfos:(BOOL)refreshFlg
{
    //タブに応じて取得するお知らせタイプを指定.
    NSArray *attributeParams;
    if (self.infoTypeSegmentControl.selectedSegmentIndex == INFOTYPENEWS) {
        attributeParams = [NSArray arrayWithObjects:
                           FormatInfoType_toString[VLINFOTYPEOFFICIALNEWS],
                           FormatInfoType_toString[VLINFOTYPEOFFICIALIMPORTANTNEWS],
                           nil];
    }else{
        attributeParams = [NSArray arrayWithObjects:
                           FormatInfoType_toString[VLINFOTYPERANKUP],
                           FormatInfoType_toString[VLINFOTYPEFOLLOWED],
                           FormatInfoType_toString[VLINFOTYPELIKED],
                           FormatInfoType_toString[VLINFOTYPECOMMENTED],
                           nil];
    }
    
    
    if(self.infoManager == nil){
        self.infoManager = [InfoManager new];
    }
    if(refreshFlg){
        self.infoManager = [InfoManager new];
        [self.tableView reloadData];
        [self.refreshControl beginRefreshing];
    }

    NSDictionary *params = @{ @"page" : @(1),};

    NSString *aToken = [Configuration loadAccessToken];
    
    //非ログインならdevice tokenをセット.
    NSString *dToken;
    if (!aToken) dToken = [Configuration loadDevToken];
    
        __weak typeof(self) weakSelf = self;
    [self.infoManager reloadInfosWithParams:params
                                     aToken:aToken
                                     dToken:dToken
                            attributeParams:attributeParams
        block:^(NSMutableArray *infos, NSUInteger *infoPage, NSError *error){
            
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if(refreshFlg){
                [self.refreshControl endRefreshing];
            }
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                
            }else{
                strongSelf.infoPage = infoPage;
                [strongSelf.tableView reloadData];
                //strongSelf.canLoadMore = strongSelf.infoManager.canLoadInfoMore;
                [strongSelf setunreadInfoCountBadge];
            }
                                          
        }];

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //add no info view if there is no info.
    [self addNoElementView:[self.infoManager.infos count]];
    
    return [self.infoManager.infos count];
}

///セルのタップ時に呼ばれる
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Info *i = [self.infoManager.infos objectAtIndex:indexPath.row];
    STR_SWITCH(i.infoType){
        STR_CASE(FormatInfoType_toString[VLINFOTYPEOFFICIALNEWS]){
            [self openOfficialNews:i];
            break;
        }
        STR_CASE(FormatInfoType_toString[VLINFOTYPEOFFICIALIMPORTANTNEWS]){
            [self openOfficialNews:i];
            break;
        }
        STR_CASE(FormatInfoType_toString[VLINFOTYPELIKED]){
            InfoFollowTableViewCell *c = (InfoFollowTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [self openDetailView:i
                            cell:c];
            break;
        }
        STR_CASE(FormatInfoType_toString[VLINFOTYPECOMMENTED]){
            InfoFollowTableViewCell *c = (InfoFollowTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [self openDetailView:i
                            cell:c];
            break;
        }
        STR_CASE(FormatInfoType_toString[VLINFOTYPERANKUP]){
            [self openRanking:i];
            break;
        }
        STR_CASE(FormatInfoType_toString[VLINFOTYPEFOLLOWED]){
            [self openUser:i];
            break;
        }
        STR_DEFAULT{
            break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([self.infoManager.infos count])
    {
        self.infoFollowCell = [tableView dequeueReusableCellWithIdentifier:@"InfoFollowViewCellId"];

        Info *jInfo = [self.infoManager.infos objectAtIndex:(NSUInteger)indexPath.row];
        BOOL isSrvFollow = NO;
        if([jInfo.isFollow isEqualToNumber:[NSNumber numberWithInt:VLISBOOLTRUE]]){
            isSrvFollow = YES;
        }
        NSNumber *myUserPID = [Configuration loadUserPid];
        if(myUserPID){
            jInfo.isFollow = [[UserManager sharedManager] getIsMyFollow:myUserPID userPID:jInfo.userPID isSrvFollow:isSrvFollow loadingDate:jInfo.loadingDate];
        }
        [self.infoFollowCell configureCellForAppRecord: jInfo];

        // フォローボタン
        [self.infoFollowCell.infoFollowBtn addTarget:self action:@selector(inFollowTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
        
        // ユーザーアイコンイベント登録(ニュース以外)
        if (![jInfo.infoType isEqualToString:FormatInfoType_toString[VLINFOTYPEOFFICIALNEWS]] &&
            ![jInfo.infoType isEqualToString:FormatInfoType_toString[VLINFOTYPEOFFICIALIMPORTANTNEWS]]) {
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconInfoTap:)];
            self.infoFollowCell.iconImageView.userInteractionEnabled = YES;
            [self.infoFollowCell.iconImageView addGestureRecognizer:tapGestureRecognizer];
            
        }
        
        UITapGestureRecognizer *tapPostGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImgInfoTap:)];
        self.infoFollowCell.infoGoodPostImageView.userInteractionEnabled = YES;
        [self.infoFollowCell.infoGoodPostImageView addGestureRecognizer:tapPostGestureRecognizer];
        
        //　公式ニュース/公式ニュース（重要）タップ時
        UITapGestureRecognizer *tapInfoOfficialNewsGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(officialNewsTap:)];
        self.infoFollowCell.infoOfficialNewsLabel.userInteractionEnabled = YES;
        [self.infoFollowCell.infoOfficialNewsLabel addGestureRecognizer:tapInfoOfficialNewsGestureRecognizer];
        
        cell = self.infoFollowCell;
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = kLoadingCellHeight;
    if([self.infoManager.infos objectAtIndex:(NSUInteger)indexPath.row]){
        Info *info = [self.infoManager.infos objectAtIndex:(NSUInteger)indexPath.row];
        InfoFollowTableViewCell *cell = (InfoFollowTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        rowHeight = [cell calcCellHeight:info];
        return rowHeight;
    }
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc]init];
}


#pragma mark - UIScrollViewDelegate

/* Scroll View のスクロール状態に合わせて */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if([_indicator isAnimating]) {
        return;
    }
    
    if(self.infoManager == nil){
        self.infoManager = [InfoManager new];
    }
    
    CGPoint offset = *targetContentOffset;
    offset.y += self.tableView.bounds.size.height - 1.0;
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) &&
       self.canLoadMore){
        
        [self startIndicator];
        
        NSDictionary *params = @{ @"page" : @(self.infoManager.infoPage)};
        NSString *aToken = [Configuration loadAccessToken];
        
        // more page
        __weak typeof(self) weakSelf = self;
        
        [self.infoManager loadMoreInfosWithParams:params aToken:(NSString *)aToken block:^(NSMutableArray *infos, NSUInteger *infoPage, NSError *error) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                
            }else{
                strongSelf.infoPage = infoPage;
                [strongSelf.tableView reloadData];
                strongSelf.canLoadMore = strongSelf.infoManager.canLoadInfoMore;
                
                [strongSelf endIndicator];
            }
        }];
        
    }
    
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    
    if ([[UIApplication sharedApplication]canOpenURL:url]){
        [[UIApplication sharedApplication]openURL:url];
    }
}

#pragma mark Button Action

// フォローボタンアクション
- (void)inFollowTouchButton:(UIButton *)sender event:(UIEvent *)event {
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    InfoFollowTableViewCell* infoFollowCell = (InfoFollowTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[FOLLOWTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]   : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[SENDER] : [Configuration loadUserPid],
                                      DEFINES_REPROEVENTPROPNAME[RECEIVER] : infoFollowCell.userPID,}];
    
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
        NSNumber *targetUserPID = infoFollowCell.userPID;
        
        NSNumber *isFollow = infoFollowCell.isFollow;
        
        if(isFollow && [isFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
            // followed -> no follow
            
            [[FollowManager sharedManager] deleteFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorNoFollow", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    
                    [infoFollowCell.infoFollowBtn setImage:[UIImage imageNamed:@"ico_follow.png"] forState:UIControlStateNormal];
                    infoFollowCell.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    
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
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorFollow", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    
                    [infoFollowCell.infoFollowBtn setImage:[UIImage imageNamed:@"ico_follower.png"] forState:UIControlStateNormal];
                    infoFollowCell.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    
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

#pragma mark UIGestureRecognizer
- (void)userIconInfoTap:(UIGestureRecognizer *)recognizer
{
    if(!self.isTapAction){
        self.isTapAction = YES;
        NSIndexPath *idxPath = [CommonUtil indexPathForTableViewAtRecognizer:self.tableView
                                                                           r:recognizer];
        Info *i = [self.infoManager.infos objectAtIndex:idxPath.row];
        [self openUser:i];
        self.isTapAction = NO;
    }
}
- (void) postImgInfoTap:(UIGestureRecognizer *)recognizer
{
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENDETAIL]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]: NSStringFromClass([self class])}];
    
    if(!self.isTapAction){
        self.isTapAction = YES;
        NSIndexPath *idxPath = [CommonUtil indexPathForTableViewAtRecognizer:self.tableView
                                                                           r:recognizer];
        Info *i = [self.infoManager.infos objectAtIndex:idxPath.row];
        InfoFollowTableViewCell *c = (InfoFollowTableViewCell *)[self.tableView cellForRowAtIndexPath:idxPath];
        
        [self openDetailView:i
                        cell:c];
        self.isTapAction = NO;
    }
}
/// 公式/公式（重要）ニュースタップ時
- (void)officialNewsTap:(UIGestureRecognizer *)recognizer
{
    if([recognizer.view isKindOfClass:[UILabel class]] && !self.isTapAction){
        self.isTapAction = YES;
        NSIndexPath * tappdedIndexPath = [CommonUtil indexPathForTableViewAtRecognizer:self.tableView
                                                                                     r:recognizer];
        Info *i = [self.infoManager.infos objectAtIndex:tappdedIndexPath.row];
        [self openOfficialNews:i];
    }
}

///ユーザ画面へ
- (void)openUser:(Info *)i {
    
    UserViewController *userView = nil;
    userView = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
    
    userView = [userView initWithUserPID:[NSNumber numberWithInt:[i.userPID intValue]]
                                  userID:i.userID];
    [userView preloadingPosts];
    [self.navigationController pushViewController:userView animated:YES];
}

///ランキング画面へ
- (void)openRanking:(Info *)i {
    RankingViewController *rankingView = nil;
    rankingView = [[UIStoryboard storyboardWithName:@"Ranking" bundle:nil ] instantiateViewControllerWithIdentifier:@"RankingViewController"];
    [rankingView initWithCategoryID:[NSNumber numberWithInt:[i.categoryID intValue]]];
    
    [rankingView.navigationItem setTitleView:[CommonUtil getNaviTitle:i.categoryName]];
    
    [self.navigationController pushViewController:rankingView animated:YES];
}

///投稿詳細画面へ
- (void)openDetailView:(Info *)i cell:(InfoFollowTableViewCell *)cell{
    
    DetailViewController *detailController = nil;
    detailController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil]
                        instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    UIImageView * postImgView;
    for (UIView *v in cell.contentView.subviews) {
        if ([v isKindOfClass:[UIImageView class]] && !v.hidden) {
            postImgView = (UIImageView *)v;
        }
    }
    [[PostManager sharedManager] getPostInfo:i.postID
                                      aToken:[Configuration loadAccessToken]
                                       block:^(NSNumber *result_code, Post *post, NSMutableDictionary *responseBody, NSError *error) {
                                           
                                           detailController.post = post;
                                           detailController.postID = i.postID;
                                           [detailController loadPost];
                                           
                                           //動画のために画像をセットしておく
                                           if (post.isMovie && postImgView)
                                               detailController.postImageTempView = postImgView ;
                                           [self.navigationController pushViewController:detailController animated:YES];
                                       }];

}

///公式ニュース・公式ニュース(重要)へ飛ぶ
- (void)openOfficialNews:(Info *)tappedInfo{
    
    //戻るボタンのタイトルをなくすために作り直し
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.backBarButtonItem.title = @"";
    
    //公式ニュースの場合はURLへとぶ
    if ([tappedInfo.infoType isEqualToString:@"n"]) {
        
        NSDictionary * vConfig = [ConfigLoader mixIn];
        
        //タップされたURLがMyRecoの場合
        if ([[[NSURL URLWithString:tappedInfo.detail] host]
             isEqual:[[NSURL URLWithString:vConfig[@"MyReco"][@"top"]] host]]) {
            //Send repro Event
            [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENMYRECO]
                                 properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]:
                                                  NSStringFromClass([self class])}];
        }
        
        InfoWebViewController * infoWebView = [[InfoWebViewController alloc] initWithURL:
                                               [NSString stringWithFormat:@"%@%@",
                                                tappedInfo.detail,
                                                vConfig[@"MyReco"][@"suffix"]]];
        
        self.isTapAction = NO;
        // 自身に移動してからpush viewしないと変な遷移になる。
        [UIView transitionFromView:self.view
                            toView:infoWebView.view
                          duration:0.1
                           options:UIViewAnimationOptionTransitionNone
                        completion:
         ^(BOOL finished) {
             [self.navigationController pushViewController:infoWebView animated:YES];
         }];
        return;
    }
    
    UIViewController *InfoOfficialNewsView = [UIViewController alloc];
    
    //caption setting
    UILabel *Infonewscaption = [[UILabel alloc] init];
    Infonewscaption.numberOfLines = 0;
    Infonewscaption.font = JPFONT(13);
    Infonewscaption.textAlignment = NSTextAlignmentCenter;
    Infonewscaption.text = tappedInfo.caption;
    
    //detail setting
    TTTAttributedLabel *Infonewsdetail = [[TTTAttributedLabel alloc] init];
    Infonewsdetail.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    Infonewsdetail.delegate = self;
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    //リンクのスタイル
    if ([NSMutableParagraphStyle class]) {
        [mutableLinkAttributes setObject:USER_DISPLAY_NAME_COLOR forKey:(NSString *)kCTForegroundColorAttributeName];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [mutableLinkAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
    } else {
        [mutableLinkAttributes setObject:(__bridge id)[[UIColor darkGrayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    }
    
    Infonewsdetail.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    Infonewsdetail.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    Infonewsdetail.numberOfLines = 0;
    Infonewsdetail.font = JPFONT(12);
    Infonewsdetail.text = tappedInfo.detail;
    
    //nav
    InfoOfficialNewsView.navigationItem.titleView.alpha = 0;
    InfoOfficialNewsView.navigationItem.titleView = self.infoTitle;
    InfoOfficialNewsView.navigationItem.titleView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:1.2f animations:^{
        InfoOfficialNewsView.navigationItem.titleView.alpha = 0;
        InfoOfficialNewsView.navigationItem.titleView.alpha = 1;
    }];
    
    //nav
    
    [InfoOfficialNewsView.view addSubview:Infonewscaption];
    [InfoOfficialNewsView.view addSubview:Infonewsdetail];
    
    //caption
    [[Infonewscaption superview]
     addConstraint:[NSLayoutConstraint constraintWithItem:Infonewscaption
                                                attribute:NSLayoutAttributeLeading
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:[Infonewscaption superview]
                                                attribute:NSLayoutAttributeLeading
                                               multiplier:1
                                                 constant:20]];
    [[Infonewscaption superview]
     addConstraint:[NSLayoutConstraint constraintWithItem:Infonewscaption
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:[Infonewscaption superview]
                                                attribute:NSLayoutAttributeTrailing
                                               multiplier:1
                                                 constant:-20]];
    [[Infonewscaption superview]
     addConstraint:[NSLayoutConstraint constraintWithItem:Infonewscaption
                                                attribute:NSLayoutAttributeTop
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:[Infonewscaption superview]
                                                attribute:NSLayoutAttributeTop
                                               multiplier:1
                                                 constant:30]];
    [Infonewscaption setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //detail
    [[Infonewsdetail superview]
     addConstraint:[NSLayoutConstraint constraintWithItem:Infonewsdetail
                                                attribute:NSLayoutAttributeLeading
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:[Infonewsdetail superview]
                                                attribute:NSLayoutAttributeLeading
                                               multiplier:1
                                                 constant:10]];
    [[Infonewsdetail superview]
     addConstraint:[NSLayoutConstraint constraintWithItem:Infonewsdetail
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:[Infonewsdetail superview]
                                                attribute:NSLayoutAttributeTrailing
                                               multiplier:1
                                                 constant:-10]];
    [[Infonewsdetail superview]
     addConstraint:[NSLayoutConstraint constraintWithItem:Infonewsdetail
                                                attribute:NSLayoutAttributeTop
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:Infonewscaption
                                                attribute:NSLayoutAttributeBottom
                                               multiplier:1
                                                 constant:10]];
    [Infonewsdetail setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    self.isTapAction = NO;
    // 自身に移動してからpush viewしないと変な遷移になる。
    [UIView transitionFromView:self.view
                        toView:InfoOfficialNewsView.view
                      duration:0.1
                       options:UIViewAnimationOptionTransitionNone
                    completion:
     ^(BOOL finished) {
         [self.navigationController pushViewController:InfoOfficialNewsView animated:YES];
     }];

}


#pragma mark CustomMethod

///未読おしらせ数を取得してバッジへセット
- (void)setunreadInfoCountBadge {
    
    [[InfoManager sharedManager] getUnreadInfoCount:[[NSMutableDictionary alloc] init]
                                             aToken:[Configuration loadAccessToken]
                                             dToken:[Configuration loadDevToken]
    block:^(NSNumber *unreadInfoCount, NSError *error) {
        if (error) {
            unreadInfoCount = [NSNumber numberWithInt:0];
        }
        [self setBadge:unreadInfoCount];
    }];
}

///与えられた数字をバッジに設定する.
- (void)setBadge:(NSNumber * )number {
    [Configuration saveInfoBadge:number];
    int sbBadge = [[Configuration loadSendBirdBadge] intValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [number intValue] + sbBadge;
    self.tabBarItem.badgeValue = ([number boolValue])?[number stringValue]:nil;
}


//「お知らせはありません」ラベル設置　初期値hidden==YES.
-(void)setNoElementMessageLabel{
    self.NoElementMessageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width/1.1, self.view.bounds.size.height/5)];
    self.NoElementMessageLabel.layer.position = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2.5);
    self.NoElementMessageLabel.font = JPFONT(11);
    self.NoElementMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.NoElementMessageLabel.numberOfLines = 0;
    self.NoElementMessageLabel.text = NSLocalizedString(@"NoInfoElementMessage", nil);
    self.NoElementMessageLabel.hidden = YES;
    [self.view addSubview:self.NoElementMessageLabel];
}

//通知タイプが変更された時に呼ばれる
-(void)infoTypeChangeAction:(UISegmentedControl*)type{
    //Loadingを出す.消すのはinfomanagerで。
    [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingLoading", nil)
                         maskType:SVProgressHUDMaskTypeBlack];
    
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[INFOSORT]
                         properties:@{DEFINES_REPROEVENTPROPNAME[TYPE] :
                                          [NSNumber numberWithInteger:type.selectedSegmentIndex]}];
    
    [self refreshInfos:YES];
    DLog("%@",type);
}

- (void)addNoElementView:(NSInteger)infocount
{
    if(!infocount){
        self.NoElementMessageLabel.hidden = NO;
    }else if(infocount){
        self.NoElementMessageLabel.hidden = YES;
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

#pragma mark - NetworkErrorViewDelete
- (void)noNetworkRetry
{
    DLog(@"HomeView no Network Retry");
    
    // network retry check
    if([[UserManager sharedManager]checkNetworkStatus]){
        // display hide
        for(UIView *v in self.view.subviews){
            if(v.tag == 99999999){
                [self refreshInfos:NO];
                [UIView animateWithDuration:0.8f animations:^{
                    v.alpha = 1.0f;
                    v.alpha = 0.0f;
                }completion:^(BOOL finished){
                    [v removeFromSuperview];
                }];
            }
        }
    }

}
@end