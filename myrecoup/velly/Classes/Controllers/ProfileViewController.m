//
//  ProfileViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "ProfileViewController.h"
#import "SettingTableViewController.h"
#import "ProfileEditViewController.h"
#import "ProfileCollectionViewLayout.h"
#import "ProfileHeaderCollectionReusableView.h"
#import "ProfileCollectionViewCell.h"
#import "ProfileNoCollectionViewCell.h"
#import "FollowListViewController.h"
#import "FollowerListViewController.h"
#import "DetailViewController.h"
#import "UserManager.h"
#import "PostManager.h"
#import "FollowManager.h"
#import "VYNotification.h"
#import "TrackingManager.h"
#import "SVProgressHUD.h"
#import "ConfigLoader.h"
#import "CommonUtil.h"
#import "UIImageView+Networking.h"
#import "UIImageView+WebCache.h"
#import "LoadingView.h"
#import "NetworkErrorView.h"
#import "Defines.h"

static NSString* const ProfileCellIdentifier = @"ProfileCell";
static NSString* const ProfileNoCellIdentifier = @"ProfileNoCell";
static NSString* const ProfileHeaderIdentifier = @"ProfileHeader";
static NSString* const ProfileFooterIdentifier = @"ProfileFooter";

extern NSString * const FormatProfileSortType_toString[];
NSString * const FormatProfileSortType_toString[] = {
    [VLHOMESORTNEW]    = @"r",      // 新着
    [VLHOMESORTPOP]    = @"p",      // 人気
    [VLHOMELIKE]       = @"l",      // いいね
};

@interface ProfileViewController () <ProfileCollectionViewDelegate, UICollectionViewDelegate, NetworkErrorViewDelete, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet ProfileHeaderCollectionReusableView *headerView;
@property (nonatomic) PostManager *postManager;
@property (strong, nonatomic) User *user;
@property BOOL noPostFlg;
@property (nonatomic, strong) NSMutableArray *cellHeights;
@property (nonatomic) NSUInteger *postPage;
@property (nonatomic) BOOL isSendLike;
@property (nonatomic) BOOL isTapAction;
@property (nonatomic) CGFloat headerHeight;
@property (nonatomic) ProfileCollectionViewCell *profileCellHeight;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation ProfileViewController

@synthesize userPID, userID;

- (id) initWithUserPID:(NSNumber *)t_userPID userID:(NSString *)t_userID {
    
    if(!self) {
        self = [[ProfileViewController alloc] init];
    }
    self.userPID = t_userPID;
    self.userID = t_userID;
    if([self.postManager isKindOfClass:[NSNull class]]){
        self.postManager = [PostManager new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _profileCellHeight = [[ProfileCollectionViewCell alloc]initWithFrame:CGRectZero];
    self.cv.delegate = self;

    //navi
    self.navigationItem.titleView = [CommonUtil getNaviTitle:NSLocalizedString(@"NavTabProfile", nil)];
    self.navigationItem.titleView.backgroundColor = [UIColor clearColor];

    self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO ;
    [self.navigationItem setBackBarButtonItem:[CommonUtil getBackNaviBtn]];
    self.navigationItem.backBarButtonItem.title = @"";
    //navi
    
    self.isLoading = NO;
    // 設定ボタン
    if(self.isMmine){
        // 自分の場合のみ
        UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        [settingBtn setAdjustsImageWhenHighlighted: NO];
        [settingBtn setBackgroundImage:[UIImage imageNamed:@"btn_setting.png"]
                             forState:UIControlStateNormal];
        [settingBtn addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *settingButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
        self.navigationItem.rightBarButtonItem = settingButtonItem;
    }
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setColor:[UIColor darkGrayColor]];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator stopAnimating];
    
    // 紹介文
    CGRect rect = _descripLabel.frame;
    [_descripLabel sizeToFit];
    rect.size.height = CGRectGetHeight(_descripLabel.frame);
    _descripLabel.frame = rect;
    
    CGFloat cellWidth = (self.view.frame.size.width / 2) - 7.0f;
    ProfileCollectionViewLayout *cvLayout = [[ProfileCollectionViewLayout alloc] init];
    cvLayout.delegate     = self;
    cvLayout.itemWidth    = cellWidth;  // 140.0f;
    cvLayout.topInset     = 10.0f;
    cvLayout.bottomInset  = 10.0f;
    cvLayout.stickyHeader = NO;
    cvLayout.footerReferenceSize = CGSizeMake(100, 230);
    self.sortType = VLHOMESORTNEW;
    [self.cv setCollectionViewLayout:cvLayout];
    self.canLoadMore = NO;
    self.isSendLike = NO;
    self.isTapAction = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"Profile"];
    
    // network check
    if(![[UserManager sharedManager]checkNetworkStatus]){
        NetworkErrorView *networkErrorView = [[NetworkErrorView alloc]init];
        networkErrorView.delegate = self;
        [networkErrorView showInView:self.view];
    }
    
    BOOL isLoadingApi = NO;
    if(self.userPID && ![self.userPID isEqualToNumber:[Configuration loadUserPid]]){
        isLoadingApi = YES;
        self.postManager = [PostManager new];
        self.userPID = [Configuration loadUserPid];
    }
    
    if(!self.isLoading || isLoadingApi){
        self.isLoading = YES;
        
        // ----------------
        // ユーザ情報取得
        // ----------------
        [self loadUser:self];
    
        // ----------------
        // 投稿一覧
        // ----------------
        [self refreshPosts:YES sortedFlg:YES];
        
    }
    //投稿後なら1.5秒待って再読みこみ.
    if (self.isAfterPost) {
        [self refreshPosts:YES sortedFlg:YES];
        self.isAfterPost = NO;
    }
}

-(void)viewDidLayoutSubviews {
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [[self.cv collectionViewLayout] invalidateLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) settingAction:(id)sender {
    // 同一ナビゲーション間での遷移の場合
    SettingTableViewController *stView = [[SettingTableViewController alloc] initWithUserPid:self.userPID];
    [self.navigationController pushViewController:stView animated:YES];
    
}
- (void) profileEditAction: (id) sender {

    ProfileEditViewController *peView = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileEditViewController"];

    if(self.user && [self.user isKindOfClass:[User class]]){
        peView.user = self.user;
    }
    peView.profileViewController = self;
    
    [self.navigationController pushViewController:peView animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if([self.postManager.posts count] == 0){
        self.noPostFlg = YES;
        return 1;
    }else{
        self.noPostFlg = NO;
    }
    return [self.postManager.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.noPostFlg){
        ProfileNoCollectionViewCell *waterfallCell = [collectionView
                                                      dequeueReusableCellWithReuseIdentifier:ProfileNoCellIdentifier forIndexPath:indexPath];
        return waterfallCell;
    }else{

        ProfileCollectionViewCell *waterfallCell = [collectionView
                                                    dequeueReusableCellWithReuseIdentifier:ProfileCellIdentifier forIndexPath:indexPath];
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
        jPost = nil;
    
        // 角丸へ
        waterfallCell.layer.cornerRadius = 5.0f;
        // はみだしを制御
        waterfallCell.clipsToBounds = true;
    
        //枠線の幅
        waterfallCell.layer.borderWidth = 0.4f;
        // 枠線の色
        waterfallCell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        // 影のかかる方向を指定する
        waterfallCell.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        // 影の透明度
        waterfallCell.layer.shadowOpacity = 0.7f;
        // 影の色
        waterfallCell.layer.shadowColor = [UIColor grayColor].CGColor;
        // ぼかしの量
        waterfallCell.layer.shadowRadius = 1.0f;

        // 投稿写真ボタンタップ時
        [waterfallCell.postImageBtn addTarget:self action:@selector(postImgAction:event:) forControlEvents:UIControlEventTouchUpInside];
        
        // like action
        [waterfallCell.postGoodBtn addTarget:self action:@selector(postGoodAction:event:) forControlEvents:UIControlEventTouchUpInside];
        // detail action
        waterfallCell.postCommentBtn.tag = (NSInteger)1838;
        [waterfallCell.postCommentBtn addTarget:self action:@selector(postImgAction:event:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if(self.postManager.posts && [self.postManager.posts count] > 0){
            NSUInteger indexRow = (NSUInteger)indexPath.row;
            if( indexRow + 1 >= [self.postManager.posts count] && self.canLoadMore && !_indicator.isAnimating){
                
                [LoadingView showInView:self.view];
                self.cv.scrollEnabled = NO;
                // scroll position fix
                [self.cv setContentOffset:self.cv.contentOffset animated:NO];
                
                NSString *aToken = [Configuration loadAccessToken];
                NSString *sortVal = FormatProfileSortType_toString[self.sortType];
                
                if(self.postManager == nil){
                    self.postManager = [PostManager new];
                }
                
                NSDictionary *params;
                // param : access_token / user / categories (id int複数可) / page / order_by ( r or p ) 投稿順 / 人気順
                if(self.sortType == VLHOMELIKE){
                    params = @{ @"page" : @(self.postManager.postPage),
                                @"liked_by_user" : self.userPID,
                                @"order_by" : @"r",};
                }else if([self.userPID isEqual: [NSNull null]]){
                    params = @{ @"page" : @(self.postManager.postPage),
                                @"order_by" : sortVal, };
                }else{
                    params = @{ @"page" : @(self.postManager.postPage),
                                @"user" : self.userPID,
                                @"order_by" : sortVal, };
                }
                __weak typeof(self) weakSelf = self;
                [self.postManager loadMorePostsWithParams:params aToken:aToken block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (error) {
                        [LoadingView dismiss];
                        self.cv.scrollEnabled = YES;
                        
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
                            [LoadingView dismiss];
                            self.cv.scrollEnabled = YES;
                        });
                    }
                }];
            }
        }
        return waterfallCell;

    }
}


- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(ProfileCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.postManager.posts != nil && [self.postManager.posts count] > 0){
        Post *jPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
        return [_profileCellHeight profileCellHeight:jPost];
    }else{
        return 0;
    }
}


- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(ProfileCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    if(self.headerHeight){
        return self.headerHeight;
    }else{
        //return (indexPath.section + 1) * 126.0f;
        return (indexPath.section + 1) * 280.0f;
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    // memo
    // kind == UICollectionElementKindSectionHeader →　ヘッダー
    // kind == UICollectionElementKindSectionFooter →　フッダー
    ProfileHeaderCollectionReusableView *titleView = nil;
    if( kind == UICollectionElementKindSectionHeader ){
        titleView =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:ProfileHeaderIdentifier
                                              forIndexPath:indexPath];
    
        // フォロー一覧
        // followCntBtn
        [titleView.followCntBtn addTarget:self action:@selector(followCntAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // フォロワー一覧
        // followerCntBtn
        [titleView.followerCntBtn addTarget:self action:@selector(followerCntAction:) forControlEvents:UIControlEventTouchUpInside];

        // プロフィール編集
        [titleView.profileEditBtn.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [titleView.profileEditBtn.layer setBorderWidth:1.0];
        [titleView.profileEditBtn.layer setCornerRadius:3.0];
        [titleView.profileEditBtn.layer setShadowOpacity:0.1f];
        [titleView.profileEditBtn.layer setShadowOffset:CGSizeMake(1, 1)];
        [titleView.profileEditBtn addTarget:self action:@selector(profileEditAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // フォローアクション
        // followBtn
        [titleView.followBtn.layer setBorderColor:[HEADER_UNDER_BG_COLOR CGColor]];
        [titleView.followBtn.layer setBorderWidth:1.0];
        [titleView.followBtn.layer setCornerRadius:3.0];
        [titleView.followBtn.layer setShadowOpacity:0.1f];
        [titleView.followBtn.layer setShadowOffset:CGSizeMake(1, 1)];
        [titleView.followBtn addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
        titleView.followBtn.hidden = YES;
        
        //self.sortType = VLHOMESORTNEW;
        // 並び替え : 投稿数
        [titleView.sortPostCntIP6Btn addTarget:self action:@selector(sortPostCntAction:) forControlEvents:UIControlEventTouchUpInside];
        // 並び替え : 人気順
        [titleView.sortPopIP6Btn addTarget:self action:@selector(sortPopAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //いいねした投稿
        [titleView.likePostBtn addTarget:self action:@selector(displayLikePost:) forControlEvents:UIControlEventTouchUpInside];
        
        // 自分 / 他人チェック
        if(self.isMmine){
            // 自分
            DLog(@"ProfileView viewDidLoad checkIsMine > mine");
            titleView.profileEditBtn.hidden = NO;
            titleView.followBtn.hidden = YES;
        }else{
            // 他人
            DLog(@"ProfileView viewDidLoad checkIsMine > other");
            titleView.profileEditBtn.hidden = YES;
            titleView.followBtn.hidden = NO;
        }
        
        self.headerView = titleView;
        return titleView;
    }
    return nil;
}


#pragma request

// マイアカウント 情報取得
- (void)loadUser:(id)sender
{
    DLog(@"ProfileView loadUser");
    
    // init
    self.headerView.userNameLabel.text = @"";
    self.headerView.userIdLabel.text = @"";
    self.headerView.descripLabel.text = @"";
    self.headerView.userImageView.image = nil;
    
    NSNumber *targetUserPID;
    targetUserPID = [Configuration loadUserPid];
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingDetailDisplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }

    __weak typeof(self) weakSelf = self;
    [[UserManager sharedManager] getUserInfo:targetUserPID block:^(NSNumber *result_code, User *srvUser, NSMutableDictionary *responseBody, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        
        if(!error){
            
            strongSelf.user = srvUser;
        
        }else{
            
            // 401  detail -> @"Invalid token."  の場合は、ログアウトし、ログイン画面へ
            // 404  detail -> @"Not found."  の場合が発生してしまう　ログイン画面へ
            // result_code = int 401
            if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_AUTH] ||
                   [result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_FOUND]){
                NSString *errorMsg = [responseBody objectForKey:@"detail"];
                NSRange searchResultAuth = [errorMsg rangeOfString:@"Invalid token"];
                NSRange searchResultNotFount = [errorMsg rangeOfString:@"Not found"];
                
                if(searchResultAuth.location != NSNotFound || searchResultNotFount.location != NSNotFound){
                    // ---------------
                    // logout
                    // ---------------
                    DLog(@"no permit token error");
                    
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
                    
                    
                    // ホームへ移動
                    HomeTabPagerViewController *homeTabPagerViewController = (HomeTabPagerViewController *)self.tabBarController.childViewControllers[0];
                    // タブを選択済みにする
                    [UIView transitionFromView:self.view
                                        toView:homeTabPagerViewController.view
                                      duration:0.1
                     //options:UIViewAnimationOptionTransitionCrossDissolve
                                       options:UIViewAnimationOptionTransitionNone
                                    completion:
                     ^(BOOL finished) {
                         self.tabBarController.selectedViewController = homeTabPagerViewController;
                         
                         // プロフィールを最初の画面に戻す
                         [self.navigationController popToRootViewControllerAnimated:NO];
                         // ログイン画面を表示
                         [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
                     }];
                }
            }else{
                // error
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
            }
        }
    }];
}

-(void)setUser:(User *)srvUser
{
    User *load_user = srvUser;
    
    // update data userId
    if(![load_user.userID isKindOfClass:[NSNull class]]){
        [Configuration saveUserId:load_user.userID];
    }

    if(load_user && [load_user isKindOfClass:[User class]]){
        // ユーザ情報取得 : OK
        // 表示設定
        self.userPID                          = load_user.userPID;
        self.userID                           = load_user.userID;
        
        self.headerView.userNameLabel.text    = load_user.username;
        self.headerView.userIdLabel.text      = load_user.dispUserID;
        if(load_user.cntFollow){
            self.headerView.followCntLabel.text   = [load_user.cntFollow stringValue];
        }else{
            self.headerView.followCntLabel.text   = @"0";
        }
        if(load_user.cntFollower){
            self.headerView.followerCntLabel.text = [load_user.cntFollower stringValue];
        }else{
            self.headerView.followerCntLabel.text = @"@";
        }
        
        CGSize postTitleSize = CGSizeZero;
        if(load_user.introduction){

            self.headerView.descripLabel.numberOfLines = 0;
            self.headerView.descripLabel.lineBreakMode = NSLineBreakByCharWrapping;
            self.headerView.descripLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            self.headerView.descripLabel.delegate = self;
            
            NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
            [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
            
            if ([NSMutableParagraphStyle class]) {
                [mutableLinkAttributes setObject:USER_DISPLAY_NAME_COLOR forKey:(NSString *)kCTForegroundColorAttributeName];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                [mutableLinkAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
            } else {
                [mutableLinkAttributes setObject:(__bridge id)[USER_DISPLAY_NAME_COLOR CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
            }
            self.headerView.descripLabel.linkAttributes = [NSDictionary
                                                           dictionaryWithDictionary:mutableLinkAttributes];
            self.headerView.descripLabel.activeLinkAttributes = [NSDictionary
                                                                 dictionaryWithDictionary:mutableLinkAttributes];
            
            self.headerView.descripLabel.text = [CommonUtil uiLabelNoBreakHeight:14.0f
                                                                           label:load_user.introduction];
            self.headerView.descripLabel.frame = CGRectMake(9, self.headerView.descripLabel.frame.origin.y, self.view.frame.size.width - 18, self.headerView.descripLabel.frame.size.height);
            [self.headerView.descripLabel sizeToFit];
            postTitleSize = self.headerView.descripLabel.frame.size;
        }
        DLog(@"postTitleSize height : %f", postTitleSize.height);
        CGFloat resizeHeaderHeight = postTitleSize.height;
        if(load_user.introduction == nil || [load_user.introduction length] == 0){
            resizeHeaderHeight = 0;
        }else if(resizeHeaderHeight < 20){
            resizeHeaderHeight = 20;
        }
        
        // 8 + 80 + 8 + 21 + 20 + 9 + 20 + 4 + 60
        // headerHeight
        self.headerHeight = 8 + 80 + 8 + 21 + 20 + 9 + resizeHeaderHeight + 4 + 60;
        [self.headerView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.headerHeight)];
        
        // icon
        CommonUtil *commonUtil = [[CommonUtil alloc] init];
        CGSize cgSize = CGSizeMake(240.0f, 240.0f);
        CGSize radiusSize = CGSizeMake(117.0f, 117.0f);
        
        self.headerView.userImageView.image = nil;
        if(load_user.iconPath && ![load_user.iconPath isKindOfClass:[NSNull class]]){
            DLog(@"%@", load_user.iconPath);
            
            dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_queue_t q_main = dispatch_get_main_queue();
            self.headerView.userImageView.image = nil;
            dispatch_async(q_global, ^{
                NSString *imageURL = load_user.iconPath;
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: imageURL]]];

                dispatch_async(q_main, ^{
                    UIImage *resizeImage = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
                    self.headerView.userImageView.image = resizeImage;
                    self.headerView.userImageView.alpha = 1;
                });
            });
        }else{
            UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"ico_nouser.png"] size:cgSize radiusSize:radiusSize];
            self.headerView.userImageView.image = image;
            self.headerView.userImageView.alpha = 1;
        }
        self.headerView.sortPostCntBtn.hidden = YES;
        self.headerView.sortPopBtn.hidden     = YES;
    }
}


- (void)refreshPosts:(BOOL)refreshFlg sortedFlg:(BOOL)sortedFlg
{
    if(sortedFlg){
        self.postManager = [PostManager new];
        [self.cv reloadData];
    }
    NSString *sortVal = FormatProfileSortType_toString[self.sortType];
    if(self.postManager == nil){
        self.postManager = [PostManager new];
    }
    NSDictionary *params;
    // param : access_token / user / categories (id int複数可) / page / order_by ( r or p ) 投稿順 / 人気順
    if(!self.userPID){
        self.userPID = [Configuration loadUserPid];
    }
    
    if(self.sortType == VLHOMELIKE){
        params = @{ @"page" : @(1),
                    @"liked_by_user" : self.userPID,
                    @"order_by" : @"r", };
    }else if([self.userPID isEqual: [NSNull null]]){
        params = @{ @"page" : @(1),
                    @"order_by" : sortVal, };
    }else{
        params = @{ @"page" : @(1),
                    @"user" : self.userPID,
                    @"order_by" : sortVal, };
    }
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    NSString *aToken = [Configuration loadAccessToken];

    __weak typeof(self) weakSelf = self;
    [self.postManager reloadPostsWithParams:params aToken:(NSString *)aToken block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        if (error) {
            DLog(@"error = %@", error);
            if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_AUTH] ||
               [resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_FOUND]){
                // 401 エラー時 : アクセストークンがあれば、削除 -> logout
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
            
            // cnt posts
            NSString *postCntStr = NSLocalizedString(@"PostUnit", nil);
            NSString *postCntStrReplace = postCntStr;
            if(self.sortType == VLHOMELIKE){
                //いいねした投稿の時は自分の投稿の数を更新しない
            }else if(strongSelf.postManager.totalPostPages){
                self.cntPost = [NSNumber numberWithInteger:strongSelf.postManager.totalPostPages];
                postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:[self.cntPost stringValue]];
                self.headerView.sortPostCntBtn.titleLabel.text   = postCntStrReplace;
                [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
                [self.headerView.sortPostCntBtn sizeToFit];
                
                self.headerView.sortPostCntIP6Btn.titleLabel.text   = postCntStrReplace;
                [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
                [self.headerView.sortPostCntIP6Btn sizeToFit];
                
            }else{
                self.cntPost = [NSNumber numberWithInt:0];
                postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:@"0"];
                self.headerView.sortPostCntBtn.titleLabel.text   = postCntStrReplace;
                [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
                [self.headerView.sortPostCntBtn sizeToFit];
                
                self.headerView.sortPostCntIP6Btn.titleLabel.text   = postCntStrReplace;
                [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
                [self.headerView.sortPostCntIP6Btn sizeToFit];
                
            }
            
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [strongSelf.cv reloadData];
            });
        }
    }];
}

- (void)startIndicator
{
    //    [_indicator startAnimating];
    //
    //    _indicator.backgroundColor = [UIColor clearColor];
    //    CGRect indicatorFrame = _indicator.frame;
    //    indicatorFrame.size.height = 36.0;
    //    [_indicator setFrame:indicatorFrame];
    
    //[self.tableView setTableFooterView:nil];
    //[self.tableView setTableFooterView:_indicator];
}


- (void)endIndicator
{
    //[_indicator stopAnimating];
    //[_indicator removeFromSuperview];
    
    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    //view.backgroundColor = [UIColor clearColor];
    //[self.tableView setTableFooterView:view];
}

#pragma mark button action

- (void)followCntAction: (id)sender
{
    DLog(@"ProfileView followCntAction");
    
    FollowerListViewController *followView = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListViewController"];
    followView.userPID = userPID;
    
    followView.profileViewController = self;
    followView.profileViewController.isLoading = NO;
    
    [self.navigationController pushViewController:followView animated:YES];
}

- (void)followerCntAction: (id)sender
{
    DLog(@"ProfileView followerCntAction");
    
    FollowerListViewController *followerView = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowerListViewController"];
    followerView.userPID = userPID;
    
    followerView.profileViewController = self;
    followerView.profileViewController.isLoading = NO;
    
    [self.navigationController pushViewController:followerView animated:YES];
}


//投稿への移動アクション
- (void)loadPost:(Post*)post placeHolderImage:(UIImageView*)placeHolderImageView sender:(UIButton*)sender
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
    __block UIImageView* blockImageView = placeHolderImageView;
    
    [[PostManager sharedManager] getPostInfo:targetPostID aToken:vellyToken block:^(NSNumber *result_code, Post *srvPost, NSMutableDictionary *responseBody, NSError *error) {
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        
        if(!error){
            
            DetailViewController *detailController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
            detailController.post = srvPost;
            detailController.postID = srvPost.postID;
            detailController.postImageTempView = blockImageView;
            if(sender.tag == 1838){
                detailController.fromtag = sender.tag;
            }
            [weakSelf.navigationController pushViewController:detailController animated:YES];
            
        }else{
            
            // エラー
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
        }
        
    }];
}

// 投稿画像アクション -> 投稿詳細へ
- (void)postImgAction:(UIButton *)sender event:(UIEvent *)event {
    DLog(@"ProfileView postImgAction");
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENDETAIL]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]: NSStringFromClass([self class])}];
    
    if(!self.isTapAction){
        
        self.isTapAction = YES;
        NSIndexPath *indexPath = [self indexPathForControlEvent:event];
        Post *tPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];

        ProfileCollectionViewCell *cell = (ProfileCollectionViewCell *)[self.cv cellForItemAtIndexPath: indexPath];
        [self loadPost:tPost placeHolderImage:cell.postImageView sender:sender];
        self.isTapAction = NO;
        
    }

}


//// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.cv];
    NSIndexPath *indexPath = [self.cv indexPathForItemAtPoint:p];
    return indexPath;
}

- (void)postGoodAction:(UIButton *)sender event:(UIEvent *)event {
    DLog(@"ProfileView postGoodAction");

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
        
        NSIndexPath *indexPath = [self indexPathForControlEvent:event];
        ProfileCollectionViewCell* profileCollectionViewCell = (ProfileCollectionViewCell *)[self.cv cellForItemAtIndexPath:indexPath];
        
        if(self.postManager == nil){
            self.postManager = [PostManager new];
        }
        NSString *postIdStr = [profileCollectionViewCell.postID stringValue];
        
        NSNumber *isGood = profileCollectionViewCell.isGood;
        
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
                    [profileCollectionViewCell.postGoodCnt setImage:[UIImage imageNamed:@"ico_heart.png"] forState:UIControlStateNormal];
                    profileCollectionViewCell.isGood = [NSNumber numberWithInt:VLPOSTLIKENO];
                    [profileCollectionViewCell minusCntGood];

                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [self.postManager updateMyGood:myUserPID postID:profileCollectionViewCell.postID isGood:VLPOSTLIKENO cntGood:profileCollectionViewCell.cntGood];
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
                    [profileCollectionViewCell.postGoodCnt setImage:[UIImage imageNamed:@"ico_heart_on.png"] forState:UIControlStateNormal];
                    profileCollectionViewCell.isGood = [NSNumber numberWithInt:VLPOSTLIKEYES];
                    [profileCollectionViewCell plusCntGood];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [self.postManager updateMyGood:myUserPID postID:profileCollectionViewCell.postID isGood:VLPOSTLIKEYES cntGood:profileCollectionViewCell.cntGood];
                    }
                }
                self.isSendLike = NO;
            }];
        }
    }
}
- (void)followAction: (id)sender
{
    DLog(@"ProfileView followAction");
    
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
        NSNumber *targetUserPID = self.userPID;
        DLog(@"%@", vellyToken);
        DLog(@"%@", self.isFollow);
        
        if(self.isFollow && [self.isFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
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
                    
                    // no follow
                    self.headerView.followBtn.titleLabel.text = NSLocalizedString(@"UserFollow", nil);
                    self.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    self.user.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    
                    // diplay update
                    int followersCnt = [self.user.cntFollower intValue];
                    followersCnt = followersCnt - 1;
                    self.headerView.followerCntLabel.text = [[NSNumber numberWithInt:followersCnt] stringValue];
                    self.user.cntFollower = [NSNumber numberWithInt:followersCnt];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[UserManager sharedManager] updateMyFollow:myUserPID userPID:targetUserPID isFollow:VLISBOOLFALSE];
                    }
                    
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"MsgNoFollowed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }else{
            // no follow -> follow
            
            DLog(@"%@", targetUserPID);
            
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
                    
                    // followed
                    self.headerView.followBtn.titleLabel.text = NSLocalizedString(@"UserFollowed", nil);
                    self.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    self.user.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    
                    // diplay update
                    int followersCnt = [self.user.cntFollower intValue];
                    followersCnt = followersCnt + 1;
                    self.headerView.followerCntLabel.text = [[NSNumber numberWithInt:followersCnt] stringValue];
                    self.user.cntFollower = [NSNumber numberWithInt:followersCnt];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[UserManager sharedManager] updateMyFollow:myUserPID userPID:targetUserPID isFollow:VLISBOOLTRUE];
                    }
                    
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"MsgFollowed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
    }
}
#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    
    if ([[UIApplication sharedApplication]canOpenURL:url]){
        [[UIApplication sharedApplication]openURL:url];
    }
    
}
// 投稿数順に並び替え
- (void)sortPostCntAction: (id)sender
{
    DLog(@"ProfileView sortProAction");
    
    NSString *postCntStr = NSLocalizedString(@"PostUnit", nil);
    NSString *postCntStrReplace = postCntStr;
    if([self.cntPost isKindOfClass:[NSNumber class]]){
        postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:[self.cntPost stringValue]];
    }else{
        postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:@"0"];
    }

    if(self.sortType == VLHOMESORTPOP || self.sortType == VLHOMELIKE){
        
        // 投稿数ボタン
        [self.headerView.sortPostCntBtn setBackgroundImage:[UIImage imageNamed:@"tab_left-on.png"] forState:UIControlStateNormal];
        [self.headerView.sortPostCntBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.headerView.sortPostCntBtn setFrame:CGRectMake(self.headerView.sortPostCntBtn.frame.origin.x, self.headerView.sortPostCntBtn.frame.origin.y, self.headerView.sortPostCntBtn.frame.size.width, 35)];
        [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
        
        [self.headerView.sortPostCntIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_left-on.png"] forState:UIControlStateNormal];
        [self.headerView.sortPostCntIP6Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
        

        // 人気順ボタン
         [self.headerView.sortPopBtn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
         [self.headerView.sortPopBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
         [self.headerView.sortPopBtn setFrame:CGRectMake(self.headerView.sortPopBtn.frame.origin.x, self.headerView.sortPopBtn.frame.origin.y, self.headerView.sortPopBtn.frame.size.width, 30)];
        
        [self.headerView.sortPopIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
        [self.headerView.sortPopIP6Btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        //いいねした投稿
        [self.headerView.likePostBtn setBackgroundImage:[UIImage imageNamed:@"tab_right-off.png"] forState:UIControlStateNormal];
        [self.headerView.likePostBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.sortType = VLHOMESORTNEW;
        [self refreshPosts:YES sortedFlg:YES];
    }else{
        // refresh measures
        [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
        [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
    }
}

// 人気順に並び替え
- (void)sortPopAction: (id)sender
{
    DLog(@"ProfileView sortGeneralAction");

    NSString *postCntStr = NSLocalizedString(@"PostUnit", nil);
    NSString *postCntStrReplace = postCntStr;
    if(self.cntPost){
        postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:[self.cntPost stringValue]];
    }else{
        postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:@"0"];
    }
    if(self.sortType == VLHOMESORTNEW || self.sortType == VLHOMELIKE){
        // 投稿数ボタン
        [self.headerView.sortPostCntBtn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
        [self.headerView.sortPostCntBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.headerView.sortPostCntBtn setFrame:CGRectMake(self.headerView.sortPostCntBtn.frame.origin.x, self.headerView.sortPostCntBtn.frame.origin.y, self.headerView.sortPostCntBtn.frame.size.width, 30)];
        [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
        
        [self.headerView.sortPostCntIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
        [self.headerView.sortPostCntIP6Btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
        
        // 人気順ボタン
        [self.headerView.sortPopBtn setBackgroundImage:[UIImage imageNamed:@"tab_right-on.png"] forState:UIControlStateNormal];
        [self.headerView.sortPopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.headerView.sortPopBtn setFrame:CGRectMake(self.headerView.sortPopBtn.frame.origin.x, self.headerView.sortPopBtn.frame.origin.y, self.headerView.sortPopBtn.frame.size.width, 35)];
        
        [self.headerView.sortPopIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_right-on.png"] forState:UIControlStateNormal];
        [self.headerView.sortPopIP6Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //いいねした投稿
        [self.headerView.likePostBtn setBackgroundImage:[UIImage imageNamed:@"tab_right-off.png"] forState:UIControlStateNormal];
        [self.headerView.likePostBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        self.sortType = VLHOMESORTPOP;
        [self refreshPosts:YES sortedFlg:YES];

    }else{
        // refresh measures
        [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
        [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
    }
}
//いいねした投稿
- (void)displayLikePost :(id)sender
{
    NSString *postCntStr = NSLocalizedString(@"PostUnit", nil);
    NSString *postCntStrReplace = postCntStr;
    if(self.cntPost){
        postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:[self.cntPost stringValue]];
    }else{
        postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:@"0"];
    }
    
    [self.headerView.sortPostCntBtn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
    [self.headerView.sortPostCntBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.headerView.sortPostCntBtn setFrame:CGRectMake(self.headerView.sortPostCntBtn.frame.origin.x, self.headerView.sortPostCntBtn.frame.origin.y, self.headerView.sortPostCntBtn.frame.size.width, 35)];
    [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
    
    
    [self.headerView.sortPostCntIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
    [self.headerView.sortPostCntIP6Btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
    
    
    // 人気順ボタン
    [self.headerView.sortPopBtn setBackgroundImage:[UIImage imageNamed:@"tab_right-off.png"] forState:UIControlStateNormal];
    [self.headerView.sortPopBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.headerView.sortPopBtn setFrame:CGRectMake(self.headerView.sortPopBtn.frame.origin.x, self.headerView.sortPopBtn.frame.origin.y, self.headerView.sortPopBtn.frame.size.width, 30)];
    
    [self.headerView.sortPopIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_right-off.png"] forState:UIControlStateNormal];
    [self.headerView.sortPopIP6Btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    //いいねした投稿
    [self.headerView.likePostBtn setBackgroundImage:[UIImage imageNamed:@"tab_right-on.png"] forState:UIControlStateNormal];
    [self.headerView.likePostBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.sortType = VLHOMELIKE;
    [self refreshPosts:YES sortedFlg:YES];
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
                
                [self loadUser:self];
                [self refreshPosts:YES sortedFlg:YES];
                
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