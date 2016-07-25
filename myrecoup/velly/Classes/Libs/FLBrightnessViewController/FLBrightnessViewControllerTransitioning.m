//
//  FLBrightnessViewControllerTransitioning.m
//  velly
//
//  Created by m_saruwatari on 2015/07/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FLBrightnessViewControllerTransitioning.h"
#import <QuartzCore/QuartzCore.h>

@implementation FLBrightnessViewControllerTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.45f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *brightViewController = (self.isDismissing == NO) ? toViewController : fromViewController;
    UIViewController *previousController = (self.isDismissing == NO) ? fromViewController : toViewController;
    
    UIImageView *imageView = nil;
    if ((self.isDismissing && !CGRectIsEmpty(self.toFrame)) || (!self.isDismissing && !CGRectIsEmpty(self.fromFrame))) {
        imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = self.fromFrame;
        [containerView addSubview:imageView];
    }
    
    if (self.isDismissing == NO) {
        [containerView addSubview:brightViewController.view];
        [containerView bringSubviewToFront:imageView];
    }
    else {
        [containerView insertSubview:previousController.view belowSubview:brightViewController.view];
    }
    
    if (self.prepareForTransitionHandler)
        self.prepareForTransitionHandler();
    
    brightViewController.view.alpha = (self.isDismissing ? 1.0f : 0.0f);
    if (imageView) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.7f options:0 animations:^{
            imageView.frame = self.toFrame;
        } completion:^(BOOL complete) {
            [imageView removeFromSuperview];
        }];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        brightViewController.view.alpha = (self.isDismissing ? 0.0f : 1.0f);
    } completion:^(BOOL complete) {
        [self reset];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)reset
{
    self.image = nil;
    self.fromFrame = CGRectZero;
    self.toFrame = CGRectZero;
    self.prepareForTransitionHandler = nil;
}

@end
