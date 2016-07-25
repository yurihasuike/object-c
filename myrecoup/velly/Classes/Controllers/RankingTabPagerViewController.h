//
//  RankingTabPagerViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/23.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GUITabPagerViewController.h"
#import "RankingViewController.h"

//@class RankingTabPagerViewController;
//
//@protocol RankingTabPagerViewDelegate <NSObject>
//
//// delegate : sorted action
//- (void) sortAction:(NSNumber *)sortIndex;
//
//@end

@interface RankingTabPagerViewController : GUITabPagerViewController

@property (nonatomic) int sortType;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegmentedControl;
//@property (nonatomic, weak) id<RankingTabPagerViewDelegate> delegate;

@property (nonatomic, strong) RankingViewController *currentPageController;

@end

