//
//  DetailImageTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/07/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface DetailImageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playIconImgView;

@property (nonatomic, assign) CGFloat cellHeight;

- (void)configureCellForAppRecord:(Post *)loadPost UIImage:(UIImage *)postTempImage;
- (CGFloat)calcCellHeight:(Post *)post;

@end
