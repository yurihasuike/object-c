//
//  UserClient.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "UserClient.h"
#import "ConfigLoader.h"
#import "NSDictionary+Sort.h"


@interface UserClient()

@property (nonatomic) NSDictionary *vConfig;

@end

@implementation UserClient

+ (instancetype)sharedUserClient
{
    static UserClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseApiURI"];
        _sharedClient = [[UserClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
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
        
        //[_sharedClient.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
        //[sharedManager.requestSerializer setValue:@"testtest" forHTTPHeaderField:@"User-Agent"];
        // basic authenticate
        //[sharedManager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"hoge" password:@"hoge"];
        // response http type
        // _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];

    });
    
    return _sharedClient;
}

+ (instancetype)sharedDevUserClient
{
    static UserClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseDevApiURI"];
        _sharedClient = [[UserClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
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

// ***************************
// ユーザメールアドレス存在チェック
// ***************************
- (void)checkUserEmail:(NSDictionary *)params aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathCheckUser = vConfig[@"ApiPathCheckUser"];

    // token
    if (aToken != nil && [aToken length] > 0) {
        //
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    NSMutableIndexSet *successCodes = [NSMutableIndexSet indexSetWithIndex:200];
    [successCodes addIndex:204];
    [successCodes addIndex:400];
    self.responseSerializer.acceptableContentTypes = (NSSet *)successCodes;
    
    //NSDictionary *params = @{ @"email" : email,};
    [self POST:apiPathCheckUser
        parameters:params
        timeoutInterval:10.0f
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //NSLog(@"%@", operation.responseString);
            //NSLog(@"%ld", operation.response.statusCode);
            
            success(operation, responseObject);

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            
            NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
            if(resposeData != nil){
                failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];

            
//            if ( [failJson isKindOfClass:[NSMutableDictionary class]] ){
//                [failJson setValue:@"400" forKey:@"statusCode"];
//            }
//            //NSString *statusCodeStr = [NSString stringWithFormat:@"%ld", operation.response.statusCode];
//            NSNumber *statusCodeNum = [NSNumber numberWithInt:(int)operation.response.statusCode];
//            if ([statusCodeNum isEqualToNumber:[NSNumber numberWithInt:400]]) {
//                [failJson setValue:@"null" forKey:@"statusCode"];
//                [failJson setValue:@"400" forKey:@"statusCode"];
//            }
//            //[failJson setObject:(NSNumber *)statusCodeNum forKey:@"statusCode"];
//            //[failJson setValue:statusCodeNum forKey:@"statusCode"];
//            NSLog(@"%@", failJson);
//            NSLog(@"%@", failJson[@"non_field_errors"]);

            }
            failed(operation, failJson, error);
        }];
}

// ***************************
// ユーザ登録
// ***************************
- (void)insertUserRegist:(NSMutableDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathInsertUser = vConfig[@"ApiPathInsertUser"];
    
    // ------------------------
    // DEBUG
    // ------------------------
    //self.baseURL = [[NSURL alloc] initWithString: @"http://pico.flasco.co.jp"];
//    [self initWithBaseURL:[[NSURL alloc] initWithString: @"https://velly.jp"]];
    
    // 登録時は、トークン不要
    
    // vellyToken
    //NSString *vellyToken     = params[@"vellyToken"];
    //[self.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    //[self.requestSerializer setValue:@"testtest" forHTTPHeaderField:@"User-Agent"];
    //[self.requestSerializer setValue:@"testtest" forHTTPHeaderField:@"Authorization: Token"];
    // BASIC認証時
    //[self.requestSerializer setAuthorizationHeaderFieldWithUsername:@"applepie" password:@"hogehoge123"];

    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    
    
    //NSDictionary *params = @{ @"email" : email,};
    DLog(@"%@", params);
    
    [self POST:apiPathInsertUser
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
// ログイン
// ***************************
- (void)sendUserLogin:(NSMutableDictionary *)params success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathSendLogin = vConfig[@"ApiPathSendLogin"];

    // ------------------------
    // DEBUG
    // ------------------------
    //self.baseURL = [[NSURL alloc] initWithString: @"http://pico.flasco.co.jp"];
//    [self initWithBaseURL:[[NSURL alloc] initWithString: @"http://pico.flasco.co.jp"]];
    //[self.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    //[self.requestSerializer setValue:@"testtest" forHTTPHeaderField:@"User-Agent"];
    //[self.requestSerializer setValue:@"testtest" forHTTPHeaderField:@"Authorization: Token"];
    // BASIC認証時
    //[self.requestSerializer setAuthorizationHeaderFieldWithUsername:@"applepie" password:@"hogehoge123"];
    //[self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
//    NSMutableIndexSet *successCodes = [NSMutableIndexSet indexSetWithIndex:200];
//    [successCodes addIndex:400];
//    self.responseSerializer.acceptableContentTypes = successCodes;
    

    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    

    [self POST:apiPathSendLogin
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
// ユーザ情報取得
// ***************************
- (void)getUserInfo:(NSNumber *)userPID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetUserInfo = vConfig[@"ApiPathGetUserInfo"];

    NSString *apiPathGetUserInfoReplace = apiPathGetUserInfo;

    // test
    //userPID = [NSNumber numberWithUnsignedInt:14];
    
    if(userPID && ![userPID isEqual: [NSNull null]]){
        // 他人アカウント参照へ
        apiPathGetUserInfo = vConfig[@"ApiPathGetUser"];
        apiPathGetUserInfoReplace = [apiPathGetUserInfo stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:[userPID stringValue]];
    }
    // token
    if (aToken != nil && [aToken length] > 0) {
        //
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }

    DLog(@"%@", apiPathGetUserInfoReplace);
    
    [self GET:apiPathGetUserInfoReplace
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
// ユーザ情報更新
// ***************************
- (void)putUserInfo:(NSMutableDictionary *)putUser imageData:(NSData *)imageData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathPutUser = vConfig[@"ApiPathPatchUserInfo"];
    NSString *apiPathPutUserReplace = apiPathPutUser;

//    if(userPID && ![userPID isEqual: [NSNull null]]){
//        apiPathPutUserReplace = [apiPathPutUser stringByReplacingOccurrencesOfString:@"<?user_pk>" withString:[userPID stringValue]];
//    }
    
    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    DLog(@"%@", [putUser description]);
    
    DLog(@"%@", imageName);

    [self PATCH:apiPathPutUserReplace
        parameters:putUser
        imageData:(NSData *)imageData
        imageName:(NSString *)imageName
        mimType:(NSString *)mimeType
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
// ログアウト
// ***************************
- (void)sendUserLogOut:(NSMutableDictionary *)params aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathSendLogOut = vConfig[@"ApiPathSendLogOut"];

    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }

    [self POST:apiPathSendLogOut
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
// Twitterトークン更新
// ***************************
- (void)postTwToken:(NSString *)aToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathPostTwToken = vConfig[@"ApiPathPostTwToken"];
    
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    NSDictionary *params = @{ @"access_token" : twToken, @"access_token_secret" : twTokenSecret, };
    
    [self POST:apiPathPostTwToken
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
// Twitterトークン削除
// ***************************
- (void)deleteTwToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathPostTwToken = vConfig[@"ApiPathPostTwToken"];
    
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }

    [self DELETE:apiPathPostTwToken
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
// Facebookトークン更新
// ***************************
- (void)postFbToken:(NSString *)aToken fbToken:(NSString *)fbToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathPostFbToken = vConfig[@"ApiPathPostFbToken"];
    
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    DLog(@"postFBtoken : fbtoken : %@", fbToken);
    NSDictionary *params = @{ @"access_token" : fbToken, };
    
    [self POST:apiPathPostFbToken
        parameters:params
        timeoutInterval:10.0f
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           success(operation, responseObject);
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
           NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
           if(resposeData != nil){
               failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
               DLog(@"failjson : %@", failJson);
           }
           failed(operation, failJson, error);
       }];
}

// ***************************
// Facebookトークン削除
// ***************************
- (void)deleteFbToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathPostFbToken = vConfig[@"ApiPathPostFbToken"];

    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }

    [self DELETE:apiPathPostFbToken
    parameters:nil
timeoutInterval:10.0f
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
           success(operation, responseObject);
           
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
           NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
           if(resposeData != nil){
               failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
               DLog(@"failjson : %@", failJson);
           }
           failed(operation, failJson, error);
       }];
}

// ***************************
// Twitterログイン
// ***************************
- (void)sendTwUserLogin:(NSString *)aToken twToken:(NSString *)twToken twTokenSecret:(NSString *)twTokenSecret success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathSendTwLogin = vConfig[@"ApiPathSendTwLogin"];
    
//    if (aToken != nil && [aToken length] > 0) {
//        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
//        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
//    }else{
//        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
//    }
    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *params = @{ @"access_token" : twToken, @"access_token_secret" : twTokenSecret, };

    
    [self POST:apiPathSendTwLogin
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
// Facebookログイン
// ***************************
- (void)sendFbUserLogin:(NSString *)aToken fbToken:(NSString *)fbToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *apiPathSendFbLogin = vConfig[@"ApiPathSendFbLogin"];
    
    //    if (aToken != nil && [aToken length] > 0) {
    //        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
    //        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    //    }else{
    //        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    //    }
    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *params = @{ @"access_token" : fbToken, };
    
    [self POST:apiPathSendFbLogin
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
