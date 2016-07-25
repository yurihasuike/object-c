//
//  FLActivityBrightnessImageProvider.m
//  velly
//
//  Created by m_saruwatari on 2015/07/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FLActivityBrightnessImageProvider.h"

@interface FLActivityBrightnessImageProvider ()

@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) CGRect brightnessFrame;
@property (nonatomic, assign, readwrite) NSInteger angle;

@property (atomic, strong) UIImage *brightnessImage;

@end

@implementation FLActivityBrightnessImageProvider

- (instancetype)initWithImage:(UIImage *)image brightnessFrame:(CGRect)brightnessFrame angle:(NSInteger)angle
{
    if (self = [super initWithPlaceholderItem:[UIImage new]]) {
        _image = image;
        _brightnessFrame = brightnessFrame;
        _angle = angle;
    }
    
    return self;
}

#pragma mark - UIActivity Protocols -
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return [[UIImage alloc] init];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    return self.brightnessImage;
}

#pragma mark - Image Generation -
- (id)item
{
    //If the user didn't touch the image, just forward along the original
    if (self.angle == 0 && CGRectEqualToRect(self.brightnessFrame, (CGRect){CGPointZero, self.image.size})) {
        self.brightnessImage = self.image;
        return self.brightnessImage;
    }
    
    //UIImage *image = [self.image brightnessFrame:self.brightnessFrame angle:self.angle];
    UIImage *image = self.image;
    self.brightnessImage = image;
    return self.brightnessImage;
}

@end
