//
//  Setting.h
//  velly
//
//  Created by m_saruwatari on 2015/05/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Setting : NSObject

/* push_on_follow : 被フォロー時プッシュ通知設定 */
@property (nonatomic, readonly) NSNumber *pushOnFollow;

/* push_on_like : 被いいね時プッシュ通知設定 */
@property (nonatomic, readonly) NSNumber *pushOnLike;

/* push_on_comment : 被コメント時プッシュ通知設定 */
@property (nonatomic, readonly) NSNumber *pushOnComment;

/* push_on_ranking : ランキングアップ時プッシュ通知設定 */
@property (nonatomic, readonly) NSNumber *pushOnRanking;


/** `JSON` 辞書から `Setting` を初期化する
 @param json.
 @return Setting.
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** Setting 初期化
 @param pushOnFollow pushOnFollow.
 @param pushOnLike pushOnLike.
 @param pushOnComment pushOnComment.
 @param pushOnRanking pushOnRanking.
 @return Setting.
 */
- (instancetype)initWithPushOn:pushOnFollow pushOnLike:(NSNumber *)pushOnLike pushOnComment:(NSNumber *)pushOnComment pushOnRanking:(NSNumber *)pushOnRanking;


@end
