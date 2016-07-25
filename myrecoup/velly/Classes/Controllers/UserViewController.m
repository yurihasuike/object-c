//
//  UserViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/12.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "UserViewController.h"
#import "UserCollectionViewLayout.h"
#import "ProfileHeaderCollectionReusableView.h"
#import "UserCollectionViewCell.h"
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
#import "MessagingTableViewController.h"
#import "Defines.h"

static NSString* const UserCellIdentifier = @"UserCell";
static NSString* const UserNoCellIdentifier = @"UserNoCell";
static NSString* const UserHeaderIdentifier = @"UserHeader";
static NSString* const UserFooterIdentifier = @"UserFooter";

extern NSString * const FormatUserSortType_toString[];
NSString * const FormatUserSortType_toString[] = {
    [VLHOMESORTNEW]    = @"r",      // 新着
    [VLHOMESORTPOP]    = @"p",      // 人気
    [VLHOMELIKE]       = @"l"       // いいね
};
// ex) NSString *str = FormatUserSortType_toString[theEnumValue];

@interface UserViewController () <UserCollectionViewDelegate, UICollectionViewDelegate, NetworkErrorViewDelete, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet ProfileHeaderCollectionReusableView *headerView;
//@property (strong, nonatomic) ProfileHeaderCollectionReusableView *headerView;

//@property (weak, nonatomic) UserManager *userManager;
@property (nonatomic) PostManager *postManager;

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *posts;

@property BOOL noPostFlg;

@property (nonatomic, strong) NSMutableArray *cellHeights;

@property (nonatomic) NSUInteger *postPage;

@property (nonatomic) BOOL isSendLike;
@property (nonatomic) BOOL isTapAction;

@property (nonatomic) CGFloat headerHeight;
@property (nonatomic) UserCollectionViewCell *userCellHeight;

@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation UserViewController

@synthesize userPID, userID;
//@synthesize userManager = _userManager;

- (id) initWithUserPID:(NSNumber *)t_userPID userID:(NSString *)t_userID {
    
    if(!self) {
        self = [[UserViewController alloc] init];
    }
    self.userPID = t_userPID;
    self.userID = t_userID;
    if([self.postManager isKindOfClass:[NSNull class]]){
        self.postManager = [PostManager new];
    }
    //[self loadUser:self];
    
    return self;
}

- (void) preloadingPosts {
    self.isLoading = YES;
    // ----------------
    // 投稿一覧
    // ----------------
    [self refreshPosts:YES sortedFlg:YES];
    
    double delayInSeconds = 0.8;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //done 0.6 seconds after.
        [self loadUser:self];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _userCellHeight = [[UserCollectionViewCell alloc]initWithFrame:CGRectZero];
    self.cv.delegate = self;
    
    // ナビゲーションタイトル
    self.navigationItem.titleView.alpha = 0;
    [self.navigationItem setTitleView:[CommonUtil getNaviTitle:NSLocalizedString(@"NavTabProfile", nil)]];
    self.navigationItem.titleView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:1.2f animations:^{
        self.navigationItem.titleView.alpha = 0;
        self.navigationItem.titleView.alpha = 1;
    }];
    
    self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationItem.backBarButtonItem.title = @"";
    //[UINavigationBar appearance].barTintColor = [UIColor clearColor];
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    // 半透明なくす
    self.navigationController.navigationBar.translucent = NO ;
    [self.navigationItem setBackBarButtonItem:[CommonUtil getBackNaviBtn]];

    self.isLoading = NO;

    // 設定ボタン
    if(self.isMmine){
        // 自分の場合のみ
        
        UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        [settingBtn setAdjustsImageWhenHighlighted: NO];
        [settingBtn setBackgroundImage:[UIImage imageNamed:@"btn_setting.png"]
                              forState:UIControlStateNormal];
        //[settingBtn addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
        //[settingBtn addTarget:self action:@selector(profileEditAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *settingButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
        self.navigationItem.rightBarButtonItem = settingButtonItem;
    }
    
    // 紹介文
    CGRect rect = _descripLabel.frame;
    [_descripLabel sizeToFit];
    rect.size.height = CGRectGetHeight(_descripLabel.frame);
    _descripLabel.frame = rect;
    
    CGFloat cellWidth = (self.view.frame.size.width / 2) - 7.0f;
    
    UserCollectionViewLayout *cvLayout = [[UserCollectionViewLayout alloc] init];
    cvLayout.delegate     = self;
    cvLayout.itemWidth    = cellWidth;  // 140.0f;
    cvLayout.topInset     = 10.0f;
    cvLayout.bottomInset  = 10.0f;
    cvLayout.stickyHeader = NO;
    cvLayout.footerReferenceSize = CGSizeMake(100, 230);
    
    self.sortType = VLHOMESORTNEW;
    
    //    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    //    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    
    [self.cv setCollectionViewLayout:cvLayout];
    //[self.cv reloadData];
    
    self.canLoadMore = NO;
    self.isSendLike = NO;
    self.isTapAction = NO;

    self.headerView.followBtn.hidden = YES;
    
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setColor:[UIColor darkGrayColor]];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator stopAnimating];
    
//    [self loadUser:self];
//    // ----------------
//    // 投稿一覧
//    // ----------------
//    [self refreshPosts:YES sortedFlg:YES];
    
    //[self loadUser:self];
//    double delayInSeconds = 0.6;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self loadUser:self];
//    });
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"User"];
    
    // network check
    if(![[UserManager sharedManager]checkNetworkStatus]){
        // error network
        NetworkErrorView *networkErrorView = [[NetworkErrorView alloc]init];
        networkErrorView.delegate = self;
        [networkErrorView showInView:self.view];
    }
    
    
    self.headerView.followBtn.hidden = YES;
    
    // ----------------
    // ユーザ情報取得
    // ----------------
    // 自分 or 他人のアカウント情報取得
//    if(!_user || [_user isKindOfClass:[NSNull class]]){
//        if(!_userManager) {
//            _userManager = [UserManager sharedManager];
//        }
//        [self loadUser:self];
//    }
    
    NSNumber *myUserPID = [Configuration loadUserPid];
    if([myUserPID isKindOfClass:[NSNull class]] || ![myUserPID isEqualToNumber:self.userPID]){
        // other
        self.headerView.followBtn.hidden = NO;
        self.headerView.followBtn.alpha = 1.0f;
    }else{
        // me
        self.headerView.followBtn.hidden = YES;
        self.headerView.followBtn.alpha = 0.0f;
    }
    if([self.isFollow isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
        // followed
        self.isFollow = [NSNumber numberWithInt:VLPOSTLIKEYES];
        [self.headerView.followBtn setTitle:NSLocalizedString(@"UserFollowed", nil) forState:UIControlStateNormal];
        
    }else{
        // no follow
        self.isFollow = [NSNumber numberWithInt:VLPOSTLIKENO];
        [self.headerView.followBtn setTitle:NSLocalizedString(@"UserFollow", nil) forState:UIControlStateNormal];
    }

    //[self loadUser:self];
    if(!self.isLoading){
        self.isLoading = YES;
        // ----------------
        // 投稿一覧
        // ----------------
        [self refreshPosts:YES sortedFlg:YES];
    
        //[self loadUser:self];
    
        double delayInSeconds = 0.8;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //done 0.6 seconds after.
            [self loadUser:self];
        });
    }else{
        // check follow
        if(self.srvLoadingDate){
            BOOL isSrvFollow = VLPOSTLIKENO;
            if([self.isFollow isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
                isSrvFollow = VLPOSTLIKEYES;
            }
            NSNumber *myUserPID = [Configuration loadUserPid];
            if(self.userPID){
                NSNumber *srvFollow = [[UserManager sharedManager] getIsMyFollow:myUserPID userPID:self.userPID isSrvFollow:isSrvFollow loadingDate:self.srvLoadingDate];
                if([srvFollow isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
                    // followed
                    self.isFollow = [NSNumber numberWithInt:VLPOSTLIKEYES];
                    [self.headerView.followBtn setTitle:NSLocalizedString(@"UserFollowed", nil) forState:UIControlStateNormal];
                }else{
                    // no follow
                    self.isFollow = [NSNumber numberWithInt:VLPOSTLIKENO];
                    [self.headerView.followBtn setTitle:NSLocalizedString(@"UserFollow", nil) forState:UIControlStateNormal];
                }
            }
        }
    }
    //メッセージ用にアイコンセット
    [self setUserIcon];
    
    //自分の茶とトークンとIDセット
    if (myUserPID)[self saveMyIDAndChatToken:myUserPID];
    
    //メッセージ送信ボタン表示の可否
    [self controlMsgBtn];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [[self.cv collectionViewLayout] invalidateLayout];
}

-(void)viewDidLayoutSubviews {
    //[self.scrollView setContentSize: self.contentView.bounds.size];
    //self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1068);
    //self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.cv.frame.size.height + 300);
    //[self.scrollView flashScrollIndicators];
}

//- (void)dealloc
//{
//    //[self closeDb];
//    //delete obj;
//    //[super dealloc];
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (!self.view.window) {
        self.view = nil;
    }
}

// ステータスバー設定
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/*
 #pragma mark - Navigation
 */

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    //return 30;
    
//    if([self.postManager.posts count] == 0){
//        self.noPostFlg = YES;
//        return 1;
//    }else{
//        self.noPostFlg = NO;
//    }
//    return [self.postManager.posts count];
    
    DLog(@"%lu", (unsigned long)[self.postManager.posts count]);
    
    if([self.postManager.posts count] == 0){
        self.noPostFlg = YES;
        return 1;
    }else{
        self.noPostFlg = NO;
    }
    return [self.postManager.posts count];
    
    //return [self.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if(self.noPostFlg){
        
        ProfileNoCollectionViewCell *waterfallCell = [collectionView dequeueReusableCellWithReuseIdentifier:UserNoCellIdentifier
                                                                                               forIndexPath:indexPath];
        return waterfallCell;
        
    }else{
        
        UserCollectionViewCell *waterfallCell = [[collectionView dequeueReusableCellWithReuseIdentifier:UserCellIdentifier forIndexPath:indexPath] initWithSubViews];
        
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
        
        // 投稿写真タップ時
        //    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImgTap:)];
        //    waterfallCell.postImageView.userInteractionEnabled = YES;
        //    [waterfallCell.postImageView addGestureRecognizer:tapGestureRecognizer];
        
        //いいね数レイアウト
        [self layoutGoodCntBtnOnImg:waterfallCell];
        
        //コメントボタンでの遷移
        waterfallCell.postCommentBtn.tag = (NSInteger)1838;
        [waterfallCell.postCommentBtn addTarget:self action:@selector(postImgComment:event:) forControlEvents:UIControlEventTouchUpInside];
        
        //小さいハート
        UITapGestureRecognizer *smallHeartTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postGoodAction:)];
        smallHeartTapGestureRecognizer.numberOfTapsRequired = 1;
        [waterfallCell.postGoodBtn addGestureRecognizer:smallHeartTapGestureRecognizer];
        waterfallCell.postGoodBtn.tag = SMALLHEART;
        
        //画像上の大きいハート
        UITapGestureRecognizer *bigHeartTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postGoodAction:)];
        bigHeartTapGestureRecognizer.numberOfTapsRequired = 1;
        [waterfallCell.PostGoodBtnOnImage addGestureRecognizer:bigHeartTapGestureRecognizer];
        waterfallCell.PostGoodBtnOnImage.tag = BIGHEART;
        
        //投稿写真ダブルタップ
        UITapGestureRecognizer *imgDoubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postGoodAction:)];
        imgDoubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [waterfallCell.postImageBtn addGestureRecognizer:imgDoubleTapGestureRecognizer];
        waterfallCell.postImageBtn.tag = IMGDOUBLETAP;
        
        // 投稿写真ボタンタップ時
        UITapGestureRecognizer *imgSingleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImgAction:)];
        imgSingleTapGestureRecognizer.numberOfTapsRequired = 1;
        [waterfallCell.postImageBtn addGestureRecognizer:imgSingleTapGestureRecognizer];
        
        [imgSingleTapGestureRecognizer requireGestureRecognizerToFail:imgDoubleTapGestureRecognizer];
        
        
        if(self.postManager.posts && [self.postManager.posts count] > 0){
            
            NSUInteger indexRow = (NSUInteger)indexPath.row;
            
            // DLog(@"%lu", (unsigned long)indexRow);
            // DLog(@"cnt : %lu", [self.postManager.posts count]);
            if(self.canLoadMore){
                DLog(@"have a next");
            }
            
            //if( indexRow + 1 == [self.postManager.posts count] && self.canLoadMore && !_indicator.isAnimating){
            if( indexRow + 1 >= [self.postManager.posts count] && self.canLoadMore){    //  !_indicator.isAnimating
                
                [LoadingView showInView:self.view];
                self.cv.scrollEnabled = NO;
                // scroll position fix
                [self.cv setContentOffset:self.cv.contentOffset animated:NO];
                //[self startIndicator];
                NSString *aToken = [Configuration loadAccessToken];
                NSString *sortVal = FormatUserSortType_toString[self.sortType];
                
                if(self.postManager == nil){
                    self.postManager = [PostManager new];
                }
                
                NSDictionary *params;
                // param : access_token / user / categories (id int複数可) / page / order_by ( r or p ) 投稿順 / 人気順
                //        if(!self.userPID){
                //            self.userPID = [Configuration loadUserPid];
                //        }
                if(self.sortType == VLHOMELIKE){
                    params = @{ @"page" : @(self.postManager.postPage), @"liked_by_user" : self.userPID, @"order_by" : @"r", };
                }else if([self.userPID isEqual: [NSNull null]]){
                    params = @{ @"page" : @(self.postManager.postPage), @"order_by" : sortVal, };
                }else{
                    params = @{ @"page" : @(self.postManager.postPage), @"user" : self.userPID, @"order_by" : sortVal, };
                }
                
                __weak typeof(self) weakSelf = self;
                [self.postManager loadMorePostsWithParams:params aToken:aToken block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    
                    if (error) {
                        DLog(@"error = %@", error);
                        [LoadingView dismiss];
                        self.cv.scrollEnabled = YES;
                        
                        UIAlertView *alert = [[UIAlertView alloc]init];
                        alert = [[UIAlertView alloc]
                                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                        [alert show];
                        
                    }else{
                        strongSelf.postPage = postPage;
                        strongSelf.canLoadMore = strongSelf.postManager.canLoadPostMore;
                        
                        double delayInSeconds = 0.3;    // 0.5
                        dispatch_time_t moreTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(moreTime, dispatch_get_main_queue(), ^(void){
                            [strongSelf.cv reloadData];
                            //[strongSelf.cv layoutIfNeeded];
                            [LoadingView dismiss];
                            self.cv.scrollEnabled = YES;
                        });
                    }
                    //[self endIndicator];
                    
                }];

                
            }
        }
        
        
        
        
        
        return waterfallCell;
        
    }
}


- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UserCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    Post *jPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
//    return [_userCellHeight userCellHeight:jPost];
    
    DLog(@"heightForItem count : %lu", (unsigned long)[self.postManager.posts count]);
    if(self.postManager.posts != nil && [self.postManager.posts count] > 0){
        Post *jPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
        return [_userCellHeight userCellHeight:jPost];
    }else{
        return 1;
    }
    
}


- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UserCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    
    DLog(@"section header height : %ld", (long)indexPath.section);

    if(self.headerHeight){
        DLog(@"header height : %f", self.headerHeight);
        return self.headerHeight;
    }else{
        //return (indexPath.section + 1) * 126.0f;
        return (indexPath.section + 1) * 280.0f;
    }
}


//- (NSMutableArray *)cellHeights {
//    if (!_cellHeights) {
//        _cellHeights = [NSMutableArray arrayWithCapacity:900];
//        for (NSInteger i = 0; i < 900; i++) {
//            //_cellHeights[i] = @(arc4random()%100*2+100);
//            _cellHeights[i] = @"320";
//        }
//    }
//    return _cellHeights;
//}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {

    ProfileHeaderCollectionReusableView *titleView = nil;
    if( kind == UICollectionElementKindSectionHeader ){
        titleView =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                           withReuseIdentifier:UserHeaderIdentifier
                                                  forIndexPath:indexPath];
        // フォロー一覧
        // followCntBtn
        [titleView.followCntBtn addTarget:self action:@selector(followCntAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // フォロワー一覧
        // followerCntBtn
        [titleView.followerCntBtn addTarget:self action:@selector(followerCntAction:) forControlEvents:UIControlEventTouchUpInside];
        
//        // プロフィール編集
//        [titleView.profileEditBtn.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
//        [titleView.profileEditBtn.layer setBorderWidth:1.0];
//        [titleView.profileEditBtn.layer setCornerRadius:3.0];
//        [titleView.profileEditBtn.layer setShadowOpacity:0.1f];
//        [titleView.profileEditBtn.layer setShadowOffset:CGSizeMake(1, 1)];
//        [titleView.profileEditBtn addTarget:self action:@selector(profileEditAction:) forControlEvents:UIControlEventTouchUpInside];

        // フォローアクション
        // followBtn
        [titleView.followBtn.layer setBorderColor:[HEADER_UNDER_BG_COLOR CGColor]];
        [titleView.followBtn.layer setBorderWidth:1.0];
        [titleView.followBtn.layer setCornerRadius:3.0];
        //[titleView.followBtn.layer setShadowOpacity:0.1f];
        //[titleView.followBtn.layer setShadowOffset:CGSizeMake(1, 1)];
        [titleView.followBtn addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
        titleView.followBtn.hidden = YES;
        
        //self.sortType = VLHOMESORTNEW;
        // 並び替え : 投稿数
        //[titleView.sortPostCntBtn addTarget:self action:@selector(sortPostCntAction:) forControlEvents:UIControlEventTouchUpInside];
        [titleView.sortPostCntIP6Btn addTarget:self action:@selector(sortPostCntAction:) forControlEvents:UIControlEventTouchUpInside];
        // 並び替え : 人気順
        //[titleView.sortPopBtn addTarget:self action:@selector(sortPopAction:) forControlEvents:UIControlEventTouchUpInside];
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
        
        //メッセージボタン
        [self layoutNewMessageBtn];
        
        //「プロ」ボタン
        [self layoutProBtn];
        
        
        return titleView;
    }

    return nil;
}

#pragma mark request

// マイアカウント or 他人アカウント 情報取得
- (void)loadUser:(id)sender
{
    DLog(@"UserView loadUser");
    
    // init
    self.headerView.userNameLabel.text = @"";
    self.headerView.userIdLabel.text = @"";
    self.headerView.descripLabel.text = @"";
    self.headerView.userImageView.image = nil;
    
    NSNumber *targetUserPID;
    if(![self.userPID isEqual: [NSNull null]]){
        targetUserPID = self.userPID;
    }

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
            [strongSelf.cv reloadData];
            
        }else{
            DLog(@"%@", error);

            // have a 404 ?
            if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_FOUND]){
                //
                
            }
            
            // エラー
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
    }];
}


-(void)setUser:(User *)srvUser
{
    User *load_user = srvUser;
    NSDictionary * vConfig = [ConfigLoader mixIn];
    if(load_user && [load_user isKindOfClass:[User class]]){
        
        // ユーザ情報取得 : OK
        // 表示設定
        self.userPID                          = load_user.userPID;
        self.userID                           = load_user.userID;
        self.userChatToken                    = load_user.chat_token;
        self.userIconPath                     = (load_user.iconPath)?load_user.iconPath:vConfig[@"UserNoImageIconPath"];
        
        self.headerView.userNameLabel.text    = load_user.username;
        self.headerView.userIdLabel.text      = load_user.dispUserID;
        if(load_user.cntFollow){
            self.headerView.followCntLabel.text   = [load_user.cntFollow stringValue];
            self.cntFollow = load_user.cntFollow;
        }else{
            self.headerView.followCntLabel.text   = @"0";
            self.cntFollow = [NSNumber numberWithInt:0];
        }
        if(load_user.cntFollower){
            self.headerView.followerCntLabel.text = [load_user.cntFollower stringValue];
            self.cntFollower = load_user.cntFollower;
        }else{
            self.headerView.followerCntLabel.text = @"@";
            self.cntFollower = [NSNumber numberWithInt:0];
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
                //paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                
                [mutableLinkAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
            } else {
                [mutableLinkAttributes setObject:(__bridge id)[USER_DISPLAY_NAME_COLOR CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
//                CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
//                CTParagraphStyleSetting paragraphStyles[1] = {
//                    {.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void *)&lineBreakMode}
//                };
//                CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyles, 1);
//                
//                [mutableLinkAttributes setObject:(__bridge id)paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
            }
            self.headerView.descripLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
            self.headerView.descripLabel.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
            //self.headerView.descripLabel.activeLinkAttributes = @{ NSFontAttributeName:JPFONT(12), NSForegroundColorAttributeName:[UIColor darkGrayColor] };
            
            self.headerView.descripLabel.text     = [CommonUtil uiLabelNoBreakHeight:12.0f label:load_user.introduction];
            //self.headerView.descripLabel.attributedText = [CommonUtil uiLabelNoBreakHeight:12.0f label:load_user.introduction];
            
            self.headerView.descripLabel.frame = CGRectMake(9, self.headerView.descripLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width - 18, self.headerView.descripLabel.frame.size.height);
            [self.headerView.descripLabel sizeToFit];
        
        // header size check
//        CGSize postTitleSize = [self.headerView.descripLabel.attributedText
//                                sizeWithFont:JPFONT(12)
//                                constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 18, 5000)
//                                lineBreakMode:self.headerView.descripLabel.lineBreakMode];
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
        self.headerHeight = 10 + 8 + 80 + 8 + 21 + 20 + 9 + resizeHeaderHeight + 4 + 60;
        [self.headerView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.headerHeight)];
        
        DLog(@"header height : %f", self.headerHeight);
        
        
        // 自分判定
        NSNumber *myUserPID = [Configuration loadUserPid];
        if([myUserPID isKindOfClass:[NSNull class]] || ![myUserPID isEqualToNumber:self.userPID]){
            // other
            self.headerView.followBtn.hidden = NO;
            self.headerView.followBtn.alpha = 1.0f;
        }else{
            // me
            self.headerView.followBtn.hidden = YES;
            self.headerView.followBtn.alpha = 0.0f;
        }
        if([load_user.isFollow isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
            // followed
            self.isFollow = [NSNumber numberWithInt:VLPOSTLIKEYES];
            [self.headerView.followBtn setTitle:NSLocalizedString(@"UserFollowed", nil) forState:UIControlStateNormal];
            
        }else{
            // no follow
            self.isFollow = [NSNumber numberWithInt:VLPOSTLIKENO];
            [self.headerView.followBtn setTitle:NSLocalizedString(@"UserFollow", nil) forState:UIControlStateNormal];
        }
        self.srvLoadingDate = [NSDate date];
        
        // icon
        CommonUtil *commonUtil = [[CommonUtil alloc] init];
//        CGSize cgSize = CGSizeMake(80.0f, 80.0f);
//        CGSize radiusSize = CGSizeMake(39.0f, 39.0f);
        CGSize cgSize = CGSizeMake(240.0f, 240.0f);
        CGSize radiusSize = CGSizeMake(117.0f, 117.0f);
            
        if(load_user.iconPath && ![load_user.iconPath isKindOfClass:[NSNull class]]){
                [self.headerView.userImageView sd_setImageWithURL:[NSURL URLWithString:load_user.iconPath]
                                                 placeholderImage:nil
                                                          options: SDWebImageCacheMemoryOnly
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                            image = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
                                                            self.headerView.userImageView.image = image;
                                                            
                                                            if(cacheType == SDImageCacheTypeMemory){
                                                                self.headerView.userImageView.alpha = 1;
                                                            }else{
                                                                [UIView animateWithDuration:0.4f animations:^{
                                                                    self.headerView.userImageView.alpha = 0;
                                                                    self.headerView.userImageView.alpha = 1;
                                                                }];
                                                            }
                                                        }];
        }else{
            UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"ico_nouser.png"] size:cgSize radiusSize:radiusSize];
            self.headerView.userImageView.image = image;
            self.headerView.userImageView.alpha = 1;
//            [UIView animateWithDuration:0.8f animations:^{
//                self.headerView.userImageView.alpha = 0;
//                self.headerView.userImageView.alpha = 1;
//            }];
        }

        // cnt posts -> refreshPost
//        NSString *postCntStr = NSLocalizedString(@"PostUnit", nil);
//        NSString *postCntStrReplace = postCntStr;
//        if([load_user.cntPost isKindOfClass:[NSNumber class]]){
//            self.cntPost = load_user.cntPost;
//            postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:[load_user.cntPost stringValue]];
//            self.headerView.sortPostCntBtn.titleLabel.text   = postCntStrReplace;
//            [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
//            [self.headerView.sortPostCntBtn sizeToFit];
//            
//        }else{
//            self.cntPost = [NSNumber numberWithInt:0];
//            postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:@"0"];
//            self.headerView.sortPostCntBtn.titleLabel.text   = postCntStrReplace;
//            [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
//            [self.headerView.sortPostCntBtn sizeToFit];
//        }
        
        
        DLog(@"screen width : %f", [[UIScreen mainScreen]bounds].size.width);
        //CGFloat screenW = [[UIScreen mainScreen]bounds].size.width;
        //CGFloat sortW   = screenW / 2 - 20.0f;
        //CGFloat sortPopX = sortW + 10.0f;
        //DLog(@"sortW width : %f", sortW);
        
        //CGRect postCntBtnFrame = self.headerView.sortPostCntIP6Btn.frame;
        //postCntBtnFrame.size.width = sortW;
        //[self.headerView.sortPostCntIP6Btn setFrame:postCntBtnFrame];
        
        //CGRect popBtnFrame     = self.headerView.sortPopIP6Btn.frame;
        //popBtnFrame.size.width = sortW;
        //popBtnFrame.origin.x   = sortPopX;
        //[self.headerView.sortPopIP6Btn setFrame:popBtnFrame];
        
        self.headerView.sortPostCntBtn.hidden = YES;
        self.headerView.sortPopBtn.hidden     = YES;
        //self.headerView.sortPostCntIP6Btn.hidden = YES;
        //self.headerView.sortPopIP6Btn.hidden     = YES;
        
        
    }
//    [self.cv setNeedsLayout];
//    [self.cv setNeedsDisplay];
    
    //load_user = nil;
}


- (void)refreshPosts:(BOOL)refreshFlg sortedFlg:(BOOL)sortedFlg
{
    //[self.refreshControl beginRefreshing];
    
    if(sortedFlg){
        self.postManager = [PostManager new];
        [self.cv reloadData];
    }
    NSString *sortVal = FormatUserSortType_toString[self.sortType];

    if(self.postManager == nil){
        self.postManager = [PostManager new];
    }
    if(refreshFlg){
        //[self.refreshControl beginRefreshing];
    }
    
    NSDictionary *params;
    // param : access_token / user / categories (id int複数可) / page / order_by ( r or p ) 投稿順 / 人気順
    
    if(self.sortType == VLHOMELIKE){
        params = @{ @"page" : @(1), @"liked_by_user" : self.userPID, @"order_by" : @"r",};
    }else if([self.userPID isEqual: [NSNull null]]){
        params = @{ @"page" : @(1), @"order_by" : sortVal, };
    }else{
        params = @{ @"page" : @(1), @"user" : self.userPID, @"order_by" : sortVal, };
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
        if(refreshFlg){
            // 更新終了
            //[self.refreshControl endRefreshing];
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
            //[strongSelf.cv reloadData];
            strongSelf.canLoadMore = strongSelf.postManager.canLoadPostMore;

            // cnt posts
            NSString *postCntStr = NSLocalizedString(@"PostUnit", nil);
            NSString *postCntStrReplace = postCntStr;
            if(self.sortType == VLHOMELIKE){
                //いいね投稿の場合投稿数は変更しない
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
                self.cntPost = [NSNumber numberWithInt:VLPOSTLIKENO];
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




#pragma mark - UIScrollViewDelegate

/* Scroll View のスクロール状態に合わせて */
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    
//    if([_indicator isAnimating]) {
//        return;
//    }
//    
//    if(self.postManager == nil){
//        self.postManager = [PostManager new];
//    }
//    
//    return;
//    
//    // offset は表示領域の上端なので, 下端にするため `tableView` の高さを付け足す. このとき 1.0 引くことであとで必ずセルのある座標になるようにしている.
//    CGPoint offset = *targetContentOffset;
//    offset.y += self.cv.bounds.size.height - 1.0;
//    // offset 位置のセルの `NSIndexPath`.
//    //NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:offset];
//    //if(indexPath.row >= self.rankingManager.populars.count - 1 && self.rankingManager.canLoadPopularMore){
//    if(self.cv.contentOffset.y >= (self.cv.contentSize.height - self.cv.bounds.size.height) &&
//       self.canLoadMore){
//        
//        NSString *aToken = [Configuration loadAccessToken];
//        NSString *sortVal = FormatUserSortType_toString[self.sortType];
//        
//        if(self.postManager == nil){
//            self.postManager = [PostManager new];
//        }
//        
//        NSDictionary *params;
//        // param : access_token / user / categories (id int複数可) / page / order_by ( r or p ) 投稿順 / 人気順
////        if(!self.userPID){
////            self.userPID = [Configuration loadUserPid];
////        }
//        if([self.userPID isEqual: [NSNull null]]){
//            params = @{ @"page" : @(self.postManager.postPage), @"order_by" : sortVal, };
//        }else{
//            params = @{ @"page" : @(self.postManager.postPage), @"user" : self.userPID, @"order_by" : sortVal, };
//        }
//        
//        __weak typeof(self) weakSelf = self;
//        [self.postManager loadMorePostsWithParams:params aToken:aToken block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            
//            if (error) {
//                DLog(@"error = %@", error);
//                
////                UIAlertView *alert = [[UIAlertView alloc]init];
////                alert = [[UIAlertView alloc]
////                            initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
////                [alert show];
//                
//            }else{
//                strongSelf.postPage = postPage;
//                [strongSelf.cv reloadData];
//                strongSelf.canLoadMore = strongSelf.postManager.canLoadPostMore;
//            }
//            
//        }];
//    }
//}


- (void)startIndicator
{
    [_indicator startAnimating];
    
    _indicator.backgroundColor = [UIColor clearColor];
    CGRect indicatorFrame = _indicator.frame;
    indicatorFrame.size.height = 36.0;
    [_indicator setFrame:indicatorFrame];
}


- (void)endIndicator
{
    [_indicator stopAnimating];
}

#pragma mark button action

// フォロー一覧へ
- (void)followCntAction: (id)sender
{
    DLog(@"UserView followCntAction");
    
    FollowerListViewController *followView = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListViewController"];
    //followView.userPID = self.userPID;
    DLog(@"%@", self.userID);
    followView = [followView initWithUserPID:self.userPID userID:self.userID];
    
    [self.navigationController pushViewController:followView animated:YES];
}

// フォロワー一覧へ
- (void)followerCntAction: (id)sender
{
    DLog(@"UserView followerCntAction");
    
    FollowerListViewController *followerView = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowerListViewController"];
    //followerView.userPID = self.userPID;;
    followerView = [followerView initWithUserPID:self.userPID userID:self.userID];
    
    [self.navigationController pushViewController:followerView animated:YES];
}

//投稿への移動アクション
- (void)loadPost:(Post*)post placeHolderImage:(UIImageView*)placeHolderImageView tag:(int)tag
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
            if(tag == 1838){
                detailController.fromtag = tag;
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
- (void)postImgAction:(UIGestureRecognizer *)recognizer{
    DLog(@"UserView postImgAction");
    HomeCollectionViewCell *cell = (HomeCollectionViewCell *)[[[recognizer view] superview] superview];
    [self moveToDetailView:[self.cv indexPathForCell:cell] tag:(int)[recognizer view].tag];

}
// 投稿画像アクション -> コメント
- (void)postImgComment:(UIButton *)sender event:(UIEvent *)event {
    
    DLog(@"HomeView postImgAction");
    [self moveToDetailView:[self indexPathForControlEvent:event] tag:(int)sender.tag];
    
}
-(void)moveToDetailView:(NSIndexPath*)indexPath tag:(int)tag{
    
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

//// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.cv];
    NSIndexPath *indexPath = [self.cv indexPathForItemAtPoint:p];
    return indexPath;
}

// いいねタップアクション
- (void)postGoodAction:(UIGestureRecognizer *)recognizer {
    DLog(@"UserView postGoodAction");
    
    UserCollectionViewCell* userCollectionViewCell = (UserCollectionViewCell*)[[[recognizer view] superview] superview];
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[GOODTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW] : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[POST] : userCollectionViewCell.postID,
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
        NSString *postIdStr = [userCollectionViewCell.postID stringValue];
        
        NSNumber *isGood = userCollectionViewCell.isGood;
        
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
                    [userCollectionViewCell.postGoodCnt setImage:[UIImage imageNamed:@"ico_heart.png"] forState:UIControlStateNormal];
                    userCollectionViewCell.isGood = [NSNumber numberWithInt:VLPOSTLIKENO];
                    [userCollectionViewCell minusCntGood];

                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [self.postManager updateMyGood:myUserPID postID:userCollectionViewCell.postID isGood:VLPOSTLIKENO cntGood:userCollectionViewCell.cntGood];
                    }
                    
                    // no alert
//                    alert = [[UIAlertView alloc]
//                             initWithTitle:NSLocalizedString(@"MsgDelGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
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
                    [userCollectionViewCell.postGoodCnt setImage:[UIImage imageNamed:@"ico_heart_on.png"] forState:UIControlStateNormal];
                    userCollectionViewCell.isGood = [NSNumber numberWithInt:VLPOSTLIKEYES];
                    [userCollectionViewCell plusCntGood];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [self.postManager updateMyGood:myUserPID postID:userCollectionViewCell.postID isGood:VLPOSTLIKEYES cntGood:userCollectionViewCell.cntGood];
                    }

//                    alert = [[UIAlertView alloc]
//                             initWithTitle:NSLocalizedString(@"MsgGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//                    [alert show];

                }
                self.isSendLike = NO;
            }];
        }

    }

}


// フォローアクション
- (void)followAction: (id)sender
{
    DLog(@"UserView followAction");
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[FOLLOWTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]   : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[SENDER] : [Configuration loadUserPid],
                                      DEFINES_REPROEVENTPROPNAME[RECEIVER] : self.userPID,}];
    
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
            
            __weak typeof(self) weakSelf = self;
            [[FollowManager sharedManager] deleteFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
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
                    
                    // no follow
                    //self.headerView.followBtn.titleLabel.text = NSLocalizedString(@"UserFollow", nil);
                    [strongSelf.headerView.followBtn setTitle:NSLocalizedString(@"UserFollow", nil) forState:UIControlStateNormal];
                    strongSelf.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    strongSelf.user.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    
                    // diplay update
                    int followersCnt = [strongSelf.cntFollower intValue];
                    followersCnt = followersCnt - 1;
                    if(followersCnt < 0) followersCnt = 0;
                    strongSelf.cntFollower = [NSNumber numberWithInt:followersCnt];
                    strongSelf.headerView.followerCntLabel.text = [[NSNumber numberWithInt:followersCnt] stringValue];

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
            
            __weak typeof(self) weakSelf = self;
            [[FollowManager sharedManager] putFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
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
                    
                    // followed
                    //self.headerView.followBtn.titleLabel.text = NSLocalizedString(@"UserFollowed", nil);
                    [strongSelf.headerView.followBtn setTitle:NSLocalizedString(@"UserFollowed", nil) forState:UIControlStateNormal];
                    strongSelf.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    strongSelf.user.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    
                    // diplay update

                    int followersCnt = [strongSelf.cntFollower intValue];
                    followersCnt = followersCnt + 1;
                    strongSelf.cntFollower = [NSNumber numberWithInt:followersCnt];
                    strongSelf.headerView.followerCntLabel.text = [[NSNumber numberWithInt:followersCnt] stringValue];

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

#pragma mark Custom Method



// 投稿数順に並び替え
- (void)sortPostCntAction: (id)sender
{
    DLog(@"UserView sortProAction");
    
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
        //[self.headerView.sortPostCntIP6Btn setFrame:CGRectMake(self.headerView.sortPostCntIP6Btn.frame.origin.x, self.headerView.sortPostCntIP6Btn.frame.origin.y, self.headerView.sortPostCntIP6Btn.frame.size.width, 35)];
        [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
        
        
        // 人気順ボタン
        [self.headerView.sortPopBtn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
        [self.headerView.sortPopBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.headerView.sortPopBtn setFrame:CGRectMake(self.headerView.sortPopBtn.frame.origin.x, self.headerView.sortPopBtn.frame.origin.y, self.headerView.sortPopBtn.frame.size.width, 30)];
        
        [self.headerView.sortPopIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
        [self.headerView.sortPopIP6Btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        //[self.headerView.sortPopIP6Btn setFrame:CGRectMake(self.headerView.sortPopIP6Btn.frame.origin.x, self.headerView.sortPopIP6Btn.frame.origin.y, self.headerView.sortPopIP6Btn.frame.size.width, 30)];
        
        //いいね投稿ボタン
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
    DLog(@"UserView sortGeneralAction");
    
    NSString *postCntStr = NSLocalizedString(@"PostUnit", nil);
    NSString *postCntStrReplace = postCntStr;
    if([self.cntPost isKindOfClass:[NSNumber class]]){
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
        //[self.headerView.sortPostCntIP6Btn setFrame:CGRectMake(self.headerView.sortPostCntIP6Btn.frame.origin.x, self.headerView.sortPostCntIP6Btn.frame.origin.y, self.headerView.sortPostCntIP6Btn.frame.size.width, 30)];
        [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
        
        // 人気順ボタン
        [self.headerView.sortPopBtn setBackgroundImage:[UIImage imageNamed:@"tab_right-on.png"] forState:UIControlStateNormal];
        [self.headerView.sortPopBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.headerView.sortPopBtn setFrame:CGRectMake(self.headerView.sortPopBtn.frame.origin.x, self.headerView.sortPopBtn.frame.origin.y, self.headerView.sortPopBtn.frame.size.width, 35)];
        
        [self.headerView.sortPopIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_right-on.png"] forState:UIControlStateNormal];
        [self.headerView.sortPopIP6Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[self.headerView.sortPopIP6Btn setFrame:CGRectMake(self.headerView.sortPopIP6Btn.frame.origin.x, self.headerView.sortPopIP6Btn.frame.origin.y, self.headerView.sortPopIP6Btn.frame.size.width, 35)];
        
        //いいね投稿ボタン
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

//いいねした投稿を表示
- (void)displayLikePost: (id)sender
{
    
    
    NSString *postCntStr = NSLocalizedString(@"PostUnit", nil);
    NSString *postCntStrReplace = postCntStr;
    if([self.cntPost isKindOfClass:[NSNumber class]]){
        postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:[self.cntPost stringValue]];
    }else{
        postCntStrReplace = [postCntStr stringByReplacingOccurrencesOfString:@"<?post_cnt>" withString:@"0"];
    }
    
    // 投稿数ボタン
    [self.headerView.sortPostCntBtn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
    [self.headerView.sortPostCntBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.headerView.sortPostCntBtn setFrame:CGRectMake(self.headerView.sortPostCntBtn.frame.origin.x, self.headerView.sortPostCntBtn.frame.origin.y, self.headerView.sortPostCntBtn.frame.size.width, 30)];
    [self.headerView.sortPostCntBtn setTitle:postCntStrReplace forState:UIControlStateNormal];
    
    [self.headerView.sortPostCntIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_left-off.png"] forState:UIControlStateNormal];
    [self.headerView.sortPostCntIP6Btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    [self.headerView.sortPostCntIP6Btn setTitle:postCntStrReplace forState:UIControlStateNormal];
    
    // 人気順ボタン
    [self.headerView.sortPopBtn setBackgroundImage:[UIImage imageNamed:@"tab_right-off.png"] forState:UIControlStateNormal];
    [self.headerView.sortPopBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.headerView.sortPopBtn setFrame:CGRectMake(self.headerView.sortPopBtn.frame.origin.x, self.headerView.sortPopBtn.frame.origin.y, self.headerView.sortPopBtn.frame.size.width, 35)];
    
    [self.headerView.sortPopIP6Btn setBackgroundImage:[UIImage imageNamed:@"tab_right-off.png"] forState:UIControlStateNormal];
    [self.headerView.sortPopIP6Btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    //いいね投稿ボタン
    [self.headerView.likePostBtn setBackgroundImage:[UIImage imageNamed:@"tab_right-on.png"] forState:UIControlStateNormal];
    [self.headerView.likePostBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.sortType = VLHOMELIKE;
    [self refreshPosts:YES sortedFlg:YES];
    
}


//メッセージ画面を開く.
-(IBAction)openMessageView:(id)sender{
    
    //send bird api -> https://sendbird.gitbooks.io/sendbird-server-api/content/en/user.html
    
    //未ログイン
    if (![self isLoggedin]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification
                                                            object:self];
        return;
    }
    
    //必要変数がなければ中止.
    if (![self canOpenMsg]) {
        return;
    }
    
    //相手ユーザを作成または確認できてから遷移.
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

//メッセージ画面へ遷移.
- (void)goToMessageView{
    
    MessagingTableViewController *messageViewController = [[MessagingTableViewController alloc] init];
    
    [messageViewController setTargetUserId:self.userChatToken];
    [messageViewController setViewMode:kMessagingViewMode];
    [messageViewController initChannelTitle];
    [messageViewController setChannelUrl:SEND_BIRD_CHANNEL_URL];
    [messageViewController setUserName:[Configuration loadUserId]];
    [messageViewController setUserId:self.myUserChatToken];
    messageViewController.userImageUrl = self.myUserIconPath;
    
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

///「プロ」ボタンのレイアウト調整する
- (void)layoutProBtn {
    self.headerView.proBtn.frame = CGRectZero;
    self.headerView.proBtn.titleLabel.font =  JPBFONT(8);
    [self.headerView.proBtn.layer setBorderColor:[USER_DISPLAY_NAME_COLOR CGColor]];
    [self.headerView.proBtn.layer setBorderWidth:1.0];
    [self.headerView.proBtn.layer setCornerRadius:5.0];
    [self.headerView.proBtn.layer setShadowOpacity:0.1f];
    [self.headerView.proBtn.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.headerView.proBtn setBackgroundColor:USER_DISPLAY_NAME_COLOR];
    [self.headerView.proBtn setTitle:NSLocalizedString(@"Pro", nil)
                                forState:UIControlStateNormal];
    [self.headerView.proBtn setTitleColor:[UIColor whiteColor]
                                     forState:UIControlStateHighlighted];
    [self.headerView.proBtn setTitleColor:[UIColor whiteColor]
                                     forState:UIControlStateNormal];
    self.headerView.proBtn.tintColor = HEADER_UNDER_BG_COLOR;

    [self.headerView addConstraints:@[
                                      [NSLayoutConstraint constraintWithItem:self.headerView.proBtn
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.headerView
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1
                                                                        constant:12],
                                      [NSLayoutConstraint constraintWithItem:self.headerView.proBtn
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.headerView.userImageView
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1
                                                                        constant:8],
                                      [NSLayoutConstraint constraintWithItem:self.headerView.proBtn
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.headerView.userNameLabel
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1
                                                                        constant:0],
                                      [NSLayoutConstraint constraintWithItem:self.headerView.proBtn
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                          toItem:0
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:10],
                                      ]];
    [self.headerView.proBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
}

///「予約する」ボタンのレイアウト
- (void)layoutNewMessageBtn{
    self.headerView.n_messageBtn.titleLabel.font =  JPFONT(11);
    [self.headerView.n_messageBtn.layer setBorderColor:[HEADER_UNDER_BG_COLOR CGColor]];
    [self.headerView.n_messageBtn.layer setBorderWidth:1.0];
    [self.headerView.n_messageBtn.layer setCornerRadius:3.0];
    [self.headerView.n_messageBtn.layer setShadowOpacity:0.1f];
    [self.headerView.n_messageBtn.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.headerView.n_messageBtn setBackgroundColor:HEADER_UNDER_BG_COLOR];
    [self.headerView.n_messageBtn setTitle:NSLocalizedString(@"MakeAppointment", nil) forState:UIControlStateNormal];
    [self.headerView.n_messageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.headerView.n_messageBtn.tintColor = HEADER_UNDER_BG_COLOR;
    [self.headerView.n_messageBtn addTarget:self
                                     action:@selector(openMessageView:)
                           forControlEvents:UIControlEventTouchUpInside];
    [self.headerView
     addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView.n_messageBtn
                                                attribute:NSLayoutAttributeTrailing
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:[self.headerView.n_messageBtn superview]
                                                attribute:NSLayoutAttributeTrailing
                                               multiplier:1
                                                 constant:-10]];
    [[self.headerView.n_messageBtn superview]
     addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView.n_messageBtn
                                                attribute:NSLayoutAttributeLeading
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:[self.headerView.n_messageBtn superview]
                                                attribute:NSLayoutAttributeLeading
                                               multiplier:1
                                                 constant:100]];
    [self.headerView.n_messageBtn
     addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView.n_messageBtn
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:nil
                                                attribute:NSLayoutAttributeHeight
                                               multiplier:1
                                                 constant:30]];
    [[self.headerView.n_messageBtn superview]
     addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView.n_messageBtn
                                                attribute:NSLayoutAttributeTop
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:[self.headerView.n_messageBtn superview]
                                                attribute:NSLayoutAttributeTop
                                               multiplier:1
                                                 constant:20]];
    [self.headerView.n_messageBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
}

///メッセージボタンの表示・非表示
- (void)controlMsgBtn{
    
    [self getUserAttr:self.userPID block:^(NSString *attr) {
        
        if ([self isLoggedin]) {
            
            [self getUserAttr:nil block:^(NSString *myattr) {
                if ([myattr isEqualToString:@"g"] && ![myattr isEqual:attr]) {
                    [self showMsgBtn];
                    [self showProBtn];
                }else{
                    [self hideMsgBtn];
                    [self hideProBtn];
                }
            }];
        }else if([attr isEqualToString:@"p"]){
            [self showMsgBtn];
            [self showProBtn];
        }else{
            [self hideMsgBtn];
            [self hideProBtn];
        }
    }];
}

///自分のチャットトークンとユーザIDをセット
- (void)saveMyIDAndChatToken:(NSNumber *)myUserPID{
    
    [[UserManager sharedManager] getUserInfo:myUserPID block:^(NSNumber *result_code, User *srvUser, NSMutableDictionary *responseBody, NSError *error) {
        if (!error) {
            [Configuration saveUserId:srvUser.userID];
            self.myUserChatToken = srvUser.chat_token;
        }
    }];
}

///ユーザの一般・プロの属性を取得
- (void)getUserAttr:(NSNumber *)userPid block:(void(^)(NSString *attr))block {
    [[UserManager sharedManager] getUserInfo:userPid
        block:^(NSNumber *result_code, User *user, NSMutableDictionary *responseBody, NSError *error) {
            if (error) {
                NSLog(@"error=%@",error);
                block(nil);
            }else{
                block(user.attribute);
            }
        }];
}

///メッセージ用のアイコンをセット
- (void)setUserIcon {
    if ([self isLoggedin]) {
        [[UserManager sharedManager] getUserInfo:nil
             block:^(NSNumber *result_code, User *user, NSMutableDictionary *responseBody, NSError *error) {
                 if (!error) {
                     NSDictionary * vConfig = [ConfigLoader mixIn];
                     [self setMyUserIconPath:(user.iconPath)? user.iconPath:vConfig[@"UserNoImageIconPath"]];
                 }
             }];
    }
}

//メッセージを開けるならYES
- (BOOL)canOpenMsg {
    return (self.userChatToken         &&
            self.myUserChatToken       &&
            self.userID                &&
            [Configuration loadUserId] &&
            self.userIconPath          &&
            self.myUserIconPath);
}

///ログインしているかどうか
- (BOOL)isLoggedin {
    return ([Configuration loadAccessToken]);
}

///メッセージボタンを隠す
- (void)hideMsgBtn{
    [self.headerView.n_messageBtn setHidden:YES];
}

///メッセージボタンを出す
- (void)showMsgBtn{
    [self.headerView.n_messageBtn setHidden:NO];
}

///「プロ」ボタンを表示
- (void)showProBtn {
    [self.headerView.proBtn setHidden:NO];
}

///「プロ」ボタンを非表示
- (void)hideProBtn {
    [self.headerView.proBtn setHidden:YES];
}

///いいね数ボタンのレイアウト
- (void)layoutGoodCntBtnOnImg:(UserCollectionViewCell *)cell {
    
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
                
                [self refreshPosts:YES sortedFlg:YES];
                double delayInSeconds = 0.8;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self loadUser:self];
                });
                
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
