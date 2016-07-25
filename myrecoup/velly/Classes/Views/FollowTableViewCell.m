//
//  FollowTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FollowTableViewCell.h"
#import "Follow.h"
#import "UIImageView+Networking.h"
#import "CommonUtil.h"
#import "UIImageView+WebCache.h"

@interface FollowTableViewCell ()

@property (nonatomic, weak) CommonUtil *commonUtil;
@property (nonatomic) Follow *follow;

@end

@implementation FollowTableViewCell

- (void)configureCellForAppRecord:(Follow *)follow
{
    self.follow = follow;
    CommonUtil *commonUtil = [[CommonUtil alloc] init];
    
    DLog(@"%@", follow);
    
    // ユーザPID
    self.userPID = follow.userPID;
    
    // ユーザID
    self.user_id = follow.userID;
    if(follow.userID) {
        self.userIdLabel.text = [@"@" stringByAppendingString:follow.userID];
    }else{
        self.userIdLabel.text = @"";
    }
    
    DLog(@"%@", follow.userID);
    
    // 予約ボタン
    if (self.appointmentBtn) {
        [self.contentView addSubview:self.appointmentBtn];
        [self layoutAppointmentBtn];
    }
    // ユーザ名
    if(follow.username && [follow.username length] > 0) {
        self.userNameLabel.text = follow.username;
    }else{
        self.userNameLabel.text = @"";
    }
    
    // ユーザアイコン
//    CGSize cgSize = CGSizeMake(50.0f, 50.0f);
//    CGSize radiusSize = CGSizeMake(23.0f, 23.0f);
    CGSize cgSize = CGSizeMake(200.0f, 200.0f);
    CGSize radiusSize = CGSizeMake(92.0f, 92.0f);
    if(follow.iconPath){
        [self.userImageView sd_setImageWithURL:[NSURL URLWithString:follow.iconPath]
                              placeholderImage:[UIImage imageNamed:@"ico_noimgs.png"]
                                       options: SDWebImageCacheMemoryOnly
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         image = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
                                         self.userImageView.image = image;
                                         
                                         [UIView animateWithDuration:0.8f animations:^{
                                             self.userImageView.alpha = 0;
                                             self.userImageView.alpha = 1;
                                         }];
                                         
                                     }];
    }else{
        self.userImageView.image = [UIImage imageNamed:@"ico_noimgs.png"];
    }
    
    // フォローボタン
    UIImage *btnFollowImg = [UIImage imageNamed:@"ico_follow.png"];
    UIImage *btnFollowedImg = [UIImage imageNamed:@"ico_follower.png"];
    // フォローしているか
    if([follow.isFollow isKindOfClass:[NSNumber class]]){
        NSComparisonResult result;
        result = [follow.isFollow compare:[NSNumber numberWithInt:0]];
        switch(result) {
            case NSOrderedSame: // 一致 : フォローしていない
            case NSOrderedAscending: // 謎パターン： フォローしていないとする
                [self.followBtn setImage:btnFollowImg forState:UIControlStateNormal];
                self.isFollow = [NSNumber numberWithInt:0];
                break;
            case NSOrderedDescending: // dispFollowが大きい: フォローしている
                [self.followBtn setImage:btnFollowedImg forState:UIControlStateNormal];
                self.isFollow = [NSNumber numberWithInt:1];
                break;
        }
    }else{
        [self.followBtn setImage:btnFollowImg forState:UIControlStateNormal];
        self.isFollow = [NSNumber numberWithInt:1];
    }
}

// 予約するボタンのレイアウト設定
- (void) layoutAppointmentBtn {
    self.appointmentBtn.titleLabel.font = JPFONT(10);
    [self.appointmentBtn.layer setBorderColor:[HEADER_UNDER_BG_COLOR CGColor]];
    [self.appointmentBtn.layer setBorderWidth:1.0];
    [self.appointmentBtn.layer setCornerRadius:3.0];
    [self.appointmentBtn.layer setShadowOpacity:0.1f];
    [self.appointmentBtn.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.appointmentBtn setBackgroundColor:HEADER_UNDER_BG_COLOR];
    [self.appointmentBtn setTitle:NSLocalizedString(@"MakeAppointment", nil)
                 forState:UIControlStateNormal];
    [self.appointmentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.appointmentBtn.tintColor = HEADER_UNDER_BG_COLOR;
    
    // 非表示
    self.appointmentBtn.hidden = YES;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
