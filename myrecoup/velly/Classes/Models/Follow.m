//
//  Follow.m
//  velly
//
//  Created by m_saruwatari on 2015/03/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "Follow.h"

@implementation Follow

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{
    // userPID
    NSNumber *userPID;
    NSNumber *userPID_ = json[@"id"];
    if ([userPID_ isKindOfClass:[NSNumber class]]) {
        userPID = userPID_;
    }
    
    // user_id
    NSString *userID;
    NSString *userID_ = json[@"username"];
    if ([userID_ isKindOfClass:[NSString class]]) {
        userID = userID_;
    }
    
    // username
    NSString *username;
    NSString *username_ = json[@"nickname"];
    if ([username_ isKindOfClass:[NSString class]]) {
        username = username_;
    }
    
    // icon_path
    NSString *iconPath;
    NSString *iconPath_ = json[@"icon"];
    if ([iconPath_ isKindOfClass:[NSString class]]) {
        iconPath = iconPath_;
    }
    
    // is_follow
    NSNumber *isFollow;
    NSNumber *isFollow_ = json[@"is_followed_by_me"];
    if ([isFollow_ isKindOfClass:[NSNumber class]]) {
        isFollow = isFollow_;
    }
    
    return [self initWithUserPID:userPID userID:userID username:username iconPath:iconPath isFollow:isFollow];
}

- (instancetype)initWithUserPID:userPID userID:(NSString *)userID username:(NSString *)username iconPath:(NSString *)iconPath isFollow:(NSNumber *)isFollow
{
    self = [super init];
    if (self) {
        _userPID = userPID;
        _userID = userID;
        _username = username;
        _iconPath = iconPath;
        if(isFollow && [isFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
            _isFollow = [NSNumber numberWithInt:1];
        }else{
            _isFollow = [NSNumber numberWithInt:0];
        }
        self.loadingDate = [NSDate date];
    }
    return self;
}

- (NSURL *)iconImageURL {
    return [NSURL URLWithString:self.iconPath];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.userPID=%@", self.userPID];
    [description appendFormat:@", self.user_id=%@", self.userID];
    [description appendFormat:@", self.username=%@", self.username];
    [description appendFormat:@", self.icon=%@", self.iconPath];
    [description appendFormat:@", self.is_follow=%@", self.isFollow];
    [description appendString:@">"];
    return description;
}


@end
