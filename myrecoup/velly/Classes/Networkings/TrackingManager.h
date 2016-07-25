//
//  TrackingManager.h
//  velly
//
//  Created by m_saruwatari on 2015/03/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrackingManager : NSObject

// スクリーン名計測用メソッド
+ (void)sendScreenTracking:(NSString *)screenName;

// イベント計測用メソッド
+ (void)sendEventTracking:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value screen:(NSString *)screen;
//mixpanel
+ (void)sendMixPanelEventTracking:(NSString *)trackname properties:(NSDictionary *)properties;

///repro
+ (void)sendReproEvent:(NSString *)eventName properties:(NSDictionary *)properties;

@end
