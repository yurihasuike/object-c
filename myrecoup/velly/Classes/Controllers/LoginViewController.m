//
//  LoginViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/02/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "LoginViewController.h"
#import "RegistViewController.h"
#import "RegistInputViewController.h"
#import "NoPasswdViewController.h"
#import "UserManager.h"
#import "SVProgressHUD.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "CSFlexibleTapAreaButton.h"
#import "SettingManager.h"
#import "STTwitter.h"
#import "Defines.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController ()

@property (nonatomic, strong) STTwitterAPI *twitter;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *noPasswdLinkBtn;

@property (weak, nonatomic) IBOutlet FormTextField *mailTextField;
@property (weak, nonatomic) IBOutlet FormTextField *passwdTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *twLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginBtn;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollSubView;

@property (strong, nonatomic) UserManager *userManager;

@end

@implementation LoginViewController

@synthesize mailTextField, passwdTextField;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    // パスワードを忘れた方画面リンクボタン
    [_noPasswdLinkBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_noPasswdLinkBtn.layer setBorderWidth:1.0];
    [_noPasswdLinkBtn.layer setCornerRadius:15.0];
    _noPasswdLinkBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    // ブラウザ起動時はコメント解除
    [self.noPasswdLinkBtn addTarget:self action:@selector(noPasswdLinkAction:) forControlEvents:UIControlEventTouchUpInside];

    // 画面上をタップした場合にはキーボード解除
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    // メールアドレスフォーム
    mailTextField.keyboardType     = UIKeyboardTypeEmailAddress;       // UIKeyboardTypeASCIICapable
    passwdTextField.keyboardType   = UIKeyboardTypeAlphabet;
    [passwdTextField setSecureTextEntry:YES];

    // スクロール可能へ
    //self.scrollView.delegate = self;
    
    //self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 598);
    //self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [[UIScreen mainScreen]bounds].size.height + 40.0f);

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // ナビゲーションバー消去
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    if(!_userManager) {
        _userManager = [UserManager sharedManager];
    }
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"Login"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // メールフォームをアクティブにする場合
    // [_mailTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidLayoutSubviews {
    if([[UIScreen mainScreen]bounds].size.height <= 480){
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height + 120.0f);
    }else{
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height + 40.0f);
    }
    [self.scrollView flashScrollIndicators];
}

// ステータスバー設定
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (void)dismissKeyboard
{
    // キーボード入力解除
    [self.view endEditing:YES];
}

#pragma mark Action Method

- (IBAction)loginAction:(id)sender {
    DLog(@"LoginView loginAction");
    
    // ---------------------------------------
    // GA EVENT
    // ---------------------------------------
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin" value:nil screen:@"Login"];
    
    NSDictionary *params = @{ @"email" : self.mailTextField.text,
                              @"password" : self.passwdTextField.text };
    _userManager = [_userManager initWithSignupAttributes:params icon:nil];
    NSString *error = [_userManager validateLogin];
    if([error length]) {
        // input error
        
        // ---------------------------------------
        // GA EVENT
        // ---------------------------------------
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin-invalid" value:nil screen:@"Login"];
        
        UIAlertView *alert = [[UIAlertView alloc]init];
        alert = [[UIAlertView alloc]
                 initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    }else{
        // API login

        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoding = vConfig[@"LoadingPostDisplay"];
        if( isLoding && [isLoding boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        
        [_userManager sendLogin:nil block:^(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error) {
            
            if( isLoding && [isLoding boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }
            if(result_code.longLongValue == API_USER_LOGIN_RESPONSE_CODE_ERROR_INVALID.longLongValue){
                // login error
                
                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin-login-ng" value:nil screen:@"Login"];
                
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiCautionLoginCheckInvalid", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];

            }else if(result_code.longLongValue == API_RESPONSE_CODE_SUCCESS.longLongValue){
                // login success
                
                // deviceToken check
                NSString *dToken = [Configuration loadDevToken];
                if(dToken){
                    [[SettingManager sharedManager] postDeviceToken:aToken dToken:dToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
                        // flg clear
                        [Configuration saveDiffDevToken:(NSInteger *)VLISACTIVENON];
#ifdef DEBUG
                        if(error){
                            // error
                            NSString *errMsg = NSLocalizedString(@"ApiErrorDeviceToken", nil);
                            errMsg = [errMsg stringByAppendingString:[result_code stringValue]];
                            UIAlertView *alert = [[UIAlertView alloc]init];
                            alert = [[UIAlertView alloc]
                                     initWithTitle:errMsg message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
#endif
                    }];
                }
                
                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin-login-ok" value:nil screen:@"Login"];
                
                
                // SEND REPRO EVENT
                [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGIN]
                                     properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                      [Configuration loadUserPid],
                                                  DEFINES_REPROEVENTPROPNAME[TYPE] :
                                                      [NSNumber numberWithInteger:EMAIL]}];

                self.mailTextField.text   = @"";
                self.passwdTextField.text = @"";
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ApiCautionLoginCheckSuccess", nil)];
                [self performSelector:@selector(closeBtnAction) withObject:nil afterDelay:0.2f];

            }else if([result_code isEqualToNumber:API_USER_LOGIN_RESPONSE_CODE_ERROR_NOTFOUND]){
                // not found
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorLoginNotFound", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }else{
                // error
                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin-login-err" value:nil screen:@"Login"];

                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorLogin", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

- (IBAction)twLoginAction:(id)sender {
    DLog(@"LoginView twLoginAction");
    
    NSString *twToken       = [Configuration loadLoginTWAccessToken];
    NSString *twTokenSecret = [Configuration loadLoginTWAccessTokenSecret];
    if([twToken length] > 0 && [twTokenSecret length] > 0){
    
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
                
                // TODO 認証へ         TODO エラーに応じて、会員登録画面へ移動させるか
                [self twLoginConnect];
                
            }else{
                
                // ログインOK
                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin-twlogin-ok" value:nil screen:@"Login"];
                
                
                // SEND REPRO EVENT
                [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGIN]
                                     properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                      [Configuration loadUserPid],
                                                  DEFINES_REPROEVENTPROPNAME[TYPE] :
                                                      [NSNumber numberWithInteger:TWITTER],
                                                  }];
                
                if(twToken){
                    [Configuration saveTWAccessToken:twToken];
                }
                if(twTokenSecret){
                    [Configuration saveTWAccessTokenSecret:twTokenSecret];
                }
                self.mailTextField.text   = @"";
                self.passwdTextField.text = @"";
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ApiCautionLoginCheckSuccess", nil)];
                [self performSelector:@selector(closeBtnAction) withObject:nil afterDelay:0.2f];
                
            }
        }];

        
    }else{
    
        [self twLoginConnect];
    
    }
    
}

- (void)twLoginConnect
{
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
        
        NSString *twEmail = @"";
        NSString *twName  = screenName;
        NSString *twToken = oauthToken;
        NSString *twTokenSecret = oauthTokenSecret;
        
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
                
                // 会員登録へ   400
                NSString *twEmailSuffix = @"";
                if(twEmail){
                    NSRange range = [twEmail rangeOfString:@"@"];
                    twEmailSuffix = [twEmail substringToIndex:range.location];
                    //DLog(@"fbEmailSuffix : %@", fbEmailSuffix);
                }
                
                // ---------------
                // user regist
                // ---------------
                RegistInputViewController *riview = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"RegistInputViewController"];
                [riview setTwToken:twToken];
                [riview setTwTokenSecret:twTokenSecret];
                [riview setInputEmail: twEmail];
                [riview setInputUserName: twName];
                [riview setInputUserId:twEmailSuffix];
                
                [self.navigationController pushViewController:riview animated:YES];
                
                
            }else{
                
                // ログインOK
                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin-twlogin-ok" value:nil screen:@"Login"];
                
                // SEND REPRO EVENT
                [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGIN]
                                     properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                      [Configuration loadUserPid],
                                                  DEFINES_REPROEVENTPROPNAME[TYPE] :
                                                      [NSNumber numberWithInteger:TWITTER],
                                                  }];

                if(twToken){
                    [Configuration saveTWAccessToken:twToken];
                }
                if(twTokenSecret){
                    [Configuration saveTWAccessTokenSecret:twTokenSecret];
                }

                self.mailTextField.text   = @"";
                self.passwdTextField.text = @"";
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ApiCautionLoginCheckSuccess", nil)];
                [self performSelector:@selector(closeBtnAction) withObject:nil afterDelay:0.2f];
                
            }
        }];
        
    } errorBlock:^(NSError *error) {
        DLog(@"-- %@", [error localizedDescription]);
    }];
}

- (IBAction)fbLoginAction:(id)sender {
    DLog(@"LoginView fbLoginAction");
    
    NSString *fbExistToken = [Configuration loadLoginFBAccessToken];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        // accessToken が取れるならログイン処理完了済
        
        NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
        
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

                // 会員登録へ 400
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         NSLog(@"fetched user:%@", result);
                         NSString *fbEmail = result[@"email"];
                         NSString *fbName  = result[@"name"];
                         NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
                         
                         if(result_code.longLongValue != API_RESPONSE_CODE_ERROR_CONFLICT.longLongValue){
                             if(fbToken){
                                 [Configuration saveFBAccessToken:fbToken];
                                 [Configuration saveLoginFBAccessToken:fbToken];
                             }
                         }
                         
                         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", fbToken]];
                         NSURLRequest *urlReq = [[NSURLRequest alloc] initWithURL:url];
                         [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                             UIImage *iConImg = nil;
                             if (connectionError) {
                                 //何回かに一回、何故かここでコケた
                                 NSLog(@"connectionError %@", [connectionError description]);
                             }else{
                                 // profile icon
                                 iConImg = [UIImage imageWithData:data];
                             }
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
                             
                         }];
                         
                     }
                 }];

                
            }else{
                
                // ログインOK
                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin-fblogin-ok" value:nil screen:@"Login"];
                
                // SEND REPRO EVENT
                [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGIN]
                                     properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                      [Configuration loadUserPid],
                                                  DEFINES_REPROEVENTPROPNAME[TYPE] :
                                                      [NSNumber numberWithInteger:FACEBOOK],
                                                  }];
                
                if(fbToken){
                    [Configuration saveFBAccessToken:fbToken];
                    [Configuration saveLoginFBAccessToken:fbToken];
                }
                self.mailTextField.text   = @"";
                self.passwdTextField.text = @"";
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ApiCautionLoginCheckSuccess", nil)];
                [self performSelector:@selector(closeBtnAction) withObject:nil afterDelay:0.2f];

            }
        }];
        
    }else if(fbExistToken){
    
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
        
        [[UserManager sharedManager] sendFbUserLogin:nil fbToken:fbExistToken block:^(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error) {
            
            if( isLoading && [isLoading boolValue] == YES ){
                // clear loading
                [SVProgressHUD dismiss];
            }
            
            if(error){
                
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
                                
                                // 会員登録へ  400
                                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *fbError) {
                                     if (!fbError) {
                                         DLog(@"fetched user:%@", result);
                                         NSString *fbEmail = result[@"email"];
                                         NSString *fbName  = result[@"name"];
                                         NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
                                         
                                         if(result_code.longLongValue != API_RESPONSE_CODE_ERROR_CONFLICT.longLongValue){
                                             if(fbToken){
                                                 [Configuration saveFBAccessToken:fbToken];
                                                 [Configuration saveLoginFBAccessToken:fbToken];
                                             }
                                         }
                                         
                                         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", fbToken]];
                                         NSURLRequest *urlReq = [[NSURLRequest alloc] initWithURL:url];
                                         [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                             UIImage *iConImg = nil;
                                             if (connectionError) {
                                                 //何回かに一回、何故かここでコケた
                                                 DLog(@"connectionError %@", [connectionError description]);
                                             }else{
                                                 // profile icon
                                                 iConImg = [UIImage imageWithData:data];
                                             }
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
                                             
                                         }];
                                     }
                                 }];
                                
                                
                                //}];
                                
                            }
                        }
                    }
                }];

                
            }else{
                
                // ログインOK
                // ---------------------------------------
                // GA EVENT
                // ---------------------------------------
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin-fblogin-ok" value:nil screen:@"Login"];
                
                // SEND REPRO EVENT
                [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGIN]
                                     properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                      [Configuration loadUserPid],
                                                  DEFINES_REPROEVENTPROPNAME[TYPE] :
                                                      [NSNumber numberWithInteger:FACEBOOK],
                                                  }];
                
                if(fbExistToken){
                    [Configuration saveFBAccessToken:fbExistToken];
                    [Configuration saveLoginFBAccessToken:fbExistToken];
                }
                self.mailTextField.text   = @"";
                self.passwdTextField.text = @"";
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ApiCautionLoginCheckSuccess", nil)];
                [self performSelector:@selector(closeBtnAction) withObject:nil afterDelay:0.2f];
                
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
                        

                            NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
                        
                            NSString *fbUserID = [FBSDKAccessToken currentAccessToken].userID;
                            NSDate *expirationDate = [FBSDKAccessToken currentAccessToken].expirationDate;
                            NSString *appID = [FBSDKAccessToken currentAccessToken].appID;
                            DLog(@"appID : %@", appID);
                            DLog(@"fbUserID : %@", fbUserID);
                            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
                            NSString *expirationDateStr = [formatter stringFromDate:expirationDate];
                            DLog(@"expirationDate : %@", expirationDateStr);
                        
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
                                
                                    // 会員登録へ  400
                                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                                     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *fbError) {
                                         if (!fbError) {
                                             DLog(@"fetched user:%@", result);
                                             NSString *fbEmail = result[@"email"];
                                             NSString *fbName  = result[@"name"];
                                             NSString *fbToken = [FBSDKAccessToken currentAccessToken].tokenString;
                                             
                                             if(result_code.longLongValue != API_RESPONSE_CODE_ERROR_CONFLICT.longLongValue){
                                                 if(fbToken){
                                                     [Configuration saveFBAccessToken:fbToken];
                                                     [Configuration saveLoginFBAccessToken:fbToken];
                                                 }
                                             }
                                         
                                             NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", fbToken]];
                                             NSURLRequest *urlReq = [[NSURLRequest alloc] initWithURL:url];
                                             [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                 UIImage *iConImg = nil;
                                                 if (connectionError) {
                                                     //何回かに一回、何故かここでコケた
                                                     DLog(@"connectionError %@", [connectionError description]);
                                                 }else{
                                                     // profile icon
                                                     iConImg = [UIImage imageWithData:data];
                                                 }
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
                                             
                                             }];
                                         }
                                     }];
                                
                                }else{
                                
                                    // ログインOK
                                    // ---------------------------------------
                                    // GA EVENT
                                    // ---------------------------------------
                                    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapLogin-fblogin-ok" value:nil screen:@"Login"];
                                
                                    // SEND REPRO EVENT
                                    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGIN]
                                                         properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                                          [Configuration loadUserPid],
                                                                      DEFINES_REPROEVENTPROPNAME[TYPE] :
                                                                          [NSNumber numberWithInteger:FACEBOOK],
                                                                      }];
                                    
                                    if(fbToken){
                                        [Configuration saveFBAccessToken:fbToken];
                                        [Configuration saveLoginFBAccessToken:fbToken];
                                    }
                                    self.mailTextField.text   = @"";
                                    self.passwdTextField.text = @"";
                                
                                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"ApiCautionLoginCheckSuccess", nil)];
                                    [self performSelector:@selector(closeBtnAction) withObject:nil afterDelay:0.2f];
                                
                                }
                            }];
                            
                        //}];
                        
                    }
                }
            }
        }];
    }
    
}

- (void)closeBtnAction
{
    DLog(@"LoginView onClose");
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)backAction:(id)sender
{
    DLog(@"LoginView onClose");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) noPasswdLinkAction: (UIButton *)button
{
    DLog(@"LoginView noPasswdLinkAction");
    
    // パスワード再発行のURLを起動
    // ブラウザ起動パターン
    //NSString *urlString = @"http://up.myreco.me/nopasswd";
    //NSURL *url = [NSURL URLWithString:urlString];
    //[[UIApplication sharedApplication] openURL:url];
    
    NoPasswdViewController *noPasswdWebcontroller = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"NoPasswdViewController"];
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *strUrl = vConfig[@"WebViewURLNoPasswd"];
    noPasswdWebcontroller.webURLPath = strUrl;
    
    [self.navigationController presentViewController:noPasswdWebcontroller animated:YES completion:nil];
    
}

@end
