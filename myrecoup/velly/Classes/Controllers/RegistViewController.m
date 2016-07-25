//
//  RegistViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/02/10.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RegistViewController.h"
#import "RegistInputViewController.h"
#import "LoginViewController.h"
#import "NoPasswdViewController.h"
#import "NSString+Validation.h"
#import "UserManager.h"
#import "SVProgressHUD.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "CoreImageHelper.h"
#import "STTwitter.h"
#import "RegistIntroductionViewController.h"
#import "CSFlexibleTapAreaButton.h"
#import "Defines.h"

#import <QuartzCore/QuartzCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Accounts/Accounts.h>

@interface RegistViewController ()

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollSubView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginLinkBtn;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *termLinkBtn;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *policyLinkBtn;
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
@property (weak, nonatomic) IBOutlet UIButton *twRegistBtn;
@property (weak, nonatomic) IBOutlet UIButton *fbRegistBtn;
@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation RegistViewController

@synthesize mailTextField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ナビゲーション背景色
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        //[self.navigationController.navigationBar setBarTintColor:NAVBAR_BACKGROUNDCOLOR];
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    else {
        // ios6
        //[self.navigationController.navigationBar setTintColor:NAVBAR_BACKGROUNDCOLOR];
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
        
    }
    // ナビゲーションバー消去
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    self.view.backgroundColor = [UIColor clearColor];

    // 背景全面画像
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [[UIImage imageNamed:@"bg_login.png"] drawInRect:self.view.bounds];
//    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImage];

    UIButton *closeBtnView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [closeBtnView setBackgroundImage:[UIImage imageNamed:@"icon_close.png"]
                            forState:UIControlStateNormal];
    [closeBtnView addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtnView];
    self.navigationItem.leftBarButtonItem = closeButtonItem;
    
    // ログイン画面リンクボタン
    [_loginLinkBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_loginLinkBtn.layer setBorderWidth:1.0];
    [_loginLinkBtn.layer setCornerRadius:15.0];
    
    // 利用規約
    _termLinkBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self.termLinkBtn addTarget:self action:@selector(termLinkAction) forControlEvents:UIControlEventTouchUpInside];
    
    // プライバシーポリシー
    _policyLinkBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self.policyLinkBtn addTarget:self action:@selector(policyLinkAction) forControlEvents:UIControlEventTouchUpInside];

    // メールアドレスフォーム
    mailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    // メールアドレス登録ボタン
    [self.registBtn addTarget:self action:@selector(registAction:) forControlEvents:UIControlEventTouchUpInside];
    
    mailTextField.placeholder = NSLocalizedString(@"TFPHolderRegistEmail", nil);
    [mailTextField setRequired:YES];

    // 画面上をタップした場合にはキーボード解除
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    // スクロール可能へ
    if([[UIScreen mainScreen]bounds].size.height <= 480){
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height + 120.0f);
    }else{
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height + 40.0f);
    }
    [self.scrollSubView setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.scrollSubView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrollSubView setFrame:self.scrollView.frame];

    self.scrollView.scrollEnabled = YES;
    
}

-(void)viewDidLayoutSubviews {
    if([[UIScreen mainScreen]bounds].size.height <= 480){
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height + 120.0f);
    }else{
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height + 40.0f);
    }
    [self.scrollView flashScrollIndicators];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // ナビゲーションバー消去
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    // ログイン済みであるか
    NSString *vellyToken = [Configuration loadAccessToken];
    if([vellyToken length]){
        // ログイン済み
        // 画面を閉じる
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }

    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"Signup"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissKeyboard
{
    // キーボード入力解除
    [self.view endEditing:YES];
}

- (void)registAction:(id)sender {

    // ---------------------------------------
    // GA EVENT
    // ---------------------------------------
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist" value:nil screen:@"Signup"];

    // メールアドレスチェック
    //NSDictionary *attributes = @{@"email":[self.mailTextField.text trim]       ?: [NSNull null],};
    //NSString *input_email = [self.mailTextField.text trim] ? : [NSNull null];
    NSString *input_email = [self.mailTextField.text trim];
    
    if(![input_email length]) {
        // メールアドレス未入力
        
        // ---------------------------------------
        // GA EVENT
        // ---------------------------------------
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-email-empty" value:nil screen:@"Signup"];

        UIAlertView *alert = [[UIAlertView alloc]init];
        alert = [[UIAlertView alloc]
                 initWithTitle:NSLocalizedString(@"ValidateUserEmptyEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }else if(![input_email isEmail]){
        // invalid Email

        // ---------------------------------------
        // GA EVENT
        // ---------------------------------------
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-email-invalid" value:nil screen:@"Signup"];

        UIAlertView *alert = [[UIAlertView alloc]init];
        alert = [[UIAlertView alloc]
                 initWithTitle:NSLocalizedString(@"ValidateUserInvalidEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }else{
        // Loading
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoding = vConfig[@"LoadingPostDisplay"];
        if( isLoding && [isLoding boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingCheck", nil) maskType:SVProgressHUDMaskTypeBlack];
        }

        [[UserManager sharedManager] checkUserEmail:input_email user_id:nil block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {

            if( isLoding && [isLoding boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }
            if(result_code.longLongValue == API_CHECK_EMAIL_RESPONSE_CODE_ERROR_INVALID.longLongValue){
                // exist user error

                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-email-exist" value:nil screen:@"Signup"];

                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiCautionRegistCheckExist", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];

            }else if(result_code.longLongValue == API_CHECK_EMAIL_RESPONSE_CODE_SUCCESS.longLongValue){
                // no exist email -> ok

                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-email-ok" value:nil screen:@"Signup"];
                
                NSString *emailSuffix = @"";
                if(input_email){
                    NSRange range = [input_email rangeOfString:@"@"];
                    emailSuffix = [input_email substringToIndex:range.location];
                    //DLog(@"fbEmailSuffix : %@", emailSuffix);
                }
                
                RegistInputViewController *riview = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"RegistInputViewController"];
                [riview setInputEmail: input_email];
                [riview setInputUserId:emailSuffix];

                //    CATransition *transition = [CATransition animation];
                //    transition.duration = 0.4;
                //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                //    transition.type = kCATransitionPush;
                //    transition.subtype = kCATransitionFromRight;
                //    [self.navigationController.view.layer addAnimation:transition forKey:nil];

                [self.navigationController pushViewController:riview animated:YES];
                //
                self.mailTextField.text = @"";

            }else{
                // error
                DLog(@"error = %@", error);

                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-email-err" value:nil screen:@"Signup"];

                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorExistEmail", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }

        }];
    }
}


// regist TW
- (IBAction)twRegistAction:(id)sender {
    DLog(@"SignupView twRegistAction");

    //DLog(@"OAUTH_TW_API_KEY : %@", OAUTH_TW_API_KEY);
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:OAUTH_TW_API_KEY
                                                 consumerSecret:OAUTH_TW_API_SECRET];
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        
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

}


- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebView
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];

    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        DLog(@"-- screenName: %@", screenName);

        NSString *twEmail = @"";
        NSString *twName  = screenName;
        NSString *twToken = oauthToken;
        NSString *twTokenSecret = oauthTokenSecret;
        
        
        // TW Login check : TWログインできなかったら、会員登録へ
        // --------------------
        // send login API
        // --------------------
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoading = vConfig[@"LoadingPostDisplay"];
        // must
        isLoading = @"YES";
        if( isLoading && [isLoading boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        
        [[UserManager sharedManager] sendTwUserLogin:nil twToken:twToken twTokenSecret:twTokenSecret block:^(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error) {
            
            if( isLoading && [isLoading boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }
            
            if(error){
                
                if(result_code.longLongValue != API_RESPONSE_CODE_ERROR_CONFLICT.longLongValue){
                    if(twToken){
                        [Configuration saveTWAccessToken:twToken];
                        [Configuration saveLoginTWAccessToken:twToken];
                    }
                    if(twTokenSecret){
                        [Configuration saveTWAccessTokenSecret:twTokenSecret];
                        [Configuration saveLoginTWAccessTokenSecret:twTokenSecret];
                    }
                }
                
                [_twitter getAccountVerifyCredentialsWithSuccessBlock:^(NSDictionary *account) {
                    
                    NSString *iConPath = account[@"profile_image_url"];
                    if(iConPath){
                        
                        // size pattern : mini / normal / bigger / original
                        NSString *iConPathReplace = [iConPath stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
                        
                        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_queue_t q_main = dispatch_get_main_queue();
                        dispatch_async(q_global, ^{
                            
                            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: iConPathReplace]]];
                            dispatch_async(q_main, ^{
                                
                                // ---------------
                                // user regist
                                // ---------------
                                
                                NSString *twEmailSuffix = @"";
                                if(twEmail && [twEmail length] > 0){
                                    NSRange range = [twEmail rangeOfString:@"@"];
                                    twEmailSuffix = [twEmail substringToIndex:range.location];
                                    //DLog(@"fbEmailSuffix : %@", twEmailSuffix);
                                }
                                
                                RegistInputViewController *riview = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"RegistInputViewController"];
                                [riview setTwToken:twToken];
                                [riview setTwTokenSecret:twTokenSecret];
                                [riview setInputEmail: twEmail];
                                [riview setInputUserName: twName];
                                [riview setInputUserId:twEmailSuffix];
                                if(image){
                                    [riview setSocialImg:image];
                                }
                                
                                [self.navigationController pushViewController:riview animated:YES];
                                
                            });
                        });
                        
                    }else{
                        
                        // ---------------
                        // user regist
                        // ---------------
                        
                        NSString *twEmailSuffix = @"";
                        if(twEmail){
                            NSRange range = [twEmail rangeOfString:@"@"];
                            twEmailSuffix = [twEmail substringToIndex:range.location];
                            //DLog(@"fbEmailSuffix : %@", twEmailSuffix);
                        }
                        
                        RegistInputViewController *riview = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"RegistInputViewController"];
                        [riview setTwToken:twToken];
                        [riview setTwTokenSecret:twTokenSecret];
                        [riview setInputEmail: twEmail];
                        [riview setInputUserName: twName];
                        [riview setInputUserId:twEmailSuffix];
                        
                        [self.navigationController pushViewController:riview animated:YES];
                    }
                    
                } errorBlock:^(NSError *error) {
                    DLog(@"error : %@", error);
                    
                    // ---------------
                    // user regist
                    // ---------------
                    
                    NSString *twEmailSuffix = @"";
                    if(twEmail){
                        NSRange range = [twEmail rangeOfString:@"@"];
                        twEmailSuffix = [twEmail substringToIndex:range.location];
                        //DLog(@"fbEmailSuffix : %@", twEmailSuffix);
                    }
                    
                    RegistInputViewController *riview = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"RegistInputViewController"];
                    [riview setTwToken:twToken];
                    [riview setTwTokenSecret:twTokenSecret];
                    [riview setInputEmail: twEmail];
                    [riview setInputUserName: twName];
                    [riview setInputUserId:twEmailSuffix];
                    
                    [self.navigationController pushViewController:riview animated:YES];
                    
                }];
                
                
            }else{
                
                if(twToken){
                    [Configuration saveTWAccessToken:twToken];
                    [Configuration saveLoginTWAccessToken:twToken];
                }
                if(twTokenSecret){
                    [Configuration saveTWAccessTokenSecret:twTokenSecret];
                    [Configuration saveLoginTWAccessTokenSecret:twTokenSecret];
                }
                
                // ログインOK
                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-twlogin-ok" value:nil screen:@"Signup"];
                
                // SEND REPRO EVENT
                [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGIN]
                                     properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                      [Configuration loadUserPid],
                                                  DEFINES_REPROEVENTPROPNAME[TYPE] :
                                                      [NSNumber numberWithInteger:TWITTER],
                                                  }];
                
                self.mailTextField.text   = @"";
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ApiCautionLoginCheckSuccess", nil)];
                [self performSelector:@selector(closeBtnAction) withObject:nil afterDelay:0.2f];
                
            }
        }];

    } errorBlock:^(NSError *error) {
        DLog(@"-- %@", [error localizedDescription]);
    }];
}


// FB登録
- (IBAction)fbRegistAction:(id)sender {
    DLog(@"SignupView fbRegistAction");
    
    if ([FBSDKAccessToken currentAccessToken]) {
        // accessToken が取れるならログイン処理は完了している

        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
                 NSString *fbEmail = result[@"email"];
                 NSString *fbName  = result[@"name"];
                 NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
                 
                 // Login check : FBログインできなかったら、会員登録へ
                 // --------------------
                 // send login API
                 // --------------------
                 NSDictionary *vConfig   = [ConfigLoader mixIn];
                 NSString *isLoading = vConfig[@"LoadingPostDisplay"];
                 // must
                 isLoading = @"YES";
                 if( isLoading && [isLoading boolValue] == YES ){
                     // Loading
                     [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
                 }
                 [[UserManager sharedManager] sendFbUserLogin:nil fbToken:fbToken block:^(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error) {
                     
                     if( isLoading && [isLoading boolValue] == YES ){
                         // clear loading
                         [SVProgressHUD dismiss];
                     }
                     if(error){
                         
                         if(result_code.longLongValue != API_RESPONSE_CODE_ERROR_CONFLICT.longLongValue){
                             if(fbToken){
                                 [Configuration saveFBAccessToken:fbToken];
                                 [Configuration saveLoginFBAccessToken:fbToken];
                             }
                         }
                         
                         // 会員登録へ
                         
                         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", fbToken]];
                         NSURLRequest *urlReq = [[NSURLRequest alloc] initWithURL:url];
                         [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                             UIImage *iConImg = nil;
                             if (connectionError) {
                                 //何回かに一回、何故かここでコケた
                                 NSLog(@"connectionError %@", [connectionError description]);
                                 
                                 // ---------------
                                 // user regist
                                 // ---------------
                                 
                                 NSString *fbEmailSuffix = @"";
                                 if(fbEmail){
                                     NSRange range = [fbEmail rangeOfString:@"@"];
                                     fbEmailSuffix = [fbEmail substringToIndex:range.location];
                                     //DLog(@"fbEmailSuffix : %@", fbEmailSuffix);
                                 }
                                 
                                 RegistInputViewController *riview = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"RegistInputViewController"];
                                 [riview setFbToken:fbToken];
                                 [riview setInputEmail: fbEmail];
                                 [riview setInputUserName: fbName];
                                 [riview setInputUserId:fbEmailSuffix];
                                 if(iConImg){
                                     [riview setSocialImg:iConImg];
                                 }
                                 
                                 //    CATransition *transition = [CATransition animation];
                                 //    transition.duration = 0.4;
                                 //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                 //    transition.type = kCATransitionPush;
                                 //    transition.subtype = kCATransitionFromRight;
                                 //    [self.navigationController.view.layer addAnimation:transition forKey:nil];
                                 
                                 [self.navigationController pushViewController:riview animated:YES];
                                 
                             }else{
                                 // profile icon
                                 iConImg = [UIImage imageWithData:data];
                                 
                                 [CoreImageHelper centerCroppingImageWithImage:iConImg atSize:CGSizeMake(100.0f, 100.0f) completion:^(UIImage *resultImg){
                                     
                                     // ---------------
                                     // user regist
                                     // ---------------
                                     
                                     NSString *fbEmailSuffix = @"";
                                     if(fbEmail){
                                         NSRange range = [fbEmail rangeOfString:@"@"];
                                         fbEmailSuffix = [fbEmail substringToIndex:range.location];
                                         //DLog(@"fbEmailSuffix : %@", fbEmailSuffix);
                                     }
                                     
                                     RegistInputViewController *riview = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"RegistInputViewController"];
                                     [riview setFbToken:fbToken];
                                     [riview setInputEmail: fbEmail];
                                     [riview setInputUserName: fbName];
                                     [riview setInputUserId:fbEmailSuffix];
                                     if(iConImg){
                                         [riview setSocialImg:resultImg];
                                     }
                                     
                                     //    CATransition *transition = [CATransition animation];
                                     //    transition.duration = 0.4;
                                     //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                     //    transition.type = kCATransitionPush;
                                     //    transition.subtype = kCATransitionFromRight;
                                     //    [self.navigationController.view.layer addAnimation:transition forKey:nil];
                                     
                                     [self.navigationController pushViewController:riview animated:YES];
                                     
                                 }];
                                 
                             }
                             
                         }];
                         
                     }else{
                         
                         if(fbToken){
                             [Configuration saveFBAccessToken:fbToken];
                             [Configuration saveLoginFBAccessToken:fbToken];
                         }
                     
                         // ログインOK
                         // ---------------------------------------
                         // GA EVENT
                         // ---------------------------------------
                         [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-fblogin-ok" value:nil screen:@"Signup"];
                         
                         // SEND REPRO EVENT
                         [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGIN]
                                              properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                               [Configuration loadUserPid],
                                                           DEFINES_REPROEVENTPROPNAME[TYPE] :
                                                               [NSNumber numberWithInteger:FACEBOOK],
                                                           }];

                         self.mailTextField.text   = @"";
                         
                         [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ApiCautionLoginCheckSuccess", nil)];
                         [self performSelector:@selector(closeBtnAction) withObject:nil afterDelay:0.2f];

                     }
                 }];
                 
             }
         }];
        
        
    }else{

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
                    // Do work
                    DLog(@"login with read email permission succeeded.");

                    if([FBSDKAccessToken currentAccessToken]){
                        
                        
                        // FB申請＋投稿時FB送信を行なう際に解除
                        //[login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                        
                        
                            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                 
                                 if (!error) {
                                     NSLog(@"fetched user:%@", result);
                                     //NSString *fbPID   = result[@"id"];
                                     NSString *fbEmail = result[@"email"];
                                     NSString *fbName  = result[@"name"];
                                     NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;


                                     // Login check : FBログインできなかったら、会員登録へ
                                     // --------------------
                                     // send login API
                                     // --------------------
                                     NSDictionary *vConfig   = [ConfigLoader mixIn];
                                     NSString *isLoading = vConfig[@"LoadingPostDisplay"];
                                     // must
                                     isLoading = @"YES";
                                     if( isLoading && [isLoading boolValue] == YES ){
                                         // Loading
                                         [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
                                     }
                                     
                                     [[UserManager sharedManager] sendFbUserLogin:nil fbToken:fbToken block:^(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *fbError) {
                                     
                                         if( isLoading && [isLoading boolValue] == YES ){
                                             // clear loading
                                             [SVProgressHUD dismiss];
                                         }
                                         if(fbError){
                                         
                                             if(result_code.longLongValue != API_RESPONSE_CODE_ERROR_CONFLICT.longLongValue){
                                                 if(fbToken){
                                                     [Configuration saveFBAccessToken:fbToken];
                                                     [Configuration saveLoginFBAccessToken:fbToken];
                                                 }
                                             }
                                             
                                             // 会員登録へ
                                         
                                             NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", fbToken]];
                                             NSURLRequest *urlReq = [[NSURLRequest alloc] initWithURL:url];
                                             [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                 UIImage *iConImg = nil;
                                                 if (connectionError) {
                                                     //何回かに一回、何故かここでコケた
                                                     DLog(@"connectionError %@", [connectionError description]);
                                                 
                                                     // ---------------
                                                     // user regist
                                                     // ---------------
                                                 
                                                     NSString *fbEmailSuffix = @"";
                                                     if(fbEmail){
                                                         NSRange range = [fbEmail rangeOfString:@"@"];
                                                         fbEmailSuffix = [fbEmail substringToIndex:range.location];
                                                         //DLog(@"fbEmailSuffix : %@", fbEmailSuffix);
                                                     }
                                                 
                                                     RegistInputViewController *riview = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"RegistInputViewController"];
                                                     [riview setFbToken:fbToken];
                                                     [riview setInputEmail: fbEmail];
                                                     [riview setInputUserName: fbName];
                                                     [riview setInputUserId:fbEmailSuffix];
                                                     if(iConImg){
                                                         [riview setSocialImg:iConImg];
                                                     }
                                                 
                                                     //    CATransition *transition = [CATransition animation];
                                                     //    transition.duration = 0.4;
                                                     //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                                     //    transition.type = kCATransitionPush;
                                                     //    transition.subtype = kCATransitionFromRight;
                                                     //    [self.navigationController.view.layer addAnimation:transition forKey:nil];
                                                 
                                                     [self.navigationController pushViewController:riview animated:YES];
                                                 
                                                 }else{
                                                     // profile icon
                                                     iConImg = [UIImage imageWithData:data];
                                                 
                                                     [CoreImageHelper centerCroppingImageWithImage:iConImg atSize:CGSizeMake(100.0f, 100.0f) completion:^(UIImage *resultImg){
                                                     
                                                         // ---------------
                                                         // user regist
                                                         // ---------------
                                                     
                                                         NSRange range = [fbEmail rangeOfString:@"@"];
                                                         NSString *fbEmailSuffix = [fbEmail substringToIndex:range.location];
                                                         //DLog(@"fbEmailSuffix : %@", fbEmailSuffix);
                                                     
                                                         RegistInputViewController *riview = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"RegistInputViewController"];
                                                         [riview setFbToken:fbToken];
                                                         [riview setInputEmail: fbEmail];
                                                         [riview setInputUserName: fbName];
                                                         [riview setInputUserId:fbEmailSuffix];
                                                         if(iConImg){
                                                             [riview setSocialImg:resultImg];
                                                         }
                                                     
                                                         //    CATransition *transition = [CATransition animation];
                                                         //    transition.duration = 0.4;
                                                         //    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                                         //    transition.type = kCATransitionPush;
                                                         //    transition.subtype = kCATransitionFromRight;
                                                         //    [self.navigationController.view.layer addAnimation:transition forKey:nil];
                                                     
                                                         [self.navigationController pushViewController:riview animated:YES];
                                                     
                                                     }];
                                                 }
                                             }];
                                         
                                         }else{
                                             
                                             if(fbToken){
                                                 [Configuration saveFBAccessToken:fbToken];
                                                 [Configuration saveLoginFBAccessToken:fbToken];
                                             }

                                             // ログインOK
                                             // ---------------------------------------
                                             // GA EVENT
                                             // ---------------------------------------
                                             [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapRegist-fblogin-ok" value:nil screen:@"Signup"];
                                         
                                             // SEND REPRO EVENT
                                             [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGIN]
                                                                  properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                                                   [Configuration loadUserPid],
                                                                               DEFINES_REPROEVENTPROPNAME[TYPE] :
                                                                                   [NSNumber numberWithInteger:FACEBOOK],
                                                                               }];
                                             
                                             self.mailTextField.text   = @"";
                                         
                                             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ApiCautionLoginCheckSuccess", nil)];
                                             [self performSelector:@selector(closeBtnAction) withObject:nil afterDelay:0.2f];

                                         }
                                    }];
                                 
                                 }
                             }];
                        
                            
                        //}];
                        
                        
                    }
                         
                }
            }
        }];

    }
    
}


- (IBAction)loginLinkAction:(id)sender {

    LoginViewController *loginView = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    loginView.view.backgroundColor = [UIColor clearColor];
    
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.5;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionPush;
//    transition.subtype = kCATransitionFromRight;
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];

    [self.navigationController pushViewController:loginView animated:YES];
    
}


- (void)clickButton
{
    DLog(@"SignupView clickButton");
}

- (void)onClose
{
    DLog(@"SignupView onClose");
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeAction:(id)sender {
    
    DLog(@"SignupView onClose");
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
}

- (void)closeBtnAction
{
    DLog(@"SignupView onClose");
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)termLinkAction
{
    DLog(@"SignupView termLinkAction");
    
    NoPasswdViewController *noPasswdWebcontroller = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"NoPasswdViewController"];
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *strUrl = vConfig[@"WebViewURLTerms"];
    noPasswdWebcontroller.webURLPath = strUrl;
    
    [self.navigationController presentViewController:noPasswdWebcontroller animated:YES completion:nil];
    
}

- (void)policyLinkAction
{
    DLog(@"SignupView policyLinkAction");
    
    NoPasswdViewController *noPasswdWebcontroller = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"NoPasswdViewController"];
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *strUrl = vConfig[@"WebViewURLPolicy"];
    noPasswdWebcontroller.webURLPath = strUrl;
    
    [self.navigationController presentViewController:noPasswdWebcontroller animated:YES completion:nil];
    
}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//     if ([segue.identifier isEqualToString:@"OpenSecondScene"]) {
//         // SecondViewController *secondViewController = segue.destinationViewController;
//         // secondViewController.someProperty = @"value";
//     }
//}


@end
