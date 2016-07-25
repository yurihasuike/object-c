//
//  ProfileEditViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "SettingTableViewController.h"
#import "SettingWebViewController.h"
#import "NoPasswdViewController.h"
#import "IQActionSheetPickerView.h"
#import "UserManager.h"
#import "User.h"
#import "SVProgressHUD.h"
#import "CommonUtil.h"
#import "CoreImageHelper.h"
#import "UIImageView+Networking.h"
#import "UIImageView+WebCache.h"
#import "MasterManager.h"
#import "TrackingManager.h"
#import "NSString+Validation.h"
#import "NSObject+Validation.h"
#import "ConfigLoader.h"
#import "UIImage+Utility.h"
#import "NetworkErrorView.h"

#import "STTwitter.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ProfileEditViewController () <NetworkErrorViewDelete>

@property (nonatomic, strong) STTwitterAPI *twitter;

@property (nonatomic, assign) int isTw;
@property (nonatomic, assign) int isFb;
@property (nonatomic, assign) BOOL isChangeIcon;
@property (nonatomic, assign) BOOL isPopPage;
@property (nonatomic, assign) BOOL isInvalid;
@property (strong, nonatomic) NSString *srvEmail;

@property (strong, nonatomic) IBOutlet UIImageView *userIconImgView;
@property (strong, nonatomic) IBOutlet UIImageView *userIconPlusImgView;
@property (nonatomic) IBOutlet UIButton *editPhotoBtn;

@property (nonatomic) UserManager *userManager;
@property (nonatomic, strong) NSMutableDictionary* areas;
@property (nonatomic, strong) NSMutableDictionary* areasRvs;
@property (nonatomic, strong) NSMutableArray* areaNames;

@end

@implementation ProfileEditViewController

@synthesize userManager = _userManager;
@synthesize user = _user;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.titleView = [CommonUtil getNaviTitle:NSLocalizedString(@"NavTabProfile", nil)];
    
    // 背景色
    self.view.backgroundColor = COMMON_DEF_GRAY_COLOR;

    // init
    _isTw = 0;
    _isFb = 0;
    self.isChangeIcon = NO;
    self.isPopPage = NO;
    
    self.descripTextView.delegate = self;
    
    // ---------------------------
    // MagicalRecordから基本情報取得
    // ---------------------------
    _userPID = [Configuration loadUserPid];
    _userID  = [Configuration loadUserId];
    _userIdField.text = _userID;
    _userNameField.text = @"";
    
    // check
    NSString *twToken = [Configuration loadTWAccessToken];
    if(![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0){
        //_twImageView.image = [UIImage imageNamed:@"ico_twitter_on.png"];
        //_twLoginedImageView.hidden = NO;
        
        self.isTw = 1;
        _twNoLabel.hidden = YES;
        _twOnImageView.hidden = NO;
    }
    NSString *fbToken = [Configuration loadFBAccessToken];
    if(![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0){
        self.isFb = 1;
        _fbNoLabel.hidden = YES;
        _fbOnImageView.hidden = NO;
    }
    
    // テキストエリア：プレースホルダー設定
    _userNameField.placeholder   = NSLocalizedString(@"TFPHolderProfileEditUserName", nil);
    _mailField.placeholder       = NSLocalizedString(@"TFPHolderProfileEditEmail", nil);
    _userIdField.placeholder     = NSLocalizedString(@"TFPHolderProfileEditUserId", nil);
    _descripTextView.placeholder = NSLocalizedString(@"TFPHolderProfileEditIntroduction", nil);
    _passwdEditTitleLabel.text   = NSLocalizedString(@"TFPHolderProfileEditPasswdEditTitle", nil);
    _userInfoLabel.text          = NSLocalizedString(@"TFPHolderProfileEditUserInfo", nil);
    _areaTitleLabel.text         = NSLocalizedString(@"TFPHolderProfileEditAreaTitle", nil);
    _birthTitleLabel.text        = NSLocalizedString(@"TFPHolderProfileEditBirthTitle", nil);
    _seiTitleLabel.text          = NSLocalizedString(@"TFPHolderProfileEditSeiTitle", nil);
    _socialLabel.text            = NSLocalizedString(@"TFPHolderProfileEditSocial", nil);
    _twStatusLabel.text          = NSLocalizedString(@"TFPHolderProfileEditTwStatus", nil);
    _fbStatusLabel.text          = NSLocalizedString(@"TFPHolderProfileEditFbStatus", nil);
    _saveBtn.titleLabel.text     = NSLocalizedString(@"TFPHolderProfileEditSaveBtn", nil);
    
    // 写真編集ボタン
    [_editPhotoBtn addTarget:self action:@selector(editPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _mailField.keyboardType     = UIKeyboardTypeEmailAddress;       // UIKeyboardTypeASCIICapable
    _userNameField.keyboardType = UIKeyboardAppearanceDefault;
    _userIdField.keyboardType   = UIKeyboardTypeAlphabet;
    
    // ニックネーム編集完了時
    //[_userNameField addTarget:self action:@selector(userNameFieldEditEnd:) forControlEvents:UIControlEventEditingDidEndOnExit];
    // メールアドレス編集完了時
    //[_mailField addTarget:self action:@selector(mailFieldEditEnd:) forControlEvents:UIControlEventEditingDidEndOnExit];
    // ユーザID編集完了時
    //[_userIdField addTarget:self action:@selector(userIdFieldEditEnd:) forControlEvents:UIControlEventEditingDidEndOnExit];
    // 自己紹介文編集完了時
    // [_descripTextView ]
    // UITextView
    
    // エリアタップアクション
    [_AreaBtn addTarget:self action:@selector(areaAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 生年月日タップアクション
    [_BirthBtn addTarget:self action:@selector(birthAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 性別タップアクション
    [_SeiBtn addTarget:self action:@selector(seiAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // パスワード変更アクション
    [_passwdEditBtn addTarget:self action:@selector(passwdEditAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // TWボタンアクション
    [_twBtn addTarget:self action:@selector(twAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // FBボタンアクション
    [_fbBtn addTarget:self action:@selector(fbAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 保存ボタンアクション
    [_saveBtn addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // スクロール可能へ
    //self.scrollView.delegate = self;
    
    DLog(@"height : %f", [[UIScreen mainScreen]bounds].size.height);
    if([[UIScreen mainScreen]bounds].size.height <= 480){
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1200);
    }else{
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1140);
    }
    self.scrollView.scrollEnabled = YES;
    //self.scrollView.scrollsToTop = NO;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setScrollsToTop:NO];
        }
    }
    
}

-(void)viewDidLayoutSubviews {
    if([[UIScreen mainScreen]bounds].size.height <= 480){
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1200);
    }else{
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 1140);
    }
    [self.scrollView flashScrollIndicators];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"ProfileEdit"];
    
    // network check
    if(![[UserManager sharedManager]checkNetworkStatus]){
        // error network
        //[NetworkErrorView showInView:self.view];
        NetworkErrorView *networkErrorView = [[NetworkErrorView alloc]init];
        networkErrorView.delegate = self;
        [networkErrorView showInView:self.view];
    }
    
    // ---------------
    // load areas
    // ---------------
    if(!_areas){
        [self loadAreas:self];
    }

    // ---------------
    // load user info
    // ---------------
    if(!self.user){
        if(!_userManager) {
            _userManager = [UserManager sharedManager];
        }
        if(!self.isChangeIcon && !self.isPopPage){
            
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //done 0.2 seconds after.
                [self loadUser:self];
            });
            
        }
    }else{
        if(!self.isChangeIcon && !self.isPopPage){

            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //done 0.2 seconds after.
                [self settingUser:self.user];
            });
            
        }
    }
    if(self.isPopPage){
        self.isPopPage = NO;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)loadAreas:(id)sender
{
    DLog(@"ProfileEditView loadAreas");

    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }

    [[MasterManager sharedManager] getUserAreasWithParams:nil block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSMutableDictionary *areas, NSError *error) {
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }

        if(result_code.longLongValue == API_RESPONSE_CODE_SUCCESS.longLongValue){
            
            NSMutableArray *mutableAreas    = [[NSMutableArray alloc] initWithCapacity:areas.count + 1];
            NSMutableDictionary *mutableAreaObjs    = [NSMutableDictionary dictionary];
            NSMutableDictionary *mutableAreaRvsObjs = [NSMutableDictionary dictionary];
            
            for (id value in [areas objectEnumerator]) {
                // id key label
                [mutableAreas addObject:value[@"name"]];
                //NSDictionary *srvArea = [NSDictionary dictionaryWithObjectsAndKeys:
                //                             value[@"id"], @"id",
                //                             value[@"name"], @"name",
                //                             nil];
                // [mutableAreaObjs addObject:[srvArea copy]];
                [mutableAreaObjs setObject:value[@"name"] forKey:value[@"id"]];
                [mutableAreaRvsObjs setObject:value[@"id"] forKey:value[@"name"]];
            }
            if(mutableAreas && mutableAreas.count > 1){
                _areaNames = [mutableAreas mutableCopy];
                _areas = [mutableAreaObjs copy];
                _areasRvs = [mutableAreaRvsObjs copy];
            }else{
                // default
                _areaNames = [NSMutableArray arrayWithObjects:@" ", @"関東", @"東京", @"埼玉", @"神奈川", @"千葉",
                                        @"北海道・東北", @"北海道", @"青森", @"秋田", @"山形", @"岩手", @"宮城", @"福島", @"栃木", @"茨城",
                                        @"中部", @"愛知", @"栃木", @"静岡", nil];
            }
        }else{
            // エラー無視で処理続行 -> X
            // default
            //_areaNames = [NSMutableArray arrayWithObjects:@" ", @"関東", @"東京", @"埼玉", @"神奈川", @"千葉",
            //               @"北海道・東北", @"北海道", @"青森", @"秋田", @"山形", @"岩手", @"宮城", @"福島", @"栃木", @"茨城",
            //               @"中部", @"愛知", @"栃木", @"静岡", nil];
            if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_TIMEOUT]){
                // 0 エラー時 : タイムアウト
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
            }
        }

    }];
}

// ユーザ情報取得
- (void)loadUser:(id)sender
{
    DLog(@"ProfileEditView loadUser");
    
    // init
    self.userIconImgView.image = nil;
    self.userIconPlusImgView.hidden = YES;
    
    if(![_userPID isKindOfClass:[NSNumber class]]) {
        _userPID = [Configuration loadUserPid];
    }

    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingDetailDisplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }

    // 自アカウントの為、userPIDは、不要
    [_userManager getUserInfo:nil block:^(NSNumber *resultCode, User *srvUser, NSMutableDictionary *responseBody, NSError *error) {

        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }

        if([srvUser isKindOfClass:[User class]]){
            // get user date -> ok
            [self settingUser:srvUser];

        }else{
            // eror
            if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_AUTH] ||
               [resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_FOUND]){
                // 401 エラー時 : アクセストークンがあれば、削除 -> logout
                //NSString *aToken = [[UserManager sharedManager]loadAccessToken];
                //if(aToken){
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
                //}
            }else{
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    }];

}

- (void) settingUser:(User *)s_user {

    // nickname
    _userNameField.text = s_user.username;
    // email -> api no data
    NSString *email = [Configuration loadEmail];
    if(!email){
        email = s_user.email;
    }
    _mailField.text = email;
    self.srvEmail = email;
    // user_id
    _userIdField.text = s_user.userID;
    // descrip
    _descripTextView.text = s_user.introduction;

    // icon
    if(!self.isChangeIcon){
        CommonUtil *commonUtil = [[CommonUtil alloc] init];
//        CGSize cgSize = CGSizeMake(100.0f, 100.0f);
//        CGSize radiusSize = CGSizeMake(16.0f, 16.0f);
        CGSize cgSize = CGSizeMake(300.0f, 300.0f);
        CGSize radiusSize = CGSizeMake(48.0f, 48.0f);
        
        if(s_user.iconPath && ![s_user.iconPath isKindOfClass:[NSNull class]]){
        
        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t q_main = dispatch_get_main_queue();
        self.userIconImgView.image = nil;
        dispatch_async(q_global, ^{
            NSString *imageURL = s_user.iconPath;
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: imageURL]]];
            dispatch_async(q_main, ^{
                UIImage *resizeImage = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
                self.userIconImgView.image = resizeImage;
                self.userIconImgView.alpha = 1;


//                [UIView animateWithDuration:0.8f animations:^{
//                    self.userIconImgView.alpha = 0;
//                    self.userIconImgView.alpha = 1;
//                }];
                
                
            });
        });
            
        }else{
            UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"ico_nouser.png"] size:cgSize radiusSize:radiusSize];
            self.userIconImgView.image = image;
            self.userIconPlusImgView.hidden = NO;
            self.userIconImgView.alpha = 1;
            
//            [UIView animateWithDuration:0.8f animations:^{
//                self.userIconImgView.alpha = 0;
//                self.userIconImgView.alpha = 1;
//            }];

        }
        
        
        //[self.userIconImgView sd_setImageWithURL:[NSURL URLWithString:s_user.iconPath] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

//        if(s_user.iconPath && ![s_user.iconPath isKindOfClass:[NSNull class]]){
//            [self.userIconImgView sd_setImageWithURL:[NSURL URLWithString:s_user.iconPath]
//                                  placeholderImage:nil
//                                           options: SDWebImageCacheMemoryOnly
//                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                             image = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
//                                             self.userIconImgView.image = nil;
//                                             self.userIconImgView.image = image;
//                                             
//                                             [UIView animateWithDuration:0.8f animations:^{
//                                                 self.userIconImgView.alpha = 0;
//                                                 self.userIconImgView.alpha = 1;
//                                             }];
//                                             
//                                             // height : postImage
//                                             //CGRect rect = CGRectMake(0, 0, image.size.width, self.userIconImgView.image.size.height);
//                                             //self.userIconImgView.frame = rect;
//                                             self.userIconPlusImgView.hidden = YES;
//                                         }];
//        }else{
//            UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"ico_nouser.png"] size:cgSize radiusSize:radiusSize];
//            self.userIconImgView.image = image;
//            self.userIconPlusImgView.hidden = NO;
//            
//            [UIView animateWithDuration:0.8f animations:^{
//                self.userIconImgView.alpha = 0;
//                self.userIconImgView.alpha = 1;
//            }];
//        }
    }
    
    // area NSNumber
    if(s_user.area && [s_user.area isKindOfClass:[NSNumber class]]){
        DLog(@"%@",_areas);
        NSString *areaName = [_areas objectForKey:@([s_user.area longValue])];
        if(areaName){
            _areaLabel.text = areaName;
        }
    }

    // birth
    if([s_user.birth isKindOfClass:[NSDate class]]){
        NSDate *birthDate = [s_user.birth copy];
        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
        NSString *outputDateFormatterStr = @"yyyy年MM月dd日";
        [outputDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
        [outputDateFormatter setDateFormat:outputDateFormatterStr];
        NSString *outputDateStr = [outputDateFormatter stringFromDate:birthDate];
        _birthLabel.text = outputDateStr;
    }

    // sex
    if(s_user.sex && [s_user.sex isKindOfClass:[NSString class]]){
        if([s_user.sex isEqualToString: @"u"]){
            //_seiLabel.text = NSLocalizedString(@"PageProfileEditSexNon", nil);
        }else if([s_user.sex isEqualToString: @"m"]){
            _seiLabel.text = NSLocalizedString(@"PageProfileEditSexMan", nil);
        }else if([s_user.sex isEqualToString: @"f"]){
            _seiLabel.text = NSLocalizedString(@"PageProfileEditSexWoman", nil);
        }
    }
    
    // twToken twTokenSecret
    if(s_user.twToken && [s_user.twToken isKindOfClass:[NSString class]] &&
       s_user.twTokenSecrect && [s_user.twTokenSecrect isKindOfClass:[NSString class]]){
        self.isTw = 1;
        _twNoLabel.hidden = YES;
        _twOnImageView.hidden = NO;
    }else{
//        self.isTw = 0;
//        _twNoLabel.hidden = NO;
//        _twOnImageView.hidden = YES;
    }
    // fbToken
    if(s_user.fbToken && [s_user.fbToken isKindOfClass:[NSString class]]){  // [fbToken length] > 0
        self.isFb = 1;
        _fbNoLabel.hidden = YES;
        _fbOnImageView.hidden = NO;
    }else{
//        self.isFb = 0;
//        _fbNoLabel.hidden = NO;
//        _fbOnImageView.hidden = YES;
    }
    
}

- (NSMutableDictionary *) putUserSetting
{
    
    NSMutableDictionary *putUser = [NSMutableDictionary dictionary];

    putUser[@"id"]        = [Configuration loadUserPid];
    //putUser[@"id"]        = (t_user.userPID) ? t_user.userPID : @"";
    putUser[@"username"]  = (self.userIdField.text) ? self.userIdField.text : @"";
    putUser[@"email"]     = (self.mailField.text) ? self.mailField.text : @"";
    putUser[@"nickname"]  = (self.userNameField.text) ? self.userNameField.text : @"";
    // ico
    putUser[@"bio"]  = (self.descripTextView.text) ? self.descripTextView.text : @"";
    // sex
    if(self.seiLabel.text && [self.seiLabel.text length] > 0){
        if([self.seiLabel.text isEqualToString: NSLocalizedString(@"PageProfileEditSexMan", nil)]){
            putUser[@"sex"]   = @"m";
        }else if([self.seiLabel.text isEqualToString: NSLocalizedString(@"PageProfileEditSexWoman", nil)]){
            putUser[@"sex"]   = @"f";
        }else{
            putUser[@"sex"]   = nil;
        }
    }
    // area
    if(self.areaLabel.text && [self.areaLabel.text length] > 0){
        NSString *areaName = [_areasRvs objectForKey:self.areaLabel.text];
        if(areaName){
            NSNumber *areaID = [NSNumber numberWithInt:[areaName intValue]];
            putUser[@"area"]   = areaID;
        }
    }
    
    // birth
    if(self.birthLabel.text && ![self.birthLabel.text isKindOfClass:[NSNull class]]){
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:NSLocalizedString(@"DateFormat", nil)];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:NSLocalizedString(@"DateTimezone", nil)]];
        NSDate *birthDate = [formatter dateFromString:self.birthLabel.text];
        if(birthDate){
            //putUser[@"birthday"]  = birthDate;
            NSDateFormatter *strFormatter = [[NSDateFormatter alloc] init];
            [strFormatter setDateFormat:NSLocalizedString(@"DateFormatSrv", nil)];
            [strFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:NSLocalizedString(@"DateTimezone", nil)]];
            NSString *birthDateStr = [strFormatter stringFromDate:birthDate];
            DLog(@"%@", birthDateStr);
            putUser[@"birthday"]  = birthDateStr;
        }
    }
    
    DLog(@"%@", putUser);
    
    return putUser;
}


- (void) editPhotoAction:(id)sender {

    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS8

        // コントローラを生成
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MsgActionIconSettingTitle", nil)
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
        // Cancel用のアクションを生成
        UIAlertAction * cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * action) {
                               DLog(@"Cancel button tapped.");
                           }];
        // ライブラリ選択用のアクションを生成
        UIAlertAction * libraryAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgActionIconLib", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               DLog(@"Library button tapped.");
                               // Load Library
                               [self cameraLibraryAction];
                               
                           }];
        // カメラ撮影用のアクションを生成
        UIAlertAction * cameraAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgActionIconCamera", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               DLog(@"Camera button tapped.");
                               //[AQPhotoPickerView selectPhoto:self];
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
        switch (buttonIndex) {
            case 0:
                [self cameraLibraryAction];
                break;
            case 1:
                [self cameraPhotoAction];
                break;
        }
    }else if(actionSheet.tag == 1){
        // Connect Tw
        switch (buttonIndex) {
            case 0:
                [self twitterConnect];
                break;
        }
    }else if(actionSheet.tag == 2){
        // Connect Fb
        switch (buttonIndex) {
            case 0:
                [self facebookConnect];
                break;
        }
    }
}

- (void) cameraLibraryAction
{
    // ライブラリ起動
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];    // UIImagePickerControllerSourceTypeSavedPhotosAlbum
        [imagePickerController setAllowsEditing:YES];
        imagePickerController.delegate = self;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
//        UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController: imagePickerController];
//        popover.delegate = self;
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [popover presentPopoverFromBarButtonItem:nil permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//            }];
        
    }
}

- (void) cameraPhotoAction
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        // カメラ対応不可端末
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"RegistUserPhotoNotCamera", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];

        [alert show];

    } else {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];

        //[imagePickerController.view setBounds: CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width / 2, [[UIScreen mainScreen]bounds].size.width / 2)];
        //[imagePickerController.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width / 2, [[UIScreen mainScreen]bounds].size.width / 2)];
        
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        //imagePickerController.editing = YES;
        //imagePickerController.showsCameraControls = YES;
        imagePickerController.allowsEditing = NO;
        //[imagePickerController setAllowsEditing:YES];
        //imagePickerController.editing = YES;
        //imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:imagePickerController animated:YES completion:nil];
            [imagePickerController takePicture];
        }];
        
        //[self presentViewController:imagePickerController animated:YES completion:nil];
        //[imagePickerController takePicture];
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
    
    if (pickImage) {
        
        // 画像を丸く
        CommonUtil *commonUtil = [[CommonUtil alloc] init];
        self.isChangeIcon = YES;
        
//        CGFloat imgRate    = origImage.size.width / origImage.size.height;
//        CGFloat targetRate = 200.0f / origImage.size.width;
//        CGFloat resizeHeight = origImage.size.height * targetRate;

        CGSize ciSize = CGSizeMake(200.0f, 200.0f);
        [CoreImageHelper centerCroppingImageWithImage:pickImage atSize:ciSize completion:^(UIImage *resultImg){
            
            CGSize cgSize = CGSizeMake(100.0f, 100.0f);
            CGSize radiusSize = CGSizeMake(50.0f, 50.0f);
            
            UIImage *iconEditImage = [commonUtil createRoundedRectImage:resultImg size:cgSize radiusSize: radiusSize];
            self.userIconImgView.hidden = NO;
            self.userIconPlusImgView.hidden = YES;
            // flag : on
            self.isChangeIcon = YES;
            self.userIconImgView.image = nil;
            self.userIconImgView.image = iconEditImage;
            
        }];

    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ImagePicker キャンセル時
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //cancel -> non action close
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ニックネーム変更時
//- (void)userNameFieldEditEnd:(UITextField*)textfield{
//    DLog(@"ProfileEditView userNameFieldEditEnd");
//    [self checkInputData:@"nickname"];
//}

// メールアドレス変更時
//- (void)mailFieldEditEnd:(UITextField*)textfield{
//    DLog(@"ProfileEditView mailFieldEditEnd");
//    [self checkInputData:@"mail"];
//}

// ユーザID変更時
//- (void)userIdFieldEditEnd:(UITextField*)textfield{
//    DLog(@"ProfileEditView userIdFieldEditEnd");
//    [self checkInputData:@"userId"];
//}

// input data check
- (BOOL) checkInputData:(NSString *)checkName
{
    self.isInvalid = NO;
    // ---------------------
    // メールアドレス
    // ---------------------
    if(![self.mailField.text hasLength]){
        // error
        self.isInvalid = YES;
        if(checkName && [checkName isEqualToString:@"mail"]){
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }else if(![self.mailField.text validateMaxLength:250]){
        // error
        self.isInvalid = YES;
        if(checkName && [checkName isEqualToString:@"mail"]){
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }else{
        if(checkName && [checkName isEqualToString:@"mail"] &&
                ![self.mailField.text isEqualToString:self.srvEmail]){
            // exist check
            // Loading
            NSDictionary *vConfig   = [ConfigLoader mixIn];
            NSString *isLoding = vConfig[@"LoadingPostDisplay"];
            if( isLoding && [isLoding boolValue] == YES ){
                // Loading
                [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingCheck", nil) maskType:SVProgressHUDMaskTypeBlack];
            }
            
            __weak typeof(self) weakSelf = self;
            [[UserManager sharedManager] checkUserEmail:self.mailField.text user_id:nil block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
            
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                if(result_code.longLongValue == API_CHECK_EMAIL_RESPONSE_CODE_ERROR_INVALID.longLongValue){
                    // exist email error
                
                    [strongSelf noActiveSubmit];
                    strongSelf.isInvalid = YES;

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
                
                }else{
                    // error
                    DLog(@"error = %@", error);
                    
//                    UIAlertView *alert = [[UIAlertView alloc]init];
//                    alert = [[UIAlertView alloc]
//                             initWithTitle:NSLocalizedString(@"ApiErrorExistEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [alert show];
                }
            }];
        }
    }
    
    // ---------------------
    // ニックネーム
    // ---------------------
    if(![self.userNameField.text hasLength]){
        // error
        self.isInvalid = YES;
        if(checkName && [checkName isEqualToString:@"nickname"]){
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthUserName", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }else if(![self.userNameField.text validateMaxLength:20]){
        // error
        self.isInvalid = YES;
        if(checkName && [checkName isEqualToString:@"nickname"]){
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthUserName", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    // ---------------------
    // ユーザID
    // ---------------------
    if(![self.userIdField.text hasLength]){
        // error
        self.isInvalid = YES;
        if(checkName && [checkName isEqualToString:@"userId"]){
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthUserId", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }else if(![self.userIdField.text validateMaxLength:30]){
        // error
        self.isInvalid = YES;
        if(checkName && [checkName isEqualToString:@"userId"]){
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthUserId", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    // ---------------------
    // 自己紹介
    // ---------------------
    if(![self.descripTextView.text hasLength]){
        // no error
    }else if(![self.descripTextView.text validateMaxLength:200]){
        // error
        self.isInvalid = YES;
        if(checkName && [checkName isEqualToString:@"descrip"]){
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ValidateUserInvalidLengthDescrip", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    // 登録ボタンアクティブチェック
    if( self.isInvalid ){
        // no save action
        [self noActiveSubmit];
        return NO;
    }else{
        // save action
        [self activeSubmit];
        return YES;
    }
}

- (void) activeSubmit
{
    // ボタンアクティブ
    self.saveBtn.enabled = YES;
    self.saveBtn.backgroundColor = INPUT_SEND_BTN_COLOR;
}

- (void) noActiveSubmit
{
    // ボタン非アクティブ
    self.saveBtn.enabled = NO;
    self.saveBtn.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark UITextFieldDDelegate

-(void)textFieldDidEndEditing:(UITextField*)textField
{
    DLog(@"ProfileEditView textFieldDidEndEditing");
    //DLog(@"tag : %d", textField.tag);
    if(textField.tag == 0){
        [self checkInputData:@"nickname"];
    }else if(textField.tag == 1){
        [self checkInputData:@"mail"];
    }else if(textField.tag == 2){
        [self checkInputData:@"userId"];
    }
}

#pragma mark UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    DLog(@"ProfileEditView textViewShouldBeginEditing");
    [UIView animateWithDuration:0.8f animations:^{
        self.scrollView.contentOffset = CGPointMake(0, -self.scrollView.contentInset.top + 140.0f);
    }];
    return YES;
}

// 紹介文変更時
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    DLog(@"ProfileEditView textViewShouldEndEditing");
    
    if([textView isKindOfClass:[UIPlaceHolderTextView class]] && textView.tag == 1){
        // textView
        [self checkInputData:@"descrip"];
    }
    return YES;
}

#pragma mark IQActionSheetPickerViewDelegate


-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    switch (pickerView.tag)
    {
//        case 1: [buttonDate setTitle:[titles componentsJoinedByString:@" - "] forState:UIControlStateNormal]; break;
        case 1:
            _areaLabel.text = [titles componentsJoinedByString:@" - "];
            
            break;
        case 2:
            if([[titles firstObject] isKindOfClass:[NSDate class]]){
                NSDate *birthDate = [titles firstObject];
                NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                NSString *outputDateFormatterStr = NSLocalizedString(@"DateFormat", nil);
                [outputDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:NSLocalizedString(@"DateTimezone", nil)]];
                [outputDateFormatter setDateFormat:outputDateFormatterStr];
                NSString *outputDateStr = [outputDateFormatter stringFromDate:birthDate];
                _birthLabel.text = outputDateStr;
                
                self.user.birth = [birthDate copy];
            }
            break;
        case 3:
            _seiLabel.text = [titles componentsJoinedByString:@" - "];
            if([[titles firstObject] isEqualToString: NSLocalizedString(@"PageProfileEditSexMan", nil)]){
                self.user.sex = @"m";
            }else if([[titles firstObject] isEqualToString: NSLocalizedString(@"PageProfileEditSexWoman", nil)]){
                self.user.sex = @"f";
            }else{
                self.user.sex = nil;
            }
            break;
            
        default:
            break;
    }
}

// setting area
- (void) areaAction:(id)sender {
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Setting Picker" delegate:self];
    [picker setTag:1];
    //[picker setTitlesForComponenets:@[@[@"北海道", @"青森", @"東京", @"日本以外"]]];
    NSArray *selectAreas = [_areaNames copy];
    [picker setTitlesForComponenets:@[selectAreas]];
    
    int selectedItem = 0;
    if(self.areaLabel.text && ![self.areaLabel.text isKindOfClass:[NSNull class]]){
        int areaCnt = 0;
        for(NSString *area in selectAreas){
            if([self.areaLabel.text isEqualToString:area]){
                selectedItem = areaCnt;
            }
            areaCnt++;
        }
    }
    [picker selectIndexes:@[@(selectedItem),] animated:NO];
    
    [picker show];
}

// setting birth
- (void) birthAction:(id)sender {
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Date Picker" delegate:self];
    [picker setTag:2];
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
    
    NSDate *birthDate;
    if(self.birthLabel.text && ![self.birthLabel.text isKindOfClass:[NSNull class]]){
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:NSLocalizedString(@"DateFormat", nil)];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:NSLocalizedString(@"DateTimezone", nil)]];
        birthDate = [formatter dateFromString:self.birthLabel.text];
    }
    if(!birthDate){
        birthDate = [NSDate date];
    }
    [picker setDate:birthDate];
    [picker show];
}

// setting sex
- (void) seiAction:(id)sender {
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Setting Picker" delegate:self];
    [picker setTag:3];
    //[picker setTitlesForComponenets:@[@[@"男性", @"女性"]]];
    [picker setTitlesForComponenets:@[@[
                                        NSLocalizedString(@"PageProfileEditSexWoman", nil),
                                        NSLocalizedString(@"PageProfileEditSexMan", nil),]]];
    
    int selectedItem = 0;
    if(self.seiLabel.text && ![self.seiLabel.text isKindOfClass:[NSNull class]]){
        if([self.seiLabel.text isEqualToString:NSLocalizedString(@"PageProfileEditSexMan", nil)]){
            selectedItem = 1;
        }
    }
    [picker selectIndexes:@[@(selectedItem),] animated:NO];
    
    [picker show];
}

// webview nopasswd
- (void) passwdEditAction:(id)sender {
    
    SettingWebViewController *webcontroller = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingWebViewController"];

    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *strUrl = vConfig[@"WebViewURLChangePasswd"];
    DLog(@"strUrl : %@", strUrl);
    webcontroller.webURLPath = strUrl;
    webcontroller.title = NSLocalizedString(@"PageChangePasswd", nil);

    self.isPopPage = YES;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationController.navigationItem.backBarButtonItem = backItem;

    [self.navigationController pushViewController:webcontroller animated:YES];
}

// connect Twitter
- (void) twAction:(id)sender {

    NSString *alertTwTitle = nil;
    NSString *alertTwExecTitle = nil;
    if(_isTw == 0) {
        alertTwTitle = NSLocalizedString(@"MsgActionSocialTwAuth", nil);
        alertTwExecTitle = NSLocalizedString(@"MsgActionSocialAuth", nil);
    }else{
        alertTwTitle = NSLocalizedString(@"MsgActionSocialTwAuth", nil);
        alertTwExecTitle = NSLocalizedString(@"MsgActionSocialNoAuth", nil);
    }
    
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS8
        
        // 連携実施の確認
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle: alertTwTitle
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
        [UIAlertAction actionWithTitle: alertTwExecTitle
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   // ボタンタップ時の処理
                                   DLog(@"OK button tapped.");

                                   [self twitterConnect];

                               }];
        // コントローラにアクションを追加
        [ac addAction:cancelAction];
        //[ac addAction:destructiveAction];
        [ac addAction:okAction];
        
        // アクションシート表示処理
        [self presentViewController:ac animated:YES completion:nil];
        
    }else{
        // under iOS
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = alertTwTitle;
        [as addButtonWithTitle:alertTwExecTitle];
        [as addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        //as.destructiveButtonIndex = 0;
        as.cancelButtonIndex = 1;
        as.tag = 1;
        [as showInView:self.view];
    }
    
}

- (void)twitterConnect
{

    if(_isTw == 0) {
        
        self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:OAUTH_TW_API_KEY
                                                     consumerSecret:OAUTH_TW_API_SECRET];
        
        [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
            DLog(@"-- url: %@", url);
            DLog(@"-- oauthToken: %@", oauthToken);
            
            NoPasswdViewController *webView = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"NoPasswdViewController"];
            webView.naviTitle = @"twitter login";
            [self presentViewController:webView animated:YES completion:^{
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [webView.webView loadRequest:request];
            }];
            
        } authenticateInsteadOfAuthorize:NO
                        forceLogin:@(YES)
                        screenName:nil
         //oauthCallback:@"me.myrecoup://twitter_access_tokens/"    // no reback -> NG
                     oauthCallback:TW_CALLBACK_URL
                        errorBlock:^(NSError *error) {
                            DLog(@"-- error: %@", error);
                            //
                            
                        }];
        
    }else{
        
        NSString *twToken = @"";
        NSString *twTokenSecret = @"";
        //NSString *twTokenSecret = @"";
        // --------------------
        // send API
        // --------------------
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoading = vConfig[@"LoadingPostDisplay"];
        // must
        isLoading = @"YES";
        if( isLoading && [isLoading boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        NSString *aToken = [Configuration loadAccessToken];
        [[UserManager sharedManager] deleteTwToken:aToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
            
            if( isLoading && [isLoading boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }

            if(error){
                DLog(@"%@", error);
                UIAlertView *alert = [[UIAlertView alloc]init];
                
                if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_CONFLICT]){
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocialConflict", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }else{
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocial", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }
                [alert show];
                
            }else{
                
                // 解除完了
                NSString *alertTwClearTitle = NSLocalizedString(@"MsgSocialClear", nil);
                self.isTw = 0;
                _twNoLabel.hidden = NO;
                _twOnImageView.hidden = YES;
                
                //_twLoginedImageView.hidden = YES;
                //_twImageView.image = [UIImage imageNamed:@"ico_facebook.png"];
                
                [Configuration saveTWAccessToken:twToken];
                [Configuration saveTWAccessTokenSecret:twTokenSecret];
                
                // login認証トークンは、残す
                //[Configuration saveLoginTWAccessToken:twToken];
                //[Configuration saveLoginTWAccessTokenSecret:twTokenSecret];
                
                [SVProgressHUD showSuccessWithStatus: alertTwClearTitle];
            }
            
        }];

    }

}


- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebView
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        DLog(@"-- screenName: %@", screenName);
        
        //NSString *twEmail = @"";
        //NSString *twName  = screenName;
        NSString *twToken = oauthToken;
        NSString *twTokenSecret = oauthTokenSecret;
        
        // --------------------
        // send API
        // --------------------
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoading = vConfig[@"LoadingPostDisplay"];
        // must
        isLoading = @"YES";
        if( isLoading && [isLoading boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        NSString *aToken = [Configuration loadAccessToken];
        [[UserManager sharedManager] postTwToken:aToken twToken:twToken twTokenSecret:twTokenSecret block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
            
            if( isLoading && [isLoading boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }

            if(error){
                DLog(@"%@", error);

                UIAlertView *alert = [[UIAlertView alloc]init];
                if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_CONFLICT]){
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocialConflict", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }else{
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocial", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }
                [alert show];
                
            }else{
                
                if(twToken){
                    [Configuration saveTWAccessToken:twToken];
                    [Configuration saveLoginTWAccessToken:twToken];
                }
                if(twTokenSecret){
                    [Configuration saveTWAccessTokenSecret:twTokenSecret];
                    [Configuration saveLoginTWAccessTokenSecret:twTokenSecret];
                }
                
                // 連携完了
                NSString *alertTwCompTitle = NSLocalizedString(@"MsgSocialComp", nil);
                self.isTw = 1;
                _twNoLabel.hidden = YES;
                _twOnImageView.hidden = NO;
                
                [SVProgressHUD showSuccessWithStatus: alertTwCompTitle];
                
            }
            
        }];
        
    } errorBlock:^(NSError *error) {
        DLog(@"-- %@", [error localizedDescription]);
    }];
}


// connect Facebook
- (void) fbAction:(id)sender {

    NSString *alertFbTitle = nil;
    NSString *alertFbExecTitle = nil;
    if(_isFb == 0) {
        alertFbTitle = NSLocalizedString(@"MsgActionSocialFbAuth", nil);
        alertFbExecTitle = NSLocalizedString(@"MsgActionSocialAuth", nil);
        
    }else{
        alertFbTitle = NSLocalizedString(@"MsgActionSocialFbAuth", nil);
        alertFbExecTitle = NSLocalizedString(@"MsgActionSocialNoAuth", nil);
    }
    
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS8
        
        // 連携実施の確認
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:alertFbTitle
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
        [UIAlertAction actionWithTitle:alertFbExecTitle
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   // ボタンタップ時の処理
                                   DLog(@"OK button tapped.");
                                   
                                   [self facebookConnect];
                               }];
        // コントローラにアクションを追加
        [ac addAction:cancelAction];
        //[ac addAction:destructiveAction];
        [ac addAction:okAction];
        
        // アクションシート表示処理
        [self presentViewController:ac animated:YES completion:nil];
        
    }else{
        // under iOS
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = alertFbTitle;
        [as addButtonWithTitle:alertFbExecTitle];
        [as addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        //as.destructiveButtonIndex = 0;
        as.cancelButtonIndex = 1;
        as.tag = 2;
        [as showInView:self.view];
    }
    
}

- (void)facebookConnect
{
    if(_isFb == 0) {
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        
        [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                DLog(@"errror:%@", error);
                // Process error -> no action
                
            } else if (result.isCancelled) {
                DLog(@"login is cancelled.");
                // Handle cancellations -> no action
                
            } else {
            
                
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                if ([result.grantedPermissions containsObject:@"email"]) {
                    
                    // FB申請＋投稿時FB送信を行なう際に解除
                    //[login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                    
                        // -----------------
                        // facebook Do work
                        // -----------------
                        DLog(@"login with read email permission succeeded.");
                        NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
                    
                        // --------------------
                        // send API
                        // --------------------
                        NSDictionary *vConfig   = [ConfigLoader mixIn];
                        NSString *isLoading = vConfig[@"LoadingPostDisplay"];
                        // must
                        isLoading = @"YES";
                        if( isLoading && [isLoading boolValue] == YES ){
                            // Loading
                            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
                        }
                        NSString *aToken = [Configuration loadAccessToken];
                        [[UserManager sharedManager] postFbToken:aToken fbToken:fbToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {

                            if( isLoading && [isLoading boolValue] == YES ){
                                // clear loading
                                [SVProgressHUD dismiss];
                            }

                            if(error){
                                DLog(@"%@", error);
                            
                                UIAlertView *alert = [[UIAlertView alloc]init];
                                if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_CONFLICT]){
                                    alert = [[UIAlertView alloc]
                                         initWithTitle:NSLocalizedString(@"ApiErrorSocialConflict", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                }else{
                                    alert = [[UIAlertView alloc]
                                         initWithTitle:NSLocalizedString(@"ApiErrorSocial", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                }
                                [alert show];
                            
                            }else{

                                if(fbToken){
                                    [Configuration saveFBAccessToken:fbToken];
                                    [Configuration saveLoginFBAccessToken:fbToken];
                                }

                                // 連携完了
                                NSString *alertFbCompTitle = NSLocalizedString(@"MsgSocialComp", nil);
                                self.isFb = 1;
                                //_fbLoginedImageView.hidden = NO;
                                //_fbImageView.image = [UIImage imageNamed:@"ico_facebook_on.png"];
                                _fbNoLabel.hidden = YES;
                                _fbOnImageView.hidden = NO;
                            
                                [SVProgressHUD showSuccessWithStatus: alertFbCompTitle];

                            }
                        
                        }];
                    
                    //}];
                     
                }
            }
        }];
        
        
        
    }else{
        
        NSString *fbToken = @"";
        // --------------------
        // send API
        // --------------------
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoading = vConfig[@"LoadingPostDisplay"];
        // must
        isLoading = @"YES";
        if( isLoading && [isLoading boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        NSString *aToken = [Configuration loadAccessToken];
        [[UserManager sharedManager] deleteFbToken:aToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {

            if( isLoading && [isLoading boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }

            if(error){
                DLog(@"%@", error);
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_CONFLICT]){
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocialConflict", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }else{
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorSocial", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                }
                [alert show];

            }else{
                
                // 解除完了
                NSString *alertFbCompTitle = NSLocalizedString(@"MsgSocialClear", nil);
                self.isFb = 0;
                _fbNoLabel.hidden = NO;
                _fbOnImageView.hidden = YES;
                
                //_fbLoginedImageView.hidden = YES;
                //_fbImageView.image = [UIImage imageNamed:@"ico_facebook.png"];

                [Configuration saveFBAccessToken:fbToken];
                
                // login認証トークンは、残す
                //[Configuration saveLoginFBAccessToken:fbToken];
                
                [SVProgressHUD showSuccessWithStatus: alertFbCompTitle];
            }
            
        }];
        
    }

}


- (void) saveAction:(id)sender {

    // ---------------------------------------
    // GA EVENT
    // ---------------------------------------
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapSubmit" value:nil screen:@"ProfileEdit"];
    
    // check email
    NSString *input_email = [self.mailField.text trim];
    NSString *input_username = (self.userIdField.text) ? self.userIdField.text : @"";
    DLog(@"%@", input_email);
    
    if(![input_email length]) {
        // empty email
        
        // ---------------------------------------
        // GA EVENT
        // ---------------------------------------
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapProfileEdit-email-empty" value:nil screen:@"ProfileEdit"];
        
        UIAlertView *alert = [[UIAlertView alloc]init];
        alert = [[UIAlertView alloc]
                 initWithTitle:NSLocalizedString(@"ValidateUserEmptyEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else if(![input_email isEmail]){
        // invalid email
        
        // ---------------------------------------
        // GA EVENT
        // ---------------------------------------
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapProfileEdit-email-invalid" value:nil screen:@"ProfileEdit"];
        
        UIAlertView *alert = [[UIAlertView alloc]init];
        alert = [[UIAlertView alloc]
                 initWithTitle:NSLocalizedString(@"ValidateUserInvalidEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else if(![input_username canBeConvertedToEncoding:NSASCIIStringEncoding]){
        // invalid username(including multi byte characters)
        
        UIAlertView *alert = [[UIAlertView alloc]init];
        alert = [[UIAlertView alloc]
                 initWithTitle:NSLocalizedString(@"ValidateUserInvalidUserID", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        // Loading
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoding = vConfig[@"LoadingPostDisplay"];
        if( isLoding && [isLoding boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingCheck", nil) maskType:SVProgressHUDMaskTypeBlack];
        }

        NSMutableDictionary *putUser = [self putUserSetting];
        // icon
        NSString *iconMimeType = nil;
        NSString *iconName = nil;
        NSData *iconData = nil;
        if( self.userIconImgView.image && self.isChangeIcon ){
            //NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            //self.userIconImgView.image.
            iconName = @"icon";
//            CGDataProviderRef imageDataProvider = CGImageGetDataProvider(self.userIconImgView.image.CGImage);
//            iconData = (NSData*)CFBridgingRelease(CGDataProviderCopyData(imageDataProvider));
            iconData = [[NSData alloc] initWithData:UIImagePNGRepresentation( self.userIconImgView.image )];
            CommonUtil *commonUtil = [[CommonUtil alloc] init];
            iconMimeType = [commonUtil mimeTypeByGuessingFromData:iconData];
            DLog(@"%@", iconMimeType);
        }

        [[UserManager sharedManager] putUserInfo:putUser imageData:(NSData *)iconData imageName:(NSString *)iconName mimeType:(NSString *)iconMimeType block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
            
            if( isLoding && [isLoding boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }
            if(error){
                DLog(@"%@", error);
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorUserUpdate", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];

            }else{
                
                self.profileViewController.isLoading = NO;
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgSaved", nil)];
            
                CATransition* transition = [CATransition animation];
                transition.duration = 0.4;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                transition.type = kCATransitionReveal;
                transition.subtype = kCATransitionFromLeft;  // kCATransitionFromLeft kCATransitionFromTop
                [self.navigationController.view.layer addAnimation:transition forKey:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }];
        
    }

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
