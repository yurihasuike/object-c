//
//  FLBrightnessToolbar.h
//  velly
//
//  Created by m_saruwatari on 2015/07/11.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLBrightnessToolbar : UIView

@property (nonatomic, strong) UISlider *brightnessSlider;

@property (nonatomic, copy) void (^cancelButtonTapped)(void);
@property (nonatomic, copy) void (^doneButtonTapped)(void);
@property (nonatomic, copy) void (^resetButtonTapped)(void);

@property (nonatomic, copy) void (^sliderChange)(void);



@property (nonatomic, assign) BOOL resetButtonEnabled;

@property (nonatomic, readonly) CGRect doneButtonFrame;

@end
