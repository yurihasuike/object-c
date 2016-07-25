//
//  Setting.m
//  velly
//
//  Created by m_saruwatari on 2015/05/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "Setting.h"

@implementation Setting

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{

    // pushOnFollow
    NSNumber *pushOnFollow;
    NSNumber *pushOnFollow_ = json[@"push_on_follow"];
    if ([pushOnFollow_ isKindOfClass:[NSNumber class]]) {
        pushOnFollow = pushOnFollow_;
    }

    // pushOnLike
    NSNumber *pushOnLike;
    NSNumber *pushOnLike_ = json[@"push_on_like"];
    if ([pushOnLike_ isKindOfClass:[NSNumber class]]) {
        pushOnLike = pushOnLike_;
    }

    // pushOnComment
    NSNumber *pushOnComment;
    NSNumber *pushOnComment_ = json[@"push_on_comment"];
    if ([pushOnComment_ isKindOfClass:[NSNumber class]]) {
        pushOnComment = pushOnComment_;
    }

    // pushOnRanking
    NSNumber *pushOnRanking;
    NSNumber *pushOnRanking_ = json[@"push_on_rank_fluc"];
    if ([pushOnRanking_ isKindOfClass:[NSNumber class]]) {
        pushOnRanking = pushOnRanking_;
    }
    
    return [self initWithPushOn:pushOnFollow pushOnLike:pushOnLike pushOnComment:pushOnComment pushOnRanking:pushOnRanking];
}

- (instancetype)initWithPushOn:pushOnFollow pushOnLike:(NSNumber *)pushOnLike pushOnComment:(NSNumber *)pushOnComment pushOnRanking:(NSNumber *)pushOnRanking
{
    self = [super init];
    if (self) {
        _pushOnFollow  = pushOnFollow;
        _pushOnLike    = pushOnLike;
        _pushOnComment = pushOnComment;
        _pushOnRanking = pushOnRanking;
//        if(isFollow && [isFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
//            _isFollow = [NSNumber numberWithInt:1];
//        }else{
//            _isFollow = [NSNumber numberWithInt:0];
//        }
    }
    return self;

}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.pushOnFollow=%@", self.pushOnFollow];
    [description appendFormat:@", self.upushOnLike=%@", self.pushOnLike];
    [description appendFormat:@", self.pushOnComment=%@", self.pushOnComment];
    [description appendFormat:@", self.pushOnRanking=%@", self.pushOnRanking];
    [description appendString:@">"];
    return description;
}

@end
