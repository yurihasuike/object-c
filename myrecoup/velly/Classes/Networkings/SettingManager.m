//
//  SettingManager.m
//  velly
//
//  Created by m_saruwatari on 2015/05/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "SettingManager.h"
#import "SettingClient.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "AFHTTPRequestOperationManager+Timeout.h"
#import "NSString+Validation.h"
#import "NSObject+Validation.h"
#import "Setting.h"

@interface  SettingManager()

@property (nonatomic, retain) Setting *setting;

@end

@implementation SettingManager

+ (SettingManager *)sharedInstance {
    
    static SettingManager *sharedInstance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[SettingManager alloc] init];
    });
    
    return sharedInstance;
}

+ (SettingManager *)sharedManager
{
    static SettingManager *_instance = nil;
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


- (void)getSettingInfo:(NSString *)aToken block:(void (^)(NSNumber *result_code, Setting *setting, NSMutableDictionary *responseBody, NSError *error))block
{

    NSString *vellyToken = aToken;
    if(![vellyToken length]) vellyToken = @"";
    
    [[SettingClient sharedClient]
     getSettingInfo:vellyToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         Setting *setting = [[Setting alloc] initWithJSONDictionary:responseObject];
         if (block) block(resultCode, setting, responseObject, nil);

     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //DLog(@"%ld", operation.response.statusCode);
         //DLog(@"%", operation.responseString);
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         if (block) block(resultCode, nil, responseBody, error);

     }
     ];

}


- (void)putUserInfo:(NSString *)aToken pushOnFollow:(NSNumber *)pushOnFollow pushOnLike:(NSNumber *)pushOnLike pushOnComment:(NSNumber *)pushOnComment pushOnRanking:(NSNumber *)pushOnRanking block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{

    NSString *vellyToken = aToken;
    if(![vellyToken length]) vellyToken = @"";
    
    [[SettingClient sharedClient]
     putUserInfo:vellyToken
     pushOnFollow:pushOnFollow
     pushOnLike:pushOnLike
     pushOnComment:pushOnComment
     pushOnRanking:pushOnRanking
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         if (block) block(resultCode, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {

         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, error);
     }
     ];
    
}


- (void)postDeviceToken:(NSString *)aToken dToken:(NSString *)dToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{

    NSString *vellyToken = aToken;
    if(![vellyToken length]) vellyToken = @"";
    
    [[SettingClient sharedClient]
     postDeviceToken:vellyToken
     dToken:dToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         if (block) block(resultCode, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, error);
     }
     ];
}

@end
