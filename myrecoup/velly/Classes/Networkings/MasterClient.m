//
//  MasterClient.m
//  velly
//
//  Created by m_saruwatari on 2015/02/20.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "MasterClient.h"

#import "ConfigLoader.h"
#import "NSDictionary+Sort.h"

@interface MasterClient()

@property (nonatomic) NSDictionary *vConfig;

@end

@implementation MasterClient

+ (instancetype)sharedClient
{
    static MasterClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseApiURI"];
        _sharedClient = [[MasterClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
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


// 投稿カテゴリ一覧を取得
- (void)getPostCategoriesWithParams:(NSDictionary *)params
                      perPage:(NSUInteger)perPage page:(NSUInteger)page
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetCategories = vConfig[@"ApiPathGetCategories"];
    //NSString *apiPathGetCategories = vConfig[@"ApiPathGetAreas"];
    
    //NSDictionary *params = @{ @"per_page" : @(perPage), @"page" : @(page),};
    [self GET:apiPathGetCategories
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


// ユーザエリア一覧を取得
- (void)getUserAreasWithParams:(NSDictionary *)params
                            perPage:(NSUInteger)perPage page:(NSUInteger)page
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetAreas = vConfig[@"ApiPathGetAreas"];

    [self GET:apiPathGetAreas
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
