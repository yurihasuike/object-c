//
//  ProfileHeaderCollectionReusableView.h
//  velly
//
//  Created by m_saruwatari on 2015/04/01.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface ProfileHeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *followCntBtn;
@property (weak, nonatomic) IBOutlet UILabel *followCntLabel;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@property (weak, nonatomic) IBOutlet UIButton *followerCntBtn;
@property (weak, nonatomic) IBOutlet UILabel *followerCntLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerLabel;

@property (weak, nonatomic) IBOutlet UIButton *profileEditBtn;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *descripLabel;

@property (weak, nonatomic) IBOutlet UIView *rankView;
@property (weak, nonatomic) IBOutlet UIButton *sortPostCntBtn;
@property (weak, nonatomic) IBOutlet UIButton *sortPopBtn;

@property (weak, nonatomic) IBOutlet UIButton *sortPostCntIP6Btn;
@property (weak, nonatomic) IBOutlet UIButton *sortPopIP6Btn;
@property (weak, nonatomic) IBOutlet UIButton *likePostBtn;
@property (nonatomic) UIButton *n_messageBtn;
@property (nonatomic) UIButton *proBtn;


@end
