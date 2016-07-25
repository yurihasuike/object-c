//
//  NSNotification+Parameters.h
//  velly
//
//  Created by m_saruwatari on 2015/03/22.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotification (Parameters)

+ (id)notificationWithName:(NSString *)name object:(id)object parameters:(id)parameters;
- (id)parameters;

@end

