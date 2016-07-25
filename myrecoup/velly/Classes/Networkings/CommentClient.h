//
//  CommentClient.h
//  velly
//
//  Created by m_saruwatari on 2015/02/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager+Timeout.h"

@protocol CommentClientDelegate;

@interface CommentClient : AFHTTPRequestOperationManager

/** delegate オブジェクト */
@property (nonatomic, weak) id <NSObject, CommentClientDelegate> delegate;

+ (instancetype)sharedClient;


/** 投稿コメント一覧を取得する
 @param perPage ページ当たりのアイテム個数.
 @param page ページ番号.
 @param block 完了時に呼び出される blocks.
 */
- (void)getCommentsWithParams:(NSNumber *)postID aToken:(NSString *)aToken perPage:(NSUInteger)perPage page:(NSUInteger)page success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

/* 投稿コメント送信 */
- (void)postComment:(NSNumber *)postID params:(NSMutableDictionary *)params aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


/* 投稿コメント削除 */
- (void)deleteComment:(NSNumber *)postID commentID:(NSNumber *)commentID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


@end

/** `CommentClientDelegate` の delegate */
@protocol CommentClientDelegate

@end
