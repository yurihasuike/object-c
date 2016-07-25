//
//  Comment.m
//  velly
//
//  Created by m_saruwatari on 2015/03/26.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "Comment.h"

#import "NSDateFormatter+MySQL.h"

@implementation Comment

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{
    
    // commentID
    NSNumber *commentID;
    NSNumber *commentID_ = json[@"id"];
    if ([commentID_ isKindOfClass:[NSNumber class]]) {
        commentID = commentID_;
    }
    
    // userPID
    NSNumber *userPID;
    NSNumber *userPID_ = json[@"author"][@"id"];
    if ([userPID_ isKindOfClass:[NSNumber class]]) {
        userPID = userPID_;
    }
    
    // user_id
    NSString *userID;
    NSString *userID_ = json[@"author"][@"username"];
    if ([userID_ isKindOfClass:[NSString class]]) {
        userID = userID_;
    }
    
    // username
    NSString *username;
    NSString *username_ = json[@"author"][@"nickname"];
    if ([username_ isKindOfClass:[NSString class]]) {
        username = username_;
    }
    
    // icon_path
    NSString *iconPath;
    NSString *iconPath_ = json[@"author"][@"icon"];
    if ([iconPath_ isKindOfClass:[NSString class]]) {
        iconPath = iconPath_;
    }
    
    // comment
    NSString *comment;
    NSString *comment_ = json[@"body"];
    if([comment_ isKindOfClass:[NSString class]]) {
        comment = comment_;
    }
    
    // created
    NSDateFormatter *dateFormatter = [NSDateFormatter MySQLDateFormatter];
    
    // created
    NSDate *created;
    NSString *createdString = json[@"create_at"];
    if ([createdString isKindOfClass:[NSString class]]) {
        created = [dateFormatter dateFromString:createdString];
    }
    
    return [self initWithCommentID:commentID userPID:(NSNumber *)userPID userID:userID username:username iconPath:iconPath comment:comment created:created];
}

- (instancetype)initWithCommentID:(NSNumber *)commentID userPID:(NSNumber *)userPID userID:(NSString *)userID username:(NSString *)username iconPath:(NSString *)iconPath comment:(NSString *)comment created:(NSDate *)created
{
    self = [super init];
    if (self) {
        _commentID = commentID;
        _userPID = userPID;
        _userID = userID;
        _username = username;
        _iconPath = iconPath;
        _comment = comment;
        _created = created;
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    if (![[self commentID] isEqualToNumber:[other commentID]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash
{
    return [self.commentID hash];
}

- (NSURL *)iconImageURL {
    return [NSURL URLWithString:self.iconPath];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.comment=%@", self.commentID];
    [description appendFormat:@", self.userPID=%@", self.userPID];
    [description appendFormat:@", self.user_id=%@", self.userID];
    [description appendFormat:@", self.username=%@", self.username];
    [description appendFormat:@", self.icon=%@", self.iconPath];
    [description appendFormat:@", self.comment=%@", self.comment];
    [description appendFormat:@", self.created=%@", self.created];
    [description appendString:@">"];
    return description;
}


@end
