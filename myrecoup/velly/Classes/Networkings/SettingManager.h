//
//  SettingManager.h
//  velly
//
//  Created by m_saruwatari on 2015/05/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LUKeychainAccess.h"
#import "AFHTTPRequestOperationManager.h"
#import "Reachability.h"
#import "Setting.h"

@class SettingManager;

@interface SettingManager : NSObject

@property (nonatomic, strong) NSNumber* networkStatus;
//@property (nonatomic, readonly) NSArray *setting;

///---------------------------------------------------------------------------------------
/// @name 管理オブジェクトを得る
///---------------------------------------------------------------------------------------

/** シングルトンの管理オブジェクトを得る
 @return `SettingManager`.
 */
+ (SettingManager *)sharedManager;

/** 通信ネットワークチェック **/
- (BOOL)checkNetworkStatus;


- (void)getSettingInfo:(NSString *)aToken block:(void (^)(NSNumber *result_code, Setting *setting, NSMutableDictionary *responseBody, NSError *error))block;

- (void)putUserInfo:(NSString *)aToken pushOnFollow:(NSNumber *)pushOnFollow pushOnLike:(NSNumber *)pushOnLike pushOnComment:(NSNumber *)pushOnComment pushOnRanking:(NSNumber *)pushOnRanking block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;

- (void)postDeviceToken:(NSString *)aToken dToken:(NSString *)dToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;


@end
