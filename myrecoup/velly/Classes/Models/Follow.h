//
//  Follow.h
//  velly
//
//  Created by m_saruwatari on 2015/03/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Follow : NSObject

/* userPID : ユーザPID */
@property (nonatomic) NSNumber *userPID;
/* user_id : ユーザID */
@property (nonatomic) NSString *userID;
/* username : ユーザ表示名 */
@property (nonatomic) NSString *username;
/* icon_path : ユーザアイコン画像パス */
@property (nonatomic) NSString *iconPath;
/* is_follow : フォローアイコン表示有無 0:表示/未 1:表示/済 */
@property (nonatomic) NSNumber *isFollow;

@property (retain, nonatomic) NSURL *iconImageURL;

@property (nonatomic) NSDate *loadingDate;

/** `JSON` 辞書から `Follow` を初期化する
 @param json.
 @return Follow.
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** Ranking 初期化
 @param userPID userPID.
 @param userID user_id.
 @param username username.
 @param iconPath icon_path.
 @param isFollow is_follow.
 @return Ranking.
 */
- (instancetype)initWithUserPID:userPID userID:(NSString *)userID username:(NSString *)username iconPath:(NSString *)iconPath isFollow:(NSNumber *)isFollow;


@end
