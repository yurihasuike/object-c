//
//  UIViewController+Categories.h
//  myrecoup
//
//  Created by aoponaopon on 2016/06/30.
//  Copyright © 2016年 aoi.fukuoka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Categories)

- (void)loadCategories:(void (^)())success fail:(void (^)(NSNumber *code))fail;

@end
