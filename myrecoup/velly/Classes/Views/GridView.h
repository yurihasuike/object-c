//
//  GridView.h
//  velly
//
//  Created by m_saruwatari on 2015/08/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridView : UIView

@property (nonatomic) BOOL isVisible;

@property (nonatomic, strong) UIView *v1;
@property (nonatomic, strong) UIView *v2;
@property (nonatomic, strong) UIView *v3;
@property (nonatomic, strong) UIView *h1;
@property (nonatomic, strong) UIView *h2;
@property (nonatomic, strong) UIView *h3;
@property (nonatomic, strong) UIView *h4;

+ (GridView *)sharedInstance;
- (void)setupSubviews;

@end
