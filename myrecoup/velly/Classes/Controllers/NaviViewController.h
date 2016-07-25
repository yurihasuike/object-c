//
//  NaviViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/02/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTabPagerViewController.h"
#import "HomeViewController.h"
#import "RankingTabPagerViewController.h"
#import "RankingViewController.h"
#import "PostViewController.h"
#import "InfoViewController.h"
#import "ProfileViewController.h"

//@class NaviViewController;
//@protocol NaviViewControllerDelegate;

@interface NaviViewController : UITabBarController <UITabBarControllerDelegate>

//@property (nonatomic, weak) id<NaviViewControllerDelegate> delegate;

@end

//@protocol NaviViewControllerDelegate
//- (void) didSelect:(NaviViewController*) tabBarController;
//@end
