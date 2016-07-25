//
//  PostChildCategoryTableViewCell.h
//  myrecoup
//
//  Created by aoponaopon on 2016/05/14.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface PostChildCategoryTableViewCell : UITableViewCell

@property (nonatomic) UIImageView *categoryIcon;
@property (nonatomic) UILabel *categoryName;

- (void)setIconImage:(Category_ *)category;

@end
