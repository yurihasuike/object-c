//
//  NetworkErrorView.h
//  velly
//
//  Created by m_saruwatari on 2015/06/23.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NetworkErrorView;

@protocol NetworkErrorViewDelete <NSObject>

- (void) noNetworkRetry;
- (void) dissmissView;

@end

@interface NetworkErrorView : UIView

@property (nonatomic) BOOL isVisible;
@property (nonatomic) UIActivityIndicatorView *indicator;
@property (nonatomic, weak) id<NetworkErrorViewDelete> delegate;
@property (nonatomic) UIImageView * noNetworkImageView;
@property (nonatomic) UILabel * noNetworkLabel;
@property (nonatomic) UIButton * noNetworkRetryBtn;
@property (nonatomic) NSLayoutConstraint * lblConstraint;

+ (void)showInView:(UIView *)superview;
+ (void)handleLayoutChanged;
+ (void)dismiss;
+ (BOOL)isVisible;

- (void)showInView:(UIView *)superview;

@end

