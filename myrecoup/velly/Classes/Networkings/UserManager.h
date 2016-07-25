//
//  UserManager.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LUKeychainAccess.h"
#import "AFHTTPRequestOperationManager.h"
#import "Reachability.h"
#import "User.h"
#import "MyFollow.h"

@class UserManager;

@interface UserManager : NSObject

@property (nonatomic) User *user;

@property (nonatomic, strong) NSNumber* networkStatus;

+ (UserManager *) sharedInstance;

///---------------------------------------------------------------------------------------
/// @name 管理オブジェクトを得る
///---------------------------------------------------------------------------------------

/** シングルトンの管理オブジェクトを得る
 @return `UserManager`.
 */
+ (UserManager *)sharedManager;
//+ (AFHTTPRequestOperationManager *) sharedManager;

- (BOOL)checkNetworkStatus;

- (instancetype)initWithSignupAttributes:(NSDictionary *)attributes icon:(UIImage *)icon;

- (NSString *)validateSignupForInsert;
- (NSString *)validateLogin;

//- (NSString *)loadLoginCallback;
//- (void)saveLoginCallback:(NSString *)loginCallback;

//- (NSString *)loadEmail;
//- (void)saveEmail:(NSString *)email;
//- (NSNumber *)loadUserPid;
//- (void)saveUserPid:(NSNumber *)userPID;
//- (NSString *)loadUserId;
//- (void)saveUserId:(NSString *)userID;
//- (NSString *)loadPassword;
//- (void)savePassword:(NSString *)password;
//- (NSString *)loadAccessToken;
//- (void)saveAccessToken:(NSString *)accessToken;
//- (NSString *)loadTWAccessToken;
//- (void)saveTWAccessToken:(NSString *)twAccessToken;
//- (NSString *)loadTWAccessTokenSecret;
//- (void)saveTWAccessTokenSecret:(NSString *)twAccessTokenSecret;
//- (NSString *)loadFBAccessToken;
//- (void)saveFBAccessToken:(NSString *)fbAccessToken;

//- (NSString *)loadDevToken;
//- (void)saveDevToken:(NSString *)devToken;
//- (NSInteger *)loadDiffDevToken;
//- (void)saveDiffDevToken:(NSInteger *)diffDevToken;

//- (NSInteger *)loadSettingFollow;
//- (void)saveSettingFollow:(NSInteger *)settingFollow;
//- (NSInteger *)loadSettingGood;
//- (void)saveSettingGood:(NSInteger *)settingGood;
//- (NSInteger *)loadSettingRanking;
//- (void)saveSettingRanking:(NSInteger *)settingRanking;
//- (NSInteger *)loadSettingPostSave;
//- (void)saveSettingPostSave:(NSInteger *)settingPostSave;

//- (NSString *)checkLogined;

- (void)checkUserEmail:(NSString *)email user_id:(NSString *)user_id block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;

- (void)sendUserRegist:(User *)user block:(void (^)(NSNumber *result_code, NSString *aToken, NSMutableDictionary *responseBody, NSError *error))block;

- (void)sendLogin:(User *)user block:(void (^)(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error))block;

- (void)getUserInfo:(NSNumber *)userPID block:(void (^)(NSNumber *result_code, User *srvUser, NSMutableDictionary *responseBody, NSError *error))block;

- (void)putUserInfo:(NSMutableDictionary *)putUser imageData:(NSData *)imageData imageName:(NSString *)imageName mimeType:(NSString *)mimeType block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;

- (void)sendLogOut:(User *)user block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;

- (void)postTwToken:(NSString *)aToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;

- (void)deleteTwToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;

- (void)postFbToken:(NSString *)aToken fbToken:(NSString *)fbToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;

- (void)deleteFbToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;

- (void)sendTwUserLogin:(NSString *)aToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret block:(void (^)(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error))block;

- (void)sendFbUserLogin:(NSString *)aToken fbToken:(NSString *)fbToken block:(void (^)(NSNumber *result_code, NSString *aToken, NSString *errMsg, NSError *error))block;


// myFollow
- (NSNumber *)getIsMyFollow:(NSNumber *)myUserPID userPID:(NSNumber *)userPID isSrvFollow:(BOOL)isSrvFollow loadingDate:(NSDate *)loadingDate;
- (void)updateMyFollow:(NSNumber *)myUserPID userPID:(NSNumber *)userPID isFollow:(BOOL)isFollow;


@end
