//
//  StartView.h
//  velly
//
//  Created by m_saruwatari on 2015/08/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartView : UIView

@property (nonatomic) BOOL isVisible;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIView *imageViewContainer;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) UIImageView *backgroundImage;


+ (void)showInView:(UIView *)superview;
+ (void)handleLayoutChanged;
+ (void)dismiss;
+ (BOOL)isVisible;

@end
