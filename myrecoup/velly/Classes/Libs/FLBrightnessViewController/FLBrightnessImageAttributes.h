//
//  FLBrightnessImageAttributes.h
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FLBrightnessImageAttributes : NSObject

@property (nonatomic, readonly) NSInteger angle;
@property (nonatomic, readonly) CGRect brightnessFrame;
@property (nonatomic, readonly) CGSize originalImageSize;

- (instancetype)initWithBrightnessFrame:(CGRect)brightnessFrame angle:(NSInteger)angle originalImageSize:(CGSize)originalSize;

@end
