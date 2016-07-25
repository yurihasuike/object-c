//
//  MasterManager.h
//  velly
//
//  Created by m_saruwatari on 2015/04/20.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@class MasterManager;

@interface MasterManager : NSObject

@property (nonatomic, strong) NSNumber* networkStatus;
@property (nonatomic, strong) NSMutableDictionary *categories;

+ (MasterManager *) sharedInstance;

+ (MasterManager *)sharedManager;

- (void)getPostCategoriesWithParams:(NSString *)user_id block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSMutableDictionary *categories, NSError *error))block;

- (void)getUserAreasWithParams:(NSString *)user_id block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSMutableDictionary *categories, NSError *error))block;

@end
