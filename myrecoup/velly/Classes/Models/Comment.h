//
//  Comment.h
//  velly
//
//  Created by m_saruwatari on 2015/03/26.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

/* id : コメントID */
@property (nonatomic) NSNumber *commentID;
/* userPID : ユーザPID */
@property (nonatomic) NSNumber *userPID;
/* user_id : ユーザID */
@property (nonatomic) NSString *userID;
/* username : ユーザ表示名 */
@property (nonatomic) NSString *username;
/* icon_path : ユーザアイコン画像パス */
@property (nonatomic) NSString *iconPath;
/* rank_title : コメント */
@property (nonatomic) NSString *comment;
/* created : お知らせ作成日時 */
@property (nonatomic) NSDate *created;


@property (retain, nonatomic) NSURL *iconImageURL;


/** `JSON` 辞書から `Ranking` を初期化する
 @param json.
 @return Comment.
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** Comment 初期化
 @param commentID id.
 @param userID user_id.
 @param username username.
 @param iconPath icon_path.
 @param comment comment,
 @param created created,
 @return Ranking.
 */
- (instancetype)initWithCommentID:(NSNumber *)commentID userPID:(NSNumber *)userPID userID:(NSString *)userID username:(NSString *)username iconPath:(NSString *)iconPath comment:(NSString *)comment created:(NSDate *)created;


@end
