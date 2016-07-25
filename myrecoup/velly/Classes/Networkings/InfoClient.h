//
//  InfoClient.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager+Timeout.h"

@protocol InfoClientDelegate;

@interface InfoClient : AFHTTPRequestOperationManager

/** delegate オブジェクト */
@property (nonatomic, weak) id <NSObject, InfoClientDelegate> delegate;

+ (instancetype)sharedClient;
+ (instancetype)sharedDevClient;

/** お知らせ一覧を取得する
 @param perPage ページ当たりのアイテム個数.
 @param page ページ番号.
 @param block 完了時に呼び出される blocks.
 */
- (void)getInfosWithParams:(NSDictionary *)params aToken:(NSString *)aToken page:(NSUInteger)page success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

/** 未読お知らせ数を取得する
 @param dToken deviceトークン(未ログインの場合のみリクエストに含める).
 @param aToken アクセストークン.
 */
- (void)getunreadInfoCountWithParams:(NSMutableDictionary * )params
                         aToken:(NSString * )aToken
                         dToken:(NSString * )dToken
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


@end


/** `InfoClientDelegate` の delegate */
@protocol InfoClientDelegate

@end
