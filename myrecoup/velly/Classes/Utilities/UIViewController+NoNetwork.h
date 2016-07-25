//
//  UIViewController+NoNetwork.h
//  myrecoup
//
//  Created by aoponaopon on 2016/06/30.
//  Copyright © 2016年 aoi.fukuoka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkErrorView.h"

@interface UIViewController (NoNetwork) <NetworkErrorViewDelete>

- (BOOL)noNetwork;
- (void)showNetWorkErrorView;
- (void)showNetWorkErrorView:(NSString *)message;
- (void)retry:(void (^)())success
         fail:(void(^)())fail;

@end
