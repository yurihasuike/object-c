//
//  FollowerTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FollowerTableViewCell.h"
#import "Follower.h"
#import "UIImageView+Networking.h"
#import "CommonUtil.h"
#import "UIImageView+WebCache.h"

@interface FollowerTableViewCell ()

@property (nonatomic, weak) CommonUtil *commonUtil;
@property (nonatomic) Follower *follower;


@end

@implementation FollowerTableViewCell

- (void)configureCellForAppRecord:(Follower *)follower
{
    self.follower = follower;
    CommonUtil *commonUtil = [[CommonUtil alloc] init];
    
    // ユーザPID
    self.userPID = follower.userPID;
    // ユーザID
    self.user_id = follower.userID;
    if(follower.userID) {
        self.userIdLabel.text = [@"@" stringByAppendingString:follower.userID];
    }
    
    // ユーザ名
    if(follower.username && [follower.username length] > 0) {
        self.userNameLabel.text = follower.username;
    }else{
        self.userNameLabel.text = @"";
    }

    // ユーザアイコン
//    CGSize cgSize = CGSizeMake(50.0f, 50.0f);
//    CGSize radiusSize = CGSizeMake(23.0f, 23.0f);
    CGSize cgSize = CGSizeMake(200.0f, 200.0f);
    CGSize radiusSize = CGSizeMake(92.0f, 92.0f);
    if(follower.iconPath){
        [self.userImageView sd_setImageWithURL:[NSURL URLWithString:follower.iconPath]
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
    if([follower.isFollow isKindOfClass:[NSNumber class]]){
        NSComparisonResult result;
        result = [follower.isFollow compare:[NSNumber numberWithInt:0]];
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

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
