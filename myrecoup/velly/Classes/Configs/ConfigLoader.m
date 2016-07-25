//
//  ConfigLoader.m
//  velly
//
//  Created by m_saruwatari on 2015/03/07.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "ConfigLoader.h"

#ifdef DEBUG
#define FD_CONFIG_LOADER_MIX_PLIST @"DebugConfig"
#else
#define FD_CONFIG_LOADER_MIX_PLIST @"ReleaseConfig"
#endif

@implementation ConfigLoader

+ (NSDictionary *)mixIn
{
    NSBundle *bundle                  = [NSBundle mainBundle];
    NSString *path                    = [bundle pathForResource:@"CommonConfig" ofType:@"plist"];
    NSMutableDictionary *commonConfig = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    path                    = [bundle pathForResource:FD_CONFIG_LOADER_MIX_PLIST ofType:@"plist"];
    NSDictionary *mixConfig = [NSDictionary dictionaryWithContentsOfFile:path];
    [commonConfig addEntriesFromDictionary:mixConfig];
    
    return [commonConfig copy];
}

@end
