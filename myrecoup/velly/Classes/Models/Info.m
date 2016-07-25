//
//  Info.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "Info.h"

#import "NSDateFormatter+MySQL.h"

@implementation Info

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{

    // infoID
    NSNumber *infoID;
    NSNumber *infoID_ = json[@"id"];
    if ([infoID_ isKindOfClass:[NSNumber class]]) {
        infoID = infoID_;
    }
    
    // infoType
    NSString *infoType;
    NSString *infoType_ = json[@"attribute"];
    // f: followed, r: rankup, l: liked, c: commented
    if ([infoType_ isKindOfClass:[NSString class]]) {
        infoType = infoType_;
    }
    
    // userPID
    NSNumber *userPID;
    NSNumber *userPID_;
    if(json[@"actor"] && ![json[@"actor"] isKindOfClass:[NSNull class]]) {
        userPID_ = json[@"actor"][@"id"];
    }
    if ([userPID_ isKindOfClass:[NSNumber class]]){
        userPID = userPID_;
    }

    // user_id
    NSString *userID;
    NSString *userID_;
    if(json[@"actor"] && ![json[@"actor"] isKindOfClass:[NSNull class]]) {
        userID_ = json[@"actor"][@"username"];
    }
    if ([userID_ isKindOfClass:[NSString class]]) {
        userID = userID_;
    }

    // post_id
    NSNumber *postID;
    NSNumber *postID_;
    if(json[@"post"] && ![json[@"post"] isKindOfClass:[NSNull class]]) {
        postID_ = json[@"post"][@"id"];
    }
    if ([postID_ isKindOfClass:[NSNumber class]]) {
        postID = postID_;
    }

    NSString *postBody;
    NSString *postBody_;
    if(json[@"post"] && ![json[@"post"] isKindOfClass:[NSNull class]]) {
        postBody_ = json[@"post"][@"body"];
    }
    if ([postBody_ isKindOfClass:[NSString class]]) {
        postBody = postBody_;
    }
    
    // img_path
    NSString *imgPath;
    NSString *imgPath_;
    if(json[@"post"] && ![json[@"post"] isKindOfClass:[NSNull class]]) {
        imgPath_ = json[@"post"][@"medium"][@"original_file"];
        
        //動画ならthumbnailを入れる
        if ([imgPath_ hasSuffix:@".mov"] || [imgPath_ hasSuffix:@".mp4"]) {
            imgPath_ = json[@"post"][@"medium"][@"thumbnail"];
        }
    }
    if ([imgPath_ isKindOfClass:[NSString class]]) {
        imgPath = imgPath_;
    }
    
    // username
    NSString *username;
    NSString *username_;
    if(json[@"actor"] && ![json[@"actor"] isKindOfClass:[NSNull class]]) {
        username_ = json[@"actor"][@"username"];
    }
    if ([username_ isKindOfClass:[NSString class]]) {
        username = username_;
    }
    
    // icon_path
    NSString *iconPath;
    NSString *iconPath_;
    if(json[@"actor"] && ![json[@"actor"] isKindOfClass:[NSNull class]]) {
        iconPath_ = json[@"actor"][@"icon"];
    }
    if ([iconPath_ isKindOfClass:[NSString class]]) {
        iconPath = iconPath_;
    }
    
    // disp_follow
    NSNumber *dispFollow;
    NSNumber *dispFollow_;
    if(json[@"actor"] && ![json[@"actor"] isKindOfClass:[NSNull class]]) {
        dispFollow_ = json[@"actor"][@"is_followed_by_me"];
    }
    // is_followed_by_me
    if ([dispFollow_ isKindOfClass:[NSNumber class]]) {
        dispFollow = dispFollow_;
    }
    
    // categoryID
    NSNumber *categoryID;
    NSNumber *categoryID_;
    if(json[@"category"] && ![json[@"category"] isKindOfClass:[NSNull class]]) {
        categoryID_ = json[@"category"][@"id"];
    }
    if ([categoryID_ isKindOfClass:[NSNumber class]]){
        categoryID = categoryID_;
    }
    
    // categoryName
    NSString *categoryName;
    NSString *categoryName_;
    if(json[@"category"] && ![json[@"category"] isKindOfClass:[NSNull class]]) {
        categoryName_ = json[@"category"][@"label"];
    }
    if ([categoryName_ isKindOfClass:[NSString class]]){
        categoryName = categoryName_;
    }
    
    // rankOld
    NSNumber *rankOld;
    NSNumber *rankOld_ = json[@"old_rank"];
    if ([rankOld_ isKindOfClass:[NSNumber class]]){
        rankOld = rankOld_;
    }
    
    // rankNew
    NSNumber *rankNew;
    NSNumber *rankNew_ = json[@"new_rank"];
    if ([rankNew_ isKindOfClass:[NSNumber class]]){
        rankNew = rankNew_;
    }
    
    // title
    NSString *title;
    NSString *title_ = json[@"title"];
    if ([title_ isKindOfClass:[NSString class]]) {
        title = title_;
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter MySQLDateFormatter];
    
    // created
    NSDate *created;
    NSString *createdString = json[@"create_at"];
    if ([createdString isKindOfClass:[NSString class]]) {
        created = [dateFormatter dateFromString:createdString];
    }
    
    // caption
    NSString *caption;
    NSString *caption_ = json[@"caption"];
    if ([caption_ isKindOfClass:[NSString class]]) {
        caption = caption_;
    }
    
    // detail
    NSString *detail;
    NSString *detail_ = json[@"detail"];
    if ([detail_ isKindOfClass:[NSString class]]) {
        detail = detail_;
    }

    return [self initWithInfoID:infoID title:title infoType:infoType userPID:userPID userID:userID postID:postID username:username iconPath:iconPath imgPath:imgPath dispFollow:dispFollow categoryID:categoryID categoryName:categoryName rankOld:rankOld rankNew:rankNew created:created caption:caption detail:detail];
}


- (instancetype)initWithInfoID:(NSNumber *)infoID title:(NSString *)title infoType:(NSString *)infoType userPID:(NSNumber *)userPID userID:(NSString *)userID postID:(NSNumber *)postID username:(NSString *)username iconPath:(NSString *)iconPath imgPath:(NSString *)imgPath dispFollow:(NSNumber *)dispFollow categoryID:(NSNumber *)categoryID categoryName:(NSString *)categoryName rankOld:(NSNumber *)rankOld rankNew:(NSNumber *)rankNew created:(NSDate *)created caption:(NSString *)caption detail:(NSString *)detail
{
    self = [super init];
    if (self) {
        _infoID = infoID;
        _title = title;
        _infoType = infoType;
        _userPID = userPID;
        _userID = userID;
        _postID = postID;
        _username = username;
        _iconPath = iconPath;
        _imgPath = imgPath;
        _isFollow = dispFollow;
        _categoryID = categoryID;
        _categoryName = categoryName;
        _rankOld = rankOld;
        _rankNew = rankNew;
        _created = created;
        _caption = caption;
        _detail = detail;
        self.loadingDate = [NSDate date];
    }
    
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    // info_id check
    if (![[self infoID] isEqualToNumber:[other infoID]])
        return NO;
    
    return YES;
}


- (NSUInteger)hash
{
    return [self.infoID hash];
}

- (NSURL *)iconImageURL {
    return [NSURL URLWithString:self.iconPath];
}


- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.infoID=%@", self.infoID];
    [description appendFormat:@", self.title=%@", self.title];
    [description appendFormat:@", self.info_type=%@", self.infoType];
    [description appendFormat:@", self.userPID=%@", self.userPID];
    [description appendFormat:@", self.user_id=%@", self.userID];
    [description appendFormat:@", self.post_id=%@", self.postID];
    [description appendFormat:@", self.username=%@", self.username];
    [description appendFormat:@", self.icon_path=%@", self.iconPath];
    [description appendFormat:@", self.img_path=%@", self.imgPath];
    [description appendFormat:@", self.disp_follow=%@", self.isFollow];
    [description appendFormat:@", self.categoryID=%@", self.categoryID];
    [description appendFormat:@", self.categoryName=%@", self.categoryName];
    [description appendFormat:@", self.rankOld=%@", self.rankOld];
    [description appendFormat:@", self.rankNew=%@", self.rankNew];
    [description appendFormat:@", self.created=%@", self.created];
    [description appendFormat:@", self.caption=%@", self.caption];
    [description appendFormat:@", self.detail=%@", self.detail];
    [description appendString:@">"];
    return description;
}


@end
