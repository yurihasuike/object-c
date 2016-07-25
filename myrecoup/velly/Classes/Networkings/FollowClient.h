//
//  FollowClient.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager+Timeout.h"

@protocol FollowClientDelegate;

@interface FollowClient : AFHTTPRequestOperationManager

/** delegate オブジェクト */
@property (nonatomic, weak) id <NSObject, FollowClientDelegate> delegate;

+ (instancetype)sharedClient;

/** フォロー一覧を取得する
 @param perPage ページ当たりのアイテム個数.
 @param page ページ番号.
 @param block 完了時に呼び出される blocks.
 */
- (void)getFollowsWithParams:(NSString *)userPID aToken:(NSString *)aToken page:(NSUInteger)page success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

/** フォロワー一覧を取得する
 @param perPage ページ当たりのアイテム個数.
 @param page ページ番号.
 @param block 完了時に呼び出される blocks.
 */
- (void)getFollowersWithParams:(NSString *)userPID aToken:(NSString *)aToken page:(NSUInteger)page success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;



/** フォロー送信 **/
- (void)putFollow:(NSNumber *)userPID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


/** フォロー解除 **/
- (void)deleteFollow:(NSNumber *)userPID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


@end

/** `FollowClientDelegate` の delegate */
@protocol FollowClientDelegate

@end
