//
//  InfoTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/03/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Info;
@interface InfoFollowTableViewCell : UITableViewCell

// ユーザアイコンが像
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
// フォローボタン
@property (weak, nonatomic) IBOutlet UIButton *infoFollowBtn;
// いいね / フォロー テキスト語尾
@property (weak, nonatomic) IBOutlet UILabel *infoFollowTextSuffixLabel;
// ランキング変更 テキスト語尾
@property (weak, nonatomic) IBOutlet UILabel *infoRankUpLabel;
// 公式ニュース/公式ニュース（重要）
@property (weak, nonatomic) IBOutlet UILabel *infoOfficialNewsLabel;

// いいね投稿画像
@property (weak, nonatomic) IBOutlet UIImageView *infoGoodPostImageView;
// ランキング変更アイコン画像
@property (weak, nonatomic) IBOutlet UIImageView *infoRankUpImageView;
// ユーザ表示名
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
// おしらせ登録日時
@property (weak, nonatomic) IBOutlet UILabel *infoDateLabel;


@property (weak, nonatomic) NSNumber *isFollow;

@property (weak, nonatomic) NSNumber *userPID;
@property (weak, nonatomic) NSString *user_id;
@property (weak, nonatomic) NSNumber *postID;

@property (weak, nonatomic) NSString *infoType;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic) NSLayoutConstraint *infoOfficialDateTrailing;
@property (nonatomic) NSLayoutConstraint *infoOfficialCaptionTrailing;

- (void)configureCellForAppRecord:(Info *)info;

- (CGFloat)calcCellHeight:(Info *)info;

@end
