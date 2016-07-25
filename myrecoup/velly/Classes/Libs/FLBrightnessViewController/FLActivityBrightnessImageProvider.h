//
//  FLActivityBrightnessImageProvider.h
//  velly
//
//  Created by m_saruwatari on 2015/07/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLActivityBrightnessImageProvider : UIActivityItemProvider

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) CGRect brightnessFrame;
@property (nonatomic, readonly) NSInteger angle;

- (instancetype)initWithImage:(UIImage *)image brightnessFrame:(CGRect)brightnessFrame angle:(NSInteger)angle;

@end
