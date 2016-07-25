//
//  UIViewController+Categories.m
//  myrecoup
//
//  Created by aoponaopon on 2016/06/30.
//  Copyright © 2016年 aoi.fukuoka. All rights reserved.
//

#import "UIViewController+Categories.h"
#import "ConfigLoader.h"
#import "CategoryManager.h"
#import "CommonUtil.h"

@implementation UIViewController (Categories)

- (void)loadCategories:(void (^)())success
                  fail:(void (^)(NSNumber *code))fail
{
    DLog(@"%@ loadPostCategories", [self class]);
    
    [[CategoryManager sharedManager]
     getCategories:^(NSNumber *result_code,
                     NSMutableDictionary *responseBody,
                     NSMutableArray *parents,
                     NSMutableArray *children,
                     NSError *error)
     {
         if (error) {
             fail(result_code);
             return ;
         }
         success();
         [CommonUtil doTaskAsynchronously:^{
             if (children) {
                 for (Category_ *child in children) {
                     NSDictionary *params = @{@"categories":child.pk,
                                              @"order_by"  :@"p"};
                     [[CategoryManager sharedManager] getRelatedPost:params category:child];
                 }
             }
         }];
     }];
}

@end
