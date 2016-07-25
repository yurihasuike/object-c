//
//  PopularViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/28.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankingManager.h"

@interface PopularViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic) BOOL isLoadingApi;
@property (nonatomic, strong) RankingManager *rankingManager;
@property (nonatomic) BOOL isAfterRegistration;

- (id) initWithUserID:(NSString *)t_userID;
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;
- (void)configureNavigationBar;

@end
