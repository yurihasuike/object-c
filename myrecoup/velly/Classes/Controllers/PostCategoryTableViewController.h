//
//  PostCategoryTableViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostEditViewController.h"
#import "PostUpdateViewController.h"

@interface PostCategoryTableViewController : UITableViewController

@property (strong, nonatomic) PostEditViewController * postEditViewController;
@property (strong, nonatomic) PostUpdateViewController * postUpdateViewController;

@end
