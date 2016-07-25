//
//  UserClient.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager+Timeout.h"

@protocol UserClientDelegate;

@interface UserClient : AFHTTPRequestOperationManager

/** delegate */
@property (nonatomic, weak) id <NSObject, UserClientDelegate> delegate;

+ (instancetype)sharedUserClient;
+ (instancetype)sharedDevUserClient;

// ***************************
// ユーザメールアドレス存在チェック
// ***************************
- (void)checkUserEmail:(NSDictionary *)params aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// ユーザ登録
// ***************************
- (void)insertUserRegist:(NSMutableDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// ログイン
// ***************************
- (void)sendUserLogin:(NSMutableDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// ユーザ情報取得
// ***************************
- (void)getUserInfo:(NSNumber *)userID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// ユーザ情報更新
// ***************************
- (void)putUserInfo:(NSMutableDictionary *)putUser imageData:(NSData *)imageData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// ログアウト
// ***************************
- (void)sendUserLogOut:(NSMutableDictionary *)params aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// Twitterトークン更新
// ***************************
- (void)postTwToken:(NSString *)aToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// Twitterトークン削除
// ***************************
- (void)deleteTwToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// Facebookトークン更新
// ***************************
- (void)postFbToken:(NSString *)aToken fbToken:(NSString *)fbToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// Facebookトークン削除
// ***************************
- (void)deleteFbToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// Twitterログイン
// ***************************
- (void)sendTwUserLogin:(NSString *)aToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// Facebookログイン
// ***************************
- (void)sendFbUserLogin:(NSString *)aToken fbToken:(NSString *)fbToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


@end


@protocol UserClientDelegate

@end