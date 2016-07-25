//
//  rankingManager.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RankingManager;

@interface RankingManager : NSObject {
    //NSMutableArray *populars;
    //NSMutableDictionary *popularIdList;
}

/** ランキング配列
 `Ranking` の `NSArray`.
 */
@property (nonatomic, readonly) NSMutableArray *rankings;
@property (nonatomic, readonly) NSMutableDictionary *rankingIdList;
@property (nonatomic, assign, readwrite) NSInteger lastFetchedRankingIndex;

@property (nonatomic, assign) NSInteger rankingPage;
@property (nonatomic, assign) NSInteger totalRankingPages;

/** おすすめ配列
 `Popular` の `NSArray`.
 */
@property (nonatomic, readonly) NSMutableArray *populars;
@property (nonatomic, readonly) NSMutableDictionary *popularIdList;
@property (nonatomic, assign, readwrite) NSInteger lastFetchedPopularIndex;

@property (nonatomic, assign) NSInteger popularPage;
@property (nonatomic, assign) NSInteger totalPopularPages;

@property (nonatomic) NSInteger nextPage;


@property (nonatomic, strong) NSNumber* networkStatus;

///---------------------------------------------------------------------------------------
/// @name 管理オブジェクトを得る
///---------------------------------------------------------------------------------------

/** シングルトンの管理オブジェクトを得る
 @return `RankingManager`.
 */
+ (RankingManager *)sharedManager;

/** 通信ネットワークチェック **/
- (BOOL)checkNetworkStatus;

///---------------------------------------------------------------------------------------
/// @name ランキングを取得する
///---------------------------------------------------------------------------------------

- (BOOL)canLoadRankingMore;

/** `rankings` を再読込する
 いまある全ての `rankings` は破棄され, 新しく読み込み直す.
 @param block 完了時に呼び出される blocks.
 */
- (void)reloadRankingsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *rankings, NSUInteger *rankingPage, NSError *error))block;

/** `rankings` の続きを読み込む
 @param block 完了時に呼び出される blocks.
 */
- (void)loadMoreRankingsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *rankings, NSUInteger *rankingPage, NSError *error))block;


///---------------------------------------------------------------------------------------
/// @name おすすめを取得する
///---------------------------------------------------------------------------------------

- (BOOL)canLoadPopularMore;

/** `populars` を再読込する
 いまある全ての `populars` は破棄され, 新しく読み込み直す.
 @param block 完了時に呼び出される blocks.
 */
- (void)reloadPopularsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *populars, NSUInteger *popularPage, NSError *error))block;

/** `populars` の続きを読み込む
 @param block 完了時に呼び出される blocks.
 */
- (void)loadMorePopularsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *populars, NSUInteger *popularPage, NSError *error))block;



@end
