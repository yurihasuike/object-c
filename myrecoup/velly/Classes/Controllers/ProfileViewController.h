//
//  ProfileViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NaviViewController.h"
#import "TTTAttributedLabel.h"

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *cv;
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
@property (nonatomic, strong) NSNumber *userPID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic) NSNumber *isFollow;
@property (nonatomic) NSNumber *cntPost;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isMmine;
@property (nonatomic) int sortType;
@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic) BOOL isAfterPost;

- (id) initWithUserPID:(NSNumber *)t_userPID userID:(NSString *)t_userID;
- (void)refreshPosts:(BOOL)refreshFlg sortedFlg:(BOOL)sortedFlg;

@end
