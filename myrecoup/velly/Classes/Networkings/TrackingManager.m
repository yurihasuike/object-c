//
//  TrackingManager.m
//  velly
//
//  Created by m_saruwatari on 2015/03/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "TrackingManager.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "Mixpanel.h"
#import <Repro/Repro.h>

#include <sys/types.h>
#include <sys/sysctl.h>

@implementation TrackingManager

// スクリーン名をGoogleAnalyticsに送信する
+ (void)sendScreenTracking:(NSString *)screenName
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // スクリーン名を設定
    [tracker set:kGAIScreenName value:screenName];
    
    // カスタムディメンションの設定(端末のモデル情報を送る)
    [tracker set:[GAIFields customDimensionForIndex:1] value:[self deviceModel]];
    
    // トラッキング情報を送信する
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    //[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    // 送信が終わったらtrackerに設定されているスクリーン名を初期化する
    [tracker set:kGAIScreenName value:nil];
}


// イベントをGoogleAnalyticsに送信する
// イベント情報送信前にスクリーン名を設定するとどの画面でイベントが起きたかも分析可能です
+ (void)sendEventTracking:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value screen:(NSString *)screen {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // スクリーン名を設定
    [tracker set:kGAIScreenName value:screen];
    
    // カスタムディメンションの設定(端末のモデル情報を送る)
    [tracker set:[GAIFields customDimensionForIndex:1] value:[self deviceModel]];
    
    // イベントのトラッキング情報を送信する
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:value] build]];
}

// iOSのモデル情報の取得メソッド
+ (NSString *)deviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *modelName = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return modelName;
}

/// MixPanelのトラッキングを送信
+ (void)sendMixPanelEventTracking:(NSString *)trackname properties:(NSDictionary *)properties{
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    //send
    [mixpanel track:trackname properties:properties];
}

/// Reproのイベントを送信
+ (void)sendReproEvent:(NSString *)eventName properties:(NSDictionary *)properties {
    [Repro track:eventName properties:properties];
}

@end
