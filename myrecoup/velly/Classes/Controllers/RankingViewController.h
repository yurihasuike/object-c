//
//  RankingViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/23.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankingManager.h"

@interface RankingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) RankingManager *rankingManager;

@property (nonatomic, strong) NSNumber *categoryID;
@property (nonatomic) int sortType;

- (id) initWithCategoryID:(NSNumber *)t_categoryID;

@property (nonatomic, assign) BOOL canLoadMore;

@property (nonatomic) BOOL isLoadingApi;
@property (nonatomic, strong) NSNumber *loginUserPID;
@property (nonatomic) BOOL isAfterPost;

- (void)refreshRankings:(BOOL)refreshFlg sortedFlg:(BOOL)sortedFlg;

@end
