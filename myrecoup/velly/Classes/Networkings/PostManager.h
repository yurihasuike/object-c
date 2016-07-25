//
//  PostManager.h
//  velly
//
//  Created by m_saruwatari on 2015/04/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import "MyGood.h"

@class PostManager;

@interface PostManager : NSObject

@property (nonatomic, readonly) Post *post;

/** 投稿配列
 `Post` の `NSArray`.
 */
@property (nonatomic, readonly) NSMutableArray *posts;
@property (nonatomic, readonly) NSMutableDictionary *postIdList;

@property (nonatomic, assign) NSInteger postPage;
@property (nonatomic, assign) NSInteger totalPostPages;

@property (nonatomic, strong) NSNumber* networkStatus;

///---------------------------------------------------------------------------------------
/// @name 管理オブジェクトを得る
///---------------------------------------------------------------------------------------

/** シングルトンの管理オブジェクトを得る
 @return `PostManager`.
 */
+ (PostManager *)sharedManager;

/** 通信ネットワークチェック **/
- (BOOL)checkNetworkStatus;


//---------------------------------------------------------------------------------------
// @name 投稿を取得する
//---------------------------------------------------------------------------------------

- (BOOL)canLoadPostMore;

/** `posts` を再読込する
 いまある全ての `posts` は破棄され, 新しく読み込み直す.
 @param block 完了時に呼び出される blocks.
 */
- (void)reloadPostsWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error))block;

/** `posts` の続きを読み込む
 @param block 完了時に呼び出される blocks.
 */
- (void)loadMorePostsWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error))block;

- (void)loadMorePostsByWord:(NSDictionary *)params aToken:(NSString *)aToken Word:(NSString*)Word Type:(NSString*)Type block:(void (^)(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error))block;

/** `post` 詳細を読み込む
 @param block 完了時に呼び出される blocks.
 */
- (void)getPostInfo:(NSNumber *)postID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, Post *post, NSMutableDictionary *responseBody, NSError *error))block;
/** 投稿送信(動画) **/
- (void)insertPostRegist:(NSMutableDictionary *)params imageData:(NSData *)imageData moviewData:(NSData *)movieData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSNumber *postID, NSError *error))block;

/** 投稿送信 **/
- (void)insertPostRegist:(NSMutableDictionary *)params imageData:(NSData *)imageData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSNumber *postID, NSError *error))block;

/** 投稿いいね送信 **/
- (void)postPostLike:(NSString *)postID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;


/** 投稿いいね解除 **/
- (void)deletePostLike:(NSString *)postID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block;

/** タグで投稿取得 **/
- (void)reloadPostsByWord:(NSDictionary *)params aToken:(NSString *)aToken Word:(NSString *)Word Type:(NSString*)Type block:(void (^)(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error))block;
/** `posts` を再読込する
 いまある全ての `posts` は破棄され, 新しく読み込み直す.(Hush Tagで。)
 @param block 完了時に呼び出される blocks.
 */
- (void)loadPostsByWord:(NSDictionary *)params aToken:(NSString *)aToken Word:(NSString*)Word Type:(NSString*)Type completion:(void (^)(NSMutableArray *posts, NSUInteger nextPage, NSNumber *result_code, NSError *error))block;

///投稿と総投稿数のみ取得
- (void)getPostsAndCount:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *posts, NSNumber *count, NSError *error))block;

// myGood
- (NSNumber *)getIsMyGood:(NSNumber *)myUserPID postID:(NSNumber *)postID isSrvGood:(BOOL)isSrvGood loadingDate:(NSDate *)loadingDate;
- (NSNumber *)getMyGoodCnt:(NSNumber *)myUserPID postID:(NSNumber *)postID srvGoodCnt:(NSNumber *)srvGoodCnt loadingDate:(NSDate *)loadingDate;
- (void)updateMyGood:(NSNumber *)myUserPID postID:(NSNumber *)postID isGood:(BOOL)isGood cntGood:(NSNumber *)cntGood;

@end
