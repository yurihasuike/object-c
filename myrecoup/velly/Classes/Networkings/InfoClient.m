//
//  InfoClient.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "InfoClient.h"
#import "ConfigLoader.h"
#import "NSDictionary+Sort.h"

@implementation InfoClient

+ (instancetype)sharedClient
{
    static InfoClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{

        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseApiURI"];
        
        _sharedClient = [[InfoClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
        // request
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        // response
        //_sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
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
    static InfoClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseDevApiURI"];
        
        _sharedClient = [[InfoClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
        // request
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        // response
        //_sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
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

// お知らせ一覧を取得
- (void)getInfosWithParams:(NSDictionary *)params
                     aToken:(NSString *)aToken
                     page:(NSUInteger)page
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{

    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetInfos = vConfig[@"ApiPathInfos"];

    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    //parameterにpageを付与
    [params setValue:@(page) forKey:@"page"];
    

    [self GET:apiPathGetInfos
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

///おしらせ未読件数取得
- (void)getunreadInfoCountWithParams:(NSMutableDictionary * )params
                         aToken:(NSString * )aToken
                         dToken:(NSString * )dToken
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed {
    
    NSDictionary * vConfig = [ConfigLoader mixIn];
    NSString * apiPathInfoCount = vConfig[@"ApiPathInfoCount"];
    
    if (aToken) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
        [params setValue:dToken forKey:@"device"];
    }
    
    [self GET:apiPathInfoCount
          parameters:params
          timeoutInterval:1.0f
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              success(operation, responseObject);
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
              NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
              if(resposeData != nil){
                  failJson = [NSJSONSerialization JSONObjectWithData:resposeData
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
              }
              failed(operation, failJson, error);
          }];
}



@end
