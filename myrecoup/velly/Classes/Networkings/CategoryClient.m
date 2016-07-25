//
//  CategoryClient.m
//  myrecoup
//
//  Created by aoponaopon on 2016/05/09.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import "CategoryClient.h"
#import "ConfigLoader.h"
#import "CommonUtil.h"

@implementation CategoryClient

static CategoryClient *sharedData_ = nil;

///API通信用のシングルトン管理インスタンスを返す
+ (CategoryClient *)sharedClient {
    @synchronized(self){
        if (!sharedData_) {
            
            NSDictionary *vConfig   = [ConfigLoader mixIn];
            NSString *baseUrl = vConfig[@"BaseApiURI"];
            sharedData_ = [[CategoryClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
            
            // request
            sharedData_.requestSerializer = [AFJSONRequestSerializer serializer];
            
            // response
            NSArray *responseSerializers =
            @[
              [AFJSONResponseSerializer serializer],
              [AFHTTPResponseSerializer serializer]
              ];
            AFCompoundResponseSerializer *responseSerializer = [AFCompoundResponseSerializer
                                                                compoundSerializerWithResponseSerializers:responseSerializers];
            sharedData_.responseSerializer = responseSerializer;
            
            // ------------------------
            // cookie delete --> server 403 error measures of mystery
            // ------------------------
            [sharedData_.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
        }
    }
    return sharedData_;
}

#pragma mark Initializer

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    return self;
}

/// すべてのカテゴリを取得
- (void)getCategories:(NSUInteger)perPage page:(NSUInteger)page
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetAllCategories = vConfig[@"ApiPathGetCategories"];
    
    [self GET:apiPathGetAllCategories
   parameters:nil
timeoutInterval:10.0f
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          success(operation, responseObject);
          
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          
          failed(operation, [CommonUtil errorJson:operation.responseString], error);
          
      }];
}

@end
