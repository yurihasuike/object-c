//
//  Ranking.m
//  velly
//
//  Created by m_saruwatari on 2015/03/25.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "Ranking.h"
#import "Post.h"

#import "NSDateFormatter+MySQL.h"

@implementation Ranking

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{

    // rankingID
    NSNumber *rankingID, *rankingID_;
    if( [json[@"id"] isKindOfClass:[NSNumber class]] ){
        rankingID_ = json[@"id"];
    }else{
        rankingID_ = [NSNumber numberWithInt:0];
    }
    if ([rankingID_ isKindOfClass:[NSNumber class]]) {
        rankingID = rankingID_;
    }

    // rank
    NSNumber *rank, *rank_;
    if( [json[@"rank"] isKindOfClass:[NSNumber class]] ){
        rank_ = json[@"rank"];
    }else{
        rank_ = [NSNumber numberWithInt:0];
    }
    if ([rank_ isKindOfClass:[NSNumber class]]) {
        rank = rank_;
    }

    // categoryID
    NSString *categoryID;
    NSString *categoryID_ = json[@"category"];
    if ([categoryID_ isKindOfClass:[NSString class]]) {
        categoryID = categoryID_;
    }
    
    // userPID
    NSNumber *userPID, *userPID_;
    if( ![json[@"user"] isKindOfClass:[NSNull class]] && [json[@"user"][@"id"] isKindOfClass:[NSNumber class]] ){
        userPID_ = json[@"user"][@"id"];
    }else{
        userPID_ = [NSNumber numberWithInt:0];
    }
    if ([userPID_ isKindOfClass:[NSNumber class]]) {
        userPID = userPID_;
    }
    
    // user_id
    NSString *userID, *userID_;
    if( ![json[@"user"] isKindOfClass:[NSNull class]] && [json[@"user"][@"username"] isKindOfClass:[NSString class]] ){
        userID_ = json[@"user"][@"username"];
    }
    if ([userID_ isKindOfClass:[NSString class]]) {
        userID = userID_;
    }

    // username
    NSString *username, *username_;
    if( ![json[@"user"] isKindOfClass:[NSNull class]] && [json[@"user"][@"nickname"] isKindOfClass:[NSString class]] ){
        username_ = json[@"user"][@"nickname"];
    }
    if ([username_ isKindOfClass:[NSString class]]) {
        username = username_;
    }

    // icon_path
    NSString *iconPath, *iconPath_;
    if( ![json[@"user"] isKindOfClass:[NSNull class]] && [json[@"user"][@"icon"] isKindOfClass:[NSString class]] ){
        iconPath_ = json[@"user"][@"icon"];
    }
    if ([iconPath_ isKindOfClass:[NSString class]]) {
        iconPath = iconPath_;
    }

    // cnt_good
    NSNumber *cntGood, *cntGood_;
    if( ![json[@"user"] isKindOfClass:[NSNull class]] && [json[@"user"][@"cnt_good"] isKindOfClass:[NSNumber class]] ){
        cntGood_ = json[@"user"][@"cnt_good"];
    }
    if ([cntGood_ isKindOfClass:[NSNumber class]]) {
        cntGood = cntGood_;
    }

    // cnt_comment
    NSNumber *cntComment, *cntComment_;
    if( ![json[@"user"] isKindOfClass:[NSNull class]] && [json[@"user"][@"cnt_comment"] isKindOfClass:[NSNumber class]] ){
        cntComment_ = json[@"user"][@"cnt_comment"];
    }
    if ([cntComment_ isKindOfClass:[NSNumber class]]) {
        cntComment = cntComment_;
    }

    // rank_title
    NSString *rankTitle, *rankTitle_;
    if( [json[@"rank_title"] isKindOfClass:[NSString class]] ){
        rankTitle_ = json[@"rank_title"];
    }
    if ([rankTitle_ isKindOfClass:[NSString class]]) {
        rankTitle = rankTitle_;
    }
    
    // is_follow
    NSNumber *isFollow, *isFollow_;
    if( ![json[@"user"] isKindOfClass:[NSNull class]] && [json[@"user"][@"is_followed_by_me"] isKindOfClass:[NSNumber class]] ){
        isFollow_ = json[@"user"][@"is_followed_by_me"];
    }
    if ([isFollow_ isKindOfClass:[NSNumber class]]) {
        isFollow = isFollow_;
    }
    
    

    // has_postImg
    BOOL hasPostImg = NO;
    // posts
    NSArray *s_posts = json[@"posts"];
    NSMutableArray *mutablePosts = [NSMutableArray array];
    if([s_posts isKindOfClass:[NSArray class]]){
        for(NSDictionary *data in s_posts) {
            
//            Post *post = [[Post alloc] initWithJSONDictionary:data];
//            [mutablePosts addObject:post];
//            if(![post.originalPath isKindOfClass:[NSNull class]] ||
//               ![post.transcodedPath isKindOfClass:[NSNull class]] ||
//               ![post.thumbnailPath isKindOfClass:[NSNull class]]){
//                hasPostImg = YES;
//            }
            
            [mutablePosts addObject:data];
            if(![data[@"medium"] isKindOfClass:[NSNull class]] && (
               ![data[@"medium"][@"original_file"] isKindOfClass:[NSNull class]] ||
               ![data[@"medium"][@"transcoded_file"] isKindOfClass:[NSNull class]] ||
               ![data[@"medium"][@"thumbnail"] isKindOfClass:[NSNull class]] )){
                hasPostImg = YES;
            }

        }
    }
    
    self.hasPostImg = hasPostImg;
    
//    NSDateFormatter *dateFormatter = [NSDateFormatter MySQLDateFormatter];
//    // created
//    NSDate *created;
//    NSString *createdString = json[@"create_at"];
//    if ([createdString isKindOfClass:[NSString class]]) {
//        created = [dateFormatter dateFromString:createdString];
//    }

    
    return [self initWithRankingID:rankingID rank:rank categoryID:categoryID userPID:userPID userID:userID username:username iconPath:iconPath cntGood:cntGood cntComment:cntComment rankTitle:rankTitle isFollow:isFollow posts:mutablePosts];
}


- (instancetype)initWithRankingID:(NSNumber *)rankingID rank:rank categoryID:(NSString *)categoryID userPID:(NSNumber *)userPID userID:(NSString *)userID username:(NSString *)username iconPath:(NSString *)iconPath cntGood:(NSNumber *)cntGood cntComment:(NSNumber *)cntComment rankTitle:(NSString *)rankTitle isFollow:(NSNumber *)isFollow posts:(NSMutableArray *)posts
{
    self = [super init];
    if (self) {
        _rankingID = rankingID;
        _rank = rank;
        _categoryID = categoryID;
        _userPID = userPID;
        _userID = userID;
        _username = username;
        _iconPath = iconPath;
        _cntGood = cntGood;
        _cntComment = cntComment;
        _rankTitle = rankTitle;
        _isFollow = isFollow;
        _posts = posts;
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
    // ranking_id + category_id + user_id が等しくないときは同一じゃない.
    if (![[self rankingID] isEqualToNumber:[other rankingID]] ||
        ![[self categoryID] isEqualToString:[other categoryID]] ||
        ![[self userID] isEqualToString:[other userID]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash
{
    return [self.rankingID hash];
}

- (NSURL *)iconImageURL {
    return [NSURL URLWithString:self.iconPath];
}


- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.ranking=%@", self.rankingID];
    [description appendFormat:@"self.category_id=%@", self.categoryID];
    [description appendFormat:@", self.user_id=%@", self.userID];
    [description appendFormat:@", self.username=%@", self.username];
    [description appendFormat:@", self.icon=%@", self.iconPath];
    [description appendFormat:@", self.cnt_good=%@", self.cntGood];
    [description appendFormat:@", self.cnt_coment=%@", self.cntComment];
    [description appendFormat:@", self.rank_title=%@", self.rankTitle];
    [description appendFormat:@", self.is_follow=%@", self.isFollow];
    [description appendFormat:@", self.posts=%@", self.posts];
    [description appendString:@">"];
    return description;
}



@end
