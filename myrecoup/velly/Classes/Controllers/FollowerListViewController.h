//
//  FollowerListViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"

@interface FollowerListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) ProfileViewController *profileViewController;

@property (nonatomic, strong) NSNumber *userPID;
@property (nonatomic, strong) NSString *userID;

- (id) initWithUserID:(NSString *)t_userID;
- (id) initWithUserPID:(NSNumber *)t_userPID userID:(NSString *)t_userID;

@property (nonatomic) BOOL isLoadingApi;

@property (nonatomic, assign) BOOL canLoadMore;

@end
