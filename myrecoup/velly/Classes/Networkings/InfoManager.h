//
//  InfoManager.h
//  velly
//
//  Created by m_saruwatari on 2015/03/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InfoManager;

@interface InfoManager : NSObject

/** お知らせ配列
 `Info` の `NSArray`.
 */
@property (nonatomic, readonly) NSMutableArray *infos;
@property (nonatomic, readonly) NSMutableDictionary *infoIdList;
@property (nonatomic, assign) NSInteger infoPage;
@property (nonatomic, assign) NSInteger totalInfoPages;
@property (nonatomic, strong) NSNumber* networkStatus;
@property (nonatomic) NSNumber * unreadInfoCount;

///---------------------------------------------------------------------------------------
/// @name 管理オブジェクトを得る
///---------------------------------------------------------------------------------------

/** シングルトンの管理オブジェクトを得る
 @return `InfoManager`.
 */
+ (InfoManager *)sharedManager;

/** 通信ネットワークチェック **/
- (BOOL)checkNetworkStatus;

///---------------------------------------------------------------------------------------
/// @name お知らせを取得する
///---------------------------------------------------------------------------------------

- (BOOL)canLoadInfoMore;

/** `infos` を再読込する
 いまある全ての `infos` は破棄され, 新しく読み込み直す.
 @param block 完了時に呼び出される blocks.
 */
- (void)reloadInfosWithParams:(NSDictionary *)params aToken:(NSString *)aToken dToken:(NSString *)dToken attributeParams:(NSArray*)attributeParams block:(void (^)(NSMutableArray *infos, NSUInteger *infoPage, NSError *error))block;

/** `infos` の続きを読み込む
 @param block 完了時に呼び出される blocks.
 */
- (void)loadMoreInfosWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *infos, NSUInteger *infoPage, NSError *error))block;

/** 未読おしらせ数を取得する
 @param block 完了時に呼び出される blocks.
 */
- (void)getUnreadInfoCount:(NSMutableDictionary * )params
                    aToken:(NSString * )aToken
                    dToken:(NSString * )dToken
                     block:(void (^)(NSNumber * unreadInfoCount, NSError *error))block;

@end
