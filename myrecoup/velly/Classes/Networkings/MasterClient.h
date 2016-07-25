//
//  MasterClient.h
//  velly
//
//  Created by m_saruwatari on 2015/02/20.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager+Timeout.h"

@protocol MasterClientDelegate;

@interface MasterClient : AFHTTPRequestOperationManager

/** delegate オブジェクト */
@property (nonatomic, weak) id <NSObject, MasterClientDelegate> delegate;

+ (instancetype)sharedClient;


/** 投稿カテゴリ一覧を取得する
 @param perPage ページ当たりのアイテム個数.
 @param page ページ番号.
 @param block 完了時に呼び出される blocks.
 */
- (void)getPostCategoriesWithParams:(NSDictionary *)params perPage:(NSUInteger)perPage page:(NSUInteger)page success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


/** ユーザエリア一覧を取得する
 @param perPage ページ当たりのアイテム個数.
 @param page ページ番号.
 @param block 完了時に呼び出される blocks.
 */
- (void)getUserAreasWithParams:(NSDictionary *)params perPage:(NSUInteger)perPage page:(NSUInteger)page success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


@end

/** `MasterClientDelegate` の delegate */
@protocol MasterClientDelegate


@end
