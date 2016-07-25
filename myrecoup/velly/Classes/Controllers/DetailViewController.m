//
//  DetailViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "DetailViewController.h"
#import "UserViewController.h"
#import "ProfileViewController.h"
#import "DAKeyboardControl.h"
#import "UserManager.h"
#import "PostManager.h"
#import "VYNotification.h"
#import "SVProgressHUD.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "CommonUtil.h"
#import "UIImageView+Networking.h"
#import "UIImageView+WebCache.h"
#import "CSNLINEOpener.h"
#import "NSArray+Sort.h"
#import "NetworkErrorView.h"
#import "Defines.h"
#import "DetailImageTableViewCell.h"
#import "DeailUserTableViewCell.h"
#import "DetailDescripTableViewCell.h"
#import "DetailActionTableViewCell.h"
#import "DetailCommentTableViewCell.h"
#import "STTwitter.h"
#import "UIViewController+MJPopupViewController.h"
#import "PostClient.h"
#import "PostUpdateViewController.h"
#import "DetailAdTableViewCell.h"
#import "ImobileSdkAds/ImobileSdkAds.h"
#import "MessagingTableViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>

#define IMOBILE_BANNER_PID     @"39673"
#define IMOBILE_BANNER_MID     @"243011"
#define IMOBILE_BANNER_SID     @"722104"

@interface DetailViewController () <NetworkErrorViewDelete, TTTAttributedLabelDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) STTwitterAPI *twitter;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDescripLabel;
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodCntLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UILabel *commentCntLabel;
@property (weak, nonatomic) IBOutlet UIButton *otherBtn;
@property (weak, nonatomic) IBOutlet UILabel *moreCommentLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreCommentBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) UIToolbar *commentToolBar;
@property (weak, nonatomic) UITextField *commentTextField;
@property (nonatomic, strong) DetailImageTableViewCell *detailImageCell;
@property (nonatomic, strong) DeailUserTableViewCell *detailUserCell;
@property (nonatomic, strong) DetailDescripTableViewCell *detaiDescrpCell;
@property (nonatomic, strong) DetailActionTableViewCell *detaiActionCell;
@property (nonatomic, strong) DetailCommentTableViewCell *detailCommentCell;
@property (nonatomic, strong) NSNumber *isLike;
@property (nonatomic) BOOL isSendLike;
@property (nonatomic) NSUInteger commentPage;

@end

static CGFloat kLoadingCellHeight = 72.0f;

@implementation DetailViewController

@synthesize postID;

- (id) initWithPostID:(NSNumber *)t_postID {
    
    if(!self) {
        self = [[DetailViewController alloc] init];
    }
    self.postID = t_postID;
    if(!self.commentManager){
        self.commentManager = [[CommentManager alloc] init];
    }
    
    return self;
}

- (void)loadingPostWidthPost:(NSNumber *)t_postID post:(Post *)post
{
    if(post){
        self.post = post;
    }
    [self loadingPostWidthPostID:t_postID];
}

- (void)loadingPostWidthPostID:(NSNumber *)t_postID {
    self.postID = t_postID;

    if(!self.commentManager){
        self.commentManager = [[CommentManager alloc] init];
    }
    
    // ----------------
    // 投稿情報取得
    // ----------------
    if(self.post == nil){
        [self loadPost];
    }else{
        [self.tableView reloadData];
    }

    // ----------------
    // コメント一覧
    // ----------------
    [self loadComments:NO refreshFlg:YES];
    
    self.isLoadingApi = YES;

}

- (id) initWithPost:(Post *)t_post {
    
    if(!self) {
        self = [[DetailViewController alloc] init];
    }
    self.post = t_post;
    
    return self;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.NavigationController setNavigationBarHidden:NO animated:NO];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    
    if (self.parentView) {
        self.NavigationController = self.parentView.navigationController;
        self.parentView.navigationItem.titleView.backgroundColor = [UIColor clearColor];
        self.parentView.navigationItem.backBarButtonItem = barButton;
    }else{
        self.NavigationController = self.navigationController;
        self.navigationItem.titleView.backgroundColor = [UIColor clearColor];
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    //戻るボタンのタイトルをなくすために作り直し
    [self.NavigationController.navigationItem setBackBarButtonItem:[CommonUtil getBackNaviBtn]];

    // ナビゲーションタイトル色
    self.NavigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    // ナビゲーションボタン色
    self.NavigationController.navigationBar.tintColor = [UIColor whiteColor];
    // ナビゲーション背景色
    if ([self.NavigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.NavigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    else {
        // ios6
        self.NavigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    
    self.detailImageCell = [[DetailImageTableViewCell alloc]initWithFrame:CGRectZero];
    
    // commentTableView
    // touchesBeganが遅い対処
    _tableView.delaysContentTouches = false;
    
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor whiteColor];      // COMMON_DEF_GRAY_COLOR
    
    //_tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 150);
    
    self.tableView = _tableView;
    [self.view addSubview:_tableView];
  
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setColor:[UIColor darkGrayColor]];
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator stopAnimating];
    
    
    self.isSendLike = NO;
    self.canLoadMore = NO;
    self.isLoadingToolBar = NO;
    self.detaiDescrpCell   = [self.tableView dequeueReusableCellWithIdentifier:@"DetailDescripTableViewCell"];
    self.detailCommentCell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailCommentTableViewCell"];
    
    //メッセージに必要な変数をそろえる
    [self enableMsg];
}


-(void)initializeUI{
    
    self.isLoadingToolBar = YES;
    UIToolbar *toolBar;
    if([Configuration checkModel] == VLModelNameIPhone6p){
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                              self.view.bounds.size.height - 40.0f,
                                                              self.view.bounds.size.width,
                                                              40.0f)];
    }else{
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                              self.view.bounds.size.height - 88.0f,
                                                              self.view.bounds.size.width,
                                                              88.0f)];
    }
    _commentToolBar = toolBar;
    _commentToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_commentToolBar];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f,
                                                                           6.0f,
                                                                           toolBar.bounds.size.width - 20.0f - 68.0f,
                                                                           28.0f)];
    _commentTextField = textField;
    _commentTextField.placeholder = NSLocalizedString(@"MsgDetailCommentPlaceHolder", nil);
    // キーボードの種類を設定
    _commentTextField.keyboardType = UIKeyboardTypeDefault;
    // リターンキーの種類を設定
    _commentTextField.returnKeyType = UIReturnKeyDefault;
    _commentTextField.borderStyle = UITextBorderStyleRoundedRect;
    _commentTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    // 編集中にテキスト消去ボタンを表示
    _commentTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_commentToolBar addSubview:_commentTextField];
    [_commentTextField addTarget:self action:@selector(textFieldShouldBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:NSLocalizedString(@"MsgDetailCommentSend", nil) forState:UIControlStateNormal];
    sendButton.backgroundColor = [UIColor lightGrayColor];
    sendButton.tintColor = [UIColor whiteColor];
    sendButton.layer.cornerRadius = 5.0f;
    sendButton.frame = CGRectMake(toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    [_commentToolBar addSubview:sendButton];
    
    self.view.keyboardTriggerOffset = _commentToolBar.bounds.size.height;
    
    // コメント送信
    [sendButton addTarget:self action:@selector(commentSendAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 外部タップで入力フォーカス解除
    UITapGestureRecognizer *tapCommentGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentCloseAction:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tapCommentGestureRecognizer];
    
    // -------------------
    
    // キーボード入力状況
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(commentSlideUpAction:) name:UIKeyboardWillShowNotification object:self.view.window];
    [center addObserver:self selector:@selector(commentSlideDownAction:) name:UIKeyboardWillHideNotification object:self.view.window];
    
    //いいね可否
    if([self.post.isGood isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
        self.isLike = [NSNumber numberWithInt:VLPOSTLIKEYES];
    }else{
        self.isLike = [NSNumber numberWithInt:VLPOSTLIKENO];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.NavigationController setNavigationBarHidden:NO animated:NO];
    
    if(!self.isLoadingToolBar){
        self.isLoadingToolBar = YES;
        [self initializeUI];
    }
    
    [TrackingManager sendScreenTracking:@"Post"];
    // network check
    if(![[UserManager sharedManager]checkNetworkStatus]){
        // error network
        NetworkErrorView *networkErrorView = [[NetworkErrorView alloc]init];
        networkErrorView.delegate = self;
        [networkErrorView showInView:self.view];
    }
    
    if(!self.isLoadingApi){
        self.isLoadingApi = YES;
        [self loadComments:NO refreshFlg:YES];
    }
    
    if(![self.categoryName isKindOfClass:[NSNull class]]){
        
        if (self.parentView) {
            self.parentView.navigationItem.titleView.alpha = 0;
            self.parentView.navigationItem.titleView = [CommonUtil getNaviTitle:self.post.categoryName];
            [UIView animateWithDuration:1.0f animations:^{
                self.parentView.navigationItem.titleView.alpha = 0;
                self.parentView.navigationItem.titleView.alpha = 1;
            }];
        }else{
            self.navigationItem.titleView.alpha = 0;
            self.navigationItem.titleView = [CommonUtil getNaviTitle:self.post.categoryName];
            [UIView animateWithDuration:1.0f animations:^{
                self.navigationItem.titleView.alpha = 0;
                self.navigationItem.titleView.alpha = 1;
            }];
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.fromtag == 1838){
        [CommonUtil delay:0.7f block:^{
            [self.commentTextField becomeFirstResponder];
        }];
    }
    //動画を自動で再生
    if ([PostManager sharedManager].post.isMovie) {
        [CommonUtil delay:0.5f block:^{
            [self playMovie];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // ここを表示させるとHOMEのナビゲーションバーが表示されてしまう
    [self.NavigationController setNavigationBarHidden:NO animated:NO];
    [self refleshHomePostsIfGoingToBackHome];
    //動画を止める
    [self stopMovie];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_commentToolBar removeFromSuperview];
    
    // 通知の受け取りを解除する
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    self.isLoadingToolBar = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// ステータスバー設定
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLayoutSubviews
{
    //[_stretchableTableHeaderView resizeView];
}

#pragma mark UIGestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        if(self.postID){
            return 1;
        }else{
            return 0;
        }
    }else if(section == 1){
        if(self.postID){
            return 1;
        }else{
            return 0;
        }
    }else if(section == 2){
        if(self.postID){
            return 1;
        }else{
            return 0;
        }
    }else if(section == 3){
        if(self.postID){
            return 1;
        }else{
            return 0;
        }
    }else if(section == 4){
        DLog(@"comment cnt : %lu", (unsigned long)[self.commentManager.comments count]);
        return [self.commentManager.comments count];
        
    }else{
        //imobile SDKのCell. 表示したければ1にする.
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 4 && [self.commentManager.comments count] > 0){
        return 32.0f;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 4 && [self.commentManager.comments count] > 0){
        UIView *presentView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 32.0f)];
//        UIImageView *sectionImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"present.png"]];
//        sectionImageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 32);
//        [presentView addSubview:sectionImageView];
        presentView.backgroundColor = COMMON_DEF_GRAY_COLOR;
        
        UILabel *presentLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 6.0f, 200.0f, 20.0f)];
        presentLabel.font = JPFONT(13);
        
        NSString *commentTitle = NSLocalizedString(@"MsgActionDetailComment", nil);
        NSUInteger commentCnt   = [self.commentManager.comments count];
        commentTitle = [commentTitle stringByReplacingOccurrencesOfString:@"<?postCnt>" withString:[NSString stringWithFormat:@"%lu", (unsigned long)commentCnt]];
        
        presentLabel.text = commentTitle;
        [presentLabel setTextColor:[UIColor darkGrayColor]];
        [presentView addSubview:presentLabel];
        
        return presentView;
    }
    return nil;
}

// フッターで余白を作成
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //if(section == 4 && [self.commentManager.comments count] > 0){
    if(section == 5){
        return 44.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0.0;
    DLog(@"height section : %ld", (long)indexPath.section);

    if(indexPath.section == 0) {
        Post *targetPost = [PostManager sharedManager].post;
        if(targetPost && [targetPost.postID isKindOfClass:[NSNumber class]]){
            //return 100;
            return [self.detailImageCell calcCellHeight:targetPost];
            //return 0;
        }
        return 0;
    }else if(indexPath.section == 2) {
        Post *targetPost = [PostManager sharedManager].post;
        if(targetPost && [targetPost.postID isKindOfClass:[NSNumber class]]){

            //[self.detailUserCell.contentView setNeedsLayout];
            //[self.detailUserCell.contentView layoutIfNeeded];
            return 72;
        }
        return 0;
    }else if(indexPath.section == 3) {
        Post *targetPost = [PostManager sharedManager].post;
        if(targetPost && [targetPost.postID isKindOfClass:[NSNumber class]]){

            // cellHeight
            //[self.detaiDescrpCell setNeedsLayout];
            //[self.detaiDescrpCell layoutIfNeeded];

            DLog(@"cellheight : %f", [self.detaiDescrpCell calcCellHeight:targetPost])
            
            return [self.detaiDescrpCell calcCellHeight:targetPost];
        }
        return 0;
    }else if(indexPath.section == 1) {
        Post *targetPost = [PostManager sharedManager].post;
        if(targetPost && [targetPost.postID isKindOfClass:[NSNumber class]]){

            //[self.detaiActionCell.contentView setNeedsLayout];
            //[self.detaiActionCell.contentView layoutIfNeeded];
            return 45;
        }
        return 0;
    }else if(indexPath.section == 4 && [self.commentManager.comments count] > 0){
    
        rowHeight = kLoadingCellHeight;
        
        DLog(@"indexPath.section : %ld", (long)indexPath.section);
        DLog(@"indexPath.row : %ld", (long)indexPath.row);
        
        if([self.commentManager.comments objectAtIndex:(NSUInteger)indexPath.row]){
        
            rowHeight = [self.detailCommentCell calcCellHeight:[self.commentManager.comments objectAtIndex:(NSUInteger)indexPath.row]];
            
        }
    
        DLog(@"comment height : %f", rowHeight);
    
        return rowHeight;
        
    }else if(indexPath.section == 5){
        //imobile SDKのCell.
        return 250;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DLog(@"index section : %ld", (long)indexPath.section);
    
    if(indexPath.section == 0){
        // post image
        self.detailImageCell = [tableView dequeueReusableCellWithIdentifier:@"DetailImageTableViewCell"];
        Post *targetPost = [PostManager sharedManager].post;
        if(targetPost && [targetPost.postID isKindOfClass:[NSNumber class]]){
            
            UITapGestureRecognizer *tapUserGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImageTap:)];
            self.detailImageCell.postImageView.userInteractionEnabled = YES;
            [self.detailImageCell.postImageView addGestureRecognizer:tapUserGestureRecognizer];
            
            if(self.postImageTempView && self.postImageTempView.image){
                [self.detailImageCell configureCellForAppRecord:targetPost UIImage:self.postImageTempView.image];
            }else{
                [self.detailImageCell configureCellForAppRecord:targetPost UIImage:nil];
            }
            self.detailImageCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self.detailImageCell.contentView setNeedsLayout];
            [self.detailImageCell.contentView layoutIfNeeded];
            return self.detailImageCell;
            
        }else{
            return self.detailImageCell;
        }
        
    }else if(indexPath.section == 2){
        // post user
        self.detailUserCell = [[tableView dequeueReusableCellWithIdentifier:@"DeailUserTableViewCell"] initWithUserPID:self.userPID userID:self.userId];
        Post *targetPost = [PostManager sharedManager].post;
        if(targetPost && [targetPost.postID isKindOfClass:[NSNumber class]]){
            
            [self.detailUserCell configureCellForAppRecord:targetPost];
        
            // ユーザアイコンタップ
            UITapGestureRecognizer *tapUserGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postUserTap:)];
            self.detailUserCell.userImageView.userInteractionEnabled = YES;
            [self.detailUserCell.userImageView addGestureRecognizer:tapUserGestureRecognizer];
            
            [self.detailUserCell.userNameBtn addTarget:self action:@selector(detailUserButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.detailUserCell.userIdBtn addTarget:self action:@selector(detailUserButton:) forControlEvents:UIControlEventTouchUpInside];
        
            self.detailUserCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //メッセージボタン
            [self.detailUserCell.msgBtn addTarget:self
                            action:@selector(openMsg:)
                  forControlEvents:UIControlEventTouchUpInside];
            [self controlMsgBtn];
            
            [self.detailUserCell setNeedsLayout];
            [self.detailUserCell layoutIfNeeded];
        
            return self.detailUserCell;
        }else{
            return self.detailUserCell;
        }
        
    }else if(indexPath.section == 3){
        // post descrip
        self.detaiDescrpCell = [tableView dequeueReusableCellWithIdentifier:@"DetailDescripTableViewCell"];
        Post *targetPost = [PostManager sharedManager].post;
        if(targetPost && [targetPost.postID isKindOfClass:[NSNumber class]]){
            self.detaiDescrpCell.postDescripLabel.tag = 2148;
            self.detaiDescrpCell.postDescripLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            self.detaiDescrpCell.postDescripLabel.delegate = self;
            NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
            [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
            if ([NSMutableParagraphStyle class]) {
                [mutableLinkAttributes setObject:USER_DISPLAY_NAME_COLOR forKey:(NSString *)kCTForegroundColorAttributeName];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                
                [mutableLinkAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
            } else {
                [mutableLinkAttributes setObject:(__bridge id)[USER_DISPLAY_NAME_COLOR CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
            }
            self.detaiDescrpCell.postDescripLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
            self.detaiDescrpCell.postDescripLabel.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
            
            //tag setting.
            UITapGestureRecognizer *TagTapEvent = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TagTapped:)];
            [self.detaiDescrpCell.postDescripLabel addGestureRecognizer:TagTapEvent];
            self.detaiDescrpCell.postDescripLabel.text = [self getTagHighlightedTextAndMemorizeTags:targetPost.descrip];
            
            [self.detaiDescrpCell configureCellForAppRecord:targetPost];
            
            self.detaiDescrpCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
            [self.detaiDescrpCell setNeedsLayout];
            [self.detaiDescrpCell layoutIfNeeded];
        
            
            return self.detaiDescrpCell;
        }else{
            return self.detaiDescrpCell;
        }

    }else if(indexPath.section == 1){
        // post action
        self.detaiActionCell = [tableView dequeueReusableCellWithIdentifier:@"DetailActionTableViewCell"];
        Post *targetPost = [PostManager sharedManager].post;
        if(targetPost && [targetPost.postID isKindOfClass:[NSNumber class]]){
            
            // check cntComment
            DLog(@"self.cntComment cntComment : %@", self.cntComment);
            DLog(@"targetPost cntComment : %@", targetPost.cntComment);
            
            if([self.cntComment isKindOfClass:[NSNumber class]] &&
                ![self.cntComment isEqualToNumber:targetPost.cntComment]){
                NSComparisonResult result;
                result = [self.cntComment compare:targetPost.cntComment];
                switch(result) {
                        case NSOrderedDescending:
                            targetPost.cntComment = self.cntComment;
                            break;
                        case NSOrderedSame:
                            break;
                        case NSOrderedAscending:
                            break;
                }
            }
            
            [self.detaiActionCell configureCellForAppRecord:targetPost];
        
            // その他ボタン
            [self.detaiActionCell.otherBtn addTarget:self action:@selector(otherDetailAction:) forControlEvents:UIControlEventTouchUpInside];
            // いいねボタン
            [self.detaiActionCell.goodBtn addTarget:self action:@selector(goodDetailAction:event:) forControlEvents:UIControlEventTouchUpInside];
            
            //when img double tapped, toggle good action.
            UITapGestureRecognizer *TapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tappedimg:)];
            TapGestureRecognizer.numberOfTapsRequired = 2;
            self.detailImageCell.userInteractionEnabled = YES;
            [self.detailImageCell addGestureRecognizer:TapGestureRecognizer];
            
            //comment Btn Action
            [self.detaiActionCell.commentBtn addTarget:self action:@selector(CommenttextBeginEditing:) forControlEvents:UIControlEventTouchUpInside];
            
            self.detaiActionCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
            [self.detaiActionCell setNeedsLayout];
            [self.detaiActionCell layoutIfNeeded];
            
            return self.detaiActionCell;
        }else{
            return self.detaiActionCell;
        }
        
    }else if(indexPath.section == 4){
        self.detailCommentCell = [tableView dequeueReusableCellWithIdentifier:@"DetailCommentTableViewCell"];
        [self.detailCommentCell configureCellForAppRecord: [self.commentManager.comments objectAtIndex:(NSUInteger)indexPath.row]];
    
        // アイコンタップ
        // ユーザアイコンタップ時
        UITapGestureRecognizer *tapUserGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postUserDetailCommentTap:)];
        self.detailCommentCell.iconImageView.userInteractionEnabled = YES;
        [self.detailCommentCell.iconImageView addGestureRecognizer:tapUserGestureRecognizer];
        self.detailCommentCell.iconImageView.tag = indexPath.row;
    
        // ハイライトなし
        self.detailCommentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        [self.detailCommentCell setNeedsLayout];
        [self.detailCommentCell layoutIfNeeded];

        return self.detailCommentCell;
    
    }else if (indexPath.section == 5){
        
        //imobile SDKのCell.
        [self.tableView registerClass:[DetailAdTableViewCell class] forCellReuseIdentifier:@"AdCell"];
        DetailAdTableViewCell *adCell = [tableView dequeueReusableCellWithIdentifier:@"AdCell"];
        
        // スポット情報を設定します
        [ImobileSdkAds registerWithPublisherID:IMOBILE_BANNER_PID MediaID:IMOBILE_BANNER_MID SpotID:IMOBILE_BANNER_SID];
        // 広告の取得を開始します
        [ImobileSdkAds startBySpotID:IMOBILE_BANNER_SID];
        
        // 表示する広告のサイズ
        CGSize imobileAdSize = CGSizeMake(300, 250);
        // デバイスの画面サイズ
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        // 広告の表示位置を算出(画面中央)
        CGFloat imobileAdPosX = (screenSize.width - imobileAdSize.width) / 2;
        
        // 広告を表示するViewを作成します
        [adCell.imobileAdView setFrame:CGRectMake(imobileAdPosX, 20, imobileAdSize.width, imobileAdSize.height)];
        
        // 広告を表示します
        [ImobileSdkAds showBySpotID:IMOBILE_BANNER_SID View:adCell.imobileAdView];
        
        return  adCell;
    }
    return nil;
}

//get NSRange of tapped String.
- (NSUInteger)getTappedLocationOfLabelString:(UITapGestureRecognizer *)recognizer
{
    UILabel *textLabel = (UILabel *)recognizer.view;
    CGPoint tapLocation = [recognizer locationInView:textLabel];
    
    // init text storage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textLabel.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    // init text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(textLabel.frame.size.width, textLabel.frame.size.height+100) ];
    textContainer.lineFragmentPadding  = 0;
    textContainer.maximumNumberOfLines = textLabel.numberOfLines;
    textContainer.lineBreakMode        = textLabel.lineBreakMode;
    
    [layoutManager addTextContainer:textContainer];
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:tapLocation
                                                      inTextContainer:textContainer
                             fractionOfDistanceBetweenInsertionPoints:NULL];
    return characterIndex;
}

//Tag Tap Event.
- (void)TagTapped:(UITapGestureRecognizer *)recognizer{
    
    //location tapped.
    NSUInteger tappedRangeFirst = [self getTappedLocationOfLabelString:recognizer];
    
    //範囲外なら処理しないx
    Post *targetPost = [PostManager sharedManager].post;
    if (tappedRangeFirst + 1 == targetPost.descrip.length) {
        return;
    }
    
    //get tag tapped.
    [self.TagNameAndRange enumerateKeysAndObjectsUsingBlock:^(id tag_name, id tag_range, BOOL *stop) {
        
        NSRange TagRange = NSRangeFromString(tag_range);
        if(NSLocationInRange(tappedRangeFirst, TagRange)){
            //delete `#`.
            tag_name = [tag_name stringByReplacingOccurrencesOfString:@"#" withString:@""];
            
            //Send Repro Event
            [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[TAGTAP]
                                 properties:@{DEFINES_REPROEVENTPROPNAME[TAG] : tag_name }];
            
            //tag検索一覧へ
            self.postTagView = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"PostTagViewController"];
            //該当タグを渡す
            self.postTagView.HushTagName = tag_name;
            [self.NavigationController pushViewController:self.postTagView animated:YES];
            return;
        }
    }];
    
}

//get tags from post description by regex and memorize these data for tap event.
- (NSMutableAttributedString *)getTagHighlightedTextAndMemorizeTags:(NSString *)postDescrip
{
    //tag array for tap event.
    self.TagNameAndRange = [[NSMutableDictionary alloc] init];
    //post description label.
    NSMutableAttributedString *tagHighlightedText = [[NSMutableAttributedString alloc] initWithString:postDescrip];
    
    NSString *regexpPattern = @"#[^# \r\t\n\f\v]*";
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression
                                   regularExpressionWithPattern:regexpPattern
                                   options:0 error:&error];
    
    if (error == nil) {
        NSArray *regexpArray = [regexp matchesInString:tagHighlightedText.string
                                               options:0
                                                 range:NSMakeRange(0, tagHighlightedText.length)];
        
        NSRange tagRange; //range of each tag.
        NSString *tag;   //each tag.
        for (NSTextCheckingResult *match in regexpArray) {
            
            tagRange = [match rangeAtIndex:0];
            tag = [tagHighlightedText.string substringWithRange:tagRange];
            
            //change tag color .
            [tagHighlightedText addAttribute:NSForegroundColorAttributeName
                                       value:USER_DISPLAY_NAME_COLOR range:tagRange];
            
            //memorize tag name and NSrange of its tag .
            [self.TagNameAndRange setObject: NSStringFromRange(tagRange) forKey:tag];
        }
    }
    return tagHighlightedText;
}
- (void)CommenttextBeginEditing:(id)sender
{
    [self.commentTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(![[Configuration checkLogined] length]){
        // no login
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        [textField resignFirstResponder];
    }
    return NO;
}

// キーボード：エンターキータップ時
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //inputResult.text = textField.text;
    // キーボード画面をクローズします。
    //[_commentTextField resignFirstResponder];
    // キーボードを隠す
    [self.view endEditing:YES];
 
    return NO;
}
#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    
    if ([[UIApplication sharedApplication]canOpenURL:url]){
        [[UIApplication sharedApplication]openURL:url];
    }
    
}
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.view.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[UITextField class]]) {
//            [obj resignFirstResponder];
//        }
//    }];
//}

#pragma mark setting method

- (void)loadPost
{
    NSNumber *targetPostID;
    if(![self.postID isEqual:[NSNull null]]){
        targetPostID = self.postID;
    }
    
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
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        
        if(!error){
            strongSelf.post = srvPost;
        }else{
            
            // エラー
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
        }
        
    }];
}

- (void)loadComments:(BOOL)noReload refreshFlg:(BOOL)refreshFlg
{
    NSNumber *post_id = self.postID;
    
    if(refreshFlg){
        self.commentManager = [CommentManager new];
    }
    
    // Loading
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }

    NSDictionary *params = @{ @"postID" : post_id, @"page" : @(1), };

    __weak typeof(self) weakSelf = self;
    [self.commentManager reloadCommentsWithParams:params block:^(NSMutableArray *comments, NSUInteger commentPage, NSError *error) {
        
        //__strong typeof(weakSelf) strongSelf = weakSelf;
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        
        if (error) {
            DLog(@"error = %@", error);
            
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            

        }else{
        
            weakSelf.canLoadMore = weakSelf.commentManager.canLoadCommentMore;
            
            DLog(@"%lu", (unsigned long)[weakSelf.commentManager.comments count]);
        
            if([self.commentManager.comments count] > 0){
                weakSelf.moreCommentBtn.hidden = NO;
                weakSelf.moreCommentLabel.hidden = NO;
            }else{
                weakSelf.moreCommentBtn.hidden = YES;
                weakSelf.moreCommentLabel.hidden = YES;
            }
            if(!noReload){
                [weakSelf.tableView reloadData];
                //[strongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            }
        }

        
    }];
}


// ------------------------
// aciton
// ------------------------

// ユーザID、ニックネームボタンアクション
- (void)detailUserButton:(UIButton *)sender {
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENPROFILE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]: NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[TAPPED]: DEFINES_REPROEVENTPROPITEM[NAME]}];
    
    Post *tPost = [PostManager sharedManager].post;
    
    // 画面内遷移の場合
    UserViewController *userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
    // 他人画面
    userViewController.isMmine = false;
    userViewController = [userViewController initWithUserPID:tPost.userPID userID:tPost.userID];
    [userViewController preloadingPosts];
    
    self.navigationItem.backBarButtonItem.title = @"";
    // 画面遷移実行後に、ナビゲーション表示へ
    //self.NavigationController.navigationBarHidden = NO;
    [self.NavigationController setNavigationBarHidden:NO animated:NO];
    userViewController.navigationController.navigationBarHidden = NO;
    self.navigationItem.backBarButtonItem.title = @"";
        
    [self.NavigationController pushViewController:userViewController animated:YES];
    userViewController = nil;
    
}

// ユーザアイコンアクション
// postUserTap
- (void)postUserTap:(UIGestureRecognizer *)recognizer
{
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENPROFILE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]: NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[TAPPED]: DEFINES_REPROEVENTPROPITEM[IMG]}];
    
    NSLog(@"gestureTest[%@]",recognizer);
    NSLog(@"[%@]",recognizer.view);
    
    Post *tPost = [PostManager sharedManager].post;
    
    UserViewController *userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
    // 他人画面
    userViewController.isMmine = false;
    userViewController = [userViewController initWithUserPID:tPost.userPID userID:tPost.userID];
    [userViewController preloadingPosts];

    
    self.navigationItem.backBarButtonItem.title = @"";
    [self.NavigationController pushViewController:userViewController animated:YES];
    
    
    // 画面遷移実行後に、ナビゲーション表示へ
    //[self.NavigationController setNavigationBarHidden:NO animated:NO];
    //profileController.navigationController.navigationBarHidden = NO;
    
}


// ImageViewタップ
- (void)postImageTap:(UIGestureRecognizer *)recognizer
{
    //タグ999の場合はムービ扱いと決める
    if([recognizer view].tag == 999){
        [self playMovie];
    }
}

///動画を再生する
- (void)playMovie{
    
    if (self.player && self.player.playbackState == MPMoviePlaybackStatePlaying) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[PostManager sharedManager].post.transcodedPath];
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [player setControlStyle:MPMovieControlStyleNone];
    [player.view setFrame:CGRectMake(0, 0,
                                     self.detailImageCell.frame.size.width,
                                     self.detailImageCell.frame.size.height)];
    
    UITapGestureRecognizer *tr = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(playerTap:)];
    [tr setDelegate:self];
    [player.view addGestureRecognizer:tr];
    
    // MoviePlayerを保持
    self.player = player;
    
    [self.detailImageCell addSubview:player.view];
    
    // 再生開始
    [player prepareToPlay];
}

///動画がタップされたらコントロールバーを出す
- (void)playerTap:(id)sender{
    [self.player setControlStyle:MPMovieControlStyleEmbedded];
}

///動画を止める
- (void)stopMovie {
    if (self.player) {
        [self.player stop];
        [self.player.view removeFromSuperview];
    }
}

- (void) commentCloseAction:(id)sender
{
    // キーボードを隠す
    [self.view endEditing:YES];
}

- (void) postUserDetailCommentTap:(UIGestureRecognizer *)recognizer
{

    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENPROFILE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]: NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[TAPPED]: DEFINES_REPROEVENTPROPITEM[IMG]}];
    
//    UICollectionViewCell *cell = (UICollectionViewCell *)[[[recognizer view] superview] superview];
//    NSIndexPath *path = [self.tableView indexPath:cell];
//    NSLog(@"Pushed :: [%d]",path.row);
    
//    UITableViewCell *cell = (UITableViewCell *)[[[recognizer view] superview] superview];
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    DLog(@"Pushed :: [%ld]",(unsigned long)path.row);
    
    
    NSInteger recognizerRow = [recognizer view].tag;
    Comment *tComment = [self.commentManager.comments objectAtIndex:recognizerRow];
    
    // 画面内遷移の場合
    UserViewController *userViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"UserViewController"];
    // 他人画面
    userViewController.isMmine = false;
    userViewController = [userViewController initWithUserPID:tComment.userPID userID:tComment.userID];
    [userViewController preloadingPosts];
    
    
    self.navigationItem.backBarButtonItem.title = @"";
    [self.NavigationController pushViewController:userViewController animated:YES];
    
    
    // 画面遷移実行後に、ナビゲーション表示へ
    //[self.NavigationController setNavigationBarHidden:NO animated:NO];
    //profileController.navigationController.navigationBarHidden = NO;
    
}

- (void) commentSlideUpAction:(NSNotification*)notification
{
    DLog(@"DetailView commentSlideUpAction");

    //キーボードの CGRect を取得
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (self.parentView) {
        keyboardRect = [[self.parentView.view superview] convertRect:keyboardRect fromView:nil];
    }else{
        keyboardRect = [[self.view superview] convertRect:keyboardRect fromView:nil];
    }
    
    
    //キーボードの animationDuration を取得
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //メインビューの高さをキーボードの高さぶん引く
    CGRect frame = self.commentToolBar.frame;
    
    
    if([Configuration checkModel] == VLModelNameIPhone6p){
        frame.origin.y = keyboardRect.origin.y - frame.size.height * 2;
        frame.origin.y = keyboardRect.origin.y - 104.0f;
    }else{
        frame.origin.y = keyboardRect.origin.y - frame.size.height * 2;
        frame.origin.y = keyboardRect.origin.y - 104.0f;
    }
    
    DLog(@"keyboardRect.y : %f", keyboardRect.origin.y);
    DLog(@"toolbar.y : %f", self.commentToolBar.frame.origin.y);
    DLog(@"frame.y : %f", frame.origin.y);
    
    //キーボードアニメーションと同じ間隔でメインビューの高さをアニメーションしつつ変更する。
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.commentToolBar.frame = frame;
    [UIView commitAnimations];
}

- (void) commentSlideDownAction:(NSNotification*)notification
{
    DLog(@"DetailView commentSlideDownAction");
    
    
    //toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
    //toolBar.frame = toolBarFrame;
    
    //キーボードの CGRect を取得
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (self.parentView) {
        keyboardRect = [[self.parentView.view superview] convertRect:keyboardRect fromView:nil];
    }else{
        keyboardRect = [[self.view superview] convertRect:keyboardRect fromView:nil];
    }
    
    
//    //キーボードの animationDuration を取得
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //メインビューの高さをキーボードの高さぶん足す（＝元の高さに戻す）
    CGRect frame = self.commentToolBar.frame;
    frame.origin.y += keyboardRect.origin.y;
    //frame.size.height += keyboardRect.size.height;
    //キーボードアニメーションと同じ間隔でメインビューの高さをアニメーションしつつ変更する。
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.commentToolBar.frame = frame;
    [UIView commitAnimations];
    
    DLog(@"toolbar.y : %f", self.commentToolBar.frame.origin.y);
    DLog(@"last.y : %f", self.view.bounds.size.height - 88.0f);
    
    // 再度指定するとなぜかうまくいく
    if([Configuration checkModel] == VLModelNameIPhone6p){
        _commentToolBar.frame = CGRectMake(0.0f,
                                           self.view.bounds.size.height - 40.0f,
                                           self.view.bounds.size.width,
                                           40.0f);
    }else{
        _commentToolBar.frame = CGRectMake(0.0f,
                                       self.view.bounds.size.height - 88.0f,
                                       self.view.bounds.size.width,
                                       40.0f);
    }
}

// コメント送信確認
- (void)commentSendAction:(id)sender
{
    DLog(@"DetailView commentSendAction");

    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[COMMENTTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW] :
                                          NSStringFromClass([self class])}];
    
    if(![[Configuration checkLogined] length]){
        // no login
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        return;
    }
    
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MsgActionPostComment", nil)
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
        [UIAlertAction actionWithTitle:NSLocalizedString(@"Send", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               // ボタンタップ時の処理
                               DLog(@"OK button tapped.");
                               [self commentSend];
                           }];
        // コントローラにアクションを追加
        [ac addAction:cancelAction];
        //[ac addAction:destructiveAction];
        [ac addAction:okAction];
        // アクションシート表示処理
        [self presentViewController:ac animated:YES completion:nil];
        
    }else{
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = NSLocalizedString(@"MsgActionPostComment", nil);
        [as addButtonWithTitle:NSLocalizedString(@"Send", nil)];
        [as addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        //as.destructiveButtonIndex = 1;    // red color
        as.cancelButtonIndex = 1;
        as.tag = 1;
        [as showInView:self.view];
    }
}

// コメント送信
- (void)commentSend
{
    DLog(@"DetailView commentSend");

    NSString *comment = self.commentTextField.text;
    //[self.commentTextField resignFirstResponder];

    // コメント空チェック
    if(!comment || ![comment length] > 0){
        // empty
        // ValidatePostEmptyComment
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert = [[UIAlertView alloc]
                 initWithTitle:NSLocalizedString(@"ValidatePostEmptyComment", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        // キーボードを隠す
        //[self.view endEditing:YES];
        // TODO
        [alert show];

    }else if(comment && [comment length] > 180){
        // over 180
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert = [[UIAlertView alloc]
                 initWithTitle:NSLocalizedString(@"ValidatePostMaxOverComment", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        // キーボードを隠す
        //[self.view endEditing:YES];
        // TODO
        [alert show];

    }else{
    
        // ------------------
        // login check
        // ------------------
        if(![[Configuration checkLogined] length]){
            // 未ログイン
            [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
            
        }else{

            NSNumber *targetPostId = self.postID;
            
            // ***************
            // send comment
            // ***************
            NSDictionary *vConfig   = [ConfigLoader mixIn];
            NSString *isLoding = vConfig[@"LoadingPostDisplay"];
            if( isLoding && [isLoding boolValue] == YES ){
                // Loading
                [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
            }
            
            NSString *vellyToken = [Configuration loadAccessToken];
            DLog(@"%@", vellyToken);
            DLog(@"%@", targetPostId);

            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"body"] = comment;
            
            __weak typeof(self) weakSelf = self;
            [self.commentManager postComment:targetPostId params:params aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
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
                             initWithTitle:NSLocalizedString(@"ApiErrorComment", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    // キーボードを隠す
                    [strongSelf.view endEditing:YES];
                    [alert show];

                }else{
                    // success
                    
                    // plus commentCnt
                    // diplay update
                    //int commentCnt = [strongSelf.post.cntComment intValue];
                    int commentCnt = [strongSelf.cntComment intValue];
                    commentCnt = commentCnt + 1;
                    //strongSelf.commentCntLabel.text = [[NSNumber numberWithInt:commentCnt] stringValue];
                    [strongSelf.commentCntLabel setText:[[NSNumber numberWithInt:commentCnt] stringValue]];
                    
                    strongSelf.post.cntComment = [NSNumber numberWithInt:commentCnt];
                    strongSelf.cntComment = [NSNumber numberWithInt:commentCnt];

                    double delayInSeconds = 0.1;
                    dispatch_time_t moreTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(moreTime, dispatch_get_main_queue(), ^(void){
                        // 更に読み込み
                        //[strongSelf.tableView reloadData];
                        
                        //NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:strongSelf.tableView]);
                        //NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
                        
                        //                        NSIndexSet *sections3 = [NSIndexSet indexSetWithIndex:3];
                        //                        [strongSelf.tableView reloadSections:sections3 withRowAnimation:UITableViewRowAnimationFade];
                        
                        [self loadComments:NO refreshFlg:YES];
                        
                    });

                    // no alert
//                    alert = [[UIAlertView alloc]
//                             initWithTitle:NSLocalizedString(@"MSgDoComment", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//                    [alert show];
                    
                    // コメント空
                    strongSelf.commentTextField.text = nil;
                    // キーボードを隠す
                    [strongSelf.view endEditing:YES];
                    
                }
            }];
            
        }

    }
}

- (void)otherDetailAction:(id)sender
{
    DLog(@"DetailView otherDetailAction");
    
    NSString *twToken       = [Configuration loadTWAccessToken];
    NSString *twTokenSecret = [Configuration loadTWAccessTokenSecret];
    NSString *fbToken       = [Configuration loadFBAccessToken];
    NSString *lineOpen      = [CSNLINEOpener canOpenLINE] ? @"1" : nil;

    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        
        // NSLocalizedString(@"MsgConfActionReport", nil)
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:nil
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
        UIAlertAction * deleteAction;
        UIAlertAction * editAction;
        if ([self.post.userID isEqualToString:[Configuration loadUserId]]) {
            //投稿削除
            deleteAction =
            [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgDoActionDelete", nil)
                                     style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action) {
                                       // ボタンタップ時の処理
                                       DLog(@"Delete button tapped.");
                                       
                                       UIAlertView *alert =
                                       [[UIAlertView alloc] initWithTitle:@"確認" message:NSLocalizedString(@"MsgConfActionDelete", nil)
                                                                 delegate:self cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
                                       [alert show];
                                       
                                   }];
            //投稿編集
            editAction =
            [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgDoActionEdit", nil)
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [self postUpdateAction];
                                   }];
        }
        // URLコピー
        UIAlertAction * copyAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"URLCopy", nil)
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   // ボタンタップ時の処理
                                   DLog(@"Copy button tapped.");
                                   [self urlCopyAction];
                               }];
        // 不適切な投稿を報告
        UIAlertAction * reportAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgDoActionReport", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               // ボタンタップ時の処理
                               DLog(@"Report button tapped.");
                               [self sendAlertMail];
                           }];
        
        // facebook share
        UIAlertAction * fbShareAction;
        if(![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0){
            fbShareAction =
            [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgDoActionFacebookShare", nil)
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                       DLog(@"Facebook Share button tapped.");
                                       [self sendFacebookShare];
                                       
                                   }];
        }
        // twitter tweet
        UIAlertAction * twTweetAction;
        if(![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0 && twTokenSecret && [twTokenSecret length] > 0){
            twTweetAction =
            [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgDoActionTwitterTweet", nil)
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {

                                       DLog(@"Twitter Tweet button tapped.");
                                       [self sendTwitterTweet];
                                       
                                   }];
        }
        // LINE send
        UIAlertAction * lineSendAction;
        if (![lineOpen isKindOfClass:[NSNull class]]) {
            // installed LINE
            lineSendAction =
            [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgDoActionLineSend", nil)
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                       DLog(@"LINE Send button tapped.");
                                       [self sendLineAction];
                                       
                                   }];
        }else{
            // no installed
            // [CSNLINEOpener openAppStore];
        }
        
        //ここで表示順序を制御
        if (deleteAction)[ac addAction:deleteAction];
        [ac addAction:reportAction];
        if (editAction)[ac addAction:editAction];
        if (twTweetAction) [ac addAction:twTweetAction];
        if (fbShareAction) [ac addAction:fbShareAction];
        if (lineSendAction) [ac addAction:lineSendAction];
        [ac addAction:copyAction];
        [ac addAction:cancelAction];
        
        // アクションシート表示処理
        [self presentViewController:ac animated:YES completion:nil];

    }else{
        int cancelIndex = 0;
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = @"";
        
        if(![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0){
            [as addButtonWithTitle:NSLocalizedString(@"MsgDoActionFacebookShare", nil)];
            cancelIndex++;
        }
        if(![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0 && twTokenSecret && [twTokenSecret length] > 0){
            [as addButtonWithTitle:NSLocalizedString(@"MsgDoActionTwitterTweet", nil)];
            cancelIndex++;
        }
        if (![lineOpen isKindOfClass:[NSNull class]]) {
            [as addButtonWithTitle:NSLocalizedString(@"MsgDoActionLineSend", nil)];
            cancelIndex++;
        }
        [as addButtonWithTitle:NSLocalizedString(@"URLCopy", nil)];
        cancelIndex++;
        [as addButtonWithTitle:NSLocalizedString(@"MsgDoActionReport", nil)];
        cancelIndex++;
        [as addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        as.destructiveButtonIndex = cancelIndex - 1;
        as.cancelButtonIndex = cancelIndex;
        
        DLog(@"%d", cancelIndex);
        
        as.tag = 0;
        [as showInView:self.view];
    }
}

//// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}
//ダブルタップでのいいね時にポップアップ
- (void)popuplike:(NSString*)imagename{
    
    UIViewController* likepopupview = [UIViewController alloc];
    likepopupview.view.frame = CGRectMake(0, 0, 1, 1);
    UIImage*like = [UIImage imageNamed:imagename];
    UIImageView*likeview = [[UIImageView alloc]initWithFrame:CGRectMake(-20, -50, 50,50) ];
    likeview.image = like;
    [likepopupview.view addSubview:likeview];
    [self presentPopupViewController:likepopupview animationType:MJPopupViewAnimationFade];
    double delayInSeconds = 0.1f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    });
}

//when detail image double tapped, toggle good action.
- (void)Tappedimg:(UIGestureRecognizer *)recognizer{

    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[GOODTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW] : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[POST] : self.postID,
                                      DEFINES_REPROEVENTPROPNAME[TYPE] : [NSNumber numberWithInteger:IMGDOUBLETAP]}];

    DLog(@"Tappedimg");
    Post *targetPost = [PostManager sharedManager].post;
    // ------------------
    // login check
    // ------------------
    if(![[Configuration checkLogined] length]){
        // 未ログイン
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        
    }else if(self.isSendLike){
        // sending -> no action
        
    }else{
        
        self.isSendLike = YES;
        NSNumber *isLike = self.isLike;
        NSString *postIdStr = [targetPost.postID stringValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        DetailActionTableViewCell *targetCell = (DetailActionTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
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
        DLog("%@",self);
        DLog(@"%@", self.isLike);
        DLog(@"%@", postIdStr);
        
        if([isLike isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
            
            // Liked -> delete Like
            [self popuplike:@"heart_popup_off.png"];
            [[PostManager sharedManager] deletePostLike:postIdStr aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
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
                    
                    //[self.goodImageView setImage:[UIImage imageNamed:@"ico_heart.png"]];
                    [self.detaiActionCell.goodImageView setImage:[UIImage imageNamed:@"heart_popup_off.png"]];
                    self.isLike = [NSNumber numberWithInt:VLPOSTLIKENO];
                    
                    //NSIndexPath *targetPath = [NSIndexPath indexPathForRow:1 inSection:3];
                    //DetailActionTableViewCell *targetCell = (DetailActionTableViewCell *)[self.tableView cellForRowAtIndexPath:targetPath];
                    if([targetCell isKindOfClass:[DetailActionTableViewCell class]]){
                        [targetCell minusCntGood];
                    }
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[PostManager sharedManager] updateMyGood:myUserPID postID:self.postID isGood:VLPOSTLIKENO cntGood:targetCell.cntGood];
                    }
                    
                    // no alert
                    //                    alert = [[UIAlertView alloc]
                    //                             initWithTitle:NSLocalizedString(@"MsgDelGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    //                    [alert show];
                    
                    
                }
                self.isSendLike = NO;
            }];
            
            
        }else{
            
            // no Like -> send Like
            [self popuplike:@"heart_popup.png"];
            [[PostManager sharedManager] postPostLike:postIdStr aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
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
                    
                    //[self.goodImageView setImage:[UIImage imageNamed:@"ico_heart_on.png"]];
                    [self.detaiActionCell.goodImageView setImage:[UIImage imageNamed:@"heart_popup.png"]];
                    self.isLike = [NSNumber numberWithInt:VLPOSTLIKEYES];
                    
                    //NSIndexPath *targetPath = [NSIndexPath indexPathForRow:1 inSection:3];
                    //DetailActionTableViewCell *targetCell = (DetailActionTableViewCell *)[self.tableView cellForRowAtIndexPath:targetPath];
                    if([targetCell isKindOfClass:[DetailActionTableViewCell class]]){
                        [targetCell plusCntGood];
                    }
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[PostManager sharedManager] updateMyGood:myUserPID postID:self.postID isGood:VLPOSTLIKEYES cntGood:targetCell.cntGood];
                    }
                    
                    //                    alert = [[UIAlertView alloc]
                    //                             initWithTitle:NSLocalizedString(@"MsgGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                    //                    [alert show];
                    
                }
                
                self.isSendLike = NO;
            }];
            
        }
        
    }
}

- (void)goodDetailAction:(UIButton *)sender event:(UIEvent *)event
{
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[GOODTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW] : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[POST] : self.postID,
                                      DEFINES_REPROEVENTPROPNAME[TYPE] : [NSNumber numberWithInteger:HEART_DETAIL]}];
    
    DLog(@"DetailView goodDetailAction");
    // ------------------
    // login check
    // ------------------
    if(![[Configuration checkLogined] length]){
        // 未ログイン
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        
    }else if(self.isSendLike){
        // sending -> no action
        
    }else{
        self.isSendLike = YES;
        
        NSNumber *isLike = self.isLike;
        NSString *postIdStr = [self.postID stringValue];
        
        NSIndexPath *indexPath = [self indexPathForControlEvent:event];
        DetailActionTableViewCell *targetCell = (DetailActionTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

        
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
        DLog(@"%@", isLike);
        DLog(@"%@", postIdStr);
        
        if([isLike isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){

            // Liked -> delete Like

            [[PostManager sharedManager] deletePostLike:postIdStr aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
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

                    //[self.goodImageView setImage:[UIImage imageNamed:@"ico_heart.png"]];
                    [self.detaiActionCell.goodImageView setImage:[UIImage imageNamed:@"heart_popup_off.png"]];
                    self.isLike = [NSNumber numberWithInt:VLPOSTLIKENO];

                    //NSIndexPath *targetPath = [NSIndexPath indexPathForRow:1 inSection:3];
                    //DetailActionTableViewCell *targetCell = (DetailActionTableViewCell *)[self.tableView cellForRowAtIndexPath:targetPath];
                    if([targetCell isKindOfClass:[DetailActionTableViewCell class]]){
                        [targetCell minusCntGood];
                    }
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[PostManager sharedManager] updateMyGood:myUserPID postID:self.postID isGood:VLPOSTLIKENO cntGood:targetCell.cntGood];
                    }
                    
                    // no alert
//                    alert = [[UIAlertView alloc]
//                             initWithTitle:NSLocalizedString(@"MsgDelGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//                    [alert show];
                    

                }
                self.isSendLike = NO;
            }];
            
            
        }else{

            // no Like -> send Like

            [[PostManager sharedManager] postPostLike:postIdStr aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
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
                    
                    //[self.goodImageView setImage:[UIImage imageNamed:@"ico_heart_on.png"]];
                    [self.detaiActionCell.goodImageView setImage:[UIImage imageNamed:@"heart_popup.png"]];
                    self.isLike = [NSNumber numberWithInt:VLPOSTLIKEYES];

                    //NSIndexPath *targetPath = [NSIndexPath indexPathForRow:1 inSection:3];
                    //DetailActionTableViewCell *targetCell = (DetailActionTableViewCell *)[self.tableView cellForRowAtIndexPath:targetPath];
                    if([targetCell isKindOfClass:[DetailActionTableViewCell class]]){
                        [targetCell plusCntGood];
                    }
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[PostManager sharedManager] updateMyGood:myUserPID postID:self.postID isGood:VLPOSTLIKEYES cntGood:targetCell.cntGood];
                    }
                    
//                    alert = [[UIAlertView alloc]
//                             initWithTitle:NSLocalizedString(@"MsgGood", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//                    [alert show];

                }
                
                self.isSendLike = NO;
            }];

        }

    }
    
}

// ----------------
// URLコピー
// ----------------
-(void)urlCopyAction
{
    // URLコピー -> clipboard copy
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *postUrl = vConfig[@"WebViewURLPost"];
    NSString *postUrlReplace = postUrl;
    postUrlReplace = [postUrl stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[self.postID stringValue]];

    [[UIPasteboard generalPasteboard] setValue:postUrlReplace forPasteboardType:@"public.text"];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert = [[UIAlertView alloc]
             initWithTitle:NSLocalizedString(@"MsgDoActionURLCopy", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [alert show];
}

// ----------------
// 通報する
// ----------------
-(void)sendAlertMail
{
    // メールビュー生成
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // メール件名
    [picker setSubject:NSLocalizedString(@"MsgPostReportSubject", nil)];
    // メール宛先 NSArray
    NSArray * toAddressList = [NSArray arrayWithObjects:NSLocalizedString(@"MsgPostReportToMail", nil), nil];
    [picker setToRecipients:toAddressList];
    // CC
    //[picker setCcRecipients:nil];
    // BCC
    //[picker setBccRecipients:nil];

    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *postUrl = vConfig[@"WebViewURLPost"];
    NSString *postUrlReplace = postUrl;
    postUrlReplace = [postUrl stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[self.postID stringValue]];
    
    // 添付画像
    //NSData *myData = [[NSData alloc] initWithData:UIImageJPEGRepresentation([UIImage imageNamed:@"Pandora_744_1392.jpg"], 1)];
    //[picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"image"];
    // メール本文
    NSString *reportBody = NSLocalizedString(@"MsgPostReportBody", nil);
    NSString *userIdStr = [Configuration loadUserId];
    if(!userIdStr){
        userIdStr = @"";
        reportBody = NSLocalizedString(@"MsgPostReportBodyNoUserID", nil);
    }else{
        // <?user_pk>
        reportBody = [reportBody stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:userIdStr];
    }
    // <?post_url>
    reportBody = [reportBody stringByReplacingOccurrencesOfString:@"<?post_url>" withString:postUrlReplace];

    [picker setMessageBody:reportBody isHTML:NO];

    // メールビュー表示
    [self presentViewController:picker animated:YES completion:nil];
}

// ----------------
// Twitter Tweet
// ----------------
-(void)sendTwitterTweet
{
    DLog(@"DetailView Twitter Tweet");

    NSString *twToken = [Configuration loadTWAccessToken];
    NSString *twTokenSecret = [Configuration loadTWAccessTokenSecret];
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:OAUTH_TW_API_KEY
                                                 consumerSecret:OAUTH_TW_API_SECRET
                                                     oauthToken:twToken
                                               oauthTokenSecret:twTokenSecret];
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *postUrl = vConfig[@"WebViewURLPost"];
    NSString *postUrlReplace = postUrl;
    // <?post_pk>
    postUrlReplace = [postUrl stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[self.postID stringValue]];
    NSString *tweetBody = NSLocalizedString(@"MsgPostTwitterTweetBody", nil);
    // <?post_url>
    tweetBody = [tweetBody stringByReplacingOccurrencesOfString:@"<?post_url>" withString:postUrlReplace];
    
    // self.descrip
    int postDescripCnt = 139 - (int)[tweetBody length];
    NSString *tweetMessage;
    if(postDescripCnt > 5 && [self.descrip length] > 0){
        NSString *tweetPostDescrip = self.descrip;
        if([self.descrip length] > postDescripCnt){
            tweetPostDescrip = [self.descrip substringFromIndex:postDescripCnt];
        }
        tweetPostDescrip = [tweetPostDescrip stringByAppendingString:@" "];
        if([self.descrip length] > postDescripCnt){
            tweetPostDescrip = [tweetPostDescrip stringByAppendingString:@"... "];
        }
        tweetMessage = [tweetPostDescrip stringByAppendingString:tweetBody];
    }else{
        tweetMessage = tweetBody;
    }
    

    
    NSURL *appURL = [NSURL URLWithString:postUrlReplace];
    
    // iOS Version
    NSString *iosVersion = [[[UIDevice currentDevice] systemVersion] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // Social.frameworkを使う
    if ([iosVersion floatValue] >= 6.0) {
        //if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterPostVC setInitialText:tweetMessage];
        [twitterPostVC addURL:appURL]; // サイトURL
        
        [self presentViewController:twitterPostVC animated:YES completion:nil];
    }
    
}

// ----------------
// Facebook Share
// ----------------
-(void)sendFacebookShare
{
    DLog(@"DetailView Facebook Share");
    
    // 投稿できるようだが、キャンセルも投稿もおちる -> delegate に selfを設定すると発生
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *postUrl = vConfig[@"WebViewURLPost"];
    NSString *postUrlReplace = postUrl;
    // <?post_pk>
    postUrlReplace = [postUrl stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[self.postID stringValue]];
    
    //NSString *facebookTitle = NSLocalizedString(@"MsgPostFacebookShareTitle", nil);
    NSString *facebookBody = self.descrip;
    facebookBody = [facebookBody stringByAppendingString:@" "];
    facebookBody = [facebookBody stringByAppendingString:postUrlReplace];
    
    SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSString* postContent = facebookBody;
    [facebookPostVC setInitialText:postContent];
    NSURL* appURL = [NSURL URLWithString:postUrlReplace];
    [facebookPostVC addURL:appURL];

    [self presentViewController:facebookPostVC animated:YES completion:nil];
    
}

// ----------------
// LINE Send
// ----------------
-(void)sendLineAction
{
    DLog(@"DetailView Line Send");
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *postUrl = vConfig[@"WebViewURLPost"];
    NSString *postUrlReplace = postUrl;
    postUrlReplace = [postUrl stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[self.postID stringValue]];
    
    [CSNLINEOpener openLINEAppWithText:postUrlReplace];
}


// アプリ内メーラーのデリゲートメソッド
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            // キャンセル
            break;
        case MFMailComposeResultSaved:
            // 保存 (ここでアラート表示するなど何らかの処理を行う)
            break;
        case MFMailComposeResultSent:
            // 送信成功 (ここでアラート表示するなど何らかの処理を行う)
            break;
        case MFMailComposeResultFailed:
            // 送信失敗 (ここでアラート表示するなど何らかの処理を行う)
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 0){

        NSString *twToken       = [Configuration loadTWAccessToken];
        NSString *twTokenSecret = [Configuration loadTWAccessTokenSecret];
        NSString *fbToken       = [Configuration loadFBAccessToken];
        NSString *lineOpen      = [CSNLINEOpener canOpenLINE] ? @"1" : nil;
        
        NSMutableArray *sheetSorting =  [NSMutableArray array];
        int cnt = 0;
        if(![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0){
            [sheetSorting insertObject:@"facebook" atIndex:cnt];
            cnt++;
        }
        if(![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0 && twTokenSecret && [twTokenSecret length] > 0){
            [sheetSorting insertObject:@"twitter" atIndex:cnt];
            cnt++;
        }
        if (![lineOpen isKindOfClass:[NSNull class]]) {
            [sheetSorting insertObject:@"line" atIndex:cnt];
            cnt++;
        }
        [sheetSorting insertObject:@"urlcopy" atIndex:cnt];
        cnt++;
        [sheetSorting insertObject:@"alert" atIndex:cnt];
        
        // 通報処理
        switch (buttonIndex) {
            case 0:
                if([[sheetSorting objectAtIndex:buttonIndex] isEqualToString:@"facebook"]){
                    // facebook share
                    [self sendFacebookShare];
                    break;
                }else if([[sheetSorting objectAtIndex:buttonIndex] isEqualToString:@"twitter"]){
                    // twitter tweet
                    [self sendTwitterTweet];
                    break;
                }else if ([[sheetSorting objectAtIndex:buttonIndex] isEqualToString:@"line"]) {
                    // Line send
                    [self sendLineAction];
                    break;
                }else if ([[sheetSorting objectAtIndex:buttonIndex] isEqualToString:@"urlcopy"]) {
                    // URLをコピー
                    [self urlCopyAction];
                    break;
                }
                break;
            case 1:
                if([[sheetSorting objectAtIndex:buttonIndex] isEqualToString:@"twitter"]){
                    // twitter tweet
                    [self sendTwitterTweet];
                    break;
                }else if ([[sheetSorting objectAtIndex:buttonIndex] isEqualToString:@"line"]) {
                    // Line send
                    [self sendLineAction];
                    break;
                }else if ([[sheetSorting objectAtIndex:buttonIndex] isEqualToString:@"urlcopy"]) {
                    // URLをコピー
                    [self urlCopyAction];
                    break;
                }else if ([[sheetSorting safeObjectAtIndex:buttonIndex] isEqualToString:@"alert"]) {
                    // 通報メール処理
                    [self sendAlertMail];
                    break;
                }
                break;
            case 2:
                if ([[sheetSorting safeObjectAtIndex:buttonIndex] isEqualToString:@"line"]) {
                    // Line send
                    [self sendLineAction];
                    break;
                }else if ([[sheetSorting safeObjectAtIndex:buttonIndex] isEqualToString:@"urlcopy"]) {
                    // URLをコピー
                    [self urlCopyAction];
                    break;
                }else if ([[sheetSorting safeObjectAtIndex:buttonIndex] isEqualToString:@"alert"]) {
                    // 通報メール処理
                    [self sendAlertMail];
                    break;
                }
                break;
            case 3:
                if ([[sheetSorting safeObjectAtIndex:buttonIndex] isEqualToString:@"urlcopy"]) {
                    // URLをコピー
                    [self urlCopyAction];
                    break;
                }else if([[sheetSorting safeObjectAtIndex:buttonIndex] isEqualToString:@"alert"]) {
                    // 通報メール処理
                    [self sendAlertMail];
                    break;
                }
            case 4:
                // 通報メール処理
                if([[sheetSorting safeObjectAtIndex:buttonIndex] isEqualToString:@"alert"]) {
                    // 通報メール処理
                    [self sendAlertMail];
                    break;
                }
                break;

        }
    }else if(actionSheet.tag == 1){
        // コメント送信
        switch (buttonIndex) {
            case 0:
                // コメント送信
                [self commentSend];
                break;
        }
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // cancelボタンが押された時の処理
            [self cancelButtonPushed];
            break;
        case 1:
            // otherボタンが押されたときの処理
            [self otherButtonPushed];
            break;
    }
}

- (void)cancelButtonPushed {}
- (void)otherButtonPushed
{
    DLog("delete Action !");
    
    //削除アクション後に投稿を再読み込みするために用意
    ProfileViewController * rootView = self.NavigationController.viewControllers[0];
    
    [[PostClient sharedClient] deletePost:[self.post.postID stringValue] aToken:[Configuration loadAccessToken] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [rootView refreshPosts:YES sortedFlg:YES];
        [self.NavigationController popToRootViewControllerAnimated:YES];
        
        //メッセージ
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgDoActionPostDeleteComp", nil)];
        
    } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
        //operation.
        NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
        DLog(@"body==%@¥n", responseBody);
        DLog(@"result==%@¥n",resultCode);
        
        
        [self.NavigationController popToRootViewControllerAnimated:YES];
        
        //メッセージ
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgDoActionPostDeleteFaild", nil)];
    }];
    
   
}

-(void)postUpdateAction{
    PostUpdateViewController *postUpdateViewController = [[PostUpdateViewController alloc] initWithPost:self.post];
    [self.NavigationController pushViewController:postUpdateViewController animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [_stretchableTableHeaderView scrollViewDidScroll:scrollView];
    
}

///「プロ」を出す
- (void)showProBtn {
    [self.detailUserCell.proBtn setHidden:NO];
}

///「プロ」を隠す
- (void)hideProBtn {
    [self.detailUserCell.proBtn setHidden:YES];
}

///メッセージボタンが押された時の処理
- (void)openMsg:(UIButton *)sender {
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
    [messageViewController setUserId:self.myChatToken];
    messageViewController.userImageUrl = self.myIconPath;
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENMESSAGE]
                         properties:@{DEFINES_REPROEVENTPROPNAME[SENDER] : [Configuration loadUserPid],
                                      DEFINES_REPROEVENTPROPNAME[RECEIVER] : self.post.userPID, }];
    
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

//メッセージを開けるならYES
- (BOOL)canOpenMsg {
    return (self.userChatToken         &&
            self.myChatToken           &&
            self.userID                &&
            [Configuration loadUserId] &&
            self.userIconPath          &&
            self.myIconPath);
}

///メッセージを開くのに必要な変数をセットする
- (void)enableMsg {
    NSDictionary *vConfig = [ConfigLoader mixIn];
    [[UserManager sharedManager] getUserInfo:self.post.userPID
        block:^(NSNumber *result_code, User *user, NSMutableDictionary *responseBody, NSError *error) {
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

///メッセージボタンの表示・非表示を制御
- (void)controlMsgBtn{
    
    [self getUserAttr:self.post.userPID block:^(NSString *attr) {
        
        if ([self isLoggedin]) {
            
            [self getUserAttr:nil block:^(NSString *myattr) {
                if ([myattr isEqualToString:@"g"] && ![myattr isEqual:attr]) {
                    [self showMsgBtn];
                    [self shortenFollowBtn];
                    [self showProBtn];
                }else{
                    [self hideMsgBtn];
                    [self broadenFollowBtn];
                    [self hideProBtn];
                }
            }];
        }else if([attr isEqualToString:@"p"]){
            [self showMsgBtn];
            [self shortenFollowBtn];
            [self showProBtn];
        }else{
            [self hideMsgBtn];
            [self broadenFollowBtn];
            [self hideProBtn];
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

///メッセージボタンを隠す
- (void)hideMsgBtn{
    [self.detailUserCell.msgBtn setHidden:YES];
}

///メッセージボタンを出す
- (void)showMsgBtn{
    [self.detailUserCell.msgBtn setHidden:NO];
}

////ログインしていればYES
- (BOOL)isLoggedin {
    if ([Configuration loadAccessToken]) {
        return YES;
    }
    return NO;
}


///高さの制約を消す
- (void)clearHeight{
    UIView *sv = [self.detailUserCell.followBtn superview];
    for (NSLayoutConstraint *c in sv.constraints) {
        if (c.firstItem != self.detailUserCell.msgBtn &&
            c.firstAttribute == NSLayoutAttributeHeight) {
            [sv removeConstraint:c];
        }
    }
}
///上マージンの制約を消す
- (void)clearMTop{
    UIView *sv = [self.detailUserCell.followBtn superview];
    for (NSLayoutConstraint *c in sv.constraints) {
        if (c != self.detailUserCell.fmTop &&
            c.firstItem == self.detailUserCell.followBtn &&
            c.firstAttribute == NSLayoutAttributeTop) {
            [sv removeConstraint:c];
        }
    }
}

///フォローボタン高さを小さくする
- (void)shortenFollowBtn {
    [self clearHeight];
    UIView *sv = [self.detailUserCell.followBtn superview];
    [sv addConstraint:self.detailUserCell.fheight];
    if (self.detailUserCell.fmTop && self.detailUserCell.fmBottom) {
        [sv removeConstraint:self.detailUserCell.fmBottom];
        [sv removeConstraint:self.detailUserCell.fmTop];
    }
}

///フォローボタン高さを大きくする
- (void)broadenFollowBtn {
    [self clearHeight];
    [self clearMTop];
    UIView *sv = [self.detailUserCell.followBtn superview];
    if (self.detailUserCell.fmTop && self.detailUserCell.fmBottom &&
        ![sv.constraints containsObject:self.detailUserCell.fmTop] &&
        ![sv.constraints containsObject:self.detailUserCell.fmBottom]) {
        [sv addConstraint:self.detailUserCell.fmBottom];
        [sv addConstraint:self.detailUserCell.fmTop];
    }
}
///ホームに戻る場合にいいねを更新できるようにHomeViewを更新する
- (void)refleshHomePostsIfGoingToBackHome {
    UIViewController *prevView = self.navigationController.topViewController;
    HomeViewController *hvc = [self getDescendantOrBrotherHomeView:prevView];
    if ([self isMovingFromParentViewController]) {
        if (hvc) {
            [hvc refreshPosts:YES sortedFlg:NO];
        }else if ([prevView isKindOfClass:[ProfileViewController class]]){
            [(ProfileViewController *)prevView refreshPosts:YES sortedFlg:NO];
        }else if ([prevView isKindOfClass:[UserViewController class]]){
            [(UserViewController *)prevView refreshPosts:YES sortedFlg:NO];
        }
    }
}
///サブセットまたはナビゲーションにおける子供を再帰的に検索してあればHomeViewをかえす
- (HomeViewController *)getDescendantOrBrotherHomeView:(UIViewController *)ancestor{
    if ([ancestor isKindOfClass:[HomeViewController class]]) {
        return (HomeViewController *)ancestor;
    }
    for (UIViewController *v in ancestor.childViewControllers) {
        if ([v isKindOfClass:[HomeViewController class]]) {
            return (HomeViewController *)v;
        }else if (v.childViewControllers.count){
            return [self getDescendantOrBrotherHomeView:v];
        }
    }
    return nil;
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
                
                [self loadPost];
                [self loadComments:NO refreshFlg:YES];
                
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



#pragma mark - UIScrollViewDelegate

/* Scroll View のスクロール状態に合わせて */
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if([_indicator isAnimating]) {
        return;
    }
    
    // offset は表示領域の上端なので, 下端にするため `tableView` の高さを付け足す. このとき 1.0 引くことであとで必ずセルのある座標になるようにしている.
    CGPoint offset = *targetContentOffset;
    offset.y += self.tableView.bounds.size.height - 1.0;
    // offset 位置のセルの `NSIndexPath`.
    //NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:offset];
    //if(indexPath.row >= self.rankingManager.populars.count - 1 && self.rankingManager.canLoadPopularMore){
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height) &&
       self.commentManager.canLoadCommentMore){
        
        [self startIndicator];
        
        NSNumber *post_id = self.postID;
        NSDictionary *params = @{ @"postID" : post_id, @"page" : @(self.commentManager.commentPage), };
        
        __weak typeof(self) weakSelf = self;
        [self.commentManager loadMoreCommentsWithParams:params block:^(NSMutableArray *comments, NSUInteger commentPage, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error) {
                DLog(@"error = %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }else{
                strongSelf.commentPage = commentPage;
                strongSelf.canLoadMore = strongSelf.commentManager.canLoadCommentMore;
                [strongSelf.tableView reloadData];
                
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
    indicatorFrame.origin.x = self.view.bounds.size.width / 2 - indicatorFrame.size.width / 2;
    indicatorFrame.origin.y = 0;
    indicatorFrame.size.height = 22.0;
    [_indicator setFrame:indicatorFrame];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 110)];
    footerView.backgroundColor = [UIColor clearColor];
    [footerView addSubview:_indicator];
    
    [self.tableView setTableFooterView:nil];
    [self.tableView setTableFooterView:footerView];
}


- (void)endIndicator
{
    [_indicator stopAnimating];
    [_indicator removeFromSuperview];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 110)];
    footerView.backgroundColor = [UIColor clearColor];
    [footerView addSubview:_indicator];
    
    [self.tableView setTableFooterView:nil];
    [self.tableView setTableFooterView:footerView];
}


@end
