//
//  StartView.m
//  velly
//
//  Created by m_saruwatari on 2015/08/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "StartView.h"

@implementation StartView

#pragma mark - Singleton

+ (StartView *)sharedInstance {
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
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    //self.backgroundImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default.png"]];
    self.backgroundImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default-568h.png"]];
    if( [Configuration checkModel] == VLModelNameIPhone4 ){
        self.backgroundImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default.png"]];
    }else if( [Configuration checkModel] == VLModelNameIPhone6 ){
        self.backgroundImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default-375w-667h@2x.png"]];
    }else if( [Configuration checkModel] == VLModelNameIPhone6p ){
        self.backgroundImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default-414w-736h@3x.png"]];
    }
    self.backgroundImage.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    [self.backgroundImage sizeToFit];
    [self addSubview:self.backgroundImage];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    indicator.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [indicator setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width / 2, ([[UIScreen mainScreen] bounds].size.height / 2) + 28)];
    [self addSubview:indicator];
    [indicator startAnimating];
    
}

+ (void)handleLayoutChanged {
    [[self sharedInstance] layoutSubviews];
}

- (void)layoutSubviews {
    
    [self fillSuperview];
    
    CGFloat imageViewAspectRatio = 1.4;
    CGFloat maxWidth = CGRectGetWidth(self.frame) * 0.9;
    CGFloat maxHeight = CGRectGetHeight(self.frame) * 0.6;
    CGFloat containerWidth = maxWidth;
    CGFloat containerHeight = containerWidth / imageViewAspectRatio;
    
    if (containerHeight > maxHeight) {
        containerHeight = maxHeight;
        containerWidth = containerHeight * imageViewAspectRatio;
    }
    
}

- (void)fillSuperview {
    //self.frame = CGRectMake(0, 0, CGRectGetWidth(self.superview.frame), CGRectGetHeight(self.superview.frame));
    
    DLog(@"width : %f",  [[UIScreen mainScreen] bounds].size.width);
    DLog(@"height : %f",  [[UIScreen mainScreen] bounds].size.height);

    
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
}

#pragma mark - Showing and hiding

+ (void)showInView:(UIView *)superview {
    [[self sharedInstance] fillSuperview];
    [self sharedInstance].isVisible = YES;
    
    [superview addSubview:[self sharedInstance]];
    [superview bringSubviewToFront:[self sharedInstance]];
    
    [self sharedInstance].alpha = 1.0;
    //    [UIView animateWithDuration:0.4 animations:^{
    //        [self sharedInstance].alpha = 1.0;
    //    }];
}

+ (void)dismiss {
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
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
