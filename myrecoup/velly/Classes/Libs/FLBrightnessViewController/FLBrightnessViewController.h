//
//  FLBrightnessViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/11.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Bright.h"

@class FLBrightnessViewController;

@protocol FLBrightnessViewControllerDelegate <NSObject>
@optional

- (void)brightnessViewController:(FLBrightnessViewController *)brightnessViewController didBrightnessImageToRect:(CGRect)brightnessRect sliderVal:(CGFloat)sliderVal;

- (void)brightnessViewController:(FLBrightnessViewController *)brightnessViewController didBrightnessToImage:(UIImage *)image brightedimage:(UIImage *)brightedimage withRect:(CGRect)cropRect sliderVal:(CGFloat)sliderVal;

- (void)brightnessViewController:(FLBrightnessViewController *)brightnessViewController didFinishCancelled:(BOOL)cancelled;

@end


@interface FLBrightnessViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *cropedimage;
@property (nonatomic, strong) UIImage *brightedimage;

@property (nonatomic, weak) id<FLBrightnessViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL showActivitySheetOnDone;
@property (nonatomic, copy) void (^prepareForTransitionHandler)(void);

@property (nonatomic, strong) NSArray *activityItems;
@property (nonatomic, strong) NSArray *applicationActivities;
@property (nonatomic, strong) NSArray *excludedActivityTypes;


- (instancetype)initWithImage:(UIImage *)image cropedimage:(UIImage *)cropedimage brightedimage:(UIImage *)brightedimage;

- (void)dismissAnimatedFromParentViewController:(UIViewController *)viewController withBrightnessImage:(UIImage *)image toFrame:(CGRect)frame completion:(void (^)(void))completion;

- (void)dismissAnimatedFromParentViewController:(UIViewController *)viewController toFrame:(CGRect)frame completion:(void (^)(void))completion;

@end
