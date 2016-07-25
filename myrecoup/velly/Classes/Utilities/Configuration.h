//
//  Configuration.h
//  velly
//
//  Created by m_saruwatari on 2015/07/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LUKeychainAccess.h"

@interface Configuration : NSObject

+ (NSNumber *)loadBadge;
+ (void)saveBadge:(NSNumber *)badge;
+ (NSNumber *)loadSendBirdBadge;
+ (void)saveSendBirdBadge:(NSNumber *)badge;
+ (NSNumber *)loadInfoBadge;
+ (void)saveInfoBadge:(NSNumber *)badge;

+ (NSString *)loadLoginCallback;
+ (void)saveLoginCallback:(NSString *)loginCallback;

+ (NSString *)loadEmail;
+ (void)saveEmail:(NSString *)email;
+ (NSNumber *)loadUserPid;
+ (void)saveUserPid:(NSNumber *)userPID;
+ (NSString *)loadUserId;
+ (void)saveUserId:(NSString *)userID;
+ (NSString *)loadUserChatToken;
+ (void)saveUserChatToken:(NSString *)chatToken;
+ (NSString *)loadPassword;
+ (void)savePassword:(NSString *)password;
+ (NSString *)loadAccessToken;
+ (void)saveAccessToken:(NSString *)accessToken;
+ (NSString *)loadTWAccessToken;
+ (void)saveTWAccessToken:(NSString *)twAccessToken;

+ (NSString *)loadLoginTWAccessToken;
+ (void)saveLoginTWAccessToken:(NSString *)loginTwAccessToken;


+ (NSString *)loadTWAccessTokenSecret;
+ (void)saveTWAccessTokenSecret:(NSString *)twAccessTokenSecret;

+ (NSString *)loadLoginTWAccessTokenSecret;
+ (void)saveLoginTWAccessTokenSecret:(NSString *)loginTwAccessTokenSecret;


+ (NSString *)loadFBAccessToken;
+ (void)saveFBAccessToken:(NSString *)fbAccessToken;

+ (NSString *)loadLoginFBAccessToken;
+ (void)saveLoginFBAccessToken:(NSString *)fbAccessToken;


+ (NSString *)loadDevToken;
+ (void)saveDevToken:(NSString *)devToken;
+ (NSInteger *)loadDiffDevToken;
+ (void)saveDiffDevToken:(NSInteger *)diffDevToken;

+ (NSInteger *)loadSettingFollow;
+ (void)saveSettingFollow:(NSInteger *)settingFollow;
+ (NSInteger *)loadSettingGood;
+ (void)saveSettingGood:(NSInteger *)settingGood;
+ (NSInteger *)loadSettingComment;
+ (void)saveSettingComment:(NSInteger *)settingComment;
+ (NSInteger *)loadSettingRanking;
+ (void)saveSettingRanking:(NSInteger *)settingRanking;
+ (NSInteger *)loadSettingPostSave;
+ (void)saveSettingPostSave:(NSInteger *)settingPostSave;

+ (NSString *)checkLogined;

#pragma mark - Synchronize
+ (void)synchronize;

+ (NSInteger)checkModel;

@end
