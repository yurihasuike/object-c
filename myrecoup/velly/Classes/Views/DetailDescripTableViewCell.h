//
//  DetailDescripTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/07/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "Post.h"

@interface DetailDescripTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *postDescripLabel;

@property (nonatomic, assign) CGFloat cellHeight;

- (void)configureCellForAppRecord:(Post *)loadPost;
//- (NSNumber *)calcCellHeight;

- (CGFloat)calcCellHeight;

- (CGFloat)calcCellHeight:(Post *)loadPost;

@end
