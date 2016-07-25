//
//  NSString+MultiLanguage.m
//  myrecoup
//
//  Created by aoponaopon on 2016/06/17.
//  Copyright © 2016年 aoi.fukuoka. All rights reserved.
//

#import "NSString+MultiLanguage.h"

@implementation NSString (MultiLanguage)

- (NSString *)localize
{
    return NSLocalizedString(self, nil);
}

@end
