//
//  PostChildCategoryTableViewController.h
//  myrecoup
//
//  Created by aoponaopon on 2016/05/14.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface PostChildCategoryTableViewController : UITableViewController

@property (nonatomic) UIViewController *parentView;
@property (nonatomic) Category_ *parent;
@property (nonatomic) NSMutableArray *categories;

- (id)initWithArgs:(UIViewController *)parentView
            parent:(Category_ *)parent;

@end
