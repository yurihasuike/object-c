//
//  FollowClient.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FollowClient.h"
#import "ConfigLoader.h"
#import "NSDictionary+Sort.h"

@implementation FollowClient

+ (instancetype)sharedClient
{
    static FollowClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseApiURI"];
        _sharedClient = [[FollowClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
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


// フォロー一覧を取得
- (void)getFollowsWithParams:(NSString *)userPID
                      aToken:(NSString *)aToken
                      page:(NSUInteger)page
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetFollows = vConfig[@"ApiPathGetFollowings"];
    
    // userPID
    NSString *apiPathGetFollowsReplace = apiPathGetFollows;
    if (userPID != nil && [userPID length] > 0) {
        apiPathGetFollowsReplace = [apiPathGetFollows stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:userPID];
    }else{
        // invalid
        apiPathGetFollowsReplace = [apiPathGetFollows stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:@"0"];
    }
    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    NSDictionary *params = @{ @"page" : @(page),};
    
    DLog(@"%@", apiPathGetFollowsReplace);
    [self GET:apiPathGetFollowsReplace
        parameters:params
        timeoutInterval:10.0f
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          // results count previous next
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

// フォロワー一覧を取得
- (void)getFollowersWithParams:(NSString *)userPID
                     aToken:(NSString *)aToken
                     page:(NSUInteger)page
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetFollowers = vConfig[@"ApiPathGetFollowers"];
    
    // userPID
    NSString *apiPathGetFollowersReplace = apiPathGetFollowers;
    if (userPID != nil && [userPID length] > 0) {
        apiPathGetFollowersReplace = [apiPathGetFollowers stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:userPID];
    }else{
        // invalid
        apiPathGetFollowersReplace = [apiPathGetFollowers stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:@"0"];
    }
    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    NSDictionary *params = @{ @"page" : @(page),};
    
    DLog(@"%@", apiPathGetFollowers);
    [self GET:apiPathGetFollowersReplace
        parameters:params
        timeoutInterval:10.0f
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          // results count previous next
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



// フォロー送信
- (void)putFollow:(NSNumber *)userPID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPutFollow = vConfig[@"ApiPathPutFollow"];
    
    // userPID
    NSString *apiPutFollowReplace = apiPutFollow;
    if (userPID != nil) {
        apiPutFollowReplace = [apiPutFollow stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:[userPID stringValue]];
    }else{
        // invalid
        apiPutFollowReplace = [apiPutFollow stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:@"0"];
    }
    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }

    DLog(@"%@", apiPutFollowReplace);
    
    [self PUT:apiPutFollowReplace
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


// フォロー解除
- (void)deleteFollow:(NSNumber *)userPID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiDeleteFollow = vConfig[@"ApiPathDeleteFollow"];
    
    // userPID
    NSString *apiDeleteFollowReplace = apiDeleteFollow;
    if (userPID != nil) {
        apiDeleteFollowReplace = [apiDeleteFollow stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:[userPID stringValue]];
    }else{
        // invalid
        apiDeleteFollowReplace = [apiDeleteFollow stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:@"0"];
    }
    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    [self DELETE:apiDeleteFollowReplace
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


@end
