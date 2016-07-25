//
//  CommentManager.h
//  velly
//
//  Created by m_saruwatari on 2015/02/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommentManager;

@interface CommentManager : NSObject

/** 投稿コメント配列
 `Comment` の `NSArray`.
 */
@property (nonatomic, readonly) NSMutableArray *comments;
@property (nonatomic, readonly) NSMutableDictionary *commentIdList;
@property (nonatomic, assign, readwrite) NSInteger lastFetchedCommentIndex;

@property (nonatomic, assign) NSInteger commentPage;
@property (nonatomic, assign) NSInteger totalCommentPages;

@property (nonatomic, strong) NSNumber* networkStatus;

///---------------------------------------------------------------------------------------
/// @name 管理オブジェクトを得る
///---------------------------------------------------------------------------------------

/** シングルトンの管理オブジェクトを得る
 @return `PostManager`.
 */
+ (CommentManager *)sharedManager;

/** 通信ネットワークチェック **/
- (BOOL)checkNetworkStatus;


//---------------------------------------------------------------------------------------
// @name 投稿コメントを取得する
//---------------------------------------------------------------------------------------

- (BOOL)canLoadCommentMore;

/** `comments` を再読込する
 いまある全ての `comments` は破棄され, 新しく読み込み直す.
 @param block 完了時に呼び出される blocks.
 */
//- (void)reloadCommentsWithParams:(NSDictionary *)params block:(void (^)(NSError *error))block;
- (void)reloadCommentsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *comments, NSUInteger commentPage, NSError *error))block;

/** `comments` の続きを読み込む
 @param block 完了時に呼び出される blocks.
 */
//- (void)loadMoreCommentsWithParams:(NSDictionary *)params block:(void (^)(NSError *error))block;
- (void)loadMoreCommentsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *comments, NSUInteger commentPage, NSError *error))block;


/* 投稿コメント送信 */
- (void)postComment:(NSNumber *)postID params:(NSMutableDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;


/* 投稿コメント削除 */
- (void)deleteComment:(NSNumber *)postID aToken:(NSString *)aToken commentID:(NSNumber *)commentID block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;



@end
