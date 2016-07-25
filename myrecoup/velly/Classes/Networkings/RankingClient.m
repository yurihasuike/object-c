//
//  RankingClient.m
//  velly
//
//  Created by m_saruwatari on 2015/03/25.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RankingClient.h"
#import "ConfigLoader.h"
#import "NSDictionary+Sort.h"
#import "CommonUtil.h"

@implementation RankingClient

+ (instancetype)sharedClient
{
    static RankingClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{

        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseApiURI"];
        _sharedClient = [[RankingClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
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
    static RankingClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseDevApiURI"];
        _sharedClient = [[RankingClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
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


// ランキング一覧を取得
- (void)getRankingsWithParams:(NSDictionary *)params
            aToken:(NSString *)aToken
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{

    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetRankings = vConfig[@"ApiPathGetRankings"];

    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    DLog(@"ranking params : %@", params);
    
    [self GET:apiPathGetRankings
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

// おすすめ一覧を取得
- (void)getPopularsWithParams:(NSDictionary *)params
            aToken:(NSString *)aToken
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetPopulars = vConfig[@"ApiPathGetPopUsers"];

    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    //ここでパラメタをURL形式にしてしまう(値が配列で渡されたときのため)
    [self.requestSerializer
     setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request,
                                                      NSDictionary *parameters,
                                                      NSError *__autoreleasing *error) {
        return [CommonUtil getURLFormattedParams:parameters];
    }];
    
    [self GET:apiPathGetPopulars
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

@end
