//
//  Ranking.h
//  velly
//
//  Created by m_saruwatari on 2015/03/25.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ranking : NSObject

/* id : ランキング順位 */
@property (nonatomic) NSNumber *rankingID;
/* rank : ランク順位 */
@property (nonatomic) NSNumber *rank;
/* category_id : カテゴリID */
@property (nonatomic) NSString *categoryID;
/* userPID : ユーザPID */
@property (nonatomic) NSNumber *userPID;
/* user_id : ユーザID */
@property (nonatomic) NSString *userID;
/* username : ユーザ表示名 */
@property (nonatomic) NSString *username;
/* icon_path : ユーザアイコン画像パス */
@property (nonatomic) NSString *iconPath;
/* cnt_good : いいね数 */
@property (nonatomic) NSNumber *cntGood;
/* cnt_comment : コメント数 */
@property (nonatomic) NSNumber *cntComment;
/* rank_title : 称号名 */
@property (nonatomic) NSString *rankTitle;
/* is_follow : フォローアイコン表示有無 0:表示/未 1:表示/済 */
@property (nonatomic) NSNumber *isFollow;
/* posts : 投稿画像s */
@property (nonatomic) NSMutableArray *posts;
/* hasPostImg : 投稿画像保持有無 */
@property (nonatomic) BOOL hasPostImg;

@property (nonatomic) NSDate *loadingDate;

@property (retain, nonatomic) NSURL *iconImageURL;


/** `JSON` 辞書から `Ranking` を初期化する
 @param json.
 @return Ranking.
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** Ranking 初期化
 @param rankingID id.
 @param rank rank.
 @param categoryID category_id.
 @param userPID userPID.
 @param userID user_id.
 @param username username.
 @param iconPath icon_path.
 @param cntGood cnt_good,
 @param cntCoomment cnt_comment,
 @param rankTitle rank_title.
 @param isFollow is_follow.
 @param posts posts.
 @return Ranking.
 */
- (instancetype)initWithRankingID:(NSNumber *)rankingID rank:(NSNumber *)rank categoryID:(NSString *)categoryID userPID:(NSNumber *)userPID userID:(NSString *)userID username:(NSString *)username iconPath:(NSString *)iconPath cntGood:(NSNumber *)cntGood cntComment:(NSNumber *)cntComment rankTitle:(NSString *)rankTitle isFollow:(NSNumber *)isFollow posts:(NSMutableArray *)posts;


@end
