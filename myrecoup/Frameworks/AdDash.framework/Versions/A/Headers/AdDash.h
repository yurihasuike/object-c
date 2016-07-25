//
//  AdDash.h
//
//  Created by jig.jp on 2014/12/08.
//  Copyright (c) 2014 jig.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AdDash : NSObject

+ (void)setServiceId:(NSString *)serviceId serviceKey:(NSString*)serviceKey;
+ (void)sendConversion;
+ (void)sendConversionWithCallback:(NSString*)callback;
+ (void)logEvent:(NSString*)eventName;
+ (void)logEvent:(NSString*)eventName parameters:(NSDictionary *)parameters;

@end