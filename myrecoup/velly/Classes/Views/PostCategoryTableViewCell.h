//
//  PostEditTableViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/06/16.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface PostCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (nonatomic) Category_ *category;

- (void)configureCellForCategoryName:(Category_ *)category;

@end
