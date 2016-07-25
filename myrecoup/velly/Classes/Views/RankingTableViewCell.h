//
//  RankingTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/03/23.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Ranking;
@interface RankingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rankinguBgImageView;
@property (weak, nonatomic) IBOutlet UILabel *rankingNumLabel;

@property (weak, nonatomic) IBOutlet UIButton *userNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *userIdBtn;


@property (weak, nonatomic) IBOutlet UIButton *followBtn;
//@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
//@property (weak, nonatomic) IBOutlet UILabel *goodNumLabel;
//@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
//@property (weak, nonatomic) IBOutlet UIImageView *rankingNameImageView;
//@property (weak, nonatomic) IBOutlet UILabel *rankingNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *post1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *post2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *post3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *post4ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rankingLineImageView;

@property (weak, nonatomic) NSNumber *isFollow;

@property (weak, nonatomic) NSNumber *userPID;
@property (weak, nonatomic) NSString *user_id;
@property (nonatomic) NSNumber *postID1;
@property (nonatomic) NSNumber *postID2;
@property (nonatomic) NSNumber *postID3;
@property (nonatomic) NSNumber *postID4;

@property (nonatomic) BOOL hasPosts;

@property (nonatomic, strong) NSNumber *cellHeight;

- (void)configureCellForAppRecord:(Ranking *)ranking myUserPID:(NSNumber *)myUserPID;

- (CGFloat) rankingCellHeight;

@end
