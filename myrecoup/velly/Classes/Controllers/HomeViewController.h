//
//  HomeViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostManager.h"
#import "BBBadgeBarButtonItem.h"

#define HOME_POSTS_SECTION 0

@interface HomeViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *cv;
@property (nonatomic, strong) NSNumber * categoryID;
@property (nonatomic) int sortType;
@property (nonatomic, strong) PostManager *postManager;
@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic) BOOL isLoadingApi;
@property (nonatomic, strong) NSNumber *loginUserPID;

@property (nonatomic, strong) NSString *loginUserID;
@property (nonatomic, strong) NSString *myUserIconPath;
@property (nonatomic, strong) NSString *userChatToken;
@property (nonatomic) BOOL isAfterPost;
@property (nonatomic) BOOL isRss;

- (void)refreshPosts:(BOOL)refreshFlg sortedFlg:(BOOL)sortedFlg;
- (void)endIndicator;
- (void)startIndicator;
- (IBAction)openMessageListView:(id)sender;
- (BOOL)shouldShowMessage;
@end
