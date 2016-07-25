//
//  Info.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Info : NSObject


/* id : お知らせID */
@property (nonatomic) NSNumber *infoID;
/* title : お知らせタイトル */
@property (nonatomic) NSString *title;
/* info_type : お知らせ種類 */
@property (nonatomic) NSString *infoType;
/* userPID : ユーザPID */
@property (nonatomic) NSNumber *userPID;
/* user_id : ユーザID */
@property (nonatomic) NSString *userID;
/* post_id : 投稿ID */
@property (nonatomic) NSNumber *postID;
/* username : ユーザ表示名 */
@property (nonatomic) NSString *username;
/* icon_path : ユーザアイコン画像パス */
@property (nonatomic) NSString *iconPath;
/* thumb_path : 投稿動画サムネイルパス */
@property (nonatomic) NSString *imgPath;
/* disp_follow : フォローアイコン表示有無 0:非表示 1:表示/未 2:表示/済 */
@property (nonatomic) NSNumber *isFollow;
/* categoryID : カテゴリーID */
@property (nonatomic) NSNumber *categoryID;
/* categoryName : カテゴリー名 */
@property (nonatomic) NSString *categoryName;
/* rankOld : 旧ランキング */
@property (nonatomic) NSNumber *rankOld;
/* rankNew : 新ランキング */
@property (nonatomic) NSNumber *rankNew;
/* created : お知らせ作成日時 */
@property (nonatomic) NSDate *created;
/* caption :お知らせキャプション*/
@property (nonatomic) NSString *caption;
/* detail :お知らせ詳細*/
@property (nonatomic) NSString *detail;

@property (nonatomic) NSDate *loadingDate;

@property (retain, nonatomic) NSURL *iconImageURL;


/** `JSON` 辞書から `Info` を初期化する
 @param json.
 @return BDYInfo.
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** Info 初期化
 @param infoID id.
 @param title title.
 @param infoType info_type.
 @param userPID userPID.
 @param userID user_id.
 @param postID post_id.
 @param username username.
 @param iconPath icon_path.
 @param imgPath imgPath.
 @param dispFollow disp_follow.
 @param categoryID categoryID.
 @param categoryName categoryName.
 @param rankOld rankOld.
 @param rankNew rankNew.
 @param created created.
 @return Info.
 */
- (instancetype)initWithInfoID:(NSNumber *)infoID title:(NSString *)title infoType:(NSString *)infoType userPID:(NSNumber *)userPID userID:(NSString *)userID postID:(NSNumber *)postID username:(NSString *)username iconPath:(NSString *)iconPath imgPath:(NSString *)imgPath dispFollow:(NSNumber *)dispFollow categoryID:(NSNumber *)categoryID categoryName:(NSString *)categoryName rankOld:(NSNumber *)rankOld rankNew:(NSNumber *)rankNew created:(NSDate *)created caption:(NSString *)caption detail:(NSString *)detail;


@end
