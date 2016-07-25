//
//  DetailPageViewController.h
//  myrecoup
//
//  Created by aoponaopon on 2016/03/26.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostManager.h"

@interface DetailPageViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic) UIPageViewController * pageView;
@property (nonatomic) Post * tappedPost;
@property (nonatomic) UIViewController * parent;
@property (nonatomic) NSUInteger parentClass;
@property (nonatomic) PostManager * postManager;
@property (nonatomic) NSString * sortVal;
@property (nonatomic) NSNumber * categoryID;
@property (nonatomic) NSInteger fromTag;
@property (nonatomic) UIButton * back_arrow_btn;
@property (nonatomic) UIButton * next_arrow_btn;

- (id)initWithParentAndTappedPost:(UIViewController * )parentViewController tappedPost:(Post * )tappedPost;
@end

