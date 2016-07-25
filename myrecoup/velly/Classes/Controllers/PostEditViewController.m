//
//  PostEditViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostEditViewController.h"
#import "PostCategoryTableViewController.h"
#import "NaviViewController.h"
#import "HomeTabPagerViewController.h"
#import "PostManager.h"
#import "UserManager.h"
#import "TrackingManager.h"
#import "AMTumblrHud.h"
#import "NSString+Validation.h"
#import "NSObject+Validation.h"
#import "SVProgressHUD.h"
#import "MasterManager.h"
#import "ConfigLoader.h"
#import "CommonUtil.h"
#import "STTwitter.h"
#import "Defines.h"
#import "PostClient.h"
#import "PostChildCategoryTableViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PostEditViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) STTwitterAPI *twitter;

@end

@implementation PostEditViewController

- (id) initWithPostImage:(UIImage *)t_postImage {
    
    if(!self) {
        self = [[PostEditViewController alloc] init];
    }
    
    self.cameraImage = t_postImage;
    [self fixCameraImageOrientation];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitleView:[CommonUtil getNaviTitle:NSLocalizedString(@"NavTabPost", nil)]];
    
    // 背景色
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    // ナビゲーションタイトル色
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    // ナビゲーションボタン色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // ナビゲーション背景色
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.950 green:0.950 blue:0.950 alpha:0.950];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        //[self.navigationController.navigationBar setBarTintColor:NAVBAR_BACKGROUNDCOLOR];
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    else {
        // ios6
        //[self.navigationController.navigationBar setTintColor:NAVBAR_BACKGROUNDCOLOR];
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
        
    }
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    self.navigationController.navigationItem.backBarButtonItem = barButton;
    self.navigationItem.backBarButtonItem = barButton;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationController.navigationItem.backBarButtonItem = backItem;
    
    
    // uitextview delegate
    self.descripView.delegate = self;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //self.scrollView.frame = viewFrame;
    //self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.scrollView setFrame:self.view.frame];
    
    DLog(@"scrollview height : %f",self.scrollView.frame.size.height);
    //[self.scrollView sizeToFit];
    
    // キャプション
    _descripView.placeholder = NSLocalizedString(@"TFPHolderPostEditDescription", nil);
    _descripView.font = [UIFont systemFontOfSize:12];
    // セル項目名
    NSArray *postEditCell = [NSArray arrayWithObjects:
                                NSLocalizedString(@"PostSectionCategory", nil),
                                NSLocalizedString(@"PostSectionShare", nil),
                                NSLocalizedString(@"PostSectionTwitter", nil),
                                NSLocalizedString(@"PostSectionFacebook", nil), nil];
    _dataSource = postEditCell;
    
    int imageW = self.cameraImage.size.width;
    int imageH = self.cameraImage.size.height;
    float scale = self.postThumbImageView.frame.size.width / imageW;
    
    CGRect postThumbImageFrame = self.postThumbImageView.frame;
    self.postThumbImageView.translatesAutoresizingMaskIntoConstraints = YES;
    postThumbImageFrame.size.width  = imageW * scale;
    postThumbImageFrame.size.height = imageH * scale;
    self.postThumbImageView.image = self.cameraImage;
    [self.postThumbImageView setFrame: postThumbImageFrame];
    
    self.postDataTimeLabel.hidden = YES;
    
    // action
    [self.postBtn addTarget:self action:@selector(postBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.categoryBtn addTarget:self action:@selector(categorySelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.childCategoryBtn addTarget:self
                              action:@selector(childCategorySelectAction:)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.twBtn addTarget:self action:@selector(twSendCheckAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fbBtn addTarget:self action:@selector(fbSendCheckAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //動画の場合
    if (self.isMovie && self.assetMaster) {
        
        self.socialSecView.hidden         = YES;
        self.twitterView.hidden           = YES;
        self.faceBookView.hidden          = YES;
        self.categoryBottomLineImg.hidden = NO;
        
        //ムービデータの準備
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        __block NSString *outputPath = [[path stringByAppendingPathComponent:@"test"] stringByAppendingPathExtension:@"mov"];
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:self.assetMaster presetName:AVAssetExportPresetHighestQuality];
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        session.outputFileType = AVFileTypeQuickTimeMovie;
        
        __weak __block id weak_self = self;
        [session exportAsynchronouslyWithCompletionHandler:^{
            NSData* assetData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:outputPath]];
            [weak_self removeFile:[NSURL fileURLWithPath:outputPath]];
            [weak_self setMovieData:assetData];
        }];
    }
    

    // 送信ボタン
    self.postBtn.enabled = NO;
    self.postBtn.backgroundColor = [UIColor lightGrayColor];
    //self.postBtn.enabled = YES;
    //self.postBtn.backgroundColor = [UIColor lightGrayColor];
    //self.postBtn.backgroundColor = INPUT_SEND_BTN_COLOR;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationController.navigationItem.backBarButtonItem = backItem;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"PostEdit"];
    
    // ソーシャル送信フラグ初期設定
    self.isSendTw = NO;
    self.isSendFb = NO;

    // ソーシャル連携状況
    NSString *twToken       = [Configuration loadTWAccessToken];
    NSString *twTokenSecret = [Configuration loadTWAccessTokenSecret];
    NSString *fbToken       = [Configuration loadFBAccessToken];
    DLog(@"tw %@",twToken);
    DLog(@"tws %@",twTokenSecret);
    DLog(@"fb %@",fbToken);

    if(![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0 &&
        ![twTokenSecret isKindOfClass:[NSNull class]] && [twTokenSecret length] > 0 ){
        self.twImageView.image = [UIImage imageNamed:@"ico_twitter_on.png"];
    }else{
        self.twImageView.image = [UIImage imageNamed:@"ico_twitter.png"];
        self.twBtn.enabled = NO;
    }
    if(![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0){
        self.fbImageView.image = [UIImage imageNamed:@"ico_facebook_on.png"];
    }else{
        self.fbImageView.image = [UIImage imageNamed:@"ico_facebook.png"];
        self.fbBtn.enabled = NO;
    }
    
    
    if([self.descripView.text length] == 0 && self.descrip){
        [self.descripView setText:self.descrip];
    }
    if(self.parent){
        // フィルタ画面、親カテゴリ選択画面からの戻り
        [self.categoryLabel setText:self.parent.label];
        
        if (self.child && ![self.parent isAncestorOf:self.child]) {
            //選択済みの子カテゴリの親でないカテゴリが再選択された時
            [self.childCategoryLabel setText:NSLocalizedString(@"childCategorySelect", nil)];
            self.child = nil;
        }
    }
    if (self.child) {
        // フィルタ画面、子カテゴリ選択画面からの戻り
        [self.childCategoryLabel setText:self.child.label];
    }
    if ([self canNotSelectChild]) {
        [self.childCategoryBtn setEnabled:NO];
        [self.childCategoryLabel setAlpha:0.5f];
        [self.icoChildCategoryImageView setAlpha:0.5f];
        [self.childSelectedImageView setAlpha:0.5f];
    }else{
        [self.childCategoryBtn setEnabled:YES];
        [self.childCategoryLabel setAlpha:1.0f];
        [self.icoChildCategoryImageView setAlpha:1.0f];
        [self.childSelectedImageView setAlpha:1.0f];
    }
    
    if(self.postEffectViewController.isSendTw) {
        // TW送信設定
        self.isSendTw = YES;
        self.twStatusImageView.image = [UIImage imageNamed:@"check_ok.png"];
    }
    if(self.postEffectViewController.isSendFb) {
        // FB送信設定
        self.isSendFb = YES;
        self.fbStatusImageView.image = [UIImage imageNamed:@"check_ok.png"];
    }
    [self checkInputData:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationController.navigationItem.backBarButtonItem = backItem;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fixCameraImageOrientation
{
    CGSize size = self.cameraImage.size;
    UIGraphicsBeginImageContext(size);
    [self.cameraImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    self.cameraImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (NSString *) checkInputData:(BOOL)noAlertCategory
{
    
    // category -> nocheck
    if(self.category){
        // permit send
        self.postBtn.enabled = YES;
        self.postBtn.backgroundColor = INPUT_SEND_BTN_COLOR;
        self.postEffectViewController.category = self.category;
        
    }else{
        // no send
        self.postBtn.enabled = NO;
        self.postBtn.backgroundColor = [UIColor lightGrayColor];
        if(!noAlertCategory){
            return NSLocalizedString(@"ValidatePostSelectCategory", nil);
        }
    }
    
    // 登録ボタンアクティブチェック
//    if( [self.descripView.text length] && self.categoryId ){
//        // ボタンアクティブ
//        self.postBtn.enabled = YES;
//        self.postBtn.backgroundColor = INPUT_SEND_BTN_COLOR;
//    }else{
//        // ボタン非アクティブ
//        self.postBtn.enabled = NO;
//        self.postBtn.backgroundColor = [UIColor lightGrayColor];
//    }
    
    __block NSUInteger inputCnt = 0;
    NSRange allGlyphs = [self.descripView.layoutManager glyphRangeForTextContainer:self.descripView.textContainer];
    [self.descripView.layoutManager enumerateLineFragmentsForGlyphRange:allGlyphs
                                                 usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop) {
                                                     inputCnt++;
                                                 }];
    DLog(@"count %lu",(unsigned long)inputCnt);
    
    if([self.descripView.text hasLength] && ![self.descripView.text validateMaxLength:150]){
        // 150 over error
        self.postBtn.enabled = NO;
        self.postBtn.backgroundColor = [UIColor lightGrayColor];
        return NSLocalizedString(@"ValidatePostMaxOverDescrip", nil);
    }else if(inputCnt > 5){
        // line 5 over error
        self.postBtn.enabled = NO;
        self.postBtn.backgroundColor = [UIColor lightGrayColor];
        return NSLocalizedString(@"ValidatePostLineMaxOverDescrip", nil);
    }else{
        if(self.postBtn.enabled){
            // active
            self.postBtn.enabled = YES;
            self.postBtn.backgroundColor = INPUT_SEND_BTN_COLOR;
        }
    }
    return nil;
}

#pragma mark custom method

///子供カテゴリを選択できなければYES
- (BOOL)canNotSelectChild{
    return (!self.parent || !self.parent.children.count);
}

///最終的に投稿するカテゴリを返す
- (Category_ *)category {
    _category = (self.child)? self.child : self.parent;
    return _category;
}

#pragma UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    DLog(@"PostEditView textViewDidEndEditing");
    
    NSString *errMsg = [self checkInputData:YES];
    if(errMsg != nil && [errMsg length] > 0){
        
        UIAlertView *alert = [[UIAlertView alloc]init];
        alert = [[UIAlertView alloc]
                 initWithTitle:errMsg message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    
    self.postEffectViewController.descrip = textView.text;
    
}

#pragma mark - Action Method

// カテゴリ選択アクション
- (void)categorySelectAction:(id)sender
{
    DLog(@"PostEditView categorySelectAction tapped.");

    PostCategoryTableViewController *postCatTableViewController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"PostCategoryTableViewController"];
    
    postCatTableViewController.postEditViewController = self;

    [self.navigationController pushViewController: postCatTableViewController animated:YES];
    
}

///「詳細カテゴリを選択」が押された時に呼ばれる
- (void)childCategorySelectAction:(UIButton *)sender
{
    PostChildCategoryTableViewController *pctv = [[PostChildCategoryTableViewController alloc]
                                                  initWithArgs:self
                                                  parent:self.parent];
    [self.navigationController pushViewController:pctv animated:YES];
}

// TW送信選択アクション
- (void)twSendCheckAction:(id)sender
{
    DLog(@"PostEditView twSendCheckAction tapped.");
    
    if(self.isSendTw) {
        // 送信選択解除
        self.isSendTw = NO;
        self.postEffectViewController.isSendTw = NO;
        self.twStatusImageView.image = [UIImage imageNamed:@"check_no.png"];
    }else{
        // 送信設定
        self.isSendTw = YES;
        self.postEffectViewController.isSendTw = YES;
        self.twStatusImageView.image = [UIImage imageNamed:@"check_ok.png"];
    }

}

// FB送信選択アクション
- (void)fbSendCheckAction:(id)sender
{
    DLog(@"PostEditView fbSendCheckAction tapped.");
    
    // test
    //[self sendFacebookShare:[NSNumber numberWithInt:1]];
    
    if(self.isSendFb) {
        // 送信選択解除
        self.isSendFb = NO;
        self.postEffectViewController.isSendFb = NO;
        self.fbStatusImageView.image = [UIImage imageNamed:@"check_no.png"];
    }else{
        // 送信設定
        self.isSendFb = YES;
        self.postEffectViewController.isSendFb = YES;
        self.fbStatusImageView.image = [UIImage imageNamed:@"check_ok.png"];
    }

}

- (void)backAction:(id)sender
{
    DLog(@"PostEditView backAction");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)postBtnAction:(id)sender
{
    DLog(@"PostEditView postBtnAction");
    
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS8

        // コントローラを生成
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MsgActionPostSend", nil)
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
        // 投稿アクションを生成
        UIAlertAction * postSendAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgDoActionPostSend", nil)
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   // ボタンタップ時の処理
                                   DLog(@"Post Send button tapped.");
                                   if (self.isMovie) {
                                       [self movieSendAction];
                                       return ;
                                   }
                                   // ライブラリ起動
                                   [self postSendAction];
                                   
                               }];

        // コントローラにアクションを追加
        [ac addAction:cancelAction];
        [ac addAction:postSendAction];
        
        // アクションシート表示処理
        [self presentViewController:ac animated:YES completion:nil];
        
        
    }else{
        // under iOS
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = NSLocalizedString(@"MsgActionPostSend", nil);
        [as addButtonWithTitle:NSLocalizedString(@"MsgDoActionPostSend", nil)];
        [as addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        //as.destructiveButtonIndex = 0;
        as.cancelButtonIndex = 1;
        as.tag = 0;
        [as showInView:self.view];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 0){
        // アイコン設定
        switch (buttonIndex) {
            case 0:
                // 投稿を送信
                [self postSendAction];
                break;
        }
    }
}

///動画送信アクション
- (void)movieSendAction {
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[MOVIESUBMIT]
                         properties:nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"body"]     = self.descripView.text;
    params[@"category"] = self.category.pk;
    
    NSData* pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation( self.cameraImage )];
    
    // icon
    NSString *postMimeType = nil;
    NSData *postData = nil;
    
    postData = self.Movie;
    CommonUtil *commonUtil = [[CommonUtil alloc] init];
    postMimeType = [commonUtil mimeTypeByGuessingFromData:postData];
    NSString *aToken = [Configuration loadAccessToken];
    
    // ---------------------
    // sending animation
    // ---------------------
    [self showSendingView];
    
    [[PostClient sharedClient] insertPostRegistMovie:params imageData:pngData movieData:postData imageName:@"test" mimeType:@"test" aToken:aToken success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *postID;
        if(responseObject[@"id"] && [responseObject[@"id"] isKindOfClass:[NSNumber class]]){
            postID = responseObject[@"id"];
        }
        
        UIWindow *window  = [UIApplication sharedApplication].keyWindow;
        NaviViewController *naviView = (NaviViewController *)window.rootViewController;
        UINavigationController *navi = window.rootViewController.childViewControllers[0];
        DLog(@"%@", navi.childViewControllers[0]);
        HomeTabPagerViewController *homeTabPagerViewController = (HomeTabPagerViewController *)navi.childViewControllers[0];
        
        naviView.tabBarController.selectedViewController = homeTabPagerViewController;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
                // 動画投稿画面を閉じる際の処理
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgDoActionPostSendComp", nil)];
                
                // ---------------------
                // sending animation delete
                // ---------------------
                [self removeSendingView];
                
            }];
        });
        
    } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
        
        //operation.
        NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
        DLog(@"body==%@¥n", responseBody);
        DLog(@"result==%@¥n",resultCode);
        
        UIWindow *window  = [UIApplication sharedApplication].keyWindow;
        NaviViewController *naviView = (NaviViewController *)window.rootViewController;
        UINavigationController *navi = window.rootViewController.childViewControllers[0];
        DLog(@"%@", navi.childViewControllers[0]);
        HomeTabPagerViewController *homeTabPagerViewController = (HomeTabPagerViewController *)navi.childViewControllers[0];
        
        naviView.tabBarController.selectedViewController = homeTabPagerViewController;
        [self dismissViewControllerAnimated:YES completion:^{
            // 動画投稿画面を閉じる際の処理
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgDoActionPostSendFaild", nil)];
            
            // ---------------------
            // sending animation delete
            // ---------------------
            [self removeSendingView];
        }];
    }];
}

- (void)postSendAction
{

    // ---------------------------------------
    // GA EVENT
    // ---------------------------------------
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapSubmit" value:nil screen:@"PostEdit"];
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[POSTSUBMIT]
                         properties:@{DEFINES_REPROEVENTPROPNAME[CATEGORY] : self.category.label,
                                      DEFINES_REPROEVENTPROPNAME[TYPE] : [self getPostSelectionType]}];
    
    // Loading
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingPostDisplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingCheck", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"body"]     = self.descripView.text;
    params[@"category"] = self.category.pk;
    params[@"share"]    = @"";  // array<string> tw fb
    if(self.isSendTw){
        params[@"share"] = [params[@"share"] stringByAppendingString:@"tw"];
    }
    if(self.isSendFb){
        if(params[@"share"]) params[@"share"] = [params[@"share"] stringByAppendingString:@","];
        params[@"share"] = [params[@"share"] stringByAppendingString:@"fb"];
    }
    // params[@"img"]

    // icon
    NSString *postMimeType = nil;
    NSString *postName = nil;
    NSData *postData = nil;
    if( self.cameraImage ) {
        //NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        //self.userIconImgView.image.
        postName = @"img";
        //            CGDataProviderRef imageDataProvider = CGImageGetDataProvider(self.userIconImgView.image.CGImage);
        //            iconData = (NSData*)CFBridgingRelease(CGDataProviderCopyData(imageDataProvider));
        postData = [[NSData alloc] initWithData:UIImagePNGRepresentation( self.cameraImage )];
        CommonUtil *commonUtil = [[CommonUtil alloc] init];
        postMimeType = [commonUtil mimeTypeByGuessingFromData:postData];
    }
    

//// test
//// -------------
//    NSNumber *testPostID = [NSNumber numberWithInt:1021];
//    if(self.isSendFb && [testPostID isKindOfClass:[NSNumber class]]){
//        [self sendFacebookShare:testPostID];
//    }
//    return;
    

    NSInteger *mySettingImgSave = [Configuration loadSettingPostSave];
    if(mySettingImgSave && mySettingImgSave == (NSInteger *)VLISACTIVEDOIT){
        // -------------------
        // save post image
        // -------------------
        if([self isPhotoAccessEnableWithIsShowAlert:NO]){
            [self saveImageToPhotosAlbum:self.cameraImage];
        }
    }

    // ---------------------
    // sending animation
    // ---------------------
    [self showSendingView];

    NSString *aToken = [Configuration loadAccessToken];
    
    [[PostManager sharedManager] insertPostRegist:params imageData:(NSData *)postData imageName:(NSString *)postName mimeType:(NSString *)postMimeType aToken:aToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSNumber *postID, NSError *error){
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        
        if(error){
            // error
            
            // ---------------------
            // sending animation delete
            // ---------------------
            [self removeSendingView];

            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgDoActionPostSendFaild", nil)];
//            UIAlertView *alert = [[UIAlertView alloc]init];
//            alert = [[UIAlertView alloc]
//                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//            [alert show];
        }else{

            // --------------------
            // send social
            // --------------------
            if(self.isSendTw && [postID isKindOfClass:[NSNumber class]]){
                [self sendTwitterTweet:postID];
            }
            if(self.isSendFb && [postID isKindOfClass:[NSNumber class]]){
                [self sendFacebookShare:postID];
            }
            
            // move Home and Post init
        
            UIWindow *window  = [UIApplication sharedApplication].keyWindow;
            NaviViewController *naviView = (NaviViewController *)window.rootViewController;
            UINavigationController *navi = window.rootViewController.childViewControllers[0];
            DLog(@"%@", navi.childViewControllers[0]);
            HomeTabPagerViewController *homeTabPagerViewController = (HomeTabPagerViewController *)navi.childViewControllers[0];
        
            naviView.tabBarController.selectedViewController = homeTabPagerViewController;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                if (self.postEffectViewController.wasPostSelectFromLibraryView) {
                //ライブラリから直接選択した場合は　星消す->rootviewへ->メッセージの順
                    // ---------------------
                    // sending animation delete
                    // ---------------------
                    [self removeSendingView];
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    [APP_DELEGATE_FUNC showTabBar:^{
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgDoActionPostSendComp", nil)];
                    }];
                    return ;
                }
                [self dismissViewControllerAnimated:YES completion:^{
                    // 動画投稿画面を閉じる際の処理
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgDoActionPostSendComp", nil)];
                    
                    // ---------------------
                    // sending animation delete
                    // ---------------------
                    [self removeSendingView];
                }];

            });
            
        }
    }];
    
}

- (void)showSendingView {
    UIView *loadingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    loadingView.backgroundColor = [UIColor blackColor];        // UIColorFromRGB(0x34465C);
    loadingView.alpha = 0.7f;
    AMTumblrHud *tumblrHUD = [[AMTumblrHud alloc] initWithFrame:CGRectMake(
                                                                           (CGFloat) ((self.view.frame.size.width - 55) * 0.5),
                                                                           (CGFloat) ((self.view.frame.size.height - 20) * 0.5), 55, 20)];
    //tumblrHUD.hudColor = UIColorFromRGB(0xF1F2F3);//[UIColor magentaColor];
    tumblrHUD.hudColor = [UIColor clearColor];//[UIColor magentaColor];
    
    [loadingView addSubview:tumblrHUD];
    [self.navigationController.view addSubview:loadingView];
    [tumblrHUD showAnimated:YES];
}

///投稿中のアニメーションを削除
- (void)removeSendingView {
    for (UIView *v in [self.navigationController.view subviews]) {
        if([v isKindOfClass:[UIView class]]){
            for(UIView *suv in v.subviews){
                if([suv isKindOfClass:[AMTumblrHud class]]){
                    DLog(@"%@", v);
                    [v removeFromSuperview];
                    [suv removeFromSuperview];
                }
            }
        }
    }
}

// ----------------
// Twitter Tweet
// ----------------
-(void)sendTwitterTweet:(NSNumber *)postID
{
    DLog(@"PostEditView Twitter Tweet");
    
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
    postUrlReplace = [postUrl stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[postID stringValue]];
    NSString *tweetBody = NSLocalizedString(@"MsgPostTwitterTweetBody", nil);
    // <?post_url>
    tweetBody = [tweetBody stringByReplacingOccurrencesOfString:@"<?post_url>" withString:postUrlReplace];
    
    // self.descrip
    int postDescripCnt = 139 - (int)[tweetBody length];
    NSString *tweetMessage;
    if(postDescripCnt > 5 && [self.descripView.text length] > 0){
        NSString *tweetPostDescrip = self.descripView.text;
        if([self.descripView.text length] > postDescripCnt){
            tweetPostDescrip = [self.descripView.text substringFromIndex:postDescripCnt];
        }
        tweetPostDescrip = [tweetPostDescrip stringByAppendingString:@" "];
        if([self.descripView.text length] > postDescripCnt){
            tweetPostDescrip = [tweetPostDescrip stringByAppendingString:@"... "];
        }
        tweetMessage = [tweetPostDescrip stringByAppendingString:tweetBody];
    }else{
        tweetMessage = tweetBody;
    }
    
    // post_descrip + post_url + @myrecome #myreco
    
    [self.twitter postStatusUpdate:tweetMessage
                 inReplyToStatusID:nil
                          latitude:nil
                         longitude:nil
                           placeID:nil
                displayCoordinates:nil
                          trimUser:nil
                      successBlock:^(NSDictionary *status) {
                          // ...
                          DLog(@"sucess %@", status);
                          
//                          UIAlertView *alert = [[UIAlertView alloc] init];
//                          alert = [[UIAlertView alloc]
//                                   initWithTitle:NSLocalizedString(@"MsgDoActionTwitterTweeted", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//                          [alert show];
                          
                      } errorBlock:^(NSError *error) {
                          // ...
                          DLog(@"failed %@", error);
                          
//                          UIAlertView *alert = [[UIAlertView alloc] init];
//                          alert = [[UIAlertView alloc]
//                                   initWithTitle:NSLocalizedString(@"MsgDoActionTwitterTweetFaild", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//                          [alert show];
                          
                      }];
    
}



// ----------------
// Facebook Share
// ----------------
-(void)sendFacebookShare:(NSNumber *)postID
{
    DLog(@"PostEditView Facebook Share");
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *postUrl = vConfig[@"WebViewURLPost"];
    NSString *postUrlReplace = postUrl;
    // <?post_pk>
    postUrlReplace = [postUrl stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[postID stringValue]];
    
    NSString *facebookTitle = NSLocalizedString(@"MsgPostFacebookShareTitle", nil);
    NSString *facebookBody = self.descripView.text;
    facebookBody = [facebookBody stringByAppendingString:@" "];
    facebookBody = [facebookBody stringByAppendingString:postUrlReplace];
    
    FBSDKShareLinkContent *shareContent = [[FBSDKShareLinkContent alloc] init];
    [shareContent setContentURL:[NSURL URLWithString:postUrlReplace]];
    [shareContent setContentTitle:facebookTitle];
    [shareContent setContentDescription:facebookBody];
    //[shareContent setImageURL:[NSURL URLWithString:@""]];

    NSString *fbToken = [Configuration loadFBAccessToken];

    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/feed", @"975109712534406"]];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/feed", @"975109712534406"]];
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
    
    NSMutableURLRequest *urlReq = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *body = [NSString stringWithFormat:@"access_token=%@&message=%@&link=%@", fbToken, facebookBody, postUrlReplace];
    urlReq.HTTPMethod = @"POST";
    urlReq.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    DLog(@"urlReq : %@", urlReq);
    [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            DLog(@"connectionError %@", connectionError);
            DLog(@"response %@", response);
            DLog(@"data %@", data);
        }
        DLog(@"connectionError %@", connectionError);
        DLog(@"response %@", response);
        DLog(@"data %@", data);
        
    }];
    
//    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
//        [[[FBSDKGraphRequest alloc]
//          initWithGraphPath:@"me/feed"
//          parameters: @{ @"message" : @"hello world"}
//          HTTPMethod:@"POST"]
//         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//             if (!error) {
//                 NSLog(@"Post id:%@", result[@"id"]);
//             }
//         }];
//    }

}



- (BOOL)isPhotoAccessEnableWithIsShowAlert:(BOOL)_isShowAlert {
    // このアプリの写真への認証状態を取得する
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    BOOL isAuthorization = NO;
    switch (status) {
        case ALAuthorizationStatusAuthorized: // 写真へのアクセスが許可されている
            isAuthorization = YES;
            break;
        case ALAuthorizationStatusNotDetermined: // 写真へのアクセスを許可するか選択されていない
            isAuthorization = YES; // 許可されるかわからないがYESにしておく
            break;
        case ALAuthorizationStatusRestricted: // 設定 > 一般 > 機能制限で利用が制限されている
        {
            isAuthorization = NO;
            if (_isShowAlert) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:NSLocalizedString(@"Error", nil)
                                          message:NSLocalizedString(@"ValidatePostSaveAlbumRestricted", nil)
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
            break;
        case ALAuthorizationStatusDenied: // 設定 > プライバシー > 写真で利用が制限されている
        {
            isAuthorization = NO;
            if (_isShowAlert) {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:NSLocalizedString(@"Error", nil)
                                          message:NSLocalizedString(@"ValidatePostSaveAlbumDenied", nil)
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
            break;
        default:
            break;
    }
    return isAuthorization;
}

- (void)saveImageToPhotosAlbum:(UIImage*)_image {
    BOOL isPhotoAccessEnable = [self isPhotoAccessEnableWithIsShowAlert:NO];
    /////// Photo Save ///////
    if (isPhotoAccessEnable) {
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:_image.CGImage
                                  orientation:(ALAssetOrientation)_image.imageOrientation
                              completionBlock:
         ^(NSURL *assetURL, NSError *error){
             
             DLog(@"URL:%@", assetURL);
             DLog(@"error:%@", error);
             
//             ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
//             if (status == ALAuthorizationStatusDenied) {
//                 UIAlertView *alertView = [[UIAlertView alloc]
//                                           initWithTitle:@"エラー"
//                                           message:@"写真へのアクセスが許可されていません。\n設定 > 一般 > 機能制限で許可してください。"
//                                           delegate:nil
//                                           cancelButtonTitle:@"OK"
//                                           otherButtonTitles:nil];
//                 [alertView show];
//             } else {
//                 UIAlertView *alertView = [[UIAlertView alloc]
//                                           initWithTitle:@""
//                                           message:@"フォトアルバムへ保存しました。"
//                                           delegate:nil
//                                           cancelButtonTitle:@"OK"
//                                           otherButtonTitles:nil];
//                 [alertView show];
//             }

         }];
    }
}

///どのタイプ(最初のアクションシートでの「写真をとる」「ライブラリから選択」)かを返す
- (NSNumber * )getPostSelectionType {
    NSNumber * type;
    if (self.postEffectViewController.wasPostSelectFromLibraryView) {
        type = [NSNumber numberWithInteger:LIBRARY];
    }else {
        type = [NSNumber numberWithInteger:TAKEAPHOTO];
    }
    return type;
}

- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
    }
}

-(void)setMovieData:(NSData*)data{
    
    self.Movie = data;
    
}
@end
