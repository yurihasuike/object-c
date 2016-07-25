//
//  FollowerTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Follower;
@interface FollowerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@property (weak, nonatomic) NSNumber *isFollow;
@property (weak, nonatomic) NSNumber *userPID;
@property (weak, nonatomic) NSString *user_id;

- (void)configureCellForAppRecord:(Follower *)follower;

@end
