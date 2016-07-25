//
//  InfoViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/02/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InfoViewController : UITableViewController
{
    NSNumber *_userId;
    NSNumber *_postId;
}

@property (nonatomic) NSNumber *userId;
@property (nonatomic) NSNumber *postId;
@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, strong) NSNumber *userPID;
@property (nonatomic) UILabel *infoTitle;
@property (nonatomic) UISegmentedControl *infoTypeSegmentControl;
@property (nonatomic) NSArray *segmentItems;

- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event;
- (void)refreshInfos:(BOOL)refreshFlg;

@end
