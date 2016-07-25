//
//  FLBrightnessViewControllerTransitioning.h
//  velly
//
//  Created by m_saruwatari on 2015/07/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FLBrightnessViewControllerTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isDismissing;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect fromFrame;
@property (nonatomic, assign) CGRect toFrame;

@property (nonatomic, copy) void (^prepareForTransitionHandler)(void);

- (void)reset;

@end
