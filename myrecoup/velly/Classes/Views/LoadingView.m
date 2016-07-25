//
//  LoadingView.m
//  velly
//
//  Created by m_saruwatari on 2015/08/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

#pragma mark - Singleton

+ (LoadingView *)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    self = [super init];
    
    [self setupSubviews];
    
    return self;
}

#pragma mark - Creating subviews

- (void)setupSubviews {
    self.alpha = 0.0;
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    DLog(@"screen main width %f", [[UIScreen mainScreen] bounds].size.width / 2);
    
    [indicator setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
                                   [[UIScreen mainScreen] bounds].size.height)];
    //indicator.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    [indicator setCenter:CGPointMake(
                                     [[UIScreen mainScreen] bounds].size.width / 2,
                                     [[UIScreen mainScreen] bounds].size.height / 3)];
    
    DLog(@"screen width: %f", [[UIScreen mainScreen] bounds].size.width);
    
    [self addSubview:indicator];
    [indicator startAnimating];
    
}

+ (void)handleLayoutChanged {
    [[self sharedInstance] layoutSubviews];
}

- (void)layoutSubviews {
    [self fillSuperview];
}

- (void)fillSuperview {
    //self.frame = CGRectMake(0, 0, CGRectGetWidth(self.superview.bounds), CGRectGetHeight(self.superview.bounds));
    
    DLog(@"%f", [[UIScreen mainScreen] bounds].size.width / 2);
    DLog(@"%f", [[UIScreen mainScreen] bounds].size.height / 2);
    
    self.frame = CGRectMake(0, 0,
                            [[UIScreen mainScreen] bounds].size.width,
                            [[UIScreen mainScreen] bounds].size.height);
    
    DLog(@"screen width: %f", [[UIScreen mainScreen] bounds].size.width);
    
}

#pragma mark - Showing and hiding

+ (void)showInView:(UIView *)superview {
    [superview addSubview:[self sharedInstance]];
    
    //[[self sharedInstance] fillSuperview];
    
    [self sharedInstance].isVisible = YES;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self sharedInstance].alpha = 1.0;
    }];
}

+ (void)showInViewNoBackGround:(UIView *)superview {
    [superview addSubview:[self sharedInstance]];
    
    [self sharedInstance].isVisible = YES;
    [self sharedInstance].backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self sharedInstance].alpha = 1.0;
    }];
}

+ (void)dismiss {
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //[self sharedInstance].transform = CGAffineTransformMakeScale(1.6, 1.6);
                         [self sharedInstance].alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [[self sharedInstance] removeFromSuperview];
                         [self sharedInstance].isVisible = NO;
                     }];
}

#pragma mark - Visibility

+ (BOOL)isVisible {
    return [self sharedInstance].isVisible;
}


@end
