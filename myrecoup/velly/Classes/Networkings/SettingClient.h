//
//  SettingClient.h
//  velly
//
//  Created by m_saruwatari on 2015/05/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager+Timeout.h"

@protocol SettingClientDelegate;

@interface SettingClient : AFHTTPRequestOperationManager

/** delegate オブジェクト */
@property (nonatomic, weak) id <NSObject, SettingClientDelegate> delegate;

+ (instancetype)sharedClient;
+ (instancetype)sharedDevClient;

// ***************************
// 設定情報取得
// ***************************
- (void)getSettingInfo:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// 設定情報更新
// ***************************
- (void)putUserInfo:(NSString *)aToken pushOnFollow:(NSNumber *)pushOnFollow pushOnLike:(NSNumber *)pushOnLike pushOnComment:(NSNumber *)pushOnComment pushOnRanking:(NSNumber *)pushOnRanking success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

// ***************************
// デバイストークン更新
// ***************************
- (void)postDeviceToken:(NSString *)aToken dToken:(NSString *)dToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


@end

/** `SettingClientDelegate` の delegate */
@protocol SettingClientDelegate

@end
