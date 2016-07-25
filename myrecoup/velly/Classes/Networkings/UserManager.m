    //
//  UserManager.m
//  velly
//
//  Created by m_saruwatari on 2015/03/25.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "UserManager.h"
#import "UserClient.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "AFHTTPRequestOperationManager+Timeout.h"
#import "NSString+Validation.h"
#import "NSObject+Validation.h"
#import "User.h"
#import "SettingManager.h"

@interface  UserManager()


@end

@implementation UserManager

+ (UserManager *)sharedInstance {

    static UserManager *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[UserManager alloc] init];
    });
    
    return sharedInstance;
}

+ (UserManager *)sharedManager
{
    static UserManager *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // init 
    }
    return self;
}


- (BOOL)checkNetworkStatus {
    if([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable){
        //[SVProgressHUD showErrorWithStatus:@""];
        self.networkStatus = [NSNumber numberWithUnsignedInt:VLISBOOLFALSE];    // NO
        return NO;
    }
    self.networkStatus = [NSNumber numberWithInt:VLISBOOLTRUE];
    return YES;
}

//+ (AFHTTPRequestOperationManager *)sharedManager {
//    static AFHTTPRequestOperationManager *sharedManager;
//    static dispatch_once_t pred;
//    dispatch_once(&pred, ^{
//        sharedManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[[NSURL alloc] initWithString:@"http://pico.flasco.co.jp"]];
//        sharedManager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        //[sharedManager.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
//        //[sharedManager.requestSerializer setValue:@"testtest" forHTTPHeaderField:@"User-Agent"];
//        // BASIC認証時
//        //[sharedManager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"hoge" password:@"hoge"];
//        // レスポンスJSON形式
//        sharedManager.responseSerializer = [AFJSONResponseSerializer serializer];
//    });
//    return sharedManager;
//}


- (instancetype)initWithSignupAttributes:(NSDictionary *)attributes icon:(UIImage *)icon {
    self = [super init];
    if (!self) {
        return nil;
    }
    if(_user == nil){
        _user = [[User alloc] init];
    }
    _user.username    = [attributes valueForKey:@"username"];
    _user.email       = [attributes valueForKey:@"email"];
    _user.userID      = [attributes valueForKey:@"user_id"];
    _user.password    = [attributes valueForKey:@"password"];
    _user.checkPolicy = [attributes valueForKey:@"check_policy"];
    _user.icon        = icon;
    
    // NSNullチェック
    // NSDictionaryではnilを表現できないため、NSNullで渡ってくる
    if ([_user.username isNSNull]) {
        _user.username = nil;
    }
    if ([_user.email isNSNull]) {
        _user.email = nil;
    }
    if ([_user.userID isNSNull]) {
        _user.userID = nil;
    }
    if ([_user.password isNSNull]) {
        _user.password = nil;
    }
    if ([_user.password isNSNull]) {
        _user.password = nil;
    }
    if([_user.checkPolicy isNSNull]){
        _user.checkPolicy = 0;
    }
    //_user = user;
    
    return self;
}

- (NSString *)validateSignupForInsert
{
    // nickname
    if (![self.user.username hasLength]) {
        return NSLocalizedString(@"ValidateUserInvalidUserName", nil);
    }else if(![self.user.username validateMaxLength:10]) {
        return NSLocalizedString(@"ValidateUserInvalidLengthUserName", nil);
    }
    // email
    if (![self.user.email isEmail]) {
        return NSLocalizedString(@"ValidateUserInvalidEmail", nil);
    }else if(![self.user.email validateMaxLength:255]) {
        return NSLocalizedString(@"ValidateUserInvalidLengthUserName", nil);
    }
    // userId
    if (![self.user.userID hasLength]) {
        return NSLocalizedString(@"ValidateUserInvalidUserId", nil);
    }else if(![self.user.userID validateMaxLength:30]) {
        return NSLocalizedString(@"ValidateUserInvalidLengthUserName", nil);
    }else if(![self.user.userID canBeConvertedToEncoding:NSASCIIStringEncoding]){
        return NSLocalizedString(@"ValidateUserInvalidUserID", nil);
    }
    // password
    if (![self.user.password validateMinMaxLength:8 maxLength:16]) {
        return NSLocalizedString(@"ValidateUserInvalidPassword", nil);
    }
    // policy
    if (self.user.checkPolicy != [NSNumber numberWithInt:1]) {
        return NSLocalizedString(@"ValidateUserInvalidTerms", nil);
    }
    return nil;
}

- (NSString *)validateLogin
{
    if (![self.user.email isEmail]) {
        return NSLocalizedString(@"ValidateUserInvalidEmail", nil);
    }
    if (![self.user.password validateMinMaxLength:8 maxLength:16]) {
        return NSLocalizedString(@"ValidateUserInvalidPassword", nil);
    }
    return nil;
}


// ------------------------
// getter / setter
// ------------------------

//- (NSString *)loadLoginCallback {
//    NSString *loginCallback = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"loginCallback"];
//    return loginCallback;
//}
//
//- (void)saveLoginCallback:(NSString *)loginCallback {
//    [[LUKeychainAccess standardKeychainAccess] setObject:loginCallback forKey:@"loginCallback"];
//}
//
//
//- (NSString *)loadEmail {
//    NSString *email = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"email"];
//    return email;
//}
//
//- (void)saveEmail:(NSString *)email {
//    [[LUKeychainAccess standardKeychainAccess] setObject:email forKey:@"email"];
//}
//
//- (NSNumber *)loadUserPid {
//    NSString *userPID = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"userPID"];
//    return [NSNumber numberWithInt:[userPID intValue]];
//}
//
//- (void)saveUserPid:(NSNumber *)userPID {
//    [[LUKeychainAccess standardKeychainAccess] setObject:userPID forKey:@"userPID"];
//}
//
//- (NSString *)loadUserId {
//    NSString *userId = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"userID"];
//    return userId;
//}
//
//- (void)saveUserId:(NSString *)userID {
//    [[LUKeychainAccess standardKeychainAccess] setObject:userID forKey:@"userID"];
//}
//
//- (NSString *)loadPassword {
//    NSString *password = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"password"];
//    return password;
//}
//
//- (void)savePassword:(NSString *)password {
//    [[LUKeychainAccess standardKeychainAccess] setObject:password forKey:@"password"];
//}
//
//
//- (NSString *)loadAccessToken {
//    NSString *accessToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyToken"];
//    return accessToken;
//}
//
//- (void)saveAccessToken:(NSString *)accessToken {
//    [[LUKeychainAccess standardKeychainAccess] setObject:accessToken forKey:@"vellyToken"];
//}
//
//- (NSString *)loadTWAccessToken {
//    NSString *twAccessToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyTWToken"];
//    return twAccessToken;
//}
//
//- (void)saveTWAccessToken:(NSString *)accessTwToken {
//    [[LUKeychainAccess standardKeychainAccess] setObject:accessTwToken forKey:@"vellyTWToken"];
//}
//
//- (NSString *)loadTWAccessTokenSecret {
//    NSString *twAccessTokenSecret = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyTWTokenSecret"];
//    return twAccessTokenSecret;
//}
//
//- (void)saveTWAccessTokenSecret:(NSString *)twAccessTokenSecret {
//    [[LUKeychainAccess standardKeychainAccess] setObject:twAccessTokenSecret forKey:@"vellyTWTokenSecret"];
//}
//
//
//- (NSString *)loadFBAccessToken {
//    NSString *fbAccessToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyFBToken"];
//    return fbAccessToken;
//}
//
//- (void)saveFBAccessToken:(NSString *)accessFbToken {
//    [[LUKeychainAccess standardKeychainAccess] setObject:accessFbToken forKey:@"vellyFBToken"];
//}
//
//- (NSString *)loadDevToken {
//    NSString *deviceToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"deviceToken"];
//    return deviceToken;
//}
//
//- (void)saveDevToken:(NSString *)devToken {
//    [[LUKeychainAccess standardKeychainAccess] setObject:devToken forKey:@"deviceToken"];
//}
//
//- (NSInteger *)loadDiffDevToken {
//    NSString *diffDeviceToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"diffDeviceToken"];
//    switch ([diffDeviceToken integerValue]) {
//        case VLISACTIVEDOIT:
//            return (NSInteger *)VLISACTIVEDOIT;
//            break;
//        case VLISACTIVENON:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//        default:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//    }
//}
//
//- (void)saveDiffDevToken:(NSInteger *)diffDevToken {
//    NSString *str = [NSString stringWithFormat:@"%zd",diffDevToken];
//    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"diffDeviceToken"];
//}
//
//- (NSInteger *)loadSettingFollow {
//    NSString *settingFollow = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"settingFollow"];
//    switch ([settingFollow integerValue]) {
//        case VLISACTIVENON:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//        case VLISACTIVEDOIT:
//            return (NSInteger *)VLISACTIVEDOIT;
//            break;
//        default:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//    }
//}
//- (void)saveSettingFollow:(NSInteger *)settingFollow {
//    NSString *str = [NSString stringWithFormat:@"%zd",settingFollow];
//    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"settingFollow"];
//}
//- (NSInteger *)loadSettingGood {
//    NSString *settingGood = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"settingGood"];
//    switch ([settingGood integerValue]) {
//        case VLISACTIVENON:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//        case VLISACTIVEDOIT:
//            return (NSInteger *)VLISACTIVEDOIT;
//            break;
//        default:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//    }
//}
//- (void)saveSettingGood:(NSInteger *)settingGood {
//    NSString *str = [NSString stringWithFormat:@"%zd",settingGood];
//    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"settingGood"];
//}
//- (NSInteger *)loadSettingRanking {
//    NSString *settingRanking = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"settingRanking"];
//    switch ([settingRanking integerValue]) {
//        case VLISACTIVENON:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//        case VLISACTIVEDOIT:
//            return (NSInteger *)VLISACTIVEDOIT;
//            break;
//        default:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//    }
//}
//- (void)saveSettingRanking:(NSInteger *)settingRanking {
//    NSString *str = [NSString stringWithFormat:@"%zd",settingRanking];
//    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"settingRanking"];
//}
//- (NSInteger *)loadSettingPostSave {
//    NSString *settingPostSave = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"settingPostSave"];
//    switch ([settingPostSave integerValue]) {
//        case VLISACTIVENON:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//        case VLISACTIVEDOIT:
//            return (NSInteger *)VLISACTIVEDOIT;
//            break;
//        default:
//            return (NSInteger *)VLISACTIVENON;
//            break;
//    }
//}
//- (void)saveSettingPostSave:(NSInteger *)settingPostSave {
//    NSString *str = [NSString stringWithFormat:@"%zd",settingPostSave];
//    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"settingPostSave"];
//}



// -----------------------------------
// ユーザ情報
// -----------------------------------


// isSrv : サーバから取得するか
//- (NSString *)checkLogined
//{
//    // access_token取得
//    NSString *vellyToken = [self loadAccessToken];
//    if([vellyToken length]) {
//        return vellyToken;
//    }
//    return nil;
//}

- (void)checkUserEmail:(NSString *)email user_id:(NSString *)user_id block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{

    NSString *vellyToken = [Configuration loadAccessToken];
    if(![vellyToken length]) vellyToken = @"";
    if(![user_id length]) user_id = @"";
    
    NSDictionary *params = @{ @"email_or_username" : email };

    //[[UserClient sharedDevUserClient]
    [[UserClient sharedUserClient]
        checkUserEmail:params
        aToken:vellyToken
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
            //NSNumber *result_code = responseObject[@"result_code"];
            //DLog(@"%@", responseObject);
            //DLog(@"%@", operation.responseData);
            //DLog(@"%ld", operation.response.statusCode);
            //NSInteger *result_code = operation.response.statusCode;
            NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];

            if (block) block(resultCode, responseObject, nil);

     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {

         //DLog(@"%ld", operation.response.statusCode);
         //DLog(@"%", operation.responseString);
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];

         if (block) block(resultCode, responseBody, error);
     }
     ];

}

- (void)sendUserRegist:(User *)user block:(void (^)(NSNumber *result_code, NSString *aToken, NSMutableDictionary *responseBody, NSError *error))block
{
    if(!user){
        user = self.user;
    }
    NSString *vellyToken    = [Configuration loadAccessToken];
    if(![vellyToken length]) vellyToken = @"";
    NSString *fbToken       = [Configuration loadFBAccessToken];
    NSString *twToken       = [Configuration loadTWAccessToken];
    NSString *twTokenSecret = [Configuration loadTWAccessTokenSecret];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //params[@"vellyToken"] = vellyToken;
    // 複数配列の場合
//    params[@"user"] = [NSMutableDictionary dictionary];
//    params[@"user"][@"email"]    = (user.email) ? user.email : @"";

    // ---------------------------------
    // サーバ側とアプリ側で項目名が異なるので注意
    // ---------------------------------
    params[@"username"]        = (user.userID) ? user.userID : @"";
    params[@"nickname"]        = (user.username) ? user.username : @"";
    params[@"email"]           = (user.email) ? user.email : @"";
    params[@"password1"]       = (user.password) ? user.password : @"";
    params[@"password2"]       = (user.password) ? user.password : @"";
    params[@"fb_access_token"] = (![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0) ? fbToken : @"";
    params[@"tw_access_token"] = (![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0) ? twToken : @"";
    params[@"tw_access_token_secret"] = (![twTokenSecret isKindOfClass:[NSNull class]] && [twTokenSecret length] > 0) ? twTokenSecret : @"";

    [[UserClient sharedUserClient]
     insertUserRegist:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {

         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         NSNumber *userPID    = responseObject[@"uid"];
         NSString *aToken     = responseObject[@"key"];
         user.userPID = userPID;
         
         DLog(@"%@", aToken);
         
         if([resultCode isEqualToNumber: API_RESPONSE_CODE_SUCCESS] ||
            [resultCode isEqualToNumber: API_RESPONSE_CODE_SUCCESS_REGIST]){
             // 登録成功

             // userPID 保存
             [Configuration saveUserPid:userPID];
             // メールアドレス 保存
             [Configuration saveEmail: user.email];
             // userID
             [Configuration saveUserId:user.userID];
             // access_token 保存
             [Configuration saveAccessToken: aToken];
             
             // 以下設定 デフォルト全ON
             // フォローされた時
             [Configuration saveSettingFollow:(NSInteger *)VLISACTIVEDOIT];
             // いいねされた時
             [Configuration saveSettingGood:(NSInteger *)VLISACTIVEDOIT];
             // 順位が変更した時
             [Configuration saveSettingRanking:(NSInteger *)VLISACTIVEDOIT];
             // 元の画像を保存
             [Configuration saveSettingPostSave:(NSInteger *)VLISACTIVEDOIT];
             
             // MegicalRecordに保存
             // 全件削除
             [User MR_truncateAll];
             [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
             // 1件削除
             //  Album *mellowgold = ...;     [mellowgold MR_deleteEntity];

             //User *mrUser = [User MR_createEntity];
             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
                 User *mruser = [User MR_findFirstByAttribute:@"email" withValue:user.email inContext:localContext];
                 if(mruser == nil){
                     mruser = [User MR_createEntityInContext:localContext];
                     mruser.userPID     = (userPID) ? userPID : [NSNumber numberWithInt:0];
                     mruser.email       = (user.email) ? user.email : @"";
                     mruser.username    = (user.username) ? user.username : @"";
                     mruser.userID      = (user.userID) ? user.userID : @"";
                     mruser.accessToken = aToken;
                 }
             } completion:^(BOOL success, NSError *error) {
                 assert(success);
             }];

             // deviceToken check
             NSString *dToken = [Configuration loadDevToken];
             NSInteger *dTokenDiff = [Configuration loadDiffDevToken];
             if(dToken && (long)VLISACTIVEDOIT == (long)dTokenDiff){

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
         
         if (block) block(resultCode, aToken, nil, nil);

     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //DLog(@"%ld", operation.response.statusCode);
         //DLog(@"%", operation.responseString);
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
         NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
         if(resposeData != nil){
             failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
         }

         if (block) block(resultCode, nil, failJson, error);
     }
     ];
}


-(void)sendLogin:(User *)user block:(void (^)(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error))block
{
    if(!user){
        user = self.user;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    // APIでは user_id = username
    params[@"email_or_username"] = (user.email) ? user.email : @"";
    params[@"password"]          = (user.password) ? user.password : @"";

    [[UserClient sharedUserClient]
         sendUserLogin:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

             NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
             // access_token
             NSString *aToken        = @"";
             if(responseObject[@"key"]){
                 aToken = responseObject[@"key"];
             }
             // userPID
             NSString *userPID       = @"";
             if(responseObject[@"uid"]){
                 userPID = responseObject[@"uid"];
             }
             // tw token
             NSString *twToken       = @"";
             if(responseObject[@"tw_access_token"]){
                 twToken = responseObject[@"tw_access_token"];
             }
             // tw token secret
             NSString *twTokenSecret = @"";
             if(responseObject[@"tw_access_token_secret"]){
                 twTokenSecret = responseObject[@"tw_access_token_secret"];
             }
             // fb token
             NSString *fbToken       = @"";
             if(responseObject[@"fb_access_token"]){
                 fbToken = responseObject[@"fb_access_token"];
             }

             if(resultCode.longLongValue == API_RESPONSE_CODE_SUCCESS.longLongValue){
                 // メールアドレス 保存
                 [Configuration saveEmail: user.email];
                 // access_token 保存
                 [Configuration saveAccessToken: aToken];
                 // userPID 保存
                 [Configuration saveUserPid:[NSNumber numberWithUnsignedInt:[userPID intValue]]];
                 // twToken 保存
                 [Configuration saveTWAccessToken:twToken];
                 // twTokenSecret 保存
                 [Configuration saveTWAccessTokenSecret:twTokenSecret];
                 // fbToken 保存
                 [Configuration saveFBAccessToken:fbToken];
                 
                 // tw,fb login用
                 if(![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0 &&
                    twTokenSecret != nil && [twTokenSecret length] > 0){
                     [Configuration saveLoginTWAccessToken:twToken];
                     [Configuration saveLoginTWAccessTokenSecret:twTokenSecret];
                 }
                 if(![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0){
                     [Configuration saveLoginFBAccessToken:fbToken];
                 }
                 
                 // MegicalRecordに保存
                 // 全件削除
                 [User MR_truncateAll];
                 [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                 
                 //User *mrUser = [User MR_createEntity];
                 [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
                     
                     User *mruser = [User MR_findFirstByAttribute:@"email" withValue:user.email inContext:localContext];
                     if(mruser == nil){
                         mruser = [User MR_createEntityInContext:localContext];
                         mruser.email       = (user.email) ? user.email : @"";
                         mruser.username    = (user.username) ? user.username : @"";
                         mruser.userID      = (user.userID) ? user.userID : @"";
                         mruser.userPID     = (userPID != nil || ![userPID isEqual:[NSNull null]]) ? [NSNumber numberWithInt:[userPID intValue]] : nil;
                         mruser.accessToken = aToken;
                     }
                 } completion:^(BOOL success, NSError *error) {
                     assert(success);
                 }];
                 
                 
             }

             if (block) block(resultCode, aToken, nil, nil);
             
         } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
             
             //operation.
             NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
             DLog(@"%@", responseBody);
         
             if (block) block(resultCode, nil, nil, error);
         }
     ];

}


- (void)getUserInfo:(NSNumber *)userPID block:(void (^)(NSNumber *result_code, User *srvUser, NSMutableDictionary *responseBody, NSError *error))block
{
    __weak typeof(self) weakSelf = self;
    
    NSString *vellyToken = [Configuration loadAccessToken];
    if(![vellyToken length]) vellyToken = @"";
    
    if(![weakSelf.user isKindOfClass:[User class]] || [weakSelf.user.userPID isKindOfClass:[NSNull class]]){
        weakSelf.user = [User alloc];
    }
    
    [[UserClient sharedUserClient]
     getUserInfo:userPID
     aToken:vellyToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         strongSelf.user = [strongSelf.user initWithJSONDictionary:responseObject];
         
         if (block) block(resultCode, strongSelf.user, responseObject, nil);

     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //DLog(@"%ld", operation.response.statusCode);
         //DLog(@"%", operation.responseString);
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         if (block) block(resultCode, nil, responseBody, error);

     }
     ];
}


- (void)putUserInfo:(NSMutableDictionary *)putUser imageData:(NSData *)imageData imageName:(NSString *)imageName mimeType:(NSString *)mimeType block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{
    
    NSString *vellyToken = [Configuration loadAccessToken];
    if(![vellyToken length]) vellyToken = @"";
    
    // this api only my account..
    // NSNumber *userPID = [self loadUserPid];
    
    [[UserClient sharedUserClient]
     putUserInfo:putUser
     imageData:imageData
     imageName:imageName
     mimeType:mimeType
     aToken:vellyToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         if (block) block(resultCode, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, error);
     }
     ];
}


- (void)sendLogOut:(User *)user block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{
    // get token
    NSString *vellyToken = [Configuration loadAccessToken];

    // flg clear
    [Configuration saveDiffDevToken:(NSInteger *)VLISACTIVENON];
    
    //if(!user){
    //    user = self.user;
    //}
    //if(![vellyToken length]) vellyToken = @"";
    // NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //     params[@"params"] = vellyToken;
    //    params[@"user"] = [NSMutableDictionary dictionary];
    //    params[@"user"][@"user_id"]  = (user.userID) ? user.userID : @"";
    //    params[@"user"][@"username"] = (user.username) ? user.username : @"";
    //    params[@"user"][@"email"]    = (user.email) ? user.email : @"";
    //    params[@"user"][@"password"] = (user.password) ? user.password : @"";
    
    //"Authorization: Token #####################################"
    
    [[UserClient sharedUserClient]
     sendUserLogOut:nil
     aToken:vellyToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         //         NSNumber *resultCode = responseObject[@"result_code"];
         //         NSString *aToken     = responseObject[@"access_token"];
         //         NSString *errMsg     = responseObject[@"error_msg"];
         //         if(resultCode.longLongValue == API_RESPONSE_CODE_SUCCESS.longLongValue){
         //         }
         //DLog(@"%", operation.responseString);
         
         // 200 : 登録成功
         if (block) block(resultCode, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //DLog(@"%ld", operation.response.statusCode);
         //DLog(@"%", operation.responseString);
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         if (block) block(resultCode, nil, error);
         
     }
     ];
    
    // device_token delete on logout api
    // no send
//    // deviceToken check
//    NSString *dToken = [[UserManager sharedManager]loadDevToken];
//    dToken = @"";   // 空送信
//    [[SettingManager sharedManager] postDeviceToken:vellyToken dToken:dToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
//        if(error){
//            // error
//            
//        }else{
//            // flg clear
//            [[UserManager sharedManager]saveDiffDevToken:(NSInteger *)VLISACTIVENON];
//            
//        }
//    }];

}


- (void)postTwToken:(NSString *)aToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{
    NSString *vellyToken = aToken;
    if(![vellyToken length]) vellyToken = @"";
    
    [[UserClient sharedUserClient]
     postTwToken:vellyToken
     twToken:twToken
     twTokenSecret:twTokenSecret
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         if (block) block(resultCode, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, error);
     }
     ];
}


- (void)deleteTwToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{
    NSString *vellyToken = aToken;
    if(![vellyToken length]) vellyToken = @"";
    
    [[UserClient sharedUserClient]
     deleteTwToken:vellyToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         if (block) block(resultCode, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, error);
     }
     ];
}


- (void)postFbToken:(NSString *)aToken fbToken:(NSString *)fbToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{
    NSString *vellyToken = aToken;
    if(![vellyToken length]) vellyToken = @"";
    
    [[UserClient sharedUserClient]
     postFbToken:vellyToken
     fbToken:fbToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         if (block) block(resultCode, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, error);
     }
     ];
}


- (void)deleteFbToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{
    NSString *vellyToken = aToken;
    if(![vellyToken length]) vellyToken = @"";
    
    [[UserClient sharedUserClient]
     deleteFbToken:vellyToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         if (block) block(resultCode, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, error);
     }
     ];
}


- (void)sendTwUserLogin:(NSString *)aToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret block:(void (^)(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error))block
{
    [[UserClient sharedUserClient]
     sendTwUserLogin:aToken
     twToken:twToken
     twTokenSecret:twTokenSecret
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         // access_token
         NSString *aToken     = responseObject[@"key"];
         // userPID
         NSString *userPID    = responseObject[@"uid"];

         // tw token
         NSString *twToken       = @"";
         if(responseObject[@"tw_access_token"]){
             twToken = responseObject[@"tw_access_token"];
         }
         // tw token secret
         NSString *twTokenSecret = @"";
         if(responseObject[@"tw_access_token_secret"]){
             twTokenSecret = responseObject[@"tw_access_token_secret"];
         }
         // fb token
         NSString *fbToken       = @"";
         if(responseObject[@"fb_access_token"]){
             fbToken = responseObject[@"fb_access_token"];
         }
         
         if(resultCode.longLongValue == API_RESPONSE_CODE_SUCCESS.longLongValue){
             // メールアドレス 保存
             //[self saveEmail: user.email];
             // access_token 保存
             [Configuration saveAccessToken: aToken];
             // userPID 保存
             [Configuration saveUserPid:[NSNumber numberWithUnsignedInt:[userPID intValue]]];
             
             // twToken 保存
             [Configuration saveTWAccessToken:twToken];
             // twTokenSecret 保存
             [Configuration saveTWAccessTokenSecret:twTokenSecret];
             // fbToken 保存
             [Configuration saveFBAccessToken:fbToken];
             
             // tw,fb login用
             if(![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0 &&
                twTokenSecret != nil && [twTokenSecret length] > 0){
                 [Configuration saveLoginTWAccessToken:twToken];
                 [Configuration saveLoginTWAccessTokenSecret:twTokenSecret];
             }
             if(![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0){
                 [Configuration saveLoginFBAccessToken:fbToken];
             }
             
             // MegicalRecordに保存
             // 全件削除
             [User MR_truncateAll];
             [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
             
             //User *mrUser = [User MR_createEntity];
//             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
//                 
//                 User *mruser = [User MR_findFirstByAttribute:@"email" withValue:user.email inContext:localContext];
//                 if(mruser == nil){
//                     mruser = [User MR_createEntityInContext:localContext];
//                     mruser.email       = (user.email) ? user.email : @"";
//                     mruser.username    = (user.username) ? user.username : @"";
//                     mruser.userID      = (user.userID) ? user.userID : @"";
//                     mruser.userPID     = (userPID != nil || ![userPID isEqual:[NSNull null]]) ? [NSNumber numberWithInt:[userPID intValue]] : nil;
//                     mruser.accessToken = aToken;
//                 }
//             } completion:^(BOOL success, NSError *error) {
//                 assert(success);
//             }];

             // deviceToken check
             // required no check device_token_diff
             NSString *dToken = [Configuration loadDevToken];
             //NSInteger *dTokenDiff = [[UserManager sharedManager]loadDiffDevToken];
             //if(dToken && (long)VLISACTIVEDOIT == (long)dTokenDiff){
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
             
         }
         
         if (block) block(resultCode, aToken, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, nil, error);
     }
     ];
}

- (void)sendFbUserLogin:(NSString *)aToken fbToken:(NSString *)fbToken block:(void (^)(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error))block
{
    [[UserClient sharedUserClient]
     sendFbUserLogin:aToken
     fbToken:fbToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         // access_token
         NSString *aToken     = responseObject[@"key"];
         // userPID
         NSString *userPID    = responseObject[@"uid"];
         
         // tw token
         NSString *twToken       = @"";
         if(responseObject[@"tw_access_token"]){
             twToken = responseObject[@"tw_access_token"];
         }
         // tw token secret
         NSString *twTokenSecret = @"";
         if(responseObject[@"tw_access_token_secret"]){
             twTokenSecret = responseObject[@"tw_access_token_secret"];
         }
         // fb token
         NSString *fbToken       = @"";
         if(responseObject[@"fb_access_token"]){
             fbToken = responseObject[@"fb_access_token"];
         }
         
         if(resultCode.longLongValue == API_RESPONSE_CODE_SUCCESS.longLongValue){
             // メールアドレス 保存
             //[self saveEmail: user.email];
             // access_token 保存
             [Configuration saveAccessToken: aToken];
             // userPID 保存
             [Configuration saveUserPid:[NSNumber numberWithUnsignedInt:[userPID intValue]]];
             
             // twToken 保存
             [Configuration saveTWAccessToken:twToken];
             // twTokenSecret 保存
             [Configuration saveTWAccessTokenSecret:twTokenSecret];
             // fbToken 保存
             [Configuration saveFBAccessToken:fbToken];
             
             // tw,fb login用
             if(![twToken isKindOfClass:[NSNull class]] && [twToken length] > 0 &&
                twTokenSecret != nil && [twTokenSecret length] > 0){
                 [Configuration saveLoginTWAccessToken:twToken];
                 [Configuration saveLoginTWAccessTokenSecret:twTokenSecret];
             }
             if(![fbToken isKindOfClass:[NSNull class]] && [fbToken length] > 0){
                 [Configuration saveLoginFBAccessToken:fbToken];
             }
             
             // MegicalRecordに保存
             // 全件削除
             [User MR_truncateAll];
             [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
             
             //User *mrUser = [User MR_createEntity];
             //             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
             //
             //                 User *mruser = [User MR_findFirstByAttribute:@"email" withValue:user.email inContext:localContext];
             //                 if(mruser == nil){
             //                     mruser = [User MR_createEntityInContext:localContext];
             //                     mruser.email       = (user.email) ? user.email : @"";
             //                     mruser.username    = (user.username) ? user.username : @"";
             //                     mruser.userID      = (user.userID) ? user.userID : @"";
             //                     mruser.userPID     = (userPID != nil || ![userPID isEqual:[NSNull null]]) ? [NSNumber numberWithInt:[userPID intValue]] : nil;
             //                     mruser.accessToken = aToken;
             //                 }
             //             } completion:^(BOOL success, NSError *error) {
             //                 assert(success);
             //             }];
             
             // deviceToken check
             // required no check device_token_diff
             NSString *dToken = [Configuration loadDevToken];
             //NSInteger *dTokenDiff = [[UserManager sharedManager]loadDiffDevToken];
             //if(dToken && (long)VLISACTIVEDOIT == (long)dTokenDiff){
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
             
         }
         
         if (block) block(resultCode, aToken, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, nil, error);
     }
     ];
}


// ----------
// myFollow
// ----------
- (NSNumber *)getIsMyFollow:(NSNumber *)myUserPID userPID:(NSNumber *)userPID isSrvFollow:(BOOL)isSrvFollow loadingDate:(NSDate *)loadingDate
{
    MyFollow *myFollow = [MyFollow getMyFollow:myUserPID userPID:userPID];
    if(myFollow){
        
        DLog(@"myFollow.modified : %@", myFollow.modified);
        DLog(@"loadingDate : %@", loadingDate);
        
        NSComparisonResult result = [loadingDate compare:myFollow.modified];
        switch(result) {
            case NSOrderedSame: // same
            case NSOrderedAscending:    // loadingDate small
                return myFollow.isFollow;
                break;
            case NSOrderedDescending:   // loadingDate bigger
                break;
        }
    }
    if(isSrvFollow){
        return [NSNumber numberWithInt:VLPOSTLIKEYES];
    }else{
        return [NSNumber numberWithInt:VLPOSTLIKENO];
    }
    return nil;
}

- (void)updateMyFollow:(NSNumber *)myUserPID userPID:(NSNumber *)userPID isFollow:(BOOL)isFollow
{
    [MyFollow updateMyFollow:myUserPID userPID:userPID isFollow:isFollow];
}


@end
