//
//  RegistInputViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/05.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RegistInputViewController.h"
#import "CommonUtil.h"
#import "CoreImageHelper.h"
#import "NSString+Validation.h"
#import "NSObject+Validation.h"
#import "UserManager.h"
#import "SVProgressHUD.h"
#import "UIImage+Utility.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "AMTumblrHud.h"
#import "Defines.h"
#import "PopularViewController.h"
#import "Ranking.h"
#import "FollowManager.h"
#import "MasterManager.h"

@interface RegistInputViewController () <UIImagePickerControllerDelegate>


@property (strong, nonatomic) IBOutlet UIImageView *userIconPlusImgView;
@property (strong, nonatomic) IBOutlet UIButton *editPhotoBtn;
@property (strong, nonatomic) IBOutlet UIImageView *ckNameImgView;
@property (strong, nonatomic) IBOutlet UIImageView *ckMailImgView;
@property (strong, nonatomic) IBOutlet UIImageView *ckIdImgView;
@property (strong, nonatomic) IBOutlet UIImageView *ckPasswdImgView;
@property (strong, nonatomic) IBOutlet UIButton *policyLinkBtn;
@property (strong, nonatomic) IBOutlet UIButton *policyBtn;
@property NSNumber *checkPolicy;
@property BOOL isInvalidEmail;
@property BOOL isIcon;
@property BOOL isSending;
@property BOOL isSettingIcon;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation RegistInputViewController

@synthesize emailTextField;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:NO animated:NO];

    // ナビゲーションタイトル
    self.navigationItem.titleView = [CommonUtil getNaviTitle:NSLocalizedString(@"PageRegistInput", nil)];
    
    // ナビゲーション背景色
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    else {
        // ios6
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }

    // 戻るボタン
    [self.navigationItem setBackBarButtonItem:[CommonUtil getBackNaviBtn]];
    [(UIButton *)self.navigationItem.backBarButtonItem.customView
     addTarget:self
     action:@selector(backAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:self.navigationItem.backBarButtonItem];
    
    // 写真編集ボタン
    [_editPhotoBtn addTarget:self action:@selector(editPhotoAction:) forControlEvents:UIControlEventTouchUpInside];

    // ナビゲーションバー表示
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[self.navigationController setToolbarHidden:YES animated:YES];
    
    // TODO 何故か上が空く
    //self.navigationController.view.frame = CGRectMake(0, -20.0f, self.view.frame.size.width, self.view.frame.size.height);

    // メールアドレス重複 : default : NO (重複していない)
    self.isInvalidEmail = NO;
    
    // 入力チェックマーク非表示
    _ckNameImgView.hidden   = YES;
    _ckMailImgView.hidden   = YES;
    _ckIdImgView.hidden     = YES;
    _ckPasswdImgView.hidden = YES;
    
    // 利用規約
    _checkPolicy = [NSNumber numberWithInt:0];
    
    // スクロール可能へ
    //self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 598);
    self.scrollView.scrollEnabled = YES;
    
    // アイコン カメラ・ライブラリ起動フラグ
    self.isSettingIcon = NO;
    
    
    // 登録ボタン
    [self.submitBtn addTarget:self action:@selector(RegistSubmitAction) forControlEvents:UIControlEventTouchUpInside];

    // 前の画面からの値をセット
    // メールアドレスフォーム
//    emailTextField.layer.borderColor = [[UIColor clearColor]CGColor];
//    emailTextField.layer.borderWidth = 0.0f;
//    emailTextField.borderStyle = UITextBorderStyleNone;
//    _usernameTextField.layer.borderColor = [[UIColor clearColor]CGColor];
//    _usernameTextField.layer.borderWidth = 0.0f;
//    _usernameTextField.borderStyle = UITextBorderStyleNone;
    
    emailTextField.keyboardType     = UIKeyboardTypeEmailAddress;       // UIKeyboardTypeASCIICapable
    _usernameTextField.keyboardType = UIKeyboardAppearanceDefault;
    _userIdTextField.keyboardType   = UIKeyboardTypeAlphabet;
    _passwdTextField.keyboardType   = UIKeyboardTypeAlphabet;
    [_passwdTextField setSecureTextEntry:YES];
    [self checkInputData:YES];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isIcon = NO;
    self.isSending = NO;
    UIImage *socialImage = self.socialImg;
    if(socialImage && !self.isSettingIcon){
        
        //CGFloat minSize = (socialImage.size.width > socialImage.size.height) ? socialImage.size.height : socialImage.size.width;
        //[CoreImageHelper centerCroppingImageWithImage:socialImage atSize:CGSizeMake(100.f, 100.f) completion:^(UIImage *resultImg){
        //[CoreImageHelper centerCroppingImageWithImage:socialImage atSize:CGSizeMake(minSize, minSize) completion:^(UIImage *resultImg){
            // 画像を丸く
            CommonUtil *commonUtil = [[CommonUtil alloc] init];
            CGSize cgSize = CGSizeMake(100.0f, 100.0f);
            CGSize radiusSize = CGSizeMake(50.0f, 50.0f);
            UIImage *iconEditImage = [commonUtil createRoundedRectImage:socialImage size:cgSize radiusSize: radiusSize];
            
            CGRect imageFrame = self.userIconImgView.frame;
            //[self.userIconImgView setImage:iconEditImage];
            self.userIconImgView.image = iconEditImage;
            self.userIconImgView.frame = imageFrame;
            [self.userIconImgView sizeToFit];
            
            self.userIconPlusImgView.hidden = YES;
            self.isIcon = YES;
            
            self.socialImg = nil;
        //}];
    }
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"SignupInput"];
}

-(void)viewDidLayoutSubviews {
    //[self.scrollView setContentSize: self.contentView.bounds.size];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 598);
    [self.scrollView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) checkInputData:(BOOL)initFlg
{
    if(initFlg){
        // ---------------------
        // メールアドレス
        // ---------------------
        if([_inputEmail length]){
            self.emailTextField.text = _inputEmail;
            self.ckMailImgView.hidden = NO;
        }
        // ---------------------
        // ニックネーム
        // ---------------------
        if([_inputUserName length]){
            
            // 10文字以上の場合には、文字きり
            if([_inputUserName length] > 10){
                _inputUserName = [_inputUserName substringToIndex:10];
            }
            self.usernameTextField.text = _inputUserName;
            self.ckNameImgView.hidden = NO;
        }
        // ---------------------
        // ユーザID
        // ---------------------
        if([_inputUserId length]){
            
            // 30文字以上の場合には、文字きり
            if([_inputUserId length] > 30){
                _inputUserId = [_inputUserId substringToIndex:30];
                // substringWithRange:NSMakeRange(0,30)]
            }
            self.userIdTextField.text = _inputUserId;
            self.ckIdImgView.hidden = NO;
            
        }
    }
    
    // 登録ボタンアクティブチェック
    if( [self.usernameTextField.text hasLength] && [self.usernameTextField.text validateMaxLength:10] &&
        [self.emailTextField.text hasLength] && [self.emailTextField.text validateMaxLength:250] &&
        [self.userIdTextField.text hasLength] && [self.userIdTextField.text validateMaxLength:30] &&
        [self.passwdTextField.text hasLength] && [self.passwdTextField.text validateMinMaxLength:8 maxLength:16] &&
        self.checkPolicy == [NSNumber numberWithInt:1] &&
        self.userIconImgView.image &&
        !self.isInvalidEmail ){
        // ボタンアクティブ
        [self activeSubmit];
    }else{
        // ボタン非アクティブ
        [self noActiveSubmit];
    }
    
    // social対応 処理チェック
    if(initFlg){
        // ---------------------
        // メールアドレス
        // ---------------------
        if([_inputEmail length]){
            // メールアドレス重複チェック
            // Loading
            NSDictionary *vConfig   = [ConfigLoader mixIn];
            NSString *isLoding = vConfig[@"LoadingPostDisplay"];
            if( isLoding && [isLoding boolValue] == YES ){
                // Loading
                [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingCheck", nil) maskType:SVProgressHUDMaskTypeBlack];
            }
            [[UserManager sharedManager] checkUserEmail:self.emailTextField.text user_id:nil block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
                
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                if(result_code.longLongValue == API_CHECK_EMAIL_RESPONSE_CODE_ERROR_INVALID.longLongValue){
                    // exist email error
                    
                    self.isInvalidEmail = YES;
                    _ckMailImgView.hidden = YES;
                    [self noActiveSubmit];
                    
                    UIAlertView *alert = [[UIAlertView alloc]init];
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiCautionRegistCheckExist", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }else if(result_code.longLongValue == API_CHECK_EMAIL_RESPONSE_CODE_SUCCESS.longLongValue){
                    // no exist email -> ok
                    
                    self.isInvalidEmail = NO;
                    _ckMailImgView.hidden = NO;
                    
                }else{
                    // error
                    DLog(@"error = %@", error);
                }
            }];
        }
    }
}

- (void) activeSubmit
{
    // ボタンアクティブ
    self.submitBtn.enabled = YES;
    self.submitBtn.backgroundColor = INPUT_SEND_BTN_COLOR;
}

- (void) noActiveSubmit
{
    // ボタン非アクティブ
    self.submitBtn.enabled = NO;
    self.submitBtn.backgroundColor = [UIColor lightGrayColor];
}

- (void) backAction: (UIButton *)button
{
    DLog(@"RegistIntroductionView backAction");
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)policyAction:(id)sender {

    // ---------------------------------------
    // GA EVENT
    // ---------------------------------------
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapPolicy" value:nil screen:@"SignupInput"];

    NSComparisonResult result;
    result = [_checkPolicy compare:[NSNumber numberWithInt:0]];
    switch(result) {
        case NSOrderedSame: // 一致 : 未同意
        case NSOrderedAscending: // 謎パターン： 未同意
            [self.policyBtn setImage:[UIImage imageNamed:@"icon_signup_checkbox_checked.png"] forState:UIControlStateNormal];
            _checkPolicy = [NSNumber numberWithInt:1];
            break;
        case NSOrderedDescending: // 同意
            [self.policyBtn setImage:[UIImage imageNamed:@"icon_signup_checkbox_nocheck.png"] forState:UIControlStateNormal];
            _checkPolicy = [NSNumber numberWithInt:0];
            break;
    }
    [self checkInputData:NO];
}

// ユーザアイコン設定
- (void) editPhotoAction:(id)sender {

    // ---------------------------------------
    // GA EVENT
    // ---------------------------------------
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapIcon" value:nil screen:@"SignupInput"];

    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS8

        // コントローラを生成
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MsgActionIconSettingTitle", nil)
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
        //[[UIAlertController alloc] preferredStyle:UIAlertControllerStyleActionSheet]:
    
        // Cancel用のアクションを生成
        UIAlertAction * cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * action) {
                               // ボタンタップ時の処理
                               DLog(@"Cancel button tapped.");
                               
                               
                           }];
        // アルバムから読み込み用のアクションを生成
        UIAlertAction * libraryAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgActionIconLib", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               // ボタンタップ時の処理
                               NSLog(@"Library button tapped.");
                               
                               [self cameraLibraryAction];
                               
                           }];
        // カメラ撮影用のアクションを生成
        UIAlertAction * cameraAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgActionIconCamera", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               // ボタンタップ時の処理
                               NSLog(@"Camera button tapped.");
                               
                               [self cameraPhotoAction];
                               
                           }];
        // コントローラにアクションを追加
        [ac addAction:cancelAction];
        [ac addAction:libraryAction];
        [ac addAction:cameraAction];
    
        // アクションシート表示処理
        [self presentViewController:ac animated:YES completion:nil];
        
    }else{
        // under iOS
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = NSLocalizedString(@"MsgActionIconSettingTitle", nil);
        [as addButtonWithTitle:NSLocalizedString(@"MsgActionIconLib", nil)];
        [as addButtonWithTitle:NSLocalizedString(@"MsgActionIconCamera", nil)];
        [as addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        //as.destructiveButtonIndex = 0;
        as.cancelButtonIndex = 2;
        as.tag = 0;
        [as showInView:self.view];
    }
        
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 0){
        // アイコン設定
        switch (buttonIndex) {
            case 0:
                // アルバムから読み込む
                [self cameraLibraryAction];
                break;
            case 1:
                // カメラで撮影する
                [self cameraPhotoAction];
                break;
        }
    }
}


- (void) cameraLibraryAction
{
    // ライブラリ起動
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        self.isSettingIcon = YES;
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [imagePickerController setAllowsEditing:YES];
        imagePickerController.delegate = self;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
    }
}

- (void) cameraPhotoAction
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // カメラ対応不可端末
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"RegistUserPhotoNotCamera", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        
        [alert show];
    } else {
        
        self.isSettingIcon = YES;
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        [imagePickerController takePicture];
        
    }
}


// ImagePicker 画像選択時
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //画像が選択されたとき。オリジナル画像をUIImageViewに突っ込む
    UIImage *origImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *editImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    
    UIImage *pickImage = nil;
    if(editImage){
        pickImage = [editImage deepCopy];
    }else{
        pickImage = [origImage deepCopy];
    }
    
    // resize
//    [UIImage resizeAspectFitImageWithImage:img atSize:200.f completion:^(UIImage *resultImg){
//        self.imageView.image = resultImg;
//        [self.imageView sizeToFit];
//    }];
    // trming
//    [UIImage centerCroppingImageWithImage:img atSize:CGSizeMake(300.f, 300.f) completion:^(UIImage *resultImg){
//        self.imageView.image = resultImg;
//        [self.imageView sizeToFit];
//    }];
    // background resize
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [UIImage resizeAspectFitImageWithImage:img atSize:200.f completion:^(UIImage *resultImg){
//            self.imageView.image = resultImg;
//            [self.imageView sizeToFit];
//        }];
//    });

    if(pickImage){

        CGFloat minSize = (pickImage.size.width > pickImage.size.height) ? pickImage.size.height : pickImage.size.width;
        //[CoreImageHelper centerCroppingImageWithImage:pickImage atSize:CGSizeMake(100.f, 100.f) completion:^(UIImage *resultImg){
        [CoreImageHelper centerCroppingImageWithImage:pickImage atSize:CGSizeMake(minSize, minSize) completion:^(UIImage *resultImg){
            // 画像を丸く
            CommonUtil *commonUtil = [[CommonUtil alloc] init];
            CGSize cgSize = CGSizeMake(100.0f, 100.0f);
            CGSize radiusSize = CGSizeMake(50.0f, 50.0f);
            UIImage *iconEditImage = [commonUtil createRoundedRectImage:pickImage size:cgSize radiusSize: radiusSize];
            //UIImage *iconEditImage = pickImage;
            
            DLog(@"icon size %f", self.userIconImgView.frame.size.width);
            
            CGRect imageFrame = self.userIconImgView.frame;
            self.userIconImgView.image = nil;
            self.userIconImgView.image = iconEditImage;
            self.userIconImgView.frame = imageFrame;
            [self.userIconImgView sizeToFit];
            
            DLog(@"icon size %f", self.userIconImgView.frame.size.width);
            
            self.userIconPlusImgView.hidden = YES;
            self.isIcon = YES;
            
            //self.socialImg = pickImage;
            self.isSettingIcon = NO;
        }];
    }else{
        self.isSettingIcon = NO;
    }
    
//    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
//    {
//        // カメラから呼ばれた場合は画像をフォトライブラリに保存してViewControllerを閉じる
//        UIImageWriteToSavedPhotosAlbum(pickImage, nil, nil, nil);
//    }
    
    
//    // オリジナル画像サイズ
//    int imageW = image.size.width;
//    int imageH = image.size.height;
//    // リサイズする倍率を作成する。
//    float scale = (imageW > imageH ? 200.0f/imageH : 200.0f/imageW);
//    // 比率に合わせてリサイズする。
//    CGSize resizedSize = CGSizeMake(imageW * scale, imageH * scale);
//    UIGraphicsBeginImageContext(resizedSize);
//    [image drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
//    UIImage *origImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
////    //サムネイル画像の作成
////    CGFloat imageWidth = 200;   //リサイズ後の幅のサイズ
////    CGFloat imageHeight= 200;   //リサイズ後の縦のサイズ
////    //リサイズする大きさを設定
////    UIGraphicsBeginImageContext(CGSizeMake(imageWidth,imageHeight));
////    //上記の領域の何処にどの大きさで表示するかを指定
////    [image drawInRect:CGRectMake(0, 0, imageWidth, imageHeight)];
////    //originalImageに上記で設定した画像を格納する。
////    UIImage *origImage = UIGraphicsGetImageFromCurrentImageContext();
////    //編集終了
////    UIGraphicsEndImageContext();
//    
//    if (origImage) {
//        
//        // 画像を丸く
//        CommonUtil *commonUtil = [[CommonUtil alloc] init];
//        CGSize cgSize = CGSizeMake(100.0f, 100.0f);
//        CGSize radiusSize = CGSizeMake(50.0f, 50.0f);
//        UIImage *iconEditImage = [commonUtil createRoundedRectImage:origImage size:cgSize radiusSize: radiusSize];
//        
//        [self.userIconImgView setImage:iconEditImage];
//        self.userIconPlusImgView.hidden = YES;
//    }
    
    [self checkInputData:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ImagePicker キャンセル時
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.isSettingIcon = NO;
    // non action close
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma UITextFieldDDelegate 

-(void)textFieldDidEndEditing:(UITextField*)textField
{
    DLog(@"RegistInputView textFieldDidEndEditing");
    [self checkInputData:NO];
    if(textField.tag == 0){
        // ニックネーム
        if([self.usernameTextField.text hasLength] && [self.usernameTextField.text validateMaxLength:10]){
            // input
            _ckNameImgView.hidden = NO;
            [self checkInputData:NO];
        }else{
            // empty
            _ckNameImgView.hidden = YES;
            [self noActiveSubmit];
            if(![self.usernameTextField.text validateMaxLength:10]){
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthUserName", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }else if(textField.tag == 1){
        // メールアドレス
            
        if([self.emailTextField.text hasLength] && [self.emailTextField.text validateMaxLength:250]){
            
            if(![self.emailTextField.text isEmail]){
                
                // invalid email
                _ckMailImgView.hidden = YES;
                [self noActiveSubmit];
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ValidateUserInvalidEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }else{
                // input
                _ckMailImgView.hidden = NO;
            
                // メールアドレス重複チェック
                if([self.emailTextField.text length]){
                    // self.isInvalidEmail
                    // Loading
                    NSDictionary *vConfig   = [ConfigLoader mixIn];
                    NSString *isLoding = vConfig[@"LoadingPostDisplay"];
                    if( isLoding && [isLoding boolValue] == YES ){
                        // Loading
                        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingCheck", nil) maskType:SVProgressHUDMaskTypeBlack];
                    }
                    [[UserManager sharedManager] checkUserEmail:self.emailTextField.text user_id:nil block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
                    
                        if( isLoding && [isLoding boolValue] == YES ){
                            // clear loading
                            [SVProgressHUD dismiss];
                        }
                        if(result_code.longLongValue == API_CHECK_EMAIL_RESPONSE_CODE_ERROR_INVALID.longLongValue){
                            // exist email error
                        
                            self.isInvalidEmail = YES;
                            _ckMailImgView.hidden = YES;
                            [self noActiveSubmit];
                            //self.submitBtn.enabled = NO;
                            //self.submitBtn.backgroundColor = [UIColor lightGrayColor];
                        
                            // ---------------------------------------
                            // GA EVENT
                            // ---------------------------------------
                            [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-email-exist" value:nil screen:@"SignupInput"];
                        
                            UIAlertView *alert = [[UIAlertView alloc]init];
                            alert = [[UIAlertView alloc]
                                 initWithTitle:NSLocalizedString(@"ApiCautionRegistCheckExist", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        
                        }else if(result_code.longLongValue == API_CHECK_EMAIL_RESPONSE_CODE_SUCCESS.longLongValue){
                            // no exist email -> ok
                        
                            self.isInvalidEmail = NO;
                            _ckMailImgView.hidden = NO;
                            [self checkInputData:NO];
                        
                        }else{
                            // error
                            DLog(@"error = %@", error);
                            // ---------------------------------------
                            // GA EVENT
                            // ---------------------------------------
                            [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-email-err" value:nil screen:@"SignupInput"];
                        
//                        UIAlertView *alert = [[UIAlertView alloc]init];
//                        alert = [[UIAlertView alloc]
//                                 initWithTitle:NSLocalizedString(@"ApiErrorExistEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
                        }
                    
                    }];
                
                }
            }

        }else{
            // empty
            _ckMailImgView.hidden = YES;
            [self noActiveSubmit];
            if(![self.emailTextField.text validateMaxLength:250]){
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }else if(textField.tag == 2){
        // ユーザID
        if([self.userIdTextField.text hasLength] && [self.userIdTextField.text validateMaxLength:30]){
            // input
            _ckIdImgView.hidden = NO;
            [self checkInputData:NO];
        }else{
            // empty
            _ckIdImgView.hidden = YES;
            [self noActiveSubmit];
            if(![self.userIdTextField.text validateMaxLength:30]){
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthUserId", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }else if(textField.tag == 3){
        // パスワード
        if([self.passwdTextField.text hasLength] && [self.passwdTextField.text validateMinMaxLength:8 maxLength:16]){
            // input
            _ckPasswdImgView.hidden = NO;
            [self checkInputData:NO];
        }else{
            // empty
            _ckPasswdImgView.hidden = YES;
            [self noActiveSubmit];
            if(![self.passwdTextField.text validateMinMaxLength:8 maxLength:16]){
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ValidateUserInvalidPassword", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    
}


- (void)RegistSubmitAction
{
    if(self.isSending){
        return;
    }
    // ---------------------------------------
    // GA EVENT
    // ---------------------------------------
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapSubmit" value:nil screen:@"SignupInput"];

    NSDictionary *params = @{ @"username" : self.usernameTextField.text,
                              @"email" : self.emailTextField.text,
                              @"user_id" : self.userIdTextField.text,
                              @"password" : self.passwdTextField.text,
                              @"check_policy" : self.checkPolicy };
    
    //UserManager *userManager = [[UserManager sharedManager] initWithSignupAttributes:params icon:self.userIconImgView.image];
    [[UserManager sharedManager] initWithSignupAttributes:params icon:self.userIconImgView.image];

    //NSString *error = [userManager validateSignupForInsert];
    NSString *error = [[UserManager sharedManager] validateSignupForInsert];
    if([error length]) {

        // ---------------------------------------
        // GA EVENT
        // ---------------------------------------
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapSubmit-invalid" value:nil screen:@"SignupInput"];

        // 入力不十分
        UIAlertView *alert = [[UIAlertView alloc]init];
        alert = [[UIAlertView alloc]
                 initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        // 会員情報送信
        // Loading
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoding = vConfig[@"LoadingPostDisplay"];
        if( isLoding && [isLoding boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }


        // ---------------------
        // sending animation
        // ---------------------
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



        self.isSending = YES;
        [[UserManager sharedManager] sendUserRegist:nil block:^(NSNumber *result_code, NSString *aToken, NSMutableDictionary *responseBody, NSError *error) {
            
            if( isLoding && [isLoding boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }

            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //done 2.0 seconds after.
                // ---------------------
                // sending animation delete
                // ---------------------
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
            });
            
            if (error) {
                // error
                self.isSending = NO;

                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapSubmit-regist-err" value:nil screen:@"SignupInput"];
                
                DLog(@"responseBody : %@", responseBody);
                
                if([[responseBody allKeys] containsObject:@"email"]){
                    // email invalid
                    UIAlertView *alert = [[UIAlertView alloc]init];
                    // NSLocalizedString(@"ApiCautionRegistCheckExist", nil)
                    NSString *errorVal = responseBody[@"email"][0];
                    alert = [[UIAlertView alloc]
                             initWithTitle:errorVal message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];

                }else if([[responseBody allKeys] containsObject:@"username"]){
                    // user id invalid
                    UIAlertView *alert = [[UIAlertView alloc]init];
                    // NSLocalizedString(@"ApiCautionRegistCheckExistUserId", nil)
                    NSString *errorVal = responseBody[@"username"][0];
                    alert = [[UIAlertView alloc]
                             initWithTitle:errorVal message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];

                }else{
                    UIAlertView *alert = [[UIAlertView alloc]init];
                    alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorUserRegist", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }else{

                if(result_code.longLongValue != API_RESPONSE_CODE_SUCCESS_REGIST.longLongValue &&
                    result_code.longLongValue != API_RESPONSE_CODE_SUCCESS.longLongValue){
                    // api error -> ng
                    self.isSending = NO;

                    // ---------------------------------------
                    // GA EVENT
                    // ---------------------------------------
                    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapSubmit-regist-ng" value:nil screen:@"SignupInput"];

                    NSString *errMsg = NSLocalizedString(@"ApiErrorUserRegist", nil);
                    
                    UIAlertView *alert = [[UIAlertView alloc]init];
                    alert = [[UIAlertView alloc]
                             initWithTitle:errMsg message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }else{
                    // regist comp -> ok
                    
                    // ---------------------------------------
                    // GA EVENT
                    // ---------------------------------------
                    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapSubmit-regist-ok" value:nil screen:@"SignupInput"];
                    
                    // SEND REPRO EVENT
                    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[SIGNUP]
                                         properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                          [Configuration loadUserPid],}];
                    
                    // ---------------------------------------
                    // MixPanel EVENT
                    // ---------------------------------------
                    //[TrackingManager sendMixPanelEventTracking:@"Signup" properties:@{@"Count":@"1"}];
                    
                    
                    // アイコン画像の送信
                    
                    NSMutableDictionary *putUser = [NSMutableDictionary dictionary];
                    putUser[@"id"]        = [Configuration loadUserPid];
                    
                    // icon
                    NSString *iconMimeType = nil;
                    NSString *iconName = nil;
                    NSData *iconData = nil;
                    if( self.userIconImgView.image && self.isIcon ){

                        iconName = @"icon";
                        iconData = [[NSData alloc] initWithData:UIImagePNGRepresentation( self.userIconImgView.image )];
                        CommonUtil *commonUtil = [[CommonUtil alloc] init];
                        iconMimeType = [commonUtil mimeTypeByGuessingFromData:iconData];
                        DLog(@"%@", iconMimeType);
                        
                        [[UserManager sharedManager] putUserInfo:putUser imageData:(NSData *)iconData imageName:(NSString *)iconName mimeType:(NSString *)iconMimeType block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
                            
                            // error non check : reason -> registed user data to srv db
                            self.isSending = NO;
                            
                            [self makeTenUsersFollowed:^{
                                PopularViewController *popularView = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"PopularViewController"];
                                [popularView setIsAfterRegistration:YES];
                                popularView.rankingManager = [RankingManager sharedManager];
                                [self.navigationController pushViewController:popularView animated:YES];
                            }];
                        }];
                        
                    }else{
                        self.isSending = NO;
                        
                        [self makeTenUsersFollowed:^{
                            PopularViewController *popularView = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"PopularViewController"];
                            [popularView setIsAfterRegistration:YES];
                            popularView.rankingManager = [RankingManager sharedManager];
                            [self.navigationController pushViewController:popularView animated:YES];
                        }];
                    }
                    
                }
            }
        }];
        
    }

}

///「フォローする」に出るユーザーのIDのみ取得
- (void)getRecommendUserIds:(void(^)(NSMutableArray *ids))block{
    NSDictionary *params = @{ @"page" : @(1),
                              @"categories" : [[NSMutableArray alloc] init]};
    [self addCatParams:params];
    
    [[RankingManager sharedManager] loadMorePopularsWithParams:params
                                              block:^(NSMutableArray *populars, NSUInteger *popularPage, NSError *error) {
                                                  NSMutableArray * ids = [[NSMutableArray alloc] init];
                                                  for (Ranking *p in populars) {
                                                      [ids addObject:p.userPID];
                                                  }
                                                  block(ids);
                                              }];
}

///デフォルトで1ページ目の人をフォローしておく
- (void)makeTenUsersFollowed:(void(^)())completion{
    __block NSString *aToken = [Configuration loadAccessToken];
    [self getRecommendUserIds:^(NSMutableArray *ids) {
        int max = 10;
        for (int follow=0; follow < max && follow < ids.count; follow++) {
            [[FollowManager sharedManager] putFollow:[ids objectAtIndex:follow]
                                              aToken:aToken
                                               block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
                                                   if (error) {
                                                       DLog("error=%@",error);
                                                   }
                                               }];

        }
        completion();
    }];
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

@end
