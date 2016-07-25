//
//  PostClient.m
//  velly
//
//  Created by m_saruwatari on 2015/02/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostClient.h"
#import "ConfigLoader.h"
//#import "NSDictionary+Sort.h"


@interface PostClient()

@property (nonatomic) NSDictionary *vConfig;

@end

@implementation PostClient

+ (instancetype)sharedClient
{
    static PostClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseApiURI"];
        
        _sharedClient = [[PostClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
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
// 投稿一覧取得
// ***************************
- (void)getPostsWithParams:(NSDictionary *)params aToken:(NSString *)aToken
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetPosts = vConfig[@"ApiPathGetPosts"];

    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }

    // ------------------------
    // cookie delete --> server 403 error measures of mystery
    // ------------------------
    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];

    //NSDictionary *params = @{ @"per_page" : @(perPage), @"page" : @(page),};
    
    DLog(@"%@", params);
    DLog(@"%@", apiPathGetPosts);
    
    [self GET:apiPathGetPosts
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
          //NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
          //DLog(@"responseCode : %@", resultCode);
          
          failed(operation, failJson, error);
      }];
}
// ***************************
// Wordで投稿一覧取得
// ***************************
- (void)getPostsByWord:(NSDictionary *)params aToken:(NSString *)aToken Word:(NSString*)Word Type:(NSString*)Type
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    
    NSString *apiPathGetPosts;
    if ([Type isEqualToString:@"tag"]) {
        apiPathGetPosts = vConfig[@"ApiPathGetPostsByTag"];
        apiPathGetPosts = [apiPathGetPosts stringByReplacingOccurrencesOfString:@"<?tag>" withString:Word];
    }
    else if([Type isEqualToString:@"word"]){
        apiPathGetPosts = vConfig[@"ApiPathGetPostsByWord"];
        apiPathGetPosts = [apiPathGetPosts stringByReplacingOccurrencesOfString:@"<?word>" withString:Word];
    }
    
    DLog("%@",apiPathGetPosts);
    
    apiPathGetPosts = [apiPathGetPosts stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    // ------------------------
    // cookie delete --> server 403 error measures of mystery
    // ------------------------
    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
    
    //NSDictionary *params = @{ @"per_page" : @(perPage), @"page" : @(page),};
    
    DLog(@"%@", params);
    DLog(@"%@", apiPathGetPosts);
    
    [self GET:apiPathGetPosts
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
          //NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
          //DLog(@"responseCode : %@", resultCode);
          
          failed(operation, failJson, error);
      }];
}
// ***************************
// 投稿情報取得
// ***************************
- (void)getPostInfo:(NSNumber *)postID aToken:(NSString *)aToken
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetPostInfo = vConfig[@"ApiPathGetPost"];
    
    // postID
    NSString *apiPathGetPostInfoReplace = apiPathGetPostInfo;
    if ([postID isKindOfClass:[NSNumber class]]) {
        apiPathGetPostInfoReplace = [apiPathGetPostInfo stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[postID stringValue]];
    }else{
        // invalid
        apiPathGetPostInfoReplace = [apiPathGetPostInfo stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:@"0"];
    }
    // token
    if (aToken != nil && [aToken length] > 0) {
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }

    [self GET:apiPathGetPostInfoReplace
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
// 投稿情報送信
// ***************************
- (void)insertPostRegist:(NSMutableDictionary *)params imageData:(NSData *)imageData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPostPost = vConfig[@"ApiPathPostPost"];
    
    // token
    if (aToken != nil && [aToken length] > 0) {
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    DLog(@"%@", params);
    DLog(@"%@", imageName);
    DLog(@"%@", mimeType);
    
    [self POST:apiPostPost
    parameters:params
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
               
               DLog(@"%@", failJson);
           }
           failed(operation, failJson, error);
       }];
}


// ***************************
// 投稿情報送信(movie)
// ***************************
- (void)insertPostRegistMovie:(NSMutableDictionary *)params imageData:(NSData *)imageData movieData:(NSData*)movieData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPostPost = vConfig[@"ApiPathPostPost"];

    // token
    if (aToken != nil && [aToken length] > 0) {
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    // 現在の日付を取得
    NSDate *currentDate = [NSDate date];
    // 日付フォーマットオブジェクトの生成
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // フォーマットを指定の日付フォーマットに設定
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    // 日付型の文字列を生成
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    imageName = [NSString stringWithFormat:@"%@%@.png",aToken,dateString];
    NSString* movieName = [NSString stringWithFormat:@"%@%@.mov",aToken,dateString];

    [self POST:apiPostPost parameters:params imageData:imageData imageName:imageName mimType:mimeType movieData:movieData movieName:movieName mimTypeMovie:@"movie/mov" timeoutInterval:10.0f success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
        if(resposeData != nil){
            failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"fail");
            //DLog(@"%@", failJson);
        }
        failed(operation, failJson, error);
    }];
    
}

// ***************************
// 投稿削除
// ***************************
- (void)deletePost:(NSString *)postId aToken:(NSString *)aToken
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathPostDelete = [vConfig[@"ApiPathPostPost"] stringByAppendingString:postId];
    
    
    // token
    if (aToken != nil && [aToken length] > 0) {
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    [self DELETE:apiPathPostDelete
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
// 投稿更新
// ***************************
- (void)updatePost:(NSString *)postId params:(NSDictionary *)params aToken:(NSString *)aToken
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathPostUpdate = [NSString stringWithFormat:@"%@%@/", vConfig[@"ApiPathPostPost"], postId];
    
    // token
    if (aToken != nil && [aToken length] > 0) {
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    [self PUT:apiPathPostUpdate parameters:params timeoutInterval: 10.0f
     
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
// 投稿いいね
// ***************************
- (void)postPostLike:(NSString *)postID aToken:(NSString *)aToken
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathPostLike = vConfig[@"ApiPathPostLike"];
    
    // postID
    NSString *apiPathPostLikeReplace = apiPathPostLike;
    if (postID != nil && [postID length] > 0) {
        apiPathPostLikeReplace = [apiPathPostLike stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:postID];
    }else{
        // invalid
        apiPathPostLikeReplace = [apiPathPostLike stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:@"0"];
    }
    // token
    if (aToken != nil && [aToken length] > 0) {
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }

    // ------------------------
    // cookie delete --> server 403 error measures of mystery
    // ------------------------
    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
    
    DLog(@"%@", apiPathPostLikeReplace);
    
    [self POST:apiPathPostLikeReplace
        parameters:nil
        timeoutInterval:10.0f
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
          success(operation, responseObject);
          
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          
          NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
          NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
          if(resposeData != nil){
              failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
          
              DLog(@"%@",failJson[@"author"]);
          }
          failed(operation, failJson, error);
      }];
}


// ***************************
// 投稿いいね解除
// ***************************
- (void)deletePostLike:(NSString *)postID aToken:(NSString *)aToken
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiDeletePostLike = vConfig[@"ApiPathDeleteLike"];

    // postID
    NSString *apiDeletePostLikeReplace = apiDeletePostLike;
    if (postID != nil && [postID length] > 0) {
        apiDeletePostLikeReplace = [apiDeletePostLike stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:postID];
    }else{
        // invalid
        apiDeletePostLikeReplace = [apiDeletePostLike stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:@"0"];
    }
    // token
    if (aToken != nil && [aToken length] > 0) {
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }

    // ------------------------
    // cookie delete --> server 403 error measures of mystery
    // ------------------------
    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
    
    [self DELETE:apiDeletePostLikeReplace
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
