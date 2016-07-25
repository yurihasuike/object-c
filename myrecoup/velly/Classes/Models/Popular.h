//
//  Popular.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Popular : NSObject{
    //NSMutableArray *posts;
}

/* id : userPID */
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
/* is_follow : フォローアイコン表示有無 0:表示/未 1:表示/済 */
@property (nonatomic) NSNumber *isFollow;
/* posts : 投稿画像s */
@property (nonatomic) NSMutableArray *posts;

@property (nonatomic) NSDate *loadingDate;

@property (retain, nonatomic) NSURL *iconImageURL;


/** `JSON` 辞書から `Popular` を初期化する
 @param json.
 @return Popular.
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** Popular 初期化
 @param userPID id.
 @param userID user_id.
 @param username username.
 @param iconPath icon_path.
 @param isFollow is_follow.
 @param posts posts.
 @return Ranking.
 */
- (instancetype)initWithUserPID:(NSNumber *)userPID userID:(NSString *)userID username:(NSString *)username iconPath:(NSString *)iconPath isFollow:(NSNumber *)isFollow posts:(NSArray *)posts;

-(instancetype)replacePopular:(Popular *)tPopular;

- (NSString *)description;

@end
