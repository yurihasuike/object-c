//
//  AppDelegate.m
//  velly
//
//  Created by m_saruwatari on 2015/02/05.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "AppDelegate.h"
#import "NaviViewController.h"
#import "RegistViewController.h"
#import "LoginViewController.h"
#import "ProfileEditViewController.h"
#import "PopularViewController.h"
#import "UserManager.h"
#import "SettingManager.h"
#import "VYNotification.h"
#import "NSNotification+Parameters.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "ConfigLoader.h"
#import "SVProgressHUD.h"
#import "StartView.h"
#import "ACTReporter.h"
#import "PostSelectFromLibraryViewController.h"
#import "InfoManager.h"
#import "Mixpanel.h"
#import "GAI.h"
#import "Defines.h"
#import "TrackingManager.h"
#import "CommonUtil.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SendBirdSDK/SendBirdSDK.h>
#import <AdDash/AdDash.h>
#import <Repro/Repro.h>

@import Firebase;

#include <AudioToolbox/AudioToolbox.h>

#define  MIXPANEL_TOKEN  @"ce62791f10ce47f00a5f30357b53b8ef"
#define  AdDASH_SERVICE_ID  @"151"
#define  AdDASH_SERVICE_KEY  @"UCcbF3EJzgob9Bqg"

@interface AppDelegate ()

@end

static NSString * const kMyRecoUpStoreName = @"MyRecoUp.sqlite";

@implementation AppDelegate

@synthesize viewController = _viewController;

// -----------------------------------
// app start or send push click start
// -----------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

//    NSArray *langs = [NSLocale preferredLanguages];
//    NSString *lang = [langs objectAtIndex:0];
//    DLog(@"%@", lang);  // ja
    
    // Initialize the library with your
    // Mixpanel project token, MIXPANEL_TOKEN
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // Later, you can get your instance with
    //Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    // Fabric
    [Fabric with:@[CrashlyticsKit]];
    
    //Send Bird
    [SendBird initAppId:SEND_BIRD_APP_ID];
    
    //MagicalRecord CoreData init
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];
    //[MagicalRecord setupCoreDataStackWithStoreNamed:kMyRecoUpStoreName];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kMyRecoUpStoreName];
    
    // AFNetworking init :  manage networkActivityIndicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    //[[AFNetworkActivityLogger sharedLogger] startLogging];

    // Google Analyticsの初期化
    [self initializeGoogleAnalytics];
    
    // AdDash
    [AdDash setServiceId:AdDASH_SERVICE_ID serviceKey:AdDASH_SERVICE_KEY];
    [AdDash sendConversion];
    
    [self setRepro];
    
    // myreco up - みんなで作る美容カタログアプリ（iOS）のインストール
    // Google iOS Download tracking snippet
    // To track downloads of your app, add this snippet to your
    // application delegate's application:didFinishLaunchingWithOptions: method.
    [ACTConversionReporter reportWithConversionID:@"937911876" label:@"hKwcCN-XvmAQxMydvwM" value:@"1.00" isRepeatable:NO];
    [ACTConversionReporter reportWithConversionID:@"937911876" label:@"ivQ6CK-dvmAQxMydvwM" value:@"1.00" isRepeatable:NO];
    
    // Firebase
    [FIRApp configure];

    // 共通設定値 初期化
    // UISwitch
    [[UISwitch appearance] setOnTintColor:USER_DISPLAY_NAME_COLOR];
    [[UINavigationBar appearance] setTintColor:HEADER_BG_COLOR];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    // push通知からの起動時
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil) {
        NSDictionary *alertData = [userInfo objectForKey:@"aps"];
        if(![alertData isKindOfClass:[NSNull class]]){
            
            NSString *badge = [alertData objectForKey:@"badge"];
            DLog(@"Received Push Badge: %@", badge);
            
            __block NSNumber * sbBadge;
            __block NSNumber * infoBadge;
            //個別に未読件数を取得
            [self getUnreadInfoCount:^(NSNumber *unreadInfoCount) {
                if ([self isLoggedin]) {
                    infoBadge = unreadInfoCount;
                    [self getUnreadSendBirdMessageCount:^(NSNumber *unreadSBCount) {
                        sbBadge = unreadSBCount;
                        [self setBadge:infoBadge SbBadge:sbBadge];
                    }];
                }else {
                    [self setBadge:unreadInfoCount SbBadge:[self getUnreadCountZero]];
                }
            }];
            
        }
    }

    // アプリ全体設定
    // NavigationBarの背景色
//    UIColor* barBaseColor = [UIColor whiteColor];
//    if( [UIDevice currentDevice].systemVersion.floatValue >= 7.0f )
//    {
//        // NavigationBarの背景色指定
//        [[UINavigationBar appearance] setBarTintColor:barBaseColor];
//        // BarButtonItemのデフォルト色指定
//        [[UINavigationBar appearance] setTintColor:[UIColor greenColor]];
//    }
//    else
//    {
//        [[UINavigationBar appearance] setTintColor:barBaseColor];
//    }


    // tablecell 下線の設定
    // iOS7の場合
//    if( [UIDevice currentDevice].systemVersion.floatValue >= 7.0f )
//    {
//        // 全体に下線を引く
//        [UITableView appearance].separatorInset  = UIEdgeInsetsZero;
//    }

    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    self.naviViewController = [[NaviViewController alloc] init];
    [self.naviViewController.tabBar setFrame:CGRectMake(
                                         self.naviViewController.tabBar.frame.origin.x,
                                         self.naviViewController.tabBar.frame.origin.y,
                                         [[UIScreen mainScreen] bounds].size.width,
                                         kTabBarHeight)];
    self.naviViewController.tabBar.backgroundColor = [UIColor clearColor];
    
    //UIImage *tabBarBgImg = [UIImage imageNamed:@"bg_nav-on01@32x.png"];
    
    
    UIImage *tabBarFirstImg = [UIImage imageNamed:@"bg_nav-on01.png"];
    //UIGraphicsBeginImageContext(CGSizeMake(itemWidth, kItemButtnHeight * imgScale));
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
    [tabBarFirstImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
    tabBarFirstImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.naviViewController.tabBar.backgroundImage = tabBarFirstImg; // [UIImage imageNamed:@"bg_nav-on01.png"];

    [self.naviViewController.navigationController setNavigationBarHidden:YES];
    
    self.window.rootViewController = self.naviViewController;
    self.naviViewController.delegate = self;

    // --------------------
    // start display
    // --------------------
    [StartView showInView:self.naviViewController.view];
    double delayInSeconds = 0.0;
    dispatch_time_t popStartTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popStartTime, dispatch_get_main_queue(), ^(void){
        [StartView dismiss];
    });
    
    
    [self.window makeKeyAndVisible];
    

    // call
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"VLshowUserRegist" object:self];
    
    // アイコンバッジ
    // [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // [UIApplication sharedApplication].applicationIconBadgeNumber = 3;
    // インジゲータ表示
    // [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
//    NSNumber *badge = [NSNumber numberWithInt:2];
//    DLog(@"Received Push Badge: %@", badge);
//    application.applicationIconBadgeNumber = [badge integerValue];
//    [Configuration saveBadge:badge];

    
    // ----------------------------------------------
    // Notification
    // ----------------------------------------------
    // お知らせバッジ設定
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateInfoBadge:) name:VYInfoBadgeNotification object:nil];
    
    // ユーザ未ログイン時会員登録画面呼び出し
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showUserRegist:) name:VYShowUserRegistNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showLoading:) name:VYShowLoadingNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideLoading:) name:VYHideLoadingNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showModalLoading:) name:VYShowModalLoadingNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideModalLoading:) name:VYHideModalLoadingNotification object:nil];

    
    // プッシュ通知のバッジチェック
    NSNumber *badgeNum = [Configuration loadInfoBadge];
    if([badgeNum isKindOfClass:[NSNumber class]] && [badgeNum intValue] > 0){
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            // ---------------------
            // Notification : sent
            // ---------------------
            VYReceivedMessageNotificationParameters *parameters = [[VYReceivedMessageNotificationParameters alloc] init];
            parameters.num = badgeNum;
            NSDictionary *userInfo = @{@"parameters": parameters};
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:VYInfoBadgeNotification object:self userInfo:userInfo];
        
            //おしらせの種類ごとに遷移を分ける.
            NSDictionary *userInfo_after = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (userInfo_after) {
                [self openInfo:userInfo_after];
            }
        });
    }
    
    HomeViewController *homeView = [HomeViewController alloc];
    self.lastActiveTab = homeView;
    
    //HomeTabPagerViewを初期値へ.
    if ([self.naviViewController.viewControllers[0] childViewControllers].count &&
        [self.naviViewController.viewControllers[0] childViewControllers][0] &&
        [[self.naviViewController.viewControllers[0] childViewControllers][0] isKindOfClass:[HomeTabPagerViewController class]]) {
        
        HomeTabPagerViewController * homeTabPagerView = (HomeTabPagerViewController*)[self.naviViewController.viewControllers[0] childViewControllers][0];
        self.lastActiveTab = homeTabPagerView;
    }
    
    //初回起動ならチュートリアルへ
    if ([self isFirstRun]) {
        [self showTutorial];
    }
    
    //アプリ起動時にdevice token送信
    [self sendAnonymousDeviceToken];
    
    //お知らせの未読件数を取得しておく(send birdのはhomeで確認しているのでZeroでも良い)
    [self getUnreadInfoCount:^(NSNumber *unreadCount) {
        [self setBadge:unreadCount SbBadge:[self getUnreadCountZero]];
    }];
    

    return YES;
    
    //return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
    VYReceivedMessageNotificationParameters *parameters = [[VYReceivedMessageNotificationParameters alloc] init];
    
    //お知らせタブにバッジ表示
    [self getUnreadInfoCount:^(NSNumber *unreadCount) {
        [Configuration saveInfoBadge:unreadCount];
        parameters.num = unreadCount;
        NSDictionary *userInfo = @{@"parameters": parameters};
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:VYInfoBadgeNotification object:self userInfo:userInfo];
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // facebookSDK init
    [FBSDKAppEvents activateApp];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    [MagicalRecord cleanUp];
    
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "jp.co.bondy.velly" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kMyRecoUpStoreName];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



// プッシュ通知のアラートをユーザが許可すると呼ばれるメソッド
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{

    DLog(@"Device Token = %@", deviceToken);
    NSString *token = deviceToken.description;
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    DLog(@"Device Token = %@", token);
    
    NSString *hasDevToken = [Configuration  loadDevToken];
    //NSInteger *diffDevTokenFlg = [Configuration loadDiffDevToken];
    //NSString *appleDevToken = [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
    if(hasDevToken && [hasDevToken isEqualToString:token ]){
    
    //DLog(@"%@", diffDevTokenFlg);
    //if(diffDevTokenFlg != nil && diffDevTokenFlg == (NSInteger *)VLISACTIVENON){
        // equal -> no action
        //[Configuration saveDevToken:token];
    }else{
        // save deviceToken
        [Configuration saveDevToken:token];
        [Configuration saveDiffDevToken:(NSInteger *)VLISACTIVEDOIT];
        // post srv
        [self postDeviceToken:token];
    }
}

// プッシュ通知APNsへのデバイス登録失敗時
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)err{
    DLog(@"Error : Fail Regist to APNS. (%@)", err);
}

// プッシュ通知許可：ios8だとこのメソッドを新たにとおるので追加
// http://qiita.com/peromasamune/items/90970e9f9d5c34d21cfd
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}


// デバイストークンのサーバ送信
-(void)postDeviceToken:(NSString *)dToken {

    NSString *aToken = [Configuration loadAccessToken];
    if(dToken){
        // logined

//        NSDictionary *vConfig   = [ConfigLoader mixIn];
//        NSString *isLoding = vConfig[@"LoadingPostDisplay"];
//        // must
//        isLoding = @"YES";
//        if( isLoding && [isLoding boolValue] == YES ){
//            // Loading
//            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
//        }

        [[SettingManager sharedManager] postDeviceToken:aToken dToken:dToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
//            if( isLoding && [isLoding boolValue] == YES ){
//                // clear loading
//                [SVProgressHUD dismiss];
//            }
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
    
//    // prepare url.
//    NSString* content = [NSString stringWithFormat:@"deviceToken=%@", deviceToken];
//    NSURL* url = [NSURL URLWithString:@"http://192.168.1.5:8080/registDeviceServelt"];
//
//    // create instance.
//    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
//
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//
//    [urlRequest setHTTPMethod:@"POST"];
//    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding ]];
//
//    // post.
//    NSURLResponse* response;
//    NSError* error = nil;
//    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
//    if(error) NSLog(@"error = %@", error);
//
//    // get result.
//    NSString* resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", resultString);
    

}

// アプリ起動中に APNsからプッシュ通知を受信した場合
// プッシュ通知を受信した際の処理
// ------------------------------------------
// when its app start (foreground or background) and recieved push alert, its method start
// ------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{

#if !TARGET_IPHONE_SIMULATOR
    
    DLog(@"remote notification: %@",[userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];

    NSString *alert = [apsInfo objectForKey:@"alert"];
    DLog(@"Received Push Alert: %@", alert);

    NSString *sound = [apsInfo objectForKey:@"sound"];
    DLog(@"Received Push Sound: %@", sound);
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    NSString *badge = [apsInfo objectForKey:@"badge"];
    DLog(@"Received Push Badge: %@", badge);
    
    NSString *params = [userInfo objectForKey:@"params"];
    DLog(@"%@", params);
    
#endif

    // 受け取ったバッジをSaveし表示
    NSDictionary *alertData = [userInfo objectForKey:@"aps"];
    if(![alertData isKindOfClass:[NSNull class]]){
        NSString *badge = [alertData objectForKey:@"badge"];
        DLog(@"Received Push Badge: %@", badge);
        
        __block NSNumber * sbBadge;
        __block NSNumber * infoBadge;
        //個別に未読件数を取得
        [self getUnreadInfoCount:^(NSNumber *unreadInfoCount) {
            if ([self isLoggedin]) {
                infoBadge = unreadInfoCount;
                [self getUnreadSendBirdMessageCount:^(NSNumber *unreadSBCount) {
                    sbBadge = unreadSBCount;
                    [self setBadge:infoBadge SbBadge:sbBadge];
                }];
            }else {
                [self setBadge:unreadInfoCount SbBadge:[self getUnreadCountZero]];
            }
        }];
    }
    // プッシュ通知のバッジチェック
    NSNumber *badgeNum = [Configuration loadInfoBadge];
    if([badgeNum isKindOfClass:[NSNumber class]] && [badgeNum intValue] > 0){
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            // ---------------------
            // Notification : sent
            // ---------------------
            VYReceivedMessageNotificationParameters *parameters = [[VYReceivedMessageNotificationParameters alloc] init];
            parameters.num = badgeNum;
            NSDictionary *userInfo = @{@"parameters": parameters};
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:VYInfoBadgeNotification object:self userInfo:userInfo];
            
        });
    }
    if (application.applicationState != UIApplicationStateActive){
        // アプリが起動していない時に、push通知が届きpush通知から起動
        [self openInfo:userInfo];
    }
    if (application.applicationState == UIApplicationStateInactive){
        // アプリがバックグラウンドで起動している時に、push通知が届きpush通知から起動
    }

}


- (void)initializeGoogleAnalytics
{
    // 例外を Google Analytics に送る
    [GAI sharedInstance].trackUncaughtExceptions = YES;

    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    //[GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *gaTrackingID = vConfig[@"GATrackingID"];
    
    // トラッキングIDを設定
    [[GAI sharedInstance] trackerWithTrackingId:gaTrackingID];
}


// URLスキーマ呼び出し
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    DLog(@"%@", [url scheme]);
    if ([[url scheme] isEqualToString:URL_SCHEMA]) {
        // app SCHEMA open
        //return YES;
    }

    // twitter web戻り判定
    
    // sankou
    // http://qiita.com/naonya3/items/c55e6151b4ff6ab5725f
    
    NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
    NSString *token = d[@"oauth_token"];
    NSString *verifier = d[@"oauth_verifier"];
    //ViewController *vc = (ViewController *)[[self window] rootViewController];
    
    DLog(@"%@", [[self window] rootViewController]);
    if(token && verifier){
        
        UIViewController *vc = (UIViewController *)[[self window] rootViewController];
        NSArray *childViews = vc.childViewControllers;
        DLog(@"%@", childViews);
//        [childViews enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
//            NSLog(@"%lu: %@", (unsigned long)idx, obj);
//            
//        }];
        
        UIViewController *testView = self.naviViewController.presentedViewController;
        DLog(@"v=%@",testView);
        DLog(@"v=%@",testView.childViewControllers);
        for( UIViewController *v in testView.childViewControllers){
            DLog(@"v=%@",v);
            if([v isKindOfClass:[RegistViewController class]]){
                [(RegistViewController *)v setOAuthToken:token oauthVerifier:verifier];
            }else if([v isKindOfClass:[LoginViewController class]]){
                [(LoginViewController *)v setOAuthToken:token oauthVerifier:verifier];
            }
        }
        for( UIViewController *v in childViews){
            DLog(@"v=%@",v);
            NSArray *childChildViews = v.childViewControllers;
            DLog(@"%@", childChildViews);
            for( UIViewController *ccv in childChildViews){
                if([ccv isKindOfClass:[ProfileEditViewController class]]){
                    [(ProfileEditViewController *)ccv setOAuthToken:token oauthVerifier:verifier];
                }else if([ccv isKindOfClass:[PopularViewController class]]){
                    [(PopularViewController *)ccv setOAuthToken:token oauthVerifier:verifier];
                }
            }
        }
        
        return YES;
        
//        for( UIViewController *v in registViews ){
//            DLog(@"v=%@",v);
//            if([v isKindOfClass:[RegistViewController class]]){
//                [(RegistViewController *)v setOAuthToken:token oauthVerifier:verifier];
//                return YES;
//            }
//        }
      
//        for( UIViewController *v in childViews ){
//            DLog(@"v=%@",v);
//            if([v isKindOfClass:[RegistViewController class]]){
//                [(RegistViewController *)v setOAuthToken:token oauthVerifier:verifier];
//                return YES;
//            }
//            NSArray *subChildViews = v.childViewControllers;
//            for( UIViewController *v2 in subChildViews){
//                DLog(@"v2=%@",v2);
//                if([v isKindOfClass:[RegistViewController class]]){
//                    [(RegistViewController *)v setOAuthToken:token oauthVerifier:verifier];
//                    return YES;
//                }
//            }
//        }
        
//        UIStoryboard *stb_login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//        RegistViewController *registView = (RegistViewController *)[stb_login instantiateViewControllerWithIdentifier:@"RegistViewController"];
//        [registView setOAuthToken:token oauthVerifier:verifier];
        //return YES;
    }

    // Facebook戻り判定
    if([sourceApplication isEqualToString:@"com.facebook.Facebook"]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    // facebook web認証戻り判定
    NSString *fbSchema = [@"fb" stringByAppendingString:OAUTH_FB_APP_ID];
    if ([[url scheme] isEqualToString:fbSchema]) {
        
//        NSDictionary *fbDic = [self parametersDictionaryFromQueryString:[url query]];
//        NSString *fb_access_token   = fbDic[@"access_token"];
//        NSString *fb_signed_request = fbDic[@"signed_request"];
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    
    
    return YES;
}
// back page
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)URL {
    if ([[URL path] isEqualToString:@"/sample"]) {
        //        SampleViewController *viewController =  [[[SampleViewController alloc] init] autorelease];
        //        [self.navigationController presentModalViewController:navController animated:NO];
    }
    return NO;
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        NSString *key = pair[0];
        NSString *value = pair[1];
        md[key] = value;
    }
    return md;
}


- (void) updateInfoBadge:(NSNotification *)notification
{
    
    VYReceivedMessageNotificationParameters *parameters = notification.parameters;
    if(parameters.num){
        NSString * badge = ([parameters.num intValue])?[parameters.num stringValue]:nil;
        UIViewController *vc = (UIViewController *)[[self window] rootViewController];
        NSArray *childViews = vc.childViewControllers;
        for( UIViewController *v in childViews){
            if([v isKindOfClass:[UINavigationController class]]){
                NSArray *reChildView = v.childViewControllers;
                for( UIViewController *reV in reChildView){
                    if([reV isKindOfClass:[InfoViewController class]]){
                        [reV.tabBarItem setBadgeValue:badge];
                    }
                }
            }
        }

    }
}

- (void) showUserRegist:(NSNotification *) notification{
    
    // ログイン画面でなく、会員登録画面を表示
    
    DLog(@"call Show Login");
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{

        UIStoryboard *stb_login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//        _registNavi = [[UINavigationController alloc] initWithRootViewController: (UINavigationController *)[stb_login instantiateInitialViewController]];
        
        _registNavi = (UINavigationController *)[stb_login instantiateInitialViewController];
        _registNavi.view.backgroundColor = [UIColor clearColor];
        UIImageView *background_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_login.png"]];
        background_imageView.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        background_imageView.frame = self.window.frame;
        background_imageView.backgroundColor = [UIColor redColor];
        [_registNavi.view insertSubview:background_imageView atIndex:0];
        
//        _loginViewController = [stb_login instantiateViewControllerWithIdentifier:@"LoginViewController"];
//        _loginNavi = [[UINavigationController alloc] initWithRootViewController: (UINavigationController *)_loginViewController];
        
    });
    //[self.naviViewController presentViewController: _registNavi animated: YES completion: nil];
    [self.naviViewController presentViewController: _registNavi animated: YES completion: nil];

}


- (void) showLoading:(NSNotification *) notification
{
    NaviViewController *navi = (NaviViewController *)self.window.rootViewController;

    //UIView *loadingView = [[UIView alloc] initWithFrame:self.window.rootViewController.view.bounds];
    //UIView *loadingView = [[UIView alloc] initWithFrame:navi.view.bounds];
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(navi.view.bounds.origin.x,
                                                                   navi.view.bounds.origin.y,
                                                                   navi.view.bounds.size.width,
                                                                   navi.view.bounds.size.height - navi.tabBar.bounds.size.height)];
    loadingView.backgroundColor = [UIColor darkGrayColor];
    loadingView.alpha = 0.0f;
    loadingView.tag = 987654321;

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [indicator setCenter:CGPointMake(loadingView.bounds.size.width / 2, loadingView.bounds.size.height / 2)];
    [loadingView addSubview:indicator];
    //[self.window.rootViewController.view addSubview:loadingView];
    [navi.view addSubview:loadingView];

    [indicator startAnimating];
    [UIView animateWithDuration:0.8f animations:^{
        loadingView.alpha = 0.0f;
        loadingView.alpha = 0.3f;
    }];
}

- (void) hideLoading:(NSNotification *) notification
{
    for(UIView *v in [self.window.rootViewController.view subviews]){
        if(v.tag == 987654321){
            [UIView animateWithDuration:0.8f animations:^{
                v.alpha = 0.3f;
                v.alpha = 0.0f;
            }completion:^(BOOL finished){
                [v removeFromSuperview];
            }];
        }
    }
}


- (void) showModalLoading:(NSNotification *) notification
{

    UINavigationController *navi = (UINavigationController *)self.naviViewController;
    
    //UIView *loadingView = [[UIView alloc] initWithFrame:self.window.rootViewController.view.bounds];
    //UIView *loadingView = [[UIView alloc] initWithFrame:navi.view.bounds];
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(navi.view.bounds.origin.x,
                                                                   navi.view.bounds.origin.y,
                                                                   navi.view.bounds.size.width,
                                                                   navi.view.bounds.size.height)];
    loadingView.backgroundColor = [UIColor darkGrayColor];
    loadingView.alpha = 0.0f;
    loadingView.tag = 987654321;
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [indicator setCenter:CGPointMake(loadingView.bounds.size.width / 2, loadingView.bounds.size.height / 2)];
    [loadingView addSubview:indicator];
    //[self.window.rootViewController.view addSubview:loadingView];
    [navi.view addSubview:loadingView];
    
    [indicator startAnimating];
    [UIView animateWithDuration:0.8f animations:^{
        loadingView.alpha = 0.0f;
        loadingView.alpha = 0.3f;
    }];
}

- (void) hideModalLoading:(NSNotification *) notification
{
    for(UIView *v in [self.naviViewController.view subviews]){
        if(v.tag == 987654321){
            [UIView animateWithDuration:0.8f animations:^{
                v.alpha = 0.3f;
                v.alpha = 0.0f;
            }completion:^(BOOL finished){
                [v removeFromSuperview];
            }];
        }
    }
}

#pragma mark UITabBarControllerDelegate Methods
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    UIViewController *childView = nil;
    if(viewController.childViewControllers.count > 0 && viewController.childViewControllers[0]){
        childView = viewController.childViewControllers[0];
    }
    
    if ([viewController isKindOfClass:[PostViewController class]]) {
        
        // SEND REPRO EVENT
        [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[POSTBUTTONTAP]
                             properties:nil];
        
        // 投稿画面は、ポップアップ

        if(![[Configuration checkLogined] length]){
            
            [Configuration saveLoginCallback:@""];
            
            // 未ログイン
            [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        
            //UIStoryboard *stb_post = [UIStoryboard storyboardWithName:@"Post" bundle:nil];
            //PostViewController *controller = [stb_post instantiateViewControllerWithIdentifier:@"PostViewController"];
            //[self.naviViewController presentViewController: controller animated:YES completion: nil];
        
            return NO;
        }else{
            // ログイン済
            
            //モーダル表示のために現在表示中のView取得.
            UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (topController.presentedViewController) {
                topController = topController.presentedViewController;
            }
            
            //ProfileViewの投稿更新のため.
            if ([self.lastActiveTab isKindOfClass:[ProfileViewController class]]) {
                ProfileViewController * profileView = (ProfileViewController *)self.lastActiveTab;
                profileView.isAfterPost = YES;
            }
            else if ([self.lastActiveTab isKindOfClass:[HomeTabPagerViewController class]]){
                HomeTabPagerViewController *homeTabPagerView = (HomeTabPagerViewController*)self.lastActiveTab;
                homeTabPagerView.currentPageController.isAfterPost = YES;
            }
            else if ([self.lastActiveTab isKindOfClass:[RankingTabPagerViewController class]]){
                RankingTabPagerViewController *rankingTabPagerView = (RankingTabPagerViewController*)self.lastActiveTab;
                rankingTabPagerView.currentPageController.isAfterPost = YES;
            }
            
            if (IOS7) {
                [self showActionSheet];
            }else {
                [self showAlertController];
            }
            return NO;
        }

    }else if([viewController isKindOfClass:[InfoViewController class]] ||
             [childView isKindOfClass:[InfoViewController class]]){
        
        // お知らせ
        
//        [Configuration saveLoginCallback:@""];

        
//        if(![[[UserManager sharedInstance] checkLogined] length]){
//            // 未ログイン
//            [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
//            
//            //UIStoryboard *stb_post = [UIStoryboard storyboardWithName:@"Post" bundle:nil];
//            //PostViewController *controller = [stb_post instantiateViewControllerWithIdentifier:@"PostViewController"];
//            //[self.naviViewController presentViewController: controller animated:YES completion: nil];
//            
//            return NO;
//        }

    }else if([viewController isKindOfClass:[ProfileViewController class]] ||
             [childView isKindOfClass:[ProfileViewController class]]){
        
        // プロフィール
        DLog(@"appDelegate aToken : %@", [Configuration checkLogined]);
        if(![[Configuration checkLogined] length]){
            
            [Configuration saveLoginCallback:@"ProfileViewController"];

            // 未ログイン
            [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
            
            //UIStoryboard *stb_post = [UIStoryboard storyboardWithName:@"Post" bundle:nil];
            //PostViewController *controller = [stb_post instantiateViewControllerWithIdentifier:@"PostViewController"];
            //[self.naviViewController presentViewController: controller animated:YES completion: nil];
            
            return NO;
        }
    }
    
    self.lastActiveTab = childView;
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self changeTabBarBackGroundImage:tabBarController viewController:viewController];
}

#pragma mark Button Event

///チュートリアルを終了する
- (void)endTutorial:(UIButton * )sender {
    [self.introView hideWithFadeOutDuration:0.7f];
}

#pragma mark EAIntroView Delegate

- (void)introDidFinish:(EAIntroView *)introView {
    [self showPushApprovalAlert];
}

#pragma mark TapGestureRecognizerMethod

///チュートリアルを進める
- (void)nextPage:(UITapGestureRecognizer * )recognizer {
    
    CGPoint tappedPoint = [self getTapPoint:recognizer];
    if ([self isRightEnd:tappedPoint]) {
        [self.introView setCurrentPageIndex:self.introView.currentPageIndex + 1 animated:YES];
    }
}

#pragma mark Custom Function

///与えられた座標が右端(端から60)ならYESを返す
- (BOOL)isRightEnd:(CGPoint)point{
    CGFloat windowWidth = [[[UIApplication sharedApplication] delegate] window].bounds.size.width;
    return (point.x >= windowWidth - 60);
}

///gestureRecognizerからタップ座標取得
- (CGPoint)getTapPoint:(UIGestureRecognizer *)recognizer{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGPoint point = [recognizer locationOfTouch:0 inView:window];
    
    return point;
}

- (void)configureLastImageView:(UIImageView * )lastImgView {
    
    UIImage * btnImage = [UIImage imageNamed:@"tutorial_end.png"];
    
    UIButton * endBtn = [[UIButton alloc] init];
    
    //縦横比
    CGFloat scale = btnImage.size.height / btnImage.size.width;
    
    //左右のmargin
    CGFloat margin = 20.0f;
    
    //幅を算出(全体 - 左右のmargin)
    CGFloat btnWidth = lastImgView.bounds.size.width - margin * 2;
    
    //以上より高さを算出
    CGFloat btnHeight = btnWidth * scale;
    
    //下のmargin
    CGFloat bottomMargin = 80.0f;
    
    [endBtn addTarget:self action:@selector(endTutorial:) forControlEvents:UIControlEventTouchUpInside];
    [endBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    endBtn.adjustsImageWhenHighlighted = NO;
    [lastImgView addSubview:endBtn];
    
    //下の間隔
    [lastImgView addConstraint:[NSLayoutConstraint
                                constraintWithItem:endBtn
                                attribute:NSLayoutAttributeBottom
                                relatedBy:NSLayoutRelationEqual
                                toItem:lastImgView
                                attribute:NSLayoutAttributeBottom
                                multiplier:1
                                constant:-bottomMargin]];
    
    //右の間隔
    [lastImgView addConstraint:[NSLayoutConstraint
                                constraintWithItem:endBtn
                                attribute:NSLayoutAttributeRight
                                relatedBy:NSLayoutRelationEqual
                                toItem:lastImgView
                                attribute:NSLayoutAttributeRight
                                multiplier:1
                                constant:-margin]];
    
    //左の間隔
    [lastImgView addConstraint:[NSLayoutConstraint
                                constraintWithItem:endBtn
                                attribute:NSLayoutAttributeLeft
                                relatedBy:NSLayoutRelationEqual
                                toItem:lastImgView
                                attribute:NSLayoutAttributeLeft
                                multiplier:1
                                constant:margin]];
    
    //高さ
    [lastImgView addConstraint:[NSLayoutConstraint
                                constraintWithItem:endBtn
                                attribute:NSLayoutAttributeHeight
                                relatedBy:NSLayoutRelationEqual
                                toItem:nil
                                attribute:NSLayoutAttributeHeight
                                multiplier:1
                                constant:btnHeight]];
    
    [endBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
}

///チュートリアルを表示
- (void)showTutorial{
    
    UIImageView * lastImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_4.png"]];
    
    EAIntroPage * page1 = [EAIntroPage pageWithCustomView:
                           [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_1.png"]]];
    EAIntroPage * page2 = [EAIntroPage pageWithCustomView:
                           [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_2.png"]]];
    EAIntroPage * page3 = [EAIntroPage pageWithCustomView:
                           [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_3.png"]]];
    EAIntroPage * page4 = [EAIntroPage pageWithCustomView:
                           lastImgView];
    
    page1.customView.userInteractionEnabled = YES;
    page2.customView.userInteractionEnabled = YES;
    page3.customView.userInteractionEnabled = YES;
    page4.customView.userInteractionEnabled = YES;
    
    self.introView = [[EAIntroView alloc]
                      initWithFrame:self.naviViewController.view.bounds
                      andPages:@[page1, page2, page3, page4]];
    
    
    [self configureLastImageView:lastImgView];
    
    self.introView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * gstrecognizer = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(nextPage:)];
    [self.introView addGestureRecognizer:gstrecognizer];
    
    //最後をスクロールで抜けるかどうか
    [self.introView setSwipeToExit:NO];
    
    //スキップボタンの色変更
    [self.introView.skipButton setTitleColor:HEADER_BG_COLOR forState:UIControlStateNormal];
    
    self.introView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    
    [self.introView setDelegate:self];
    
    //表示
    [self.introView showInView:self.naviViewController.view animateDuration:0.7f];
}

///プッシュ通知許可アラートを表示
- (void)showPushApprovalAlert {
    
    UIApplication * application = [UIApplication sharedApplication];
    
    //Send Push init
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1){
        if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
            // conf permit send push : over ios8
            if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
            {
                // get device token
                [application registerForRemoteNotifications];
                
                // display alert
                UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                                UIUserNotificationTypeBadge |
                                                                UIUserNotificationTypeSound);
                
                UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                        settingsForTypes:userNotificationTypes
                                                        categories:nil];
                [application registerUserNotificationSettings:settings];
            }
        }else{
            // conf permit send push : until ios7
            [application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge|
                                                              UIRemoteNotificationTypeSound|
                                                              UIRemoteNotificationTypeAlert)];
        }
    }
}

- (void)setRepro {
    // Setup Repro
    [Repro setup:REPRO_TOKEN];
    
    // Start Recording
    [Repro startRecording];
    
    // Crash Report
    [Repro enableCrashReporting];
}

///バッジをセット
- (void)setBadge:(NSNumber *)infoBadge SbBadge:(NSNumber * )SbBadge {
    NSNumber * totalBadge = [NSNumber numberWithInt:[infoBadge intValue] + [SbBadge intValue]];
    [Configuration saveInfoBadge:infoBadge];
    [Configuration saveSendBirdBadge:SbBadge];
    [Configuration saveBadge:totalBadge];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [totalBadge integerValue];
}
///ログインしていたらYES
- (BOOL)isLoggedin {
    return ([[Configuration loadAccessToken] boolValue]);
}
///チャットトークン未登録ならYES
- (BOOL)hasNoCorrectChatToken:(NSString * )chatToken {
    NSString * savedChatToken = [Configuration loadUserChatToken];
    return (!savedChatToken || ![chatToken isEqualToString:savedChatToken]);
}
///ユーザ情報取得
- (void)getUserInfo:(void(^)(User * user, NSError * error))block {
    [[UserManager sharedManager] getUserInfo:nil
    block:^(NSNumber *result_code, User *srvUser, NSMutableDictionary *responseBody, NSError *error) {
        block(srvUser, error);
    }];
}
///SendBirdにリクエストするユーザが適切な値を持っていなければYES
- (BOOL)userCanNotLoginSB:(User * )user{
    return (!user.userID || !user.iconPath || !user.chat_token);
}
///未読メッセージゼロを返したい時に使用
- (NSNumber * )getUnreadCountZero {
    return [NSNumber numberWithInt:0];
}
///SendBirdに実際にリクエストを投げて未読メッセージを取得
- (void)requestToSB:(User * )user block:(void(^)(NSNumber * unreadCount))block {
    
    NSDictionary * vConfig= [ConfigLoader mixIn];
    NSString * userID = user.userID;
    NSString * userIconPath = (user.iconPath)? user.iconPath:vConfig[@"UserNoImageIconPath"];
    NSString * userChatToken = user.chat_token;
    
    //ログイン
    [SendBird loginWithUserId:userChatToken
                  andUserName:userID
              andUserImageUrl:userIconPath
               andAccessToken:@""];
    
    //メッセージ確認
    [[SendBird queryMessagingUnreadCount]
     executeWithResultBlock:^(int unreadCount) {
         //save chat token.
         if ([self hasNoCorrectChatToken:userChatToken]) {
             [Configuration saveUserChatToken:userChatToken];
         }
         block([NSNumber numberWithInt:unreadCount]);
     } errorBlock:^(NSInteger code) {
         DLog("error_code=%ld",code);
         block([self getUnreadCountZero]);
     }];
    [SendBird cancelAll];
}
///SendBirdの未読メッセージ件数を取得
- (void)getUnreadSendBirdMessageCount:(void(^)(NSNumber * unreadCount))block {
    [self getUserInfo:^(User *user, NSError *error) {
        if (error || [self userCanNotLoginSB:user]) {
            DLog("error=%@,canlogin=%d",error, [self userCanNotLoginSB:user]);
            block([self getUnreadCountZero]);
            return ;
        }
        [self requestToSB:user block:^(NSNumber *unreadCount) {
            block(unreadCount);
        }];
    }];
}
///お知らせの未読件数を取得
- (void)getUnreadInfoCount:(void(^)(NSNumber * unreadCount))block {
    
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    __block NSString * aToken = [Configuration loadAccessToken];
    __block NSString * dToken = [Configuration loadDevToken];
    
    [[InfoManager sharedManager] getUnreadInfoCount:params
                                             aToken:aToken
                                             dToken:dToken
    block:^(NSNumber *unreadInfoCount, NSError *error) {
        if (error) unreadInfoCount = [self getUnreadCountZero];
        block(unreadInfoCount);
    }];
}


/**
 *ホームアイコンダブルタップで投稿一番上へスクロール
 *@param viewController 選択されたViewController
 */
- (void)scrollToTopIfNeed:(UIViewController *) viewController{
    
    UIViewController *childView;
    if(viewController.childViewControllers.count > 0 && viewController.childViewControllers[0]){
        childView = viewController.childViewControllers[0];
    }
    //一番上の投稿へスクロール.
    if (childView && [self.lastActiveTab isKindOfClass:[HomeTabPagerViewController class]]) {
        HomeTabPagerViewController * homeTabPagerView = (HomeTabPagerViewController*)childView;
        [homeTabPagerView toTop];
    }
    
}

/**
 *タブの画像切り替え処理.
 *@param tabBarController このインスタンスのNaviViewController
 *@param viewController 選択されたViewController
 */
- (void)changeTabBarBackGroundImage:(UITabBarController *)tabBarController
                     viewController:(UIViewController *)viewController {
    
    if(tabBarController.selectedIndex == 0){
        
        //Send Repro Event
        [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENHOME]
                             properties:nil];
        
        [self scrollToTopIfNeed:viewController];
        
        UIImage *tabBarHomeImg = [UIImage imageNamed:@"bg_nav-on01.png"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
        [tabBarHomeImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
        tabBarHomeImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        tabBarController.tabBar.backgroundImage = tabBarHomeImg; // [UIImage imageNamed:@"bg_nav-on01.png"];
        //UITabBarItem *tbi = [tabBarController.tabBar.items objectAtIndex:0];
        //tbi.image = [UIImage imageNamed:@"btn_tab_ranking.png"];
        
    }else if (tabBarController.selectedIndex == 1){
        // ranking
        
        //Send Repro Event
        [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENRANKING]
                             properties:nil];
        
        UIImage *tabBarRankingImg = [UIImage imageNamed:@"bg_nav-on02.png"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
        [tabBarRankingImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
        tabBarRankingImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        tabBarController.tabBar.backgroundImage = tabBarRankingImg; // [UIImage imageNamed:@"bg_nav-on02.png"];
        
    }else if (tabBarController.selectedIndex == 2){
        // record
        
        UIImage *tabBarRecordImg = [UIImage imageNamed:@"bg_nav-on03.png"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
        [tabBarRecordImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
        tabBarRecordImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        tabBarController.tabBar.backgroundImage = tabBarRecordImg; // [UIImage imageNamed:@"bg_nav-on03.png"];
        //self.tabBar.hidden = YES;
        //self.navigationController.navigationBarHidden = YES;
    }else if (tabBarController.selectedIndex == 3){
        // info
        
        //Send Repro Event
        [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENINFO]
                             properties:nil];
        
        UIImage *tabBarInfoImg = [UIImage imageNamed:@"bg_nav-on04.png"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
        [tabBarInfoImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
        tabBarInfoImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        tabBarController.tabBar.backgroundImage = tabBarInfoImg; // [UIImage imageNamed:@"bg_nav-on04.png"];
    }else if (tabBarController.selectedIndex == 4){
        // profile
        
        //Send Repro Event
        [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENMYPAGE]
                             properties:nil];
        
        UIImage *tabBarProfileImg = [UIImage imageNamed:@"bg_nav-on05.png"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
        [tabBarProfileImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
        tabBarProfileImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        tabBarController.tabBar.backgroundImage = tabBarProfileImg; // [UIImage imageNamed:@"bg_nav-on05.png"];
    }else{
        // other
        
        UIImage *tabBarImg = [UIImage imageNamed:@"bg_nav.png"];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
        [tabBarImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
        tabBarImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        tabBarController.tabBar.backgroundImage = tabBarImg; // [UIImage imageNamed:@"bg_nav.png"];
    }
}

- (void)openInfo:(NSDictionary *)userInfo
{
    
    VYReceivedMessageNotificationParameters *parameters = [[VYReceivedMessageNotificationParameters alloc] init];
    
    parameters.url = [userInfo objectForKey:@"url"];
    parameters.category_id = [userInfo objectForKey:@"cat"];
    parameters.post_id = [userInfo objectForKey:@"post"];
    parameters.user_id = [userInfo objectForKey:@"user"];
    parameters.user_pid = [userInfo objectForKey:@"userid"];
    parameters.is_sendbird_message = [userInfo objectForKey:@"s"];
    
    NSDictionary *userInfop = @{@"parameters": parameters};
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            
    //send notification to hometabpagerview
    [notificationCenter postNotificationName:VYInfoDetailNotification object:self userInfo:userInfop];
    
    
}

///ログイン状態でない時にAccessTokenなしでDeviceTokenのみサーバーに送る
- (void)sendAnonymousDeviceToken {
    // deviceToken check
    NSString *dToken = [Configuration loadDevToken];
    NSString *aToken = [Configuration loadAccessToken];
    if(!aToken && dToken){
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
}

///下のタブバーを隠す
- (void)hideTabBar {
    [self.naviViewController.tabBar setHidden:YES];
    [self.naviViewController.tabBar setFrame:CGRectMake(
                                                        self.naviViewController.tabBar.frame.origin.x,
                                                        self.naviViewController.tabBar.frame.origin.y,
                                                        [[UIScreen mainScreen] bounds].size.width,0)];
}

///下のタブバーを表示する
- (void)showTabBar:(void (^)())completion
{
    [self.naviViewController.tabBar setHidden:NO];
    [self changeTabBarBackGroundImage:self.naviViewController viewController:self.naviViewController.selectedViewController];
    [self.naviViewController.tabBar setFrame:CGRectMake(
                                                        self.naviViewController.tabBar.frame.origin.x,
                                                        self.naviViewController.tabBar.frame.origin.y,
                                                        [[UIScreen mainScreen] bounds].size.width,
                                                        kTabBarHeight)];
    if (completion) completion();
    
}

///初回起動ならYES
- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //初回起動時刻またはデバイストークンが格納されていれば初回ではない
    if ([userDefaults objectForKey:@"firstRunDate"] || [Configuration loadDevToken]) {
        return NO;
    }
    
    // 初回起動日時を保存
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate"];
    [userDefaults synchronize];
    
    return YES;
}

///iOS7にもあるActionSheetを使う
- (void)showActionSheet {
    UIActionSheet *as = [[UIActionSheet alloc] init];
    as.delegate = self;
    as.title = NSLocalizedString(@"PostActionTitle", nil);
    [as addButtonWithTitle:NSLocalizedString(@"PostActionTakePic", nil)];
    [as addButtonWithTitle:NSLocalizedString(@"PostActionLib", nil)];
    [as addButtonWithTitle:NSLocalizedString(@"PostActionTakeMov", nil)];
    [as addButtonWithTitle:NSLocalizedString(@"PostActionCancel", nil)];
    [as showInView:[CommonUtil getNaviViewController].view];
}

///iOS8以上のUIAlertControllerを使う
- (void)showAlertController{
    
    
    __block UIStoryboard *stb_post;
    
    UIAlertController *postTypeAlertController = [UIAlertController
                                                  alertControllerWithTitle:NSLocalizedString(@"PostActionTitle", nil)
                                                  message:nil
                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    //「写真を撮る」選択時の処理.
    [postTypeAlertController
     addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"PostActionTakePic", nil)
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {
        [self takePicAction:stb_post];
        
    }]];
    //「アルバムから選択する」選択時の処理.
    [postTypeAlertController
     addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"PostActionLib", nil)
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {
        [self fromLibAction];
        
    }]];
    //「ムービーを撮る」選択時の処理.
    [postTypeAlertController
     addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"PostActionTakeMov", nil)
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {
        [self movieAction:stb_post];
        
    }]];
    //キャンセル処理.
    [postTypeAlertController
     addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"PostActionCancel", nil)
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {
    }]];
    
    //表示処理
    [[CommonUtil getNaviViewController] presentViewController:postTypeAlertController
                                                     animated:YES
                                                   completion:nil];
}

///「動画を撮る」へ
- (void)movieAction:(UIStoryboard *)stb {
    
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[POSTBUTTON_MOVIETAP]
                         properties:nil];
    
    stb = [UIStoryboard storyboardWithName:@"Movie" bundle:nil];
    _postNavi = (UINavigationController *)[stb instantiateInitialViewController];
    [self.naviViewController presentViewController: _postNavi animated:YES completion: nil];
}

///「アルバムから選択」へ
- (void)fromLibAction{
    
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[POSTBUTTON_LIBRARYTAP]
                         properties:nil];
    
    PostSelectFromLibraryViewController * postSelectFromLibraryViewController = [[PostSelectFromLibraryViewController alloc] initWithPreviousTab:self.lastActiveTab];
    [self.naviViewController presentViewController:postSelectFromLibraryViewController animated:YES completion:^{
        [self hideTabBar];
    }];
}

///「写真を撮る」へ
- (void)takePicAction:(UIStoryboard *)stb{
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[POSTBUTTON_TAKEAPICTAP]
                         properties:nil];
    
    stb = [UIStoryboard storyboardWithName:@"Post" bundle:nil];
    _postNavi = (UINavigationController *)[stb instantiateInitialViewController];
    [self.naviViewController presentViewController: _postNavi animated:YES completion: nil];
}

#pragma mark UIActionSheet Delegate

///投稿アクションの判別
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __block UIStoryboard *stb_post;
    
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    STR_SWITCH(btnTitle){
        STR_CASE(NSLocalizedString(@"PostActionTakePic", nil)){
            [self takePicAction:stb_post];
            break;
        }
        STR_CASE(NSLocalizedString(@"PostActionLib", nil)){
            [self fromLibAction];
            break;
        }
        STR_CASE(NSLocalizedString(@"PostActionTakeMov", nil)){
            [self movieAction:stb_post];
            break;
        }
        STR_DEFAULT{
            break;
        }
    }
}
@end
