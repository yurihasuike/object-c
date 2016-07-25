//
//  NetworkErrorView.m
//  velly
//
//  Created by m_saruwatari on 2015/06/23.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "NetworkErrorView.h"
#import "UserManager.h"

static const CGFloat margin = 20;

@implementation NetworkErrorView

#pragma mark - Singleton

+ (NetworkErrorView *)sharedInstance {
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

    self.backgroundColor = COMMON_DEF_GRAY_COLOR;
    self.alpha = 1.0f;
    self.tag   = 99999999;
    
    self.noNetworkImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_error.png"]];
    [self.noNetworkImageView setCenter:CGPointMake([[UIScreen mainScreen]bounds].size.width / 2, [[UIScreen mainScreen]bounds].size.height / 4)];
    [self addSubview:self.noNetworkImageView];
    
    self.noNetworkLabel = [[UILabel alloc]init];
    self.noNetworkLabel.textAlignment = NSTextAlignmentCenter;
    self.noNetworkLabel.font = JPBFONT(14);
    self.noNetworkLabel.text = NSLocalizedString(@"MsgNoNetwork", nil);
    self.noNetworkLabel.textColor = [UIColor lightGrayColor];
    self.noNetworkLabel.numberOfLines = 0;
    [self.noNetworkLabel setFrame:CGRectMake(0 ,0 ,0 ,self.noNetworkLabel.bounds.size.height)];
    [self addSubview:self.noNetworkLabel];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.noNetworkLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:margin]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.noNetworkLabel
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:-margin]];
    self.lblConstraint = [NSLayoutConstraint constraintWithItem:self.noNetworkImageView
                                                      attribute:NSLayoutAttributeBottom
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.noNetworkLabel
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1
                                                       constant:-margin];
    [self addConstraint:self.lblConstraint];
    
    [self.noNetworkLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.noNetworkRetryBtn = [[UIButton alloc]init];
    self.noNetworkRetryBtn.titleLabel.font = JPBFONT(14);
    [self.noNetworkRetryBtn setTitle:NSLocalizedString(@"MsgNoNetworkRetry", nil) forState:UIControlStateNormal];
    [self.noNetworkRetryBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.noNetworkRetryBtn setFrame:CGRectMake(0 ,0 ,0 ,self.noNetworkRetryBtn.bounds.size.height)];
    [self.noNetworkRetryBtn addTarget:self action:@selector(noNetworkRetry:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.noNetworkRetryBtn];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.noNetworkRetryBtn
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:margin]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.noNetworkRetryBtn
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:-margin]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.noNetworkLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.noNetworkRetryBtn
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1
                                                      constant:-40]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.noNetworkRetryBtn
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:50]];
    
    [self.noNetworkRetryBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicator setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
                                   [[UIScreen mainScreen] bounds].size.height)];
    [self.indicator setCenter:CGPointMake(
                                     [[UIScreen mainScreen] bounds].size.width / 2,
                                     [[UIScreen mainScreen] bounds].size.height / 3)];
    [self addSubview:self.indicator];
    [self.indicator stopAnimating];
    
}

+ (void)handleLayoutChanged {
    // For some reason layout subviews isn't called when rotation happens on an iPad? Need
    // to look into this more. For now, let our super view tell us to update.
    [[self sharedInstance] layoutSubviews];
}

- (void)layoutSubviews {
    [self fillSuperview];
    [super layoutSubviews];
}

- (void)fillSuperview {
    self.frame = CGRectMake(0, 0, CGRectGetWidth(self.superview.frame), CGRectGetHeight(self.superview.frame));
}


#pragma mark - Showing and hiding

+ (void)showInView:(UIView *)superview {
    [superview addSubview:[self sharedInstance]];
    
    [[self sharedInstance] fillSuperview];
    
    [self sharedInstance].isVisible = YES;
    
    [UIView animateWithDuration:0.4 animations:^{
        [self sharedInstance].alpha = 1.0;
    }];
}

- (void)showInView:(UIView *)superview {
    [superview addSubview:self];
    
    [self fillSuperview];
    self.isVisible = YES;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1.0;
    }];
}

+ (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        [self sharedInstance].alpha = 0.0;
    } completion:^(BOOL finished) {
        [[self sharedInstance] removeFromSuperview];
        
        [self sharedInstance].isVisible = NO;
    }];
}

#pragma mark - Visibility

+ (BOOL)isVisible {
    return [self sharedInstance].isVisible;
}

- (void)noNetworkRetry:(id)sender
{
    DLog(@"HomeView no Network Retry");
    
    self.indicator.alpha = 1.0f;
    [self.indicator startAnimating];
    double delayInSeconds = 1.0;
    dispatch_time_t keepTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(keepTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.8f animations:^{
            self.indicator.alpha = 0.0f;
        }completion:^(BOOL finished){
            [self.indicator stopAnimating];
        }];
    });

    if([[UserManager sharedManager]checkNetworkStatus]){

        // delegate
        if ([self.delegate respondsToSelector:@selector(noNetworkRetry)]) {
            [self.delegate noNetworkRetry];
        }
        
        [UIView animateWithDuration:0.8f animations:^{
            self.alpha = 1.0f;
            self.alpha = 0.0f;
        }completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
        
    }else{
        // keep
    }
}

@end
