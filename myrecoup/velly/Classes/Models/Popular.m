//
//  Popular.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "Popular.h"
#import "Post.h"

#import "NSDateFormatter+MySQL.h"

@implementation Popular

@synthesize posts = _posts;

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
    
    // posts
    
    NSArray *s_posts = json[@"posts"];
    //NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[s_posts count]];
    NSMutableArray *mutablePosts = [NSMutableArray new];
    if([s_posts isKindOfClass:[NSArray class]]){
        
        for(NSDictionary *data in s_posts){
            //Post *t_post = [[Post alloc] initWithJSONDictionary:data];
            //Post *t_post = [Post initFromDictionary:data];
            [mutablePosts addObject:data];
        }
    }
    
    //    NSDateFormatter *dateFormatter = [NSDateFormatter MySQLDateFormatter];
    //    // created
    //    NSDate *created;
    //    NSString *createdString = json[@"create_at"];
    //    if ([createdString isKindOfClass:[NSString class]]) {
    //        created = [dateFormatter dateFromString:createdString];
    //    }
    
    
    return [self initWithUserPID:userPID userID:userID username:username iconPath:iconPath isFollow:isFollow posts:mutablePosts];
}


- (instancetype)initWithUserPID:(NSNumber *)userPID userID:(NSString *)userID username:(NSString *)username iconPath:(NSString *)iconPath isFollow:(NSNumber *)isFollow posts:(NSMutableArray *)mutablePosts
{
    self = [super init];
    if (self) {
        if(userPID)     _userPID = userPID;
        if(userID)      _userID = userID;
        if(username)    _username = username;
        if(iconPath)    _iconPath = iconPath;
        if(isFollow && [isFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
            _isFollow = [NSNumber numberWithInt:1];
        }else{
            _isFollow = [NSNumber numberWithInt:0];
        }
        self.posts = mutablePosts;
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
    if (![[self userPID] isEqualToNumber:[other userPID]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash
{
    return [self.userPID hash];
}

- (NSURL *)iconImageURL {
    return [NSURL URLWithString:self.iconPath];
}


-(instancetype)replacePopular:(Popular *)tPopular
{
    if (self && ![tPopular isKindOfClass:[NSNull class]]) {
        if(![tPopular.userPID isKindOfClass:[NSNull class]])   self.userPID = tPopular.userPID;
        if(![tPopular.userID isKindOfClass:[NSNull class]])  self.userID = tPopular.userID;
        if(![tPopular.username isKindOfClass:[NSNull class]])   self.username = tPopular.username;
        if(![tPopular.iconPath isKindOfClass:[NSNull class]] && [tPopular.iconPath length] > 0) self.iconPath = tPopular.iconPath;
        if(![tPopular.cntGood isKindOfClass:[NSNull class]]) self.cntGood = tPopular.cntGood;
        if(![tPopular.cntComment isKindOfClass:[NSNull class]]) self.cntComment = tPopular.cntComment;
        if(![tPopular.isFollow isKindOfClass:[NSNull class]]) self.isFollow = tPopular.isFollow;
        if(![tPopular.posts isKindOfClass:[NSNull class]]) self.posts = tPopular.posts;
    }
    return self;
}


- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.userPID=%@", self.userPID];
    [description appendFormat:@", self.user_id=%@", self.userID];
    [description appendFormat:@", self.username=%@", self.username];
    [description appendFormat:@", self.icon=%@", self.iconPath];
    [description appendFormat:@", self.is_follow=%@", self.isFollow];
    [description appendFormat:@", self.posts=%@", self.posts];
    [description appendString:@">"];
    return description;
}

@end
