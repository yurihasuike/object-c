//
//  PopularTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Popular;
@interface PopularTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@property (weak, nonatomic) IBOutlet UIButton *userNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *userIdBtn;


@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIImageView *post1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *post2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *post3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *post4ImageView;
@property (weak, nonatomic) IBOutlet UIView *popularLineView;

@property (nonatomic) Popular *popular;

@property (weak, nonatomic) NSNumber *userPID;
@property (weak, nonatomic) NSNumber *isFollow;

@property (weak, nonatomic) NSString *user_id;
@property (nonatomic) NSNumber *postID1;
@property (nonatomic) NSNumber *postID2;
@property (nonatomic) NSNumber *postID3;
@property (nonatomic) NSNumber *postID4;
@property (nonatomic) BOOL hasPosts;

@property (nonatomic, strong) NSNumber *cellHeight;

- (void)configureCellForAppRecord:(Popular *)popular;

- (CGFloat) popularCellHeight;

@end
