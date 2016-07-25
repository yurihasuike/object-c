//
//  UIImage+Bright.h
//  velly
//
//  Created by m_saruwatari on 2015/09/21.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface UIImage (Bright)

- (UIImage *)brightImage:(CGFloat)sliderVal;
- (UIImage *)brightImageWithFrame:(CGRect)frame sliderVal:(CGFloat)sliderVal;

@end
