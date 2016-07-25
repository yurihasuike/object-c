//
//  PostClient.h
//  velly
//
//  Created by m_saruwatari on 2015/02/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager+Timeout.h"

@protocol PostClientDelegate;

@interface PostClient : AFHTTPRequestOperationManager

/** delegate オブジェクト */
@property (nonatomic, weak) id <NSObject, PostClientDelegate> delegate;

+ (instancetype)sharedClient;

/** 投稿一覧を取得する
 */
- (void)getPostsWithParams:(NSDictionary *)params aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

/** Wordで投稿一覧を取得する
 */
- (void)getPostsByWord:(NSDictionary *)params aToken:(NSString *)aToken Word:(NSString*)Word Type:(NSString*)Type
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

/** 投稿詳細を取得する
 */
- (void)getPostInfo:(NSNumber *)postID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

/** 投稿送信 **/
- (void)insertPostRegist:(NSMutableDictionary *)params imageData:(NSData *)imageData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

/** 投稿削除 **/
- (void)deletePost:(NSString *)postId aToken:(NSString *)aToken
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

/** 投稿更新 **/
- (void)updatePost:(NSString *)postId params:(NSDictionary *)params aToken:(NSString *)aToken
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

/** 投稿いいね **/
- (void)postPostLike:(NSString *)postID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;


/** 投稿いいね解除 **/
- (void)deletePostLike:(NSString *)postID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;

- (void)insertPostRegistMovie:(NSMutableDictionary *)params imageData:(NSData *)imageData movieData:(NSData*)movieData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;



@end

/** `PostClientDelegate` の delegate */
@protocol PostClientDelegate

@end
