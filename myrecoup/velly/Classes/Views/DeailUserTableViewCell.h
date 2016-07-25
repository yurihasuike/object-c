//
//  DeailUserTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/07/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

//for follow
#import "PostManager.h"
#import "UserManager.h"

@interface DeailUserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *userNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *userIdBtn;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (nonatomic) NSLayoutConstraint *fheight;
@property (nonatomic) NSLayoutConstraint *fmTop;
@property (nonatomic) NSLayoutConstraint *fmBottom;
@property (nonatomic) NSNumber *cellHeight;
@property (nonatomic) UIButton *msgBtn;
@property (nonatomic) UIView *spacer;
@property (nonatomic) UIButton *proBtn;

//for follow button
@property (nonatomic) UIButton *followBtn;
@property (nonatomic, strong) NSNumber *userPID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic) PostManager *postManager;
@property (nonatomic) NSNumber *isFollow;
@property (nonatomic) NSDate *srvLoadingDate;
@property (strong, nonatomic) User *user;
- (id) initWithUserPID:(NSNumber *)t_userPID userID:(NSString *)t_userID;
- (void)configureFollow:(Post *)loadPost;

- (void)configureCellForAppRecord:(Post *)loadPost;
//- (NSNumber *)calcCellHeight;

@end
