//
//  HomeViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "HomeViewController.h"
#import "NetworkErrorView.h"
#import "HomeTabPagerViewController.h"
#import "HomeCollectionViewLayout.h"
#import "HomeCollectionViewCell.h"
#import "HomeHeaderCollectionReusableView.h"
#import "UserViewController.h"
#import "DetailViewController.h"
#import "SVProgressHUD.h"
#import "UserManager.h"
#import "MasterManager.h"
#import "VYNotification.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "LoadingView.h"
#import "NetworkErrorView.h"
#import "ServerManager.h"
#import "UIImageView+Networking.h"
#import "UIImageView+WebCache.h"
#import "ServerManager.h"
#import "MessagingTableViewController.h"
#import "DetailPageViewController.h"
#import "Defines.h"

static NSString* const HomeCellIdentifier = @"HomeCell";
static NSString* const HomeHeaderIdentifier = @"HomeHeader";
static NSString* const HomeFooterIdentifier = @"HomeFooter";

extern NSString * const FormatPostSortType_toString[];
NSString * const FormatPostSortType_toString[] = {
    [VLHOMESORTNEW]    = @"r",      // 新着
    [VLHOMESORTPOP]    = @"p"       // 人気
};
// ex) NSString *str = FormatPostSortType_toString[theEnumValue];

@interface HomeViewController () <HomeCollectionViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NetworkErrorViewDelete> // HomeTabPagerViewDelegate

@property (weak, nonatomic) IBOutlet HomeHeaderCollectionReusableView *homeHeaderCollectionReusableView;
@property (nonatomic, strong) NSMutableArray *cellHeights;
@property (nonatomic) NSArray *posts;

@property (nonatomic) NSUInteger *postPage;

@property (nonatomic) BOOL isSendLike;
@property (nonatomic) BOOL isTapAction;

@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@property (nonatomic) HomeCollectionViewCell *homeCellHeight;

@end


@implementation HomeViewController

@synthesize categoryID = _categoryID;
//@synthesize postManager = _postManager;


- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 9999){
        NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1035632643&mt=8"];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem.title = @"";
    if ([self.parentViewController.parentViewController isKindOfClass:[HomeTabPagerViewController class]]) {
        HomeTabPagerViewController *homeTabPagerView = (HomeTabPagerViewController*)self.parentViewController.parentViewController;
        [homeTabPagerView.messageBtn addTarget:self action:@selector(openMessageListView:) forControlEvents:UIControlEventTouchUpInside];
    }
    //Rssなら後の処理は行わない
    if (self.isRss)return;
    
    //self.navigationController.navigationBar.hidden = NO;
    //self.navigationController.navigationBar.backgroundColor = HEADER_BG_COLOR;
    //[self.navigationController setNavigationBarHidden:YES animated:NO];

    _homeCellHeight = [[HomeCollectionViewCell alloc]initWithFrame:CGRectZero];
    //_homeCellHeight = [self.cv dequeueReusableCellWithReuseIdentifier:HomeCellIdentifier forIndexPath:nil];

    self.postManager = [PostManager new];

    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.cv.frame.size.width, 30.0f)];
    [self.refreshControl addTarget:self action:@selector(reload:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.transform = CGAffineTransformMakeScale(0.8, 0.8);
    //self.refreshControl.tintColor = HEADER_BG_COLOR;
    //[self.cv. addSubview:self.refreshControl];
    //[self.refreshControl:self.refreshControl];
    [self.cv addSubview:self.refreshControl];
    
    self.cv.dataSource = self;
    self.cv.delegate = self;
    self.cv.decelerationRate = UIScrollViewDecelerationRateNormal;

    
    CGFloat cellWidth = (self.view.frame.size.width / 2) - 7.0f;
    
    HomeCollectionViewLayout *cvLayout = [[HomeCollectionViewLayout alloc] init];
    cvLayout.delegate     = self;
    cvLayout.itemWidth    = cellWidth; // 140.0f;
    cvLayout.topInset     = 10.0f;
    cvLayout.bottomInset  = 10.0f;
    cvLayout.stickyHeader = NO;
    [self.cv setCollectionViewLayout:cvLayout];
    
    self.sortType = 0;
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setColor:[UIColor darkGrayColor]];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator stopAnimating];
    
//    // 並び替えテスト
//    NSArray *sortItems = [NSArray arrayWithObjects:@"新着順", @"人気順", nil];
//    if (!_sortSegmentedControl) {
//        _sortSegmentedControl = [[UISegmentedControl alloc]initWithItems:sortItems];
//        _sortSegmentedControl.center = self.view.center;
//        // init selected
//        _sortSegmentedControl.selectedSegmentIndex = 0;
//        self.navigationItem.titleView = _sortSegmentedControl;
//        self.navigationController.navigationItem.titleView = _sortSegmentedControl;
//    }else{
//        //[_sortSegmentedControl removeAllSegments];
//        self.navigationItem.titleView = _sortSegmentedControl;
//        self.navigationController.navigationItem.titleView = _sortSegmentedControl;
//    }
    
    NSString *keyPath;
    if([self.categoryID isKindOfClass:[NSNumber class]]){
        keyPath = [@"homePosts" stringByAppendingString:[self.categoryID stringValue]];
    }else{
        keyPath = @"homePosts";
    }
//    [self.postManager addObserver:self
//                          forKeyPath:keyPath
//                             options:NSKeyValueObservingOptionNew
//                             context:nil];
    
    self.canLoadMore = NO;
    self.isLoadingApi = NO;
    self.isSendLike = NO;
    self.isTapAction = NO;

    // ------------------
    // post list -> TabPagerView loading
    // ------------------
    [self refreshPosts:NO sortedFlg:NO];
//    if([self.postManager isKindOfClass:[PostManager class]] && [self.postManager.posts count] > 0){
//        
//        double delayInSeconds = 2.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            //done 0.4 seconds after.
//            [self.cv reloadData];
//        });
//    }
    
    
//    DLog(@" height : %f", self.view.frame.size.height);
//    CGRect frame = self.view.frame;
//    frame.size.height = frame.size.height - 44;
//    [self.view setFrame:frame];
    
    CGRect bounds = self.cv.bounds;
    bounds.size.height = bounds.size.height - 44;
    [self.cv setBounds:bounds];
    
    CGRect frame = self.cv.frame;
    frame.size.height = frame.size.height - 44;
    [self.cv setFrame:frame];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSString* api = @"check_version/";
    
    //client_type=ios
    NSDictionary* parameters = @{
                                 @"client_type":@"ios",
                                 @"number":[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]
                                 };
    
    //APIにリクエスト
    [[ServerManager sharedManager] getJson:api Parameters:parameters
     
                                   Success:^(NSDictionary* result){
                                       
                                       if([(NSNumber *)result[@"is_valid"] boolValue]){
                                           
                                       }else{
                                           //強制verUP
                                           // 生成と同時に各種設定も完了させる例
                                           UIAlertView *alert = [[UIAlertView alloc]
                                                                 initWithTitle:@"お知らせ"
                                                                 message:@"アプリのバージョンアップが必要です。"
                                                                 delegate:nil
                                                                 cancelButtonTitle:nil
                                                                 otherButtonTitles:@"OK", nil
                                                                 ];
                                           alert.tag = 9999;
                                           alert.delegate = self;
                                           [alert show];
                                           
                                       }
                                   }
     //独自エラー用（パラメータ不足等）
                                      fail:^(NSDictionary* failJson){
                                          
                                      }
     //HTTPステータスエラー時
                                     Error:^(NSDictionary* errorJson){
                                         
                                         
                                     }
     ];
    
}
//ログイン中ならメッセージ一覧へのボタンを表示し新着メッセ確認
- (void)checkUserLoginAndSetIconAndUnreadMessages{
    
    HomeTabPagerViewController *homeTabPagerView = (HomeTabPagerViewController *)self.parentViewController.parentViewController;
    
    if (![homeTabPagerView isKindOfClass:[HomeTabPagerViewController class]]) {
        return;
    }
    
    if ([Configuration loadAccessToken]) {
        [[UserManager sharedManager] getUserInfo:nil block:^(NSNumber *result_code, User *srvUser, NSMutableDictionary *responseBody, NSError *error) {
            if (!error) {
                
                NSDictionary * vConfig= [ConfigLoader mixIn];
                self.loginUserID = srvUser.userID;
                self.myUserIconPath = (srvUser.iconPath)? srvUser.iconPath:vConfig[@"UserNoImageIconPath"];
                self.userChatToken = srvUser.chat_token;
                
                //一つでもなければキャンセル.
                if (!self.loginUserID || !self.myUserIconPath || !self.userChatToken) {
                    return;
                }
                
                //新着メッセージ確認
                [SendBird loginWithUserId:self.userChatToken
                              andUserName:self.loginUserID
                          andUserImageUrl:self.myUserIconPath
                           andAccessToken:@""];
                
                [[SendBird queryMessagingUnreadCount]
                 executeWithResultBlock:^(int unreadMessageCount) {
                     
                     //save chat token.
                     if (![Configuration loadUserChatToken] ||
                         ![self.userChatToken isEqualToString:[Configuration loadUserChatToken]])
                     {
                         [Configuration saveUserChatToken:self.userChatToken];
                     }
                    if (unreadMessageCount) {
                        homeTabPagerView.barMessageBtn.badgeValue = [NSString
                                                                     stringWithFormat:@"%d",unreadMessageCount];
                    }else{
                        homeTabPagerView.barMessageBtn.badgeValue = @"";
                    }
                     
                     [Configuration saveSendBirdBadge:
                      [NSNumber numberWithInt:unreadMessageCount]];
                     NSNumber * infoBadge = [Configuration loadInfoBadge];
                     
                     [UIApplication sharedApplication].applicationIconBadgeNumber = [infoBadge intValue] + unreadMessageCount;
                } errorBlock:^(NSInteger code) {
                    
                }];
                [SendBird cancelAll];
                homeTabPagerView.messageBtn.hidden = NO;
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //check login
    [self checkUserLoginAndSetIconAndUnreadMessages];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"HomePage"];
    
    // network check
    if(![[UserManager sharedManager]checkNetworkStatus]){
        
        NetworkErrorView *networkErrorView = [[NetworkErrorView alloc]init];
        networkErrorView.delegate = self;
        [networkErrorView showInView:self.view];
        
    }
    if( ![self.loginUserPID isEqualToNumber: [Configuration loadUserPid]] || self.isLoadingApi ){
        // reload posts
        if(self.isLoadingApi) self.isLoadingApi = NO;
        
        self.loginUserPID = [Configuration loadUserPid];
        self.postManager = [PostManager new];
        [self.cv reloadData];
        [self refreshPosts:NO sortedFlg:NO];

    }
    
    //ログインしていればメッセージボタンを表示
    HomeTabPagerViewController * homeTabPagerView = (HomeTabPagerViewController *)self.parentViewController.parentViewController;
    if ([homeTabPagerView isKindOfClass:[HomeTabPagerViewController class]]) {
        if (self.loginUserID && [Configuration loadAccessToken]) {
            homeTabPagerView.messageBtn.hidden = NO;
        }
        else{
            homeTabPagerView.messageBtn.hidden = YES;
        }
    }
    
    //投稿後なら新規投稿を反映させる.
    if (self.isAfterPost) {
        [self refreshPosts:YES sortedFlg:YES];
        self.isAfterPost = NO;
    }
    //フォローカテゴリでログインしていれば該当メッセージは非表示
    if ([self isFollowCategory] && ![self isNotLoggedIn]) {
        [self noNetworkRetry];
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
// ここを表示すると、スライドでナビが表示
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // 画面を離れる場合は、ナビ表示
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.cv.collectionViewLayout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [[self.cv collectionViewLayout] invalidateLayout];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//メッセージ一覧を開く
-(IBAction)openMessageListView:(id)sender{
    
    if (!self.loginUserID || !self.userChatToken || !self.myUserIconPath) {
        return;
    }
    //すでにメッセージリストにいる場合は抜ける
    if ([self.navigationController.visibleViewController isKindOfClass:[MessagingTableViewController class]]) {
        return;
    }
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENMESSAGELIST]
                         properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] : [Configuration loadUserPid]}];
    
    MessagingTableViewController *messageListViewController = [[MessagingTableViewController alloc] init];
    NSDictionary * vConfig = [ConfigLoader mixIn];
    [messageListViewController setViewMode:kMessagingChannelListViewMode];
    [messageListViewController initChannelTitle];
    [messageListViewController setChannelUrl:SEND_BIRD_CHANNEL_URL];
    [messageListViewController setUserName:self.loginUserID];
    [messageListViewController setUserId:self.userChatToken];
    messageListViewController.userImageUrl = (self.myUserIconPath)? self.myUserIconPath :vConfig[@"UserNoImageIconPath"];
    [self.navigationController pushViewController:messageListViewController animated:YES];
}
//- (void)dealloc
//{
//    self.tableView.delegate = nil;
//}

/* KVO で変更があったとき呼ばれる */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *checkPath;
    if([self.categoryID isKindOfClass:[NSNumber class]]){
        keyPath = [@"homePosts" stringByAppendingString:[self.categoryID stringValue]];
    }else{
        keyPath = @"homePosts";
    }
    if (object == self.postManager && [keyPath isEqualToString:checkPath]) {
        // 配列が変更された場所のインデックス.
        NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];
        // 変更の種類.
        NSKeyValueChange changeKind = (NSKeyValueChange)[change[NSKeyValueChangeKindKey] integerValue];
        
        // 配列に詰め替え.
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }];
        
        // `posts` の変更の種類に合わせて TableView を更新.
        //[self.cv beginUpdates]; // 更新開始.
        if (changeKind == NSKeyValueChangeInsertion) {
            // 新しく追加されたとき.
            [self.cv insertItemsAtIndexPaths:indexPaths];
        }
        else if (changeKind == NSKeyValueChangeRemoval) {
            // 取り除かれたとき.
            [self.cv deleteItemsAtIndexPaths:indexPaths];
        }
        else if (changeKind == NSKeyValueChangeReplacement) {
            // 値が更新されたとき.
            [self.cv reloadItemsAtIndexPaths:indexPaths];
        }
        //[self.tableView endUpdates]; // 更新終了.
    }
}


//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.cv performBatchUpdates:^{
//        for (NSDictionary *change in _sectionChanges) {
//            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
//                switch(type) {
//                    case NSFetchedResultsChangeInsert:
//                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
//                        break;
//                    case NSFetchedResultsChangeDelete:
//                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
//                        break;
//                }
//            }];
//        }
//        for (NSDictionary *change in _itemChanges) {
//            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
//                switch(type) {
//                    case NSFetchedResultsChangeInsert:
//                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
//                        break;
//                    case NSFetchedResultsChangeDelete:
//                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
//                        break;
//                    case NSFetchedResultsChangeUpdate:
//                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
//                        break;
//                    case NSFetchedResultsChangeMove:
//                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
//                        break;
//                }
//            }];
//        }
//    } completion:^(BOOL finished) {
//        _sectionChanges = nil;
//        _itemChanges = nil;
//    }];
//}


- (void)reload:(__unused id)sender {
    //self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // 更新開始
    //[self.refreshControl beginRefreshing];
    
    //self.postManager = [PostManager new];
    //[self.cv reloadData];
    //[self refreshPosts:YES sortedFlg:NO];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:VYHomeReloadPostNotification object:self userInfo:nil];
    
    
    // action
    //[self refreshPosts:YES sortedFlg:YES];
    //[NSThread sleepForTimeInterval:0.5f];
    
    // 更新終了
    //[self.refreshControl endRefreshing];
}

- (void)refreshPosts:(BOOL)refreshFlg sortedFlg:(BOOL)sortedFlg
{
    //Rssなら投稿を読み込まない
    if (self.isRss) return;
    
    if(sortedFlg){
        self.postManager = [PostManager new];
        [self.cv reloadData];
    }
    if(self.postManager == nil){
        self.postManager = [PostManager new];
    }
    if(refreshFlg){
        [self.refreshControl beginRefreshing];
    }

    NSString *sortVal = FormatPostSortType_toString[self.sortType];
    // param : access_token / user / categories (id int複数可) / page / order_by ( r or p ) 投稿順 / 人気順
    //NSDictionary *params = @{ @"category_id" : @("test"), @"attribute_id" : @(1), @"page" : @(1),};
    NSDictionary *params;
    
    //おすすめ : categories : パラメタ指定なし
    if(self.categoryID && [self.categoryID isKindOfClass:[NSNumber class]] && ![self isAllOrFollowCategory]){
        params = @{ @"categories" : self.categoryID, @"page" : @(1), @"order_by" : sortVal, };
    }else{
        params = @{ @"page" : @(1), @"order_by" : sortVal, @"following" : @([self isFollowCategory])};
    }
    
    DLog(@"homeView loadPost : %@", params);

    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    
    NSString * aToken = [Configuration loadAccessToken];
    
    __weak typeof(self) weakSelf = self;
    
    [self.postManager reloadPostsWithParams:params aToken:(NSString *)aToken block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
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
            if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_AUTH]){
                // 401 エラー時 : アクセストークンがあれば、削除 -> logout
                NSString *aToken = [Configuration loadAccessToken];
                if(aToken){
                    // access_token等キーチェーン削除
                    [Configuration saveUserPid:nil];
                    [Configuration saveUserId:nil];
                    [Configuration saveEmail:nil];
                    [Configuration savePassword:nil];
                    [Configuration saveAccessToken:nil];
                    [Configuration saveTWAccessToken:nil];
                    [Configuration saveTWAccessTokenSecret:nil];
                    [Configuration saveFBAccessToken:nil];
                    [Configuration saveSettingFollow:nil];
                    [Configuration saveSettingGood:nil];
                    [Configuration saveSettingRanking:nil];
                    // 元画像の保存可否は端末単位で常に保持させておくので消さない
                    // [Configuration saveSettingPostSave:nil];
                    
                    // MagicalRecord削除
                    [User MR_truncateAll];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                    [self refreshPosts:NO sortedFlg:YES];
                }
                
            }else if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_TIMEOUT]){
                // 0 エラー時 : タイムアウト
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
            }
            
        }else{
            
            strongSelf.postPage = postPage;
            strongSelf.canLoadMore = strongSelf.postManager.canLoadPostMore;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (![self shouldShowMessage]) {
                    [strongSelf.cv reloadData];
                }else{
                    //x秒後に再度メッセージを出すべきか判断
                    float x = 0.5;
                    [self delay:x block:^{
                        //出すべきなら出す
                        if ([self shouldShowMessage]) {
                            [[self getErrorView] showInView:self.view];
                        }else{
                            [self noNetworkRetry];
                        }
                    }];
                }
                
                
            });

        }

    }];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [self.cv.collectionViewLayout invalidateLayout];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {

    DLog(@"postmanager count : %lu", (unsigned long)[self.postManager.posts count]);
    if (section == HOME_POSTS_SECTION) {
        return [self.postManager.posts count];
    }
    return [self.postManager.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    
    HomeCollectionViewCell *waterfallCell = [[collectionView dequeueReusableCellWithReuseIdentifier:HomeCellIdentifier forIndexPath:indexPath] initWithSubViews];
    
    //メッセージを出すべき時なら空のセルを返す
    if ([self shouldShowMessage]) return waterfallCell;
    
    waterfallCell.contentView.frame = waterfallCell.bounds;
    waterfallCell.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    Post *jPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
    
    BOOL isSrvGood = NO;
    if([jPost.isGood isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
        isSrvGood = YES;
    }
    NSNumber *myUserPID = [Configuration loadUserPid];
    if(myUserPID){
        jPost.isGood = [self.postManager getIsMyGood:myUserPID postID:jPost.postID isSrvGood:isSrvGood loadingDate:jPost.loadingDate];
        jPost.cntGood = [self.postManager getMyGoodCnt:myUserPID postID:jPost.postID srvGoodCnt:jPost.cntGood loadingDate:jPost.loadingDate];
    }
    [waterfallCell configureCellForAppRecord: jPost];
    
    // 角丸へ
    waterfallCell.layer.cornerRadius = 5.0f;
    // はみだしを制御
    waterfallCell.clipsToBounds = true;

    //枠線の幅
    waterfallCell.layer.borderWidth = 0.4f;
    // 枠線の色
    waterfallCell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    // 領域外をマスクで切り取る設定をしない
    // これを解除すると、レイアウト崩れるか、、影が表示されない
    //waterfallCell.layer.masksToBounds = NO;
    // 影のかかる方向を指定する
    waterfallCell.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    // 影の透明度
    waterfallCell.layer.shadowOpacity = 0.7f;
    // 影の色
    waterfallCell.layer.shadowColor = [UIColor grayColor].CGColor;
    // ぼかしの量
    waterfallCell.layer.shadowRadius = 1.0f;
    
    // ユーザアイコンタップ時
    UITapGestureRecognizer *tapUserGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postUserTap:)];
    waterfallCell.postUserImageView.userInteractionEnabled = YES;
    [waterfallCell.postUserImageView addGestureRecognizer:tapUserGestureRecognizer];
    
    [waterfallCell.postUserNameBtn addTarget:self action:@selector(postUserAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [waterfallCell.postUserIdBtn addTarget:self action:@selector(postUserAction:event:) forControlEvents:UIControlEventTouchUpInside];
    
    // 投稿写真ボタンタップ時
    //[waterfallCell.postImageBtn addTarget:self action:@selector(postImgAction:event:) forControlEvents:UIControlEventTouchUpInside];
    //投稿写真ダブルタップ時
    UITapGestureRecognizer *doubletapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTappedimg:)];
    doubletapGestureRecognizer.numberOfTapsRequired = 2;
    [waterfallCell.postImageView addGestureRecognizer:doubletapGestureRecognizer];
    
    // 投稿写真タップ時
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImgTap:)];
    waterfallCell.postImageView.userInteractionEnabled = YES;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    // ダブルタップに失敗した時だけシングルタップとする
    [tapGestureRecognizer requireGestureRecognizerToFail:doubletapGestureRecognizer];

    [waterfallCell.postImageView addGestureRecognizer:tapGestureRecognizer];

    
    // いいねタップ時
//    [waterfallCell.postGoodCnt addTarget:self action:@selector(postGoodAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [waterfallCell.postGoodBtn addTarget:self action:@selector(postGoodAction:event:) forControlEvents:UIControlEventTouchUpInside];
    waterfallCell.postGoodBtn.tag = SMALLHEART;
    
     [waterfallCell.PostGoodBtnOnImage addTarget:self action:@selector(postGoodAction:event:) forControlEvents:UIControlEventTouchUpInside];
    waterfallCell.PostGoodBtnOnImage.tag = BIGHEART;
    
    
    //comment tap
    waterfallCell.postCommentBtn.tag = (NSInteger)1838;
    [waterfallCell.postCommentBtn addTarget:self action:@selector(postImgAction:event:) forControlEvents:UIControlEventTouchUpInside];
    
    [self layoutGoodCntBtnOnImg:waterfallCell];
    

    //[waterfallCell setNeedsLayout];
    
    
    if(self.postManager.posts && [self.postManager.posts count] > 0){
        
        NSUInteger indexRow = (NSUInteger)indexPath.row;
        
        //if( indexRow + 1 == [self.postManager.posts count] && self.canLoadMore && !_indicator.isAnimating){
        if(indexRow + 1 >= [self.postManager.posts count] && self.canLoadMore && !_indicator.isAnimating){
            
            [LoadingView showInView:self.view];
            self.cv.scrollEnabled = NO;
            // scroll position fix
            [self.cv setContentOffset:self.cv.contentOffset animated:NO];
            [self startIndicator];
            
            NSString * aToken = [Configuration loadAccessToken];
            
            NSString *sortVal = FormatPostSortType_toString[self.sortType];
            NSDictionary *params;
            if(self.categoryID && [self.categoryID isKindOfClass:[NSNumber class]] && ![self isAllOrFollowCategory]){
                params = @{ @"categories" : self.categoryID, @"page" : @(self.postManager.postPage), @"order_by" : sortVal, };
            }else{
                params = @{ @"page" : @(self.postManager.postPage), @"order_by" : sortVal, @"following" : @([self isFollowCategory])};
            }
            __weak typeof(self) weakSelf = self;
            [self.postManager loadMorePostsWithParams:params aToken:aToken block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if (error) {
                    DLog(@"error = %@", error);
                    [LoadingView dismiss];
                    strongSelf.cv.scrollEnabled = YES;
                    
                    if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_TIMEOUT]){
                        // 0 エラー時 : タイムアウト
                        UIAlertView *alert = [[UIAlertView alloc]init];
                        alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                        [alert show];
                    }
                    
                }else{
                    strongSelf.postPage = postPage;
                    strongSelf.canLoadMore = strongSelf.postManager.canLoadPostMore;
                    double delayInSeconds = 0.3;    // 0.5
                    dispatch_time_t moreTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(moreTime, dispatch_get_main_queue(), ^(void){
                        [strongSelf.cv reloadData];
                        //[strongSelf.cv layoutIfNeeded];
                        [LoadingView dismiss];
                        strongSelf.cv.scrollEnabled = YES;
                    });
                }
                [self endIndicator];
                
            }];
        
        }
    }
    
    return waterfallCell;

}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(HomeCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self shouldShowMessage]) {
       return 0;
    }
    Post *jPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
    return [_homeCellHeight homeCellHeight:jPost];
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(HomeCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    return cell.frame.size;
//}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //UIImage *image = [[self.photos objectAtIndex:indexPath.section] objectAtIndex:indexPath.item];
    //return CGSizeMake(image.size.width / 2, image.size.height / 2);
    
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //Post *jPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
    if(cell != nil){
        DLog(@"%f", cell.frame.size.height);
    
        return cell.frame.size;
    }
    return CGSizeZero;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    //Post *jPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
//    
//    DLog(@"%f", cell.frame.size.height);
//    
//    return cell.frame.size;
//}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(HomeCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    return cell.frame.size;
//    
//    //UIImage *image = [[self.photos objectAtIndex:indexPath.section] objectAtIndex:indexPath.item];
//    //return CGSizeMake(image.size.width / 2, image.size.height / 2);
//}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(HomeCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
//    Post *jPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
//    
//    if(jPost){
//        //cell.frame.size = CGSizeMake(160, 30);
//        //HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[self.cv cellForItemAtIndexPath:indexPath];
//        DLog(@"%f", cell.frame.size.height);
//        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.bounds.size.width, [cell homeCellHeight:nil]);
//        DLog(@"%f", cell.postImageView.image.size.height);
//        if(cell.postImageView.image){
//            DLog(@"test");
//            DLog(@"%f", [cell.cellHeight floatValue]);
//            DLog(@"%f", [cell homeCellHeight:nil]);
//        }
//        DLog(@"%@", cell.cellHeight);
//    }

}


- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(HomeCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    
    //return (indexPath.section + 1) * 34.0f;
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(HomeCollectionViewLayout *)collectionViewLayout
heightForFooterAtIndexPath:(NSIndexPath *)indexPath {
    
    //return (indexPath.section + 1) * 34.0f;
    return 320.0f;
}

// セル高さ判定
//- (NSMutableArray *)cellHeights {
//    if (!_cellHeights) {
//        _cellHeights = [NSMutableArray arrayWithCapacity:900];
//        for (NSInteger i = 0; i < 900; i++) {
//            _cellHeights[i] = @(arc4random()%100*2+150);
//            //_cellHeights[i] = @"320";
//        }
//    }
//    return _cellHeights;
//}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath; {
    
    // memo
    // kind == UICollectionElementKindSectionHeader →　ヘッダー
    // kind == UICollectionElementKindSectionFooter →　フッダー
    // UICollectionReusableView *reusableview = nil;
    //  if (kind == UICollectionElementKindSectionHeader) {
    //  headerView = [self.mCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
    // //headerに画像をセット
    // NSURL* imageUrl = [NSURL URLWithString:brandDetail.dBrandIconImage];
    // UIImage *placeholderImage = [UIImage imageNamed:@"code.png"];
    // [headerView.mBrandView sd_setImageWithURL:imageUrl placeholderImage:placeholderImage];
    // headerView.mBrandName.text = brandDetail.dBrandName;
    // reusableview = headerView; }
    //  if (kind == UICollectionElementKindSectionFooter){
    // footerView = [self.mCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
    // reusableview = footerView; }
    // return reusableview;
    
    HomeHeaderCollectionReusableView *titleView = nil;
    UICollectionReusableView *footerView = nil;
    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
    
        titleView =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:HomeHeaderIdentifier
                                              forIndexPath:indexPath];
        
    
        //[titleView.sortNewBtn addTarget:self action:@selector(sortNewAction:) forControlEvents:UIControlEventTouchUpInside];
        //[titleView.sortPopBtn addTarget:self action:@selector(sortPopAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //self.homeHeaderCollectionReusableView = titleView;
        
        return titleView;
        
    
    //titleView.frame = CGRectMake(0,0, 320, 100);
    
    //titleView.lblTitle.text = [NSString stringWithFormat: @"Section %d", indexPath.section];
    }
    //if ([kind isEqualToString: UICollectionElementKindSectionFooter]) {
    else if (kind == UICollectionElementKindSectionFooter){
        // footer
        footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                        withReuseIdentifier:HomeFooterIdentifier
                                                               forIndexPath:indexPath];
        //footerView.frame.size = CGSizeMake(self.view.frame.size.width, 100);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 320)];
        view.backgroundColor = [UIColor blackColor];
        
        [footerView addSubview:view];
        
        return footerView;
    }
    return nil;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //クリックされたらよばれる ただし余白部分のみ
    //DLog(@"Clicked %d-%d",indexPath.section,indexPath.row);
}



#pragma mark - UIScrollViewDelegate

/* Scroll View のスクロール状態に合わせて */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    // ControllerのAdjust Scroll View insets をoff

    if([_indicator isAnimating]) {
        return;
    }
    
    if(self.postManager == nil){
        self.postManager = [PostManager new];
    }
    
    return;
    

}


- (void)startIndicator
{
    [_indicator startAnimating];
    
    _indicator.backgroundColor = [UIColor clearColor];
    CGRect indicatorFrame = _indicator.frame;
    indicatorFrame.size.height = 36.0;
    [_indicator setFrame:indicatorFrame];
    
    //[self.cv setTableFooterView:nil];
    //[self.cv setTableFooterView:_indicator];
}


- (void)endIndicator
{
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
    
}


//// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.cv];
    NSIndexPath *indexPath = [self.cv indexPathForItemAtPoint:p];
    return indexPath;
}

- (void)loadPost:(Post*)post placeHolderImage:(UIImageView*)placeHolderImageView tag:(NSInteger)tag
{
    NSNumber *targetPostID = post.postID;
    
    // Loading
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    
    NSString *vellyToken = [Configuration loadAccessToken];
    
    __weak typeof(self) weakSelf = self;
    [[PostManager sharedManager] getPostInfo:targetPostID aToken:vellyToken block:^(NSNumber *result_code, Post *srvPost, NSMutableDictionary *responseBody, NSError *error) {
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        
        if(!error){
            DetailPageViewController * dPageView = [[DetailPageViewController alloc]
                                                    initWithParentAndTappedPost:self tappedPost:post];
            if(tag == 1838){
                dPageView.fromTag = tag;
            }
            [weakSelf.navigationController pushViewController:dPageView animated:YES];
        }else{
            
            // エラー
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
        }
        
    }];
}

//detailViewアクション共通化@横関
-(void)moveToDetailView:(NSIndexPath*)indexPath tag:(NSInteger)tag{
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENDETAIL]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]: NSStringFromClass([self class])}];
    
    if(!self.isTapAction){
        
        self.isTapAction = YES;
        HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[self.cv cellForItemAtIndexPath: indexPath];
        Post *tPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
        [self loadPost:tPost placeHolderImage:cell.postImageView tag:tag];
        self.isTapAction = NO;
        

    }

}


// 投稿画像アクション -> コメント
- (void)postImgAction:(UIButton *)sender event:(UIEvent *)event {
    
    DLog(@"HomeView postImgAction");
    
    if (sender.tag == 1838) {
        // SEND REPRO EVENT
        [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[COMMENTTAP]
                             properties:@{DEFINES_REPROEVENTPROPNAME[VIEW] :
                                              NSStringFromClass([self class])}];
    }
    [self moveToDetailView:[self indexPathForControlEvent:event] tag:sender.tag];
    
}
//when water fall img double tapped, toggle good action.
- (void)doubleTappedimg:(UIGestureRecognizer *)recognizer{
    DLog(@"HomeView doubleTappedimg");
    
    HomeCollectionViewCell *homeCollectionViewCell = (HomeCollectionViewCell *)[[[recognizer view] superview] superview];
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[GOODTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW] : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[POST] : homeCollectionViewCell.postID,
                                      DEFINES_REPROEVENTPROPNAME[TYPE] : [NSNumber numberWithInteger:recognizer.view.tag]}];
    
    // ------------------
    // login check
    // ------------------
    if(![[Configuration checkLogined] length]){
        
        [Configuration saveLoginCallback:@""];
        
        // 未ログイン
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        
    }else if(self.isSendLike){
        // sending -> no action
        
    }else{
        self.isSendLike = YES;
        
        if(self.postManager == nil){
            self.postManager = [PostManager new];
        }
        NSString *postIdStr = [homeCollectionViewCell.postID stringValue];
        
        NSNumber *isGood = homeCollectionViewCell.isGood;
        
        // **********
        // send like
        // **********
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoding = vConfig[@"LoadingPostDisplay"];
        if( isLoding && [isLoding boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        
        NSString *vellyToken = [Configuration loadAccessToken];
        DLog(@"%@", vellyToken);
        DLog(@"%@", isGood);
        DLog(@"%@", postIdStr);
        
        if([isGood isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
            // liked -> delete like
            [self.postManager deletePostLike:postIdStr aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorNoGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    [homeCollectionViewCell.postGoodCnt setImage:[UIImage imageNamed:@"ico_heart.png"] forState:UIControlStateNormal];
                    
                    homeCollectionViewCell.isGood = [NSNumber numberWithInt:VLPOSTLIKENO];
                    [homeCollectionViewCell minusCntGood];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [self.postManager updateMyGood:myUserPID postID:homeCollectionViewCell.postID isGood:VLPOSTLIKENO cntGood:homeCollectionViewCell.cntGood];
                    }
                    
                    
                    // no alert
                    //                    alert = [[UIAlertView alloc]
                    //                         initWithTitle:NSLocalizedString(@"MsgDelGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    //                    [alert show];
                    
                }
                self.isSendLike = NO;
            }];
            
        }else{
            // no like -> send like
            [self.postManager postPostLike:postIdStr aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    [homeCollectionViewCell.postGoodCnt setImage:[UIImage imageNamed:@"ico_heart_on.png"] forState:UIControlStateNormal];
                    homeCollectionViewCell.isGood = [NSNumber numberWithInt:VLPOSTLIKEYES];
                    [homeCollectionViewCell plusCntGood];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [self.postManager updateMyGood:myUserPID postID:homeCollectionViewCell.postID isGood:VLPOSTLIKEYES cntGood:homeCollectionViewCell.cntGood];
                    }
                    
                    
                    //                    alert = [[UIAlertView alloc]
                    //                         initWithTitle:NSLocalizedString(@"MsgGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    //                    [alert show];
                    
                }
                self.isSendLike = NO;
            }];
        }
        
    }
}

//// 投稿写真タップアクション -> 投稿詳細へ
- (void)postImgTap:(UIGestureRecognizer *)recognizer
{
    DLog(@"HomeView postImgTap");
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[[[recognizer view] superview] superview];
    [self moveToDetailView:[self.cv indexPathForCell:cell] tag:[recognizer view].tag];
}

// ユーザ詳細アクション -> アカウント詳細へ

// ユーザアイコンアクション
- (void)postUserTap:(UIGestureRecognizer *)recognizer
{
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENPROFILE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]:
                                          NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[TAPPED]:
                                          DEFINES_REPROEVENTPROPITEM[IMG]}];
    
    NSLog(@"gestureTest[%@]",recognizer);
    NSLog(@"[%@]",recognizer.view);
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[[[recognizer view] superview] superview];
    NSIndexPath *path = [self.cv indexPathForCell:cell];
    
    Post *tPost = [self.postManager.posts objectAtIndex:(NSUInteger)path.row];

    UserViewController *userViewController = nil;
    userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
    
    // 他人画面
    userViewController.isMmine = false;
    userViewController = [userViewController initWithUserPID:tPost.userPID userID:tPost.userID];
    [userViewController preloadingPosts];
    
    self.navigationItem.backBarButtonItem.title = @"";
    
    [self.navigationController pushViewController:userViewController animated:YES];
    
    userViewController = nil;
}

- (void)postUserAction:(UIButton *)sender event:(UIEvent *)event {
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENPROFILE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]:
                                          NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[TAPPED]:
                                          DEFINES_REPROEVENTPROPITEM[NAME]}];
    
    DLog(@"HomeView postUserAction");
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    Post *tPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
    
    UserViewController *userViewController = nil;
    userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
    
    // 他人画面
    userViewController.isMmine = false;
    userViewController = [userViewController initWithUserPID:tPost.userPID userID:tPost.userID];
    [userViewController preloadingPosts];
        
    self.navigationItem.backBarButtonItem.title = @"";
    [self.navigationController pushViewController:userViewController animated:YES];
}


// いいねタップアクション
- (void)postGoodAction:(UIButton *)sender event:(UIEvent *)event {
    DLog(@"HomeView postGoodAction");
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    HomeCollectionViewCell* homeCollectionViewCell = (HomeCollectionViewCell *)[self.cv cellForItemAtIndexPath:indexPath];
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[GOODTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW] : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[POST] : homeCollectionViewCell.postID,
                                      DEFINES_REPROEVENTPROPNAME[TYPE] : [NSNumber numberWithInteger:sender.tag]}];
    
    // ------------------
    // login check
    // ------------------
    if(![[Configuration checkLogined] length]){
        
        [Configuration saveLoginCallback:@""];
        
        // 未ログイン
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        
    }else if(self.isSendLike){
        // sending -> no action
        
    }else{
        self.isSendLike = YES;

        if(self.postManager == nil){
            self.postManager = [PostManager new];
        }
        NSString *postIdStr = [homeCollectionViewCell.postID stringValue];
        
        NSNumber *isGood = homeCollectionViewCell.isGood;

        // **********
        // send like
        // **********
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoding = vConfig[@"LoadingPostDisplay"];
        if( isLoding && [isLoding boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }

        NSString *vellyToken = [Configuration loadAccessToken];
        DLog(@"%@", vellyToken);
        DLog(@"%@", isGood);
        DLog(@"%@", postIdStr);

        if([isGood isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
            // liked -> delete like
            [self.postManager deletePostLike:postIdStr aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorNoGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    [homeCollectionViewCell.postGoodCnt setImage:[UIImage imageNamed:@"ico_heart.png"] forState:UIControlStateNormal];
                    
                    homeCollectionViewCell.isGood = [NSNumber numberWithInt:VLPOSTLIKENO];
                    [homeCollectionViewCell minusCntGood];

                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [self.postManager updateMyGood:myUserPID postID:homeCollectionViewCell.postID isGood:VLPOSTLIKENO cntGood:homeCollectionViewCell.cntGood];
                    }
                }
                self.isSendLike = NO;
            }];

        }else{
            // no like -> send like
            [self.postManager postPostLike:postIdStr aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    [homeCollectionViewCell.postGoodCnt setImage:[UIImage imageNamed:@"ico_heart_on.png"] forState:UIControlStateNormal];
                    homeCollectionViewCell.isGood = [NSNumber numberWithInt:VLPOSTLIKEYES];
                    [homeCollectionViewCell plusCntGood];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [self.postManager updateMyGood:myUserPID postID:homeCollectionViewCell.postID isGood:VLPOSTLIKEYES cntGood:homeCollectionViewCell.cntGood];
                    }
                }
                self.isSendLike = NO;
            }];
        }

    }
    
}


// 並び替えアクション

// 未使用
- (void)sortNewAction: (id)sender
{
    DLog(@"HomeView sortNewAction");
    if(self.sortType == 1){

        // 新着順
        [self.homeHeaderCollectionReusableView.sortNewBtn setBackgroundImage:[UIImage imageNamed:@"bg_righttab-on.png"] forState:UIControlStateNormal];
        [self.homeHeaderCollectionReusableView.sortNewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.homeHeaderCollectionReusableView.sortNewBtn setFrame:CGRectMake(
            self.homeHeaderCollectionReusableView.sortNewBtn.frame.origin.x,
            self.homeHeaderCollectionReusableView.sortPopBtn.frame.origin.y,
            self.homeHeaderCollectionReusableView.sortNewBtn.frame.size.width, 35)];
        // 人気順
        [self.homeHeaderCollectionReusableView.sortPopBtn setBackgroundImage:[UIImage imageNamed:@"bg_righttab-off.png"] forState:UIControlStateNormal];
        [self.homeHeaderCollectionReusableView.sortPopBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.homeHeaderCollectionReusableView.sortPopBtn setFrame:CGRectMake(
            self.homeHeaderCollectionReusableView.sortPopBtn.frame.origin.x,
            self.homeHeaderCollectionReusableView.sortNewBtn.frame.origin.y,
            self.homeHeaderCollectionReusableView.sortPopBtn.frame.size.width, 30)];

        self.sortType = 0;

    }
    
}

// 未使用
- (void)sortPopAction: (id)sender
{
    DLog(@"HomeView sortPopAction");
    if(self.sortType == 0){

        // 新着順
        [self.homeHeaderCollectionReusableView.sortNewBtn setBackgroundImage:[UIImage imageNamed:@"bg_righttab-off.png"] forState:UIControlStateNormal];
        [self.homeHeaderCollectionReusableView.sortNewBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.homeHeaderCollectionReusableView.sortNewBtn setFrame:CGRectMake(
            self.homeHeaderCollectionReusableView.sortNewBtn.frame.origin.x,
            self.homeHeaderCollectionReusableView.sortPopBtn.frame.origin.y,
            self.homeHeaderCollectionReusableView.sortNewBtn.frame.size.width, 30)];
        // 人気順
        [self.homeHeaderCollectionReusableView.sortPopBtn setBackgroundImage:[UIImage imageNamed:@"bg_righttab-on.png"] forState:UIControlStateNormal];
        [self.homeHeaderCollectionReusableView.sortPopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.homeHeaderCollectionReusableView.sortPopBtn setFrame:CGRectMake(
            self.homeHeaderCollectionReusableView.sortPopBtn.frame.origin.x,
            self.homeHeaderCollectionReusableView.sortNewBtn.frame.origin.y,
            self.homeHeaderCollectionReusableView.sortPopBtn.frame.size.width, 35)];
        
        self.sortType = 1;
        
    }
}

#pragma mark - HomeTabPagerViewDelegate
- (void) sortAction:(NSNumber *)sortIndex
{
    DLog(@"HomeTabPagerViewDelegate sortAction:");
    
    self.sortType = [sortIndex intValue];
    
    DLog(@"homeView sortIndex : %@", sortIndex);
    
    DLog(@"homeView categoryID : %@", self.categoryID);
    DLog(@"homeView sortType : %d", self.sortType);
    
    // reloading
    //[self refreshPosts:YES sortedFlg:YES];
    //self.cv.dataSource = self;
    //[self reload:self];
}

//おすすめかフォローカテゴリーならYESを返す
- (BOOL)isAllOrFollowCategory {
    return ([self isAllCategory] || [self isFollowCategory]);
}
//フォローカテゴリならYES
- (BOOL)isFollowCategory {
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    return (self.categoryID && [[self.categoryID stringValue] isEqualToString:vConfig[@"FollowCategoryPk"]]);
}
//おすすめカテゴリならYES
- (BOOL)isAllCategory {
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    return (self.categoryID && [[self.categoryID stringValue] isEqualToString:vConfig[@"AllCategoryPk"]]);
}
//フォローしてくださいメッセージを出すべきならYES
- (BOOL)shouldShowMessage {
    return ([self isFollowCategory] && (!self.postManager.posts.count || [self isNotLoggedIn]));
}
//ログインしていなければYES
- (BOOL)isNotLoggedIn {
    return (![Configuration loadAccessToken]);
}

//遅延実行
- (void)delay:(float)time block:(void (^)())block{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        block();
    });
}

///適切な文字をセットしてエラーViewを返す
- (NetworkErrorView * )getErrorView {
    
    NetworkErrorView *erView = [[NetworkErrorView alloc] init];
    erView.noNetworkImageView.hidden = YES;
    erView.noNetworkLabel.font = JPBFONT(16);
    erView.noNetworkRetryBtn.titleLabel.font = JPBFONT(16);
    erView.backgroundColor = [UIColor whiteColor];
    erView.delegate = self;
    
    //文言の位置修正
    [erView removeConstraint:erView.lblConstraint];
    [erView addConstraint:[NSLayoutConstraint constraintWithItem:erView.noNetworkImageView
                                                       attribute:NSLayoutAttributeBottom
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:erView.noNetworkLabel
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1
                                                        constant:20]];
    //ログインしていない場合
    if ([self isNotLoggedIn]) {
        erView.noNetworkLabel.text = NSLocalizedString(@"MsgNoFLogin", nil);
        
        [erView.noNetworkRetryBtn setTitle:NSLocalizedString(@"MsgNofLoginRetry", nil)
                                  forState:UIControlStateNormal];
        
        //まず他のアクションの登録を解除
        [erView.noNetworkRetryBtn removeTarget:nil
                                        action:nil
                              forControlEvents:UIControlEventAllEvents];
        
        [erView.noNetworkRetryBtn addTarget:self
                                     action:@selector(noLoginAction:)
                           forControlEvents:UIControlEventTouchUpInside];
        
        //色と枠線変更
        [erView.noNetworkRetryBtn setTitleColor:HEADER_UNDER_BG_COLOR
                                       forState:UIControlStateNormal];
        erView.noNetworkRetryBtn.layer.cornerRadius = 3.0;
        erView.noNetworkRetryBtn.layer.borderColor = HEADER_UNDER_BG_COLOR.CGColor;
        erView.noNetworkRetryBtn.layer.borderWidth = 1.0;
    }else{
        erView.noNetworkLabel.text = NSLocalizedString(@"MsgNoFollow", nil);
        [erView.noNetworkRetryBtn setTitle:NSLocalizedString(@"MsgNoNetworkRetry", nil)
                                  forState:UIControlStateNormal];
    }
    return erView;
}

///ログイン・新規登録モーダルを表示
- (void)noLoginAction:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification
                                                        object:self];
}

///いいね数ボタンのレイアウト
- (void)layoutGoodCntBtnOnImg:(HomeCollectionViewCell *)cell {
    
    cell.goodCntBtnOnImg.frame = CGRectZero;
    cell.goodCntBtnOnImg.userInteractionEnabled = NO;
    cell.goodCntBtnOnImg.titleLabel.adjustsFontSizeToFitWidth = YES;
    cell.goodCntBtnOnImg.titleLabel.font =  JPBFONT(13);
    [cell.goodCntBtnOnImg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cell.goodCntBtnOnImg.layer setShadowOpacity:0.4f];
    [cell.goodCntBtnOnImg.layer setShadowOffset:CGSizeMake(1, 1)];
    
    
    UIView *superView = [cell.goodCntBtnOnImg superview];
    [superView addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:cell.PostGoodBtnOnImage
                                                        attribute:NSLayoutAttributeTrailingMargin
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:cell.goodCntBtnOnImg
                                                        attribute:NSLayoutAttributeLeadingMargin
                                                       multiplier:1
                                                         constant:-15],
                           [NSLayoutConstraint constraintWithItem:cell.PostGoodBtnOnImage
                                                        attribute:NSLayoutAttributeCenterYWithinMargins
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:cell.goodCntBtnOnImg
                                                        attribute:NSLayoutAttributeCenterYWithinMargins
                                                       multiplier:1
                                                         constant:0],
                           ]];
    [cell.goodCntBtnOnImg setTranslatesAutoresizingMaskIntoConstraints:NO];
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
                
                // 投稿一覧
                [self refreshPosts:NO sortedFlg:NO];
                
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
