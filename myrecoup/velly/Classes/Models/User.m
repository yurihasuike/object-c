//
//  User.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "User.h"

#import "NSDateFormatter+MySQL.h"

@interface User ()

// Private interface goes here.


@end


@implementation User

@synthesize username = _username;
@synthesize email = _email;
@synthesize userPID = _userPID;
@synthesize dispUserID = _dispUserID;
@synthesize userID = _userID;
@synthesize password = _password;
@synthesize checkPolicy = _checkPolicy;
@synthesize introduction = _introduction;
@synthesize accessToken = _accessToken;
@synthesize twToken = _twToken;
@synthesize twTokenSecrect = _twTokenSecrect;
@synthesize fbToken = _fbToken;
@synthesize area = _area;
@synthesize sex = _sex;
@synthesize birth = _birth;
@synthesize isPushFollow = _isPushFollow;
@synthesize isPushGood = _isPushGood;
@synthesize isPushComment = _isPushComment;
@synthesize cntFollow = _cntFollow;
@synthesize cntFollower = _cntFollower;
@synthesize cntPost = _cntPost;
@synthesize created = _created;
@synthesize is_followed_by_me = _is_followed_by_me;
@synthesize icon = _icon;
@synthesize iconPath = _iconPath;
@synthesize isFollow = _isFollow;
@synthesize loadingDate = _loadingDate;
@synthesize attribute = _attribute;
@synthesize chat_token = _chat_token;

-(void)awakeFromInsert {
    [super awakeFromInsert];
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *) CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    self.identifier = uuidStr;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{
    // birth created
    NSDateFormatter *dateFormatter = [NSDateFormatter MySQLDateFormatter];
    NSDateFormatter *birthDateFormatter = [NSDateFormatter UserBirthDateFormatter];
    
    // userPID
    NSNumber *userPID;
    NSNumber *userPID_ = json[@"id"];
    if([userPID_ isKindOfClass:[NSNumber class]]) {
        userPID = userPID_;
    }
    
    NSString *email;
    NSString *email_ = json[@"email"];
    if ([email_ isKindOfClass:[NSString class]]) {
        email = email_;
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
    
    // introduction
    NSString *introduction;
    NSString *introduction_ = json[@"bio"];
    if ([introduction_ isKindOfClass:[NSString class]]) {
        introduction = introduction_;
    }
    
    // accessToken
    NSString *accessToken;
    NSString *accessToken_ = json[@"access_token"];
    if([accessToken_ isKindOfClass:[NSString class]]) {
        accessToken = accessToken_;
    }
    
    // twToken
    NSString *twToken;
    NSString *twToken_ = json[@"twitter_token"];
    if([twToken_ isKindOfClass:[NSString class]]) {
        twToken = twToken_;
    }
    
    // twTokenSercret
    NSString *twTokenSecret;
    NSString *twTokenSecret_ = json[@"twitter_token_sercret"];
    if([twTokenSecret_ isKindOfClass:[NSString class]]) {
        twTokenSecret = twTokenSecret_;
    }
    
    // fbToken
    NSString *fbToken;
    NSString *fbToken_ = json[@"facebook_token"];
    if([fbToken_ isKindOfClass:[NSString class]]) {
        fbToken = fbToken_;
    }
    
    // area
    NSNumber *area;
    NSNumber *area_ = json[@"area"];
    if([area_ isKindOfClass:[NSNumber class]]) {
        area = area_;
    }

    // sex
    NSString *sex;
    NSString *sex_ = json[@"sex"];
    if([sex_ isKindOfClass:[NSString class]]) {
        sex = sex_;
    }
    
    // birth
    NSDate *birth;
    NSString *birthString = json[@"birthday"];
    if ([birthString isKindOfClass:[NSString class]]) {
        birth = [birthDateFormatter dateFromString:birthString];
    }
    
    // isPushFollow
    NSNumber *isPushFollow;
    NSNumber *isPushFollow_ = json[@"is_push_follow"];
    if([isPushFollow_ isKindOfClass:[NSNumber class]]) {
        isPushFollow = isPushFollow_;
    }
    
    // isPushGood
    NSNumber *isPushGood;
    NSNumber *isPushGood_ = json[@"is_push_good"];
    if([isPushGood_ isKindOfClass:[NSNumber class]]) {
        isPushGood = isPushGood_;
    }
    
    // isPushComment
    NSNumber *isPushComment;
    NSNumber *isPushComment_ = json[@"is_push_comment"];
    if([isPushComment_ isKindOfClass:[NSNumber class]]) {
        isPushComment = isPushComment_;
    }
    
    // cntFollow
    NSNumber *cntFollow;
    NSNumber *cntFollow_ = json[@"cnt_following"];
    if([cntFollow_ isKindOfClass:[NSNumber class]]) {
        cntFollow = cntFollow_;
    }
    
    // cntFollower
    NSNumber *cntFollower;
    NSNumber *cntFollower_ = json[@"cnt_followers"];
    if([cntFollower_ isKindOfClass:[NSNumber class]]) {
        cntFollower = cntFollower_;
    }
    
    // cntPost
    NSNumber *cntPost;
    NSNumber *cntPost_ = json[@"cnt_posts"];
    if([cntPost_ isKindOfClass:[NSNumber class]]) {
        cntPost = cntPost_;
    }
    
    // is_followed_by_me
    NSNumber *isFollow;
    NSNumber *isFollow_ = json[@"is_followed_by_me"];
    if([isFollow_ isKindOfClass:[NSNumber class]]){
        isFollow = isFollow_;
    }
    
    // created
    NSDate *created;
    NSString *createdString = json[@"date_joined"];
    if ([createdString isKindOfClass:[NSString class]]) {
        created = [dateFormatter dateFromString:createdString];
    }
    
    // is_followed_by_me
    NSNumber *is_followed_by_me;
    NSNumber *is_followed_by_me_ = json[@"is_followed_by_me"];
    if([is_followed_by_me_ isKindOfClass:[NSNumber class]]) {
        is_followed_by_me = is_followed_by_me_;
    }
    
    // attribute
    NSString *attribute = json[@"attribute"];
    
    NSString *chat_token;
    NSString *chat_token_ = json[@"chat_token"];
    if([chat_token_ isKindOfClass:[NSString class]]) {
        chat_token = chat_token_;
    }
    
    return [self initWithUserPID:userPID userID:userID email:(NSString *)email username:username iconPath:iconPath introduction:introduction accessToken:accessToken twToken:twToken twTokenSecret:(NSString *)twTokenSecret fbToken:fbToken area:area sex:sex birth:birth isPushFollow:isPushFollow isPushGood:isPushGood isPushComment:isPushComment cntFollow:cntFollow cntFollower:cntFollower cntPost:cntPost isFollow:isFollow created:created is_followed_by_me:is_followed_by_me attribute:attribute chat_token:chat_token];
    
}


- (instancetype)initWithUserPID:(NSNumber *)userPID userID:(NSString *)userID email:(NSString *)email username:(NSString *)username iconPath:(NSString *)iconPath introduction:(NSString *)introduction accessToken:(NSString *)accessToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret fbToken:(NSString *)fbToken area:(NSNumber *)area sex:(NSString *)sex birth:(NSDate *)birth isPushFollow:(NSNumber *)isPushFollow isPushGood:(NSNumber *)isPushGood isPushComment:(NSNumber *)isPushComment cntFollow:(NSNumber *)cntFollow cntFollower:(NSNumber *)cntFollower cntPost:(NSNumber *)cntPost isFollow:(NSNumber *)isFollow created:(NSDate *)created is_followed_by_me:(NSNumber *)is_followed_by_me attribute:(NSString *)attribute chat_token:(NSString *)chat_token
{
    self = [super init];
    if (self) {
        if(userPID)     self.userPID = userPID;
        if(userID){
            //self.userID = userID;
            self.userID = userID;
            self.dispUserID = [@"@" stringByAppendingFormat:@"%@", userID];
        }
        if(email)       self.email = email;
        if(username)    self.username = username;
        if(iconPath && [iconPath length] > 0)    self.iconPath = iconPath;
        if(introduction && [introduction length] > 0) self.introduction  = introduction;
        if(accessToken) self.accessToken = accessToken;
        if(twToken)     self.twToken = twToken;
        if(twTokenSecret) self.twTokenSecrect = twTokenSecret;
        if(fbToken)     self.fbToken = fbToken;
        //DLog(@"%@", area);
        if(area && ![area isKindOfClass:[NSNull class]]){
            self.area = area;
        }else{
            self.area = [NSNumber numberWithInt:0];
        }
        if(sex)         self.sex = sex;
        if(birth)       self.birth = birth;
        if(isPushFollow) self.isPushFollow = isPushFollow;
        if(isPushGood)  self.isPushGood = isPushGood;
        if(isPushComment) self.isPushComment = isPushComment;
        if(cntFollow) {
            self.cntFollow = cntFollow;
        }else{
            self.cntFollow = [NSNumber numberWithInt:0];
        }
        if(cntFollower) {
            self.cntFollower = cntFollower;
        }else{
            self.cntFollower = [NSNumber numberWithInt:0];
        }
        if(cntPost) {
            self.cntPost = cntPost;
        }else{
            self.cntPost = [NSNumber numberWithInt:0];
        }
        if(isFollow && [isFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
            self.isFollow = [NSNumber numberWithInt:1];
        }else{
            self.isFollow = [NSNumber numberWithInt:0];
        }
        if(created)     self.created = created;
        if(is_followed_by_me && [is_followed_by_me isEqualToNumber:[NSNumber numberWithInt:1]]){
            self.is_followed_by_me = [NSNumber numberWithInt:1];
        }else{
            self.is_followed_by_me = [NSNumber numberWithInt:0];
        }
        if (attribute) self.attribute = attribute;
        if (chat_token) self.chat_token = chat_token;
        self.loadingDate = [NSDate date];
    }
    return self;
}

@end
