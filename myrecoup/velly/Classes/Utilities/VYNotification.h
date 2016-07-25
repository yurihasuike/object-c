//
//  VYNotification.h
//  velly
//
//  Created by m_saruwatari on 2015/03/22.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const VYUserRankingToHomeNotification;
UIKIT_EXTERN NSString *const VYPostRankingToHomeNotification;
UIKIT_EXTERN NSString *const VYUserInfoToHomeNotification;
UIKIT_EXTERN NSString *const VYPostInfoToHomeNotification;

UIKIT_EXTERN NSString *const VYHomeReloadPostNotification;
UIKIT_EXTERN NSString *const VYRankingReloadUserNotification;

UIKIT_EXTERN NSString *const VYSentMessageNotification;
UIKIT_EXTERN NSString *const VYReceivedMessageNotification;

UIKIT_EXTERN NSString *const VYShowUserRegistNotification;

UIKIT_EXTERN NSString *const VYInfoBadgeNotification;
UIKIT_EXTERN NSString *const VYInfoDetailNotification;

UIKIT_EXTERN NSString *const VYShowLoadingNotification;
UIKIT_EXTERN NSString *const VYHideLoadingNotification;

UIKIT_EXTERN NSString *const VYShowModalLoadingNotification;
UIKIT_EXTERN NSString *const VYHideModalLoadingNotification;

@interface VYNotificationParameters : NSObject

    @property (strong, nonatomic) NSNumber *userId;
    @property (strong, nonatomic) NSNumber *postId;

@end

@interface VYSentMessageNotificationParameters : NSObject

    @property (strong, nonatomic) NSString *tweet;
    @property (nonatomic) NSUInteger statusCode;

@end

@interface VYReceivedMessageNotificationParameters : NSObject

    @property (strong, nonatomic) NSString *from;
    @property (strong, nonatomic) NSString *message;
    @property (strong, nonatomic) NSNumber *num;
    @property (strong, nonatomic) NSString *url;
    @property (strong, nonatomic) NSString *category_id;
    @property (strong, nonatomic) NSString *post_id;
    @property (strong, nonatomic) NSString *user_id;
    @property (strong, nonatomic) NSString *user_pid;
    @property (strong, nonatomic) NSNumber *is_sendbird_message;

@end

@interface VYNotificationParametersInfo : NSObject
    @property (strong, nonatomic) NSNumber *userId;
    @property (strong, nonatomic) NSNumber *postId;
    @property (strong, nonatomic) UIImageView *postImgView;
@end
