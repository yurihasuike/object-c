//
//  DetailActionTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/07/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface DetailActionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UILabel *goodCntLabel;

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UILabel *commentCntLabel;

@property (weak, nonatomic) IBOutlet UIButton *otherBtn;

@property (nonatomic) NSNumber *cntGood;
@property (nonatomic) NSNumber *cntComment;

@property (nonatomic) NSNumber *cellHeight;

- (void)configureCellForAppRecord:(Post *)loadPost;
//- (NSNumber *)calcCellHeight;

- (void) plusCntGood;
- (void) minusCntGood;

@end
