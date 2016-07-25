//
//  UIViewController+NoNetwork.m
//  myrecoup
//
//  Created by aoponaopon on 2016/06/30.
//  Copyright © 2016年 aoi.fukuoka. All rights reserved.
//

#import "UIViewController+NoNetwork.h"
#import "UserManager.h"

@implementation UIViewController (NoNetwork)

- (BOOL)noNetwork
{
    return ![[UserManager sharedManager] checkNetworkStatus];
}

- (void)showNetWorkErrorView
{
    NetworkErrorView *networkErrorView = [[NetworkErrorView alloc] init];
    networkErrorView.delegate = self;
    [networkErrorView showInView:self.view];
}

- (void)showNetWorkErrorView:(NSString *)message
{
    NetworkErrorView *networkErrorView = [[NetworkErrorView alloc] init];
    networkErrorView.delegate = self;
    if (message) [networkErrorView.noNetworkLabel setText:message];
    [networkErrorView showInView:self.view];
}

- (void)retry:(void (^)())success fail:(void (^)())fail
{
    if (!self.noNetwork) {
        for(UIView *v in self.view.subviews){
            if(v.tag == 99999999){
                [UIView animateWithDuration:0.8f animations:^{
                    v.alpha = 1.0f;
                    v.alpha = 0.0f;
                }completion:^(BOOL finished){
                    [v removeFromSuperview];
                    success();
                    return;
                }];
            }
        }
    }
    fail();
}

- (void)noNetworkRetry
{
    DLog(@"%@ no Network Retry", NSStringFromClass([self class]));
    [self retry:^{
    } fail:^{
    }];
}
@end
