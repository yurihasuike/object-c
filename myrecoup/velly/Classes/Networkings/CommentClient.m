//
//  CommentClient.m
//  velly
//
//  Created by m_saruwatari on 2015/02/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "CommentClient.h"
#import "ConfigLoader.h"
#import "NSDictionary+Sort.h"

@interface CommentClient()

@property (nonatomic) NSDictionary *vConfig;

@end

@implementation CommentClient

+ (instancetype)sharedClient
{
    static CommentClient *_sharedClient = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *baseUrl = vConfig[@"BaseApiURI"];
        _sharedClient = [[CommentClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:baseUrl]];
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
// 投稿コメント一覧取得
// ***************************
- (void)getCommentsWithParams:(NSNumber *)postID aToken:(NSString *)aToken perPage:(NSUInteger)perPage page:(NSUInteger)page success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPathGetComments = vConfig[@"ApiPathGetComments"];

    // postID
    NSString *apiPathGetCommentsReplace = apiPathGetComments;
    if ([postID isKindOfClass:[NSNumber class]]) {
        apiPathGetCommentsReplace = [apiPathGetComments stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[postID stringValue]];
    }else{
        // invalid
        apiPathGetCommentsReplace = [apiPathGetComments stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:@"0"];
    }
    // token
    if (aToken != nil && [aToken length] > 0) {
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    // param
    NSDictionary *params = @{ @"page" : @(page), };
    
    DLog(@"%@", apiPathGetCommentsReplace);

    [self GET:apiPathGetCommentsReplace
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
// 投稿コメント送信
// ***************************
- (void)postComment:(NSNumber *)postID params:(NSMutableDictionary *)params aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiPostComment = vConfig[@"ApiPathPostComment"];
    
    // postID
    NSString *apiPostCommentReplace = apiPostComment;
    if (postID != nil) {
        apiPostCommentReplace = [apiPostComment stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[postID stringValue]];
    }else{
        // invalid
        apiPostCommentReplace = [apiPostComment stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:@"0"];
    }

    // token
    if (aToken != nil && [aToken length] > 0) {
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    DLog(@"%@", apiPostCommentReplace);
    DLog(@"%@", params);
    DLog(@"%@", params[@"body"]);
    
    
    [self POST:apiPostCommentReplace
        parameters:params
        timeoutInterval:10.0f
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             success(operation, responseObject);
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSData *resposeData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
             NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
             if(resposeData != nil){
                 failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
             
                 DLog(@"%@", failJson);
             
                 NSString *author = failJson[@"author"];
                 DLog(@"%@", author);
             }
             failed(operation, failJson, error);
         }];

}


// ***************************
// 投稿コメント削除
// ***************************
- (void)deleteComment:(NSNumber *)postID commentID:(NSNumber *)commentID aToken:(NSString *)aToken success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed
{
    NSDictionary *vConfig      = [ConfigLoader mixIn];
    NSString *apiDeletComment = vConfig[@"ApiPathDeleteComment"];
    
    // postID
    NSString *apiDeletCommentReplace = apiDeletComment;
    if (postID != nil) {
        apiDeletCommentReplace = [apiDeletComment stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:[postID stringValue]];
    }else{
        // invalid
        apiDeletCommentReplace = [apiDeletComment stringByReplacingOccurrencesOfString:@"<?post_pk>" withString:@"0"];
    }
    // commentID
    if (commentID != nil) {
        apiDeletCommentReplace = [apiDeletCommentReplace stringByReplacingOccurrencesOfString:@"<?pk>" withString:[commentID stringValue]];
    }else{
        // invalid
        apiDeletCommentReplace = [apiDeletCommentReplace stringByReplacingOccurrencesOfString:@"<?pk>" withString:@"0"];
    }
    
    // token
    if (aToken != nil && [aToken length] > 0) {
        //[self.requestSerializer setValue:aToken forHTTPHeaderField:@"Authorization: Token"];
        NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
        [self.requestSerializer setValue:sendAToken forHTTPHeaderField:@"Authorization"];
    }else{
        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Authorization"];
    }
    
    [self DELETE:apiDeletCommentReplace
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
