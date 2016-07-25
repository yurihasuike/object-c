//
//  FLBrightnessImageAttributes.m
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FLBrightnessImageAttributes.h"

@interface FLBrightnessImageAttributes ()

@property (nonatomic, assign, readwrite) NSInteger angle;
@property (nonatomic, assign, readwrite) CGRect brightnessFrame;
@property (nonatomic, assign, readwrite) CGSize originalImageSize;

@end

@implementation FLBrightnessImageAttributes

- (instancetype)initWithBrightnessFrame:(CGRect)brightnessFrame angle:(NSInteger)angle originalImageSize:(CGSize)originalSize
{
    if (self = [super init]) {
        _angle = angle;
        _brightnessFrame = brightnessFrame;
        _originalImageSize = originalSize;
    }
    
    return self;
}

@end
