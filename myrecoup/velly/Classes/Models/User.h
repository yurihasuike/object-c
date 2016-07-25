//
//  User.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "_User.h"

@interface User : _User {}

@property (nonatomic) NSString *dispUserID;
@property (nonatomic) NSString *password;
@property (nonatomic) UIImage *icon;
@property (nonatomic) NSNumber *checkPolicy;
@property (nonatomic) NSNumber *is_followed_by_me;
@property (nonatomic) NSDate *loadingDate;
@property (nonatomic) NSString *attribute;
@property (nonatomic) NSString *chat_token;

/** `JSON` 辞書から `User` を初期化する
 @param json.
 @return User.
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;

/** User 初期化
 @param userID id.
 @param username username.
 @param email email.
 @param iconPath icon_path.
 @param introduction introduction.
 @param accessToken accessToken.
 @param twToken twToken.
 @param twTokenSecret twTokenSecret.
 @param fbToken fbToken.
 @param area area.
 @param sex sex.
 @param birth birth.
 @param isPushFollow is_push_follow.
 @param isPushGood is_push_good.
 @param isPushComment is_push_comment.
 @param cntFollow cnt_follow.
 @param cntFollower cnt_follower.
 @param cntPost cnt_post.
 @param isFollow isFollow.
 @param created created,
 @param is_followed_by_me is_followed_by_me.
 @param attribute pro or generel.
 @param chat_token token for sendbird message.
 @return Post.
 */
- (instancetype)initWithUserPID:(NSNumber *)userPID userID:(NSString *)userID email:(NSString *)email username:(NSString *)username iconPath:(NSString *)iconPath introduction:(NSString *)introduction accessToken:(NSString *)accessToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret fbToken:(NSString *)fbToken area:(NSNumber *)area sex:(NSString *)sex birth:(NSDate *)birth isPushFollow:(NSNumber *)isPushFollow isPushGood:(NSNumber *)isPushGood isPushComment:(NSNumber *)isPushComment cntFollow:(NSNumber *)cntFollow cntFollower:(NSNumber *)cntFollower cntPost:(NSNumber *)cntPost isFollow:(NSNumber *)isFollow created:(NSDate *)created is_followed_by_me:(NSNumber *)is_followed_by_me attribute:(NSString *)attribute chat_token:(NSString *)chat_token;

@end
