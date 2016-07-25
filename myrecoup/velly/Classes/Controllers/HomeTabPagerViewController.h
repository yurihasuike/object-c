//
//  HomeTabPagerViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GUITabPagerViewController.h"
#import "HomeViewController.h"
#import "RssNewsViewController.h"
#import "Configuration.h"
#import "NetworkErrorView.h"
//@class HomeTabPagerViewController;
//
//@protocol HomeTabPagerViewDelegate <NSObject>
//
//// delegate : sorted action
//- (void) sortAction:(NSNumber *)sortIndex;
//
//@end

@interface HomeTabPagerViewController : GUITabPagerViewController <UINavigationControllerDelegate, NetworkErrorViewDelete>
//@interface HomeTabPagerViewController : UIViewController
{
    NSNumber *_userId;
    NSNumber *_postId;
}

@property (nonatomic) int sortType;
@property (nonatomic) NSNumber *userId;
@property (nonatomic) NSNumber *postId;
@property (nonatomic) NSNumber *currentCategoryId;

@property (strong, nonatomic) IBOutlet UISegmentedControl *sortSegmentedControl;
//@property (nonatomic, weak) id<HomeTabPagerViewDelegate> delegate;

@property (nonatomic, strong) HomeViewController *currentPageController;

@property (nonatomic) RssNewsViewController *rssNewsViewController;

@property (nonatomic) UIButton *messageBtn;
@property (nonatomic) BBBadgeBarButtonItem *barMessageBtn;

-(void)toTop;

@end
