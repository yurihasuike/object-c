//
//  SettingClient.m
//  velly
//
//  Created by m_saruwatari on 2015/05/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "SettingClient.h"
#import "ConfigLoader.h"
#import "NSDictionary+Sort.h"

@interface SettingClient()

@property (nonatomic) NSDictionary *vConfig;

@end

@implementation SettingClient

+ (instancetype)sharedClient
{
    static SettingClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseApiURI"];
        _sharedClient = [[SettingClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
        // request
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        // response
        NSArray *responseSerializers =
        @[
          [AFJSONResponseSerializer serializer],
          [AFHTTPResponseSerializer serializer]
          ];
        AFCompoundResponseSerializer *responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
        _sharedClient.responseSerializer = responseSerializer;
        
        // ------------------------
        // cookie delete --> server 403 error measures of mystery
        // ------------------------
        [_sharedClient.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
        
    });
    
    return _sharedClient;
}

+ (instancetype)sharedDevClient
{
    static SettingClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseDevApiURI"];
        _sharedClient = [[SettingClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
        // request
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        // response
        NSArray *responseSerializers =
        @[
          [AFJSONResponseSerializer serializer],
          [AFHTTPResponseSerializer serializer]
          ];
        AFCompoundResponseSerializer *responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
        _sharedClient.responseSerializer = responseSerializer;
        // ------------------------
        // cookie delete --> server 403 error measures of mystery
        // ------------------------
        [_sharedClient.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
        
    });

    return _sharedClient;
}

#pragma mark Initializer

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    return self;
}

#pragma mark Request

// ***************************
// 設定情報取得
// ***************************
- (void)getSettingInfo:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathGetSetting = vConfig[@"ApiPathGetSetting"];
    
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    [self GET:apiPathGetSetting
        parameters:nil
        timeoutInterval:10.0f
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           success(operation, responseObject);
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
           NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
           if(resposeData != nil){
               failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
           }
           failed(operation, failJson, error);
       }];

}

// ***************************
// 設定情報更新
// ***************************
- (void)putUserInfo:(NSString *)aToken pushOnFollow:(NSNumber *)pushOnFollow pushOnLike:(NSNumber *)pushOnLike pushOnComment:(NSNumber *)pushOnComment pushOnRanking:(NSNumber *)pushOnRanking success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathPutSetting = vConfig[@"ApiPathPutSetting"];
    
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    NSDictionary *params = @{ @"push_on_follow" : pushOnFollow, @"push_on_like" : pushOnLike, @"push_on_comment" : pushOnComment, @"push_on_rank_fluc" : pushOnRanking, };

    [self PUT:apiPathPutSetting
        parameters:params
        timeoutInterval:10.0f
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           success(operation, responseObject);
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
           NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
           if(resposeData != nil){
               failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
           }
           failed(operation, failJson, error);
       }];
}


// ***************************
// デバイストークン更新
// ***************************
- (void)postDeviceToken:(NSString *)aToken dToken:(NSString *)dToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathPostDevice = vConfig[@"ApiPathPostDevice"];
    
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    NSDictionary *params = @{ @"device_token" : dToken, };
    
    DLog(@"apiPathPostDevice : %@", apiPathPostDevice);
    DLog(@"aToken : %@", aToken);
    DLog(@"dToken : %@", dToken);
    
    [self POST:apiPathPostDevice
        parameters:params
        timeoutInterval:10.0f
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           success(operation, responseObject);
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
           NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
           if(resposeData != nil){
               failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
               if(failJson != nil) DLog(@"%@", failJson[@"device_token"]);
           }
           failed(operation, failJson, error);
       }];
}


@end
