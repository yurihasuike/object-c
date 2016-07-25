//
//  LoadingView.h
//  velly
//
//  Created by m_saruwatari on 2015/08/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (nonatomic) BOOL isVisible;

+ (void)showInView:(UIView *)superview;
+ (void)showInViewNoBackGround:(UIView *)superview;
+ (void)handleLayoutChanged;
+ (void)dismiss;
+ (BOOL)isVisible;

@end
