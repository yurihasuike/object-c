//
//  FollowManager.h
//  velly
//
//  Created by m_saruwatari on 2015/03/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FollowManager;

@interface FollowManager : NSObject

/** フォロー配列
 `Follow` の `NSArray`.
 */
@property (nonatomic, readonly) NSMutableArray *follows;
@property (nonatomic, readonly) NSMutableDictionary *followIdList;

@property (nonatomic, assign) NSInteger followPage;
@property (nonatomic, assign) NSInteger totalFollowPages;

/** フォロワー配列
 `Follower` の `NSArray`.
 */
@property (nonatomic, readonly) NSMutableArray *followers;
@property (nonatomic, readonly) NSMutableDictionary *followerIdList;

@property (nonatomic, assign) NSInteger followerPage;
@property (nonatomic, assign) NSInteger totalFollowerPages;


@property (nonatomic, strong) NSNumber* networkStatus;

///---------------------------------------------------------------------------------------
/// @name 管理オブジェクトを得る
///---------------------------------------------------------------------------------------

/** シングルトンの管理オブジェクトを得る
 @return `FollowManager`.
 */
+ (FollowManager *)sharedManager;

/** 通信ネットワークチェック **/
- (BOOL)checkNetworkStatus;

///---------------------------------------------------------------------------------------
/// @name フォローを取得する
///---------------------------------------------------------------------------------------

- (BOOL)canLoadFollowMore;

/** `follows` を再読込する
 いまある全ての `follows` は破棄され, 新しく読み込み直す.
 @param block 完了時に呼び出される blocks.
 */
- (void)reloadFollowsWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *follows, NSUInteger *followPage, NSError *error))block;

/** `follows` の続きを読み込む
 @param block 完了時に呼び出される blocks.
 */
- (void)loadMoreFollowsWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *follows, NSUInteger *followPage, NSError *error))block;


///---------------------------------------------------------------------------------------
/// @name フォロワーを取得する
///---------------------------------------------------------------------------------------

- (BOOL)canLoadFollowerMore;

/** `followers` を再読込する
 いまある全ての `follows` は破棄され, 新しく読み込み直す.
 @param block 完了時に呼び出される blocks.
 */
- (void)reloadFollowersWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *followers, NSUInteger *followerPage, NSError *error))block;

/** `followers` の続きを読み込む
 @param block 完了時に呼び出される blocks.
 */
- (void)loadMoreFollowersWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *followers, NSUInteger *followerPage, NSError *error))block;


///---------------------------------------------------------------------------------------


/** フォロー送信 **/
- (void)putFollow:(NSNumber *)userPID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;


/** フォロー解除 **/
- (void)deleteFollow:(NSNumber *)userPID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;



@end
