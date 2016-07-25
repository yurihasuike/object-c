//
//  NSNotification+Parameters.m
//  velly
//
//  Created by m_saruwatari on 2015/03/22.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "NSNotification+Parameters.h"

@implementation NSNotification (Parameters)

+ (id)notificationWithName:(NSString *)name object:(id)object parameters:(id)parameters
{
    NSDictionary *userInfo = @{@"parameters" : parameters};
    return [self notificationWithName:name object:object userInfo:userInfo];
}

- (id)parameters
{
    return [self.userInfo objectForKey:@"parameters"];
}

@end
