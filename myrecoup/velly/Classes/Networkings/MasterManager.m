//
//  MasterManager.m
//  velly
//
//  Created by m_saruwatari on 2015/04/20.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "MasterManager.h"
#import "MasterClient.h"
#import "SVProgressHUD.h"

@implementation MasterManager

+ (MasterManager *)sharedInstance {
    
    static MasterManager *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[MasterManager alloc] init];
    });
    
    return sharedInstance;
}

+ (MasterManager *)sharedManager
{
    static MasterManager *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // init
    }
    return self;
}

- (BOOL)checkNetworkStatus {
    if([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable){
        [SVProgressHUD showErrorWithStatus:@""];
        self.networkStatus = [NSNumber numberWithUnsignedInt:0];    // NO
        return NO;
    }
    self.networkStatus = [NSNumber numberWithInt:1];
    return YES;
}

- (void)getPostCategoriesWithParams:(NSString *)user_id block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSMutableDictionary *categories, NSError *error))block
{
    NSDictionary *params = nil;
    
    [[MasterClient sharedClient]
     getPostCategoriesWithParams:params
     perPage:0
     page:0
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         // id key label
         NSMutableDictionary *categories = responseObject[@"results"];
         self.categories = categories;
         
         if (block) block(resultCode, responseObject, categories, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //DLog(@"%ld", operation.response.statusCode);
         //DLog(@"%", operation.responseString);
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         if (block) block(resultCode, responseBody, nil, error);
     }
     ];
}

- (void)getUserAreasWithParams:(NSString *)user_id block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSMutableDictionary *categories, NSError *error))block
{
    NSDictionary *params = nil;
    
    [[MasterClient sharedClient]
     getUserAreasWithParams:params
     perPage:0
     page:0
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         // id key label
         NSMutableDictionary *areas = responseObject[@"results"];
         //DLog(@"%@", areas);
         
         if (block) block(resultCode, responseObject, areas, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //DLog(@"%ld", operation.response.statusCode);
         //DLog(@"%", operation.responseString);
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         if (block) block(resultCode, responseBody, nil, error);
     }
     ];
}

@end
