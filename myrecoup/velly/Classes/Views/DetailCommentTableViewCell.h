//
//  DetailCommentTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface DetailCommentTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView *iconImageView;
@property (nonatomic) IBOutlet UILabel *userNameLabel;

@property (nonatomic) IBOutlet UILabel *commentLabel;

@property (nonatomic) IBOutlet UILabel *commentDateLabel;

@property (weak, nonatomic) IBOutlet UIView *lineView;


@property (nonatomic) NSString *userID;
@property (nonatomic) NSNumber *userPID;

@property (nonatomic) NSNumber *cellHeight;


- (void)configureCellForAppRecord:(Comment *)comment;
- (CGFloat)calcCellHeight:(Comment *)comment;



@end
