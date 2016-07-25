//
//  PostManager.m
//  velly
//
//  Created by m_saruwatari on 2015/04/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostManager.h"
#import "PostClient.h"
#import "Post.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "ConfigLoader.h"

@interface  PostManager()

@property (nonatomic, readwrite) Post *post;

@property (nonatomic, readwrite) NSMutableArray *posts;
@property (nonatomic) NSMutableDictionary *postIdList;

@property (nonatomic) NSInteger *nextPage;
@property (nonatomic) NSNumber *count;

@end

static NSUInteger const kPostManagerPostsPerPage = 20;

@implementation PostManager


+ (PostManager *)sharedManager
{
    static PostManager *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            _instance.posts = [NSMutableArray array];
        }
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.posts = [NSMutableArray array];
        self.nextPage = (NSInteger *)1;
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

- (BOOL)canLoadPostMore
{
    if(self.postPage > 1){
        return (self.totalPostPages > kPostManagerPostsPerPage * (self.postPage - 1));
    }else{
        return NO;
    }
}

- (void)reloadPostsWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error))block
{
    
    self.postPage = 1;
    self.totalPostPages = 0;
    
    __weak typeof(self) weakSelf = self;
    [self loadPostsWithParams:params
                            aToken:(NSString *)aToken
                      completion:^(NSMutableArray *api_posts, NSUInteger postPage, NSNumber *resultCode, NSError *error) {
                          
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          
                          if(!error){
                              
                              NSMutableArray *l_posts = (strongSelf.posts) ? strongSelf.posts.mutableCopy : @[].mutableCopy;
                              NSMutableDictionary *l_postIdList = (strongSelf.postIdList) ? strongSelf.postIdList.mutableCopy : @{}.mutableCopy;
                              
                              for (Post *p in api_posts) {
                                  
                                  DLog(@"%@", [p description]);
                                  
                                  NSUInteger f_postID = (unsigned long)[p.postID integerValue];
                                  if (l_postIdList[@(f_postID)] && l_posts[[l_postIdList[@(f_postID)] integerValue]] ) {
                                      [l_posts replaceObjectAtIndex:[strongSelf.postIdList[@(f_postID)] integerValue] withObject:p];
                                  } else {
                                      [l_posts addObject:p];
                                      l_postIdList[@(f_postID)] = @([l_posts count] - 1);
                                  }
                              }
                              
                              DLog(@"%@", l_postIdList);
                              strongSelf.posts = l_posts;
                              strongSelf.postIdList = l_postIdList;
                              
                              if (block) block(l_posts, &postPage, resultCode, error);
                              
                          }else{
                              DLog(@"Error: %@", error);
                              block(nil, 0, resultCode, error);
                          }
                              
//                              // `posts` 全てを置き換える.
//                              // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
//                              [[strongSelf mutableArrayValueForKey:@"posts"]
//                                    replaceObjectsInRange:NSMakeRange(0, strongSelf.posts.count)
//                                    withObjectsFromArray:r_posts];
                              
//                              if(self.posts && [self.posts count] > 0){
//                                  
////                              //[self.posts
////                              [[self mutableArrayValueForKey:@"posts"]
////                               replaceObjectsInRange:NSMakeRange(0, self.posts.count)
////                               withObjectsFromArray:r_posts];
//                                  
//                                  [self.posts removeAllObjects];
//                                  self.posts = [r_posts mutableCopy];
//
//                              }else{
//                                  self.posts = [r_posts mutableCopy];
//                              }
//                          }
//                          if (nextPage)
//                              strongSelf.nextPage = (NSInteger *)nextPage;
                          //if (block) block(posts, &postPage, resultCode, error);
     
     
                      }];
}

///投稿と総投稿数のみ取得
- (void)getPostsAndCount:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *posts, NSNumber *count, NSError *error))block
{
    [[PostClient sharedClient]
     getPostsWithParams:params
     aToken:aToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSMutableArray *posts;
         NSArray *postsJSON = responseObject[@"results"];
         if ([postsJSON isKindOfClass:[NSArray class]]) {
             posts = [self parsePosts:postsJSON];
         }
         
         // count
         NSNumber *count = responseObject[@"count"];
         
         block(posts, count, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         block(nil, 0, error);
         
     }];
}



//Wordで投稿取得
- (void)reloadPostsByWord:(NSDictionary *)params aToken:(NSString *)aToken Word:(NSString*)Word Type:(NSString*)Type block:(void (^)(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error))block
{
    
    self.postPage = 1;
    self.totalPostPages = 0;
    
    __weak typeof(self) weakSelf = self;
    [self loadPostsByWord:params
                       aToken:(NSString *)aToken
                    Word:(NSString*)Word
                     Type:(NSString*)Type
                   completion:^(NSMutableArray *api_posts, NSUInteger postPage, NSNumber *resultCode, NSError *error) {
                       
                       __strong typeof(weakSelf) strongSelf = weakSelf;
                       
                       if(!error){
                           
                           NSMutableArray *l_posts = (strongSelf.posts) ? strongSelf.posts.mutableCopy : @[].mutableCopy;
                           NSMutableDictionary *l_postIdList = (strongSelf.postIdList) ? strongSelf.postIdList.mutableCopy : @{}.mutableCopy;
                           
                           for (Post *p in api_posts) {
                               
                               DLog(@"%@", [p description]);
                               
                               NSUInteger f_postID = (unsigned long)[p.postID integerValue];
                               if (l_postIdList[@(f_postID)] && l_posts[[l_postIdList[@(f_postID)] integerValue]] ) {
                                   [l_posts replaceObjectAtIndex:[strongSelf.postIdList[@(f_postID)] integerValue] withObject:p];
                               } else {
                                   [l_posts addObject:p];
                                   l_postIdList[@(f_postID)] = @([l_posts count] - 1);
                               }
                           }
                           
                           DLog(@"%@", l_postIdList);
                           strongSelf.posts = l_posts;
                           strongSelf.postIdList = l_postIdList;
                           
                           if (block) block(l_posts, &postPage, resultCode, error);
                           
                       }else{
                           DLog(@"Error: %@", error);
                           block(nil, 0, resultCode, error);
                       }
                       
                       //                              // `posts` 全てを置き換える.
                       //                              // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
                       //                              [[strongSelf mutableArrayValueForKey:@"posts"]
                       //                                    replaceObjectsInRange:NSMakeRange(0, strongSelf.posts.count)
                       //                                    withObjectsFromArray:r_posts];
                       
                       //                              if(self.posts && [self.posts count] > 0){
                       //
                       ////                              //[self.posts
                       ////                              [[self mutableArrayValueForKey:@"posts"]
                       ////                               replaceObjectsInRange:NSMakeRange(0, self.posts.count)
                       ////                               withObjectsFromArray:r_posts];
                       //
                       //                                  [self.posts removeAllObjects];
                       //                                  self.posts = [r_posts mutableCopy];
                       //
                       //                              }else{
                       //                                  self.posts = [r_posts mutableCopy];
                       //                              }
                       //                          }
                       //                          if (nextPage)
                       //                              strongSelf.nextPage = (NSInteger *)nextPage;
                       //if (block) block(posts, &postPage, resultCode, error);
                       
                       
                   }];
}


- (void)loadMorePostsWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error))block
{

    __weak typeof(self) weakSelf = self;
    [self loadPostsWithParams:params
                            aToken:(NSString *)aToken
                      completion:^(NSMutableArray *api_posts, NSUInteger postPage, NSNumber *resultCode, NSError *error) {
                          
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          
//                          if (api_posts) {
//                              NSMutableArray *newPosts = [self updatePosts:api_posts];
//                              // 次のページは下に追加.
//                              // KVO 発火のため `mutableArrayValueForKey:` を介して add する.
//                              [[self mutableArrayValueForKey:@"posts"]
//                               addObjectsFromArray:newPosts];
//                          }
//                          if (block) block(resultCode, error);
                          
                          
                          NSMutableArray *l_posts = (strongSelf.posts) ? strongSelf.posts.mutableCopy : @[].mutableCopy;
                          NSMutableDictionary *l_postIdList = (strongSelf.postIdList) ? strongSelf.postIdList.mutableCopy : @{}.mutableCopy;
                          
                          for (Post *p in api_posts) {
                              
                              NSUInteger f_postID = (unsigned long)[p.postID integerValue];
                              if (l_postIdList[@(f_postID)] && l_posts[[l_postIdList[@(f_postID)] integerValue]] ) {
                                  [l_posts replaceObjectAtIndex:[strongSelf.postIdList[@(f_postID)] integerValue] withObject:p];
                              } else {
                                  [l_posts addObject:p];
                                  l_postIdList[@(f_postID)] = @([l_posts count] - 1);
                              }
                          }

                          strongSelf.posts = l_posts;
                          strongSelf.postIdList = l_postIdList;
                          
                          if (block) block(l_posts, &postPage, resultCode, error);
                          
                      }];
}



- (void)loadMorePostsByWord:(NSDictionary *)params aToken:(NSString *)aToken Word:(NSString*)Word Type:(NSString*)Type block:(void (^)(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error))block
{
    
    __weak typeof(self) weakSelf = self;
    [self loadPostsByWord:params
                       aToken:(NSString *)aToken
                       Word:Word
                       Type:Type
                   completion:^(NSMutableArray *api_posts, NSUInteger postPage, NSNumber *resultCode, NSError *error) {
                       
                       __strong typeof(weakSelf) strongSelf = weakSelf;
                       
                       //                          if (api_posts) {
                       //                              NSMutableArray *newPosts = [self updatePosts:api_posts];
                       //                              // 次のページは下に追加.
                       //                              // KVO 発火のため `mutableArrayValueForKey:` を介して add する.
                       //                              [[self mutableArrayValueForKey:@"posts"]
                       //                               addObjectsFromArray:newPosts];
                       //                          }
                       //                          if (block) block(resultCode, error);
                       
                       
                       NSMutableArray *l_posts = (strongSelf.posts) ? strongSelf.posts.mutableCopy : @[].mutableCopy;
                       NSMutableDictionary *l_postIdList = (strongSelf.postIdList) ? strongSelf.postIdList.mutableCopy : @{}.mutableCopy;
                       
                       for (Post *p in api_posts) {
                           
                           NSUInteger f_postID = (unsigned long)[p.postID integerValue];
                           if (l_postIdList[@(f_postID)] && l_posts[[l_postIdList[@(f_postID)] integerValue]] ) {
                               [l_posts replaceObjectAtIndex:[strongSelf.postIdList[@(f_postID)] integerValue] withObject:p];
                           } else {
                               [l_posts addObject:p];
                               l_postIdList[@(f_postID)] = @([l_posts count] - 1);
                           }
                       }
                       
                       strongSelf.posts = l_posts;
                       strongSelf.postIdList = l_postIdList;
                       
                       if (block) block(l_posts, &postPage, resultCode, error);
                       
                   }];
}


/* 投稿を読み込む
 `reloadPostsWithBlock:` や `loadMorePostsWithBlock:` から呼び出される.
 @param page 読み込むページ.
 @param block 完了時に呼び出される blocks.
 @see reloadPostsWithBlock:
 @see loadMorePostsWithBlock:
 */

- (void)loadPostsWithParams:(NSDictionary *)params aToken:(NSString *)aToken completion:(void (^)(NSMutableArray *posts, NSUInteger nextPage, NSNumber *result_code, NSError *error))block
{
    
    NSString *vellyToken = @"";
    if (aToken != nil && [aToken length] > 0) {
        vellyToken = aToken;
    }else{
        vellyToken = @"";
    }

    __weak typeof(self) weakSelf = self;
    [[PostClient sharedClient]
     getPostsWithParams:params
     aToken:vellyToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
//         NSMutableArray *posts = [NSMutableArray array];
//         //NSUInteger nextPage = page;
//         NSArray *postsJSON = responseObject[@"results"];
//         if ([postsJSON isKindOfClass:[NSArray class]]) {
//            posts = [strongSelf parsePosts:postsJSON];
//         }
//         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
//         if (block) block(posts, resultCode, nil);

         NSMutableArray *api_posts;
         NSArray *postsJSON = responseObject[@"results"];
         if ([postsJSON isKindOfClass:[NSArray class]]) {
             api_posts = [strongSelf parsePosts:postsJSON];
         }
         // count
         NSNumber *count = responseObject[@"count"];
         if(count && [count isKindOfClass:[NSNumber class]]){
             strongSelf.totalPostPages = [count integerValue];
         }
         // next
         NSString *nextPageURL = responseObject[@"next"];
         if (nextPageURL && [nextPageURL isKindOfClass:[NSString class]]) {
             if ([postsJSON isKindOfClass:[NSArray class]]) {
                 strongSelf.postPage++;
             }else{
                 // no next page
                 strongSelf.postPage = 0;
             }
         }else{
             // no next page
             strongSelf.postPage = 0;
         }
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%ld", (long)strongSelf.postPage);
         
         if (block) block(api_posts, strongSelf.postPage, resultCode, nil);
         
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {

         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         if (block) block(nil, 0, resultCode, error);
     }
     ];
}
//Wordで投稿取得
- (void)loadPostsByWord:(NSDictionary *)params aToken:(NSString *)aToken Word:(NSString*)Word Type:(NSString*)Type completion:(void (^)(NSMutableArray *posts, NSUInteger nextPage, NSNumber *result_code, NSError *error))block
{
    
    NSString *vellyToken = @"";
    if (aToken != nil && [aToken length] > 0) {
        vellyToken = aToken;
    }else{
        vellyToken = @"";
    }
    
    __weak typeof(self) weakSelf = self;
    [[PostClient sharedClient]
     getPostsByWord:params
     aToken:vellyToken
     Word:Word
     Type:Type
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         //         NSMutableArray *posts = [NSMutableArray array];
         //         //NSUInteger nextPage = page;
         //         NSArray *postsJSON = responseObject[@"results"];
         //         if ([postsJSON isKindOfClass:[NSArray class]]) {
         //            posts = [strongSelf parsePosts:postsJSON];
         //         }
         //         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         //         if (block) block(posts, resultCode, nil);
         
         NSMutableArray *api_posts;
         NSArray *postsJSON = responseObject[@"results"];
         if ([postsJSON isKindOfClass:[NSArray class]]) {
             api_posts = [strongSelf parsePosts:postsJSON];
         }
         // count
         NSNumber *count = responseObject[@"count"];
         if(count && [count isKindOfClass:[NSNumber class]]){
             strongSelf.totalPostPages = [count integerValue];
         }
         // next
         NSString *nextPageURL = responseObject[@"next"];
         if (nextPageURL && [nextPageURL isKindOfClass:[NSString class]]) {
             if ([postsJSON isKindOfClass:[NSArray class]]) {
                 strongSelf.postPage++;
             }else{
                 // no next page
                 strongSelf.postPage = 0;
             }
         }else{
             // no next page
             strongSelf.postPage = 0;
         }
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%ld", (long)strongSelf.postPage);
         
         if (block) block(api_posts, strongSelf.postPage, resultCode, nil);
         
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         if (block) block(nil, 0, resultCode, error);
     }
     ];
}


- (void)getPostInfo:(NSNumber *)postID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, Post *post, NSMutableDictionary *responseBody, NSError *error))block
{
    __weak typeof(self) weakSelf = self;

    NSString *vellyToken = @"";
    if(aToken && [aToken length] > 0) vellyToken = aToken;
    
    if(![weakSelf.post isKindOfClass:[Post class]] || [weakSelf.post.postID isKindOfClass:[NSNull class]]){
        weakSelf.post = [Post alloc];
    }

    [[PostClient sharedClient]
     getPostInfo:postID
     aToken:vellyToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         strongSelf.post = [strongSelf.post initWithJSONDictionary:responseObject];
         //Post *post = nil;
         //DLog(@"%@", post.descrip);
         
         if (block) block(resultCode, strongSelf.post, responseObject, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         if (block) block(resultCode, nil, responseBody, error);
         
        }
     ];
}


/* 投稿の情報が保存された `JSON` 辞書を `Post` にパースする
 @param posts 投稿を表す `NSDictionary` の配列.
 @return `Post` の配列.
 */
- (NSMutableArray *)parsePosts:(NSArray *)i_posts
{
    NSMutableArray *mutablePosts = [NSMutableArray array];
    
    //NSMutableArray *posts = (self.posts) ? self.posts : @[].mutableCopy;
    //NSMutableDictionary *postIdList = (self.postIdList) ? self.postIdList : @{}.mutableCopy;

    [i_posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            
            
//            if( [obj[@"id"] isKindOfClass:[NSNumber class]] ){
//                
//                NSUInteger f_postID = (unsigned long)[obj[@"id"] integerValue];
//                if (postIdList[@(f_postID)] && posts[[postIdList[@(f_postID)] integerValue]]) {
//                    
//                    NSUInteger post_num = (unsigned long)[postIdList[@(f_postID)] integerValue];
//                    //DLog(@"%ld", test);
//                    Post *post = [posts objectAtIndex:post_num];
//                    post = [post initWithJSONDictionary:obj];
//                    [mutablePosts addObject:post];
//                    
//                }else{
//                    Post *post = [[Post alloc] initWithJSONDictionary:obj];
//                    [mutablePosts addObject:post];
//
//                }
//            }
            
            
            // first
            
            Post *post = [[Post alloc] initWithJSONDictionary:obj];
            [mutablePosts addObject:post];

        }
    }];
    
//    for (NSDictionary *p in posts) {
//        if ([p isKindOfClass:[NSDictionary class]]) {
//            Post *post = [[Post alloc] initWithJSONDictionary:p];
//            [mutablePosts addObject:post];
//        }
//    }
    
    return [mutablePosts mutableCopy];
}


/* `posts` に存在する投稿を新しいものに置き換える
 `posts` に存在する投稿を新しいもので置き換え, いままで存在しなかったものを返すメソッド.
 返された新しい投稿を `posts` に追加するのは呼び出し元の責任.
 
 @param posts 置き換えたい `Posts` の配列.
 @return `posts` に存在しなかった、新しい投稿の配列が返る.
 */
- (NSMutableArray *)updatePosts:(NSArray *)posts
{
    NSMutableArray *newPosts = [NSMutableArray array];
    NSMutableArray *updatedPosts = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [self.posts indexOfObject:obj];
        if (index == NSNotFound) {
            // 見つからないときは新しいブックマーク.
            [newPosts addObject:obj];
        }
        else {
            // 見つかったときは置き換える.
            [indexSet addIndex:index];
            [updatedPosts addObject:obj];
        }
    }];
    // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
    [[self mutableArrayValueForKey:@"posts"]
     replaceObjectsAtIndexes:indexSet withObjects:updatedPosts];
    // return remain rankings
    return newPosts;
}

/** 投稿送信(movie) **/
- (void)insertPostRegist:(NSMutableDictionary *)params imageData:(NSData *)imageData moviewData:(NSData *)movieData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSNumber *postID, NSError *error))block
{
    
    //    NSString *vellyToken = [self loadAccessToken];
    //    if(![vellyToken length]) vellyToken = @"";
    
    // this api only my account..
    // NSNumber *userPID = [self loadUserPid];
    
    [[PostClient sharedClient]
     insertPostRegist:params
     imageData:(NSData *)imageData
     imageName:(NSString *)imageName
     mimeType:(NSString *)mimeType
     aToken:aToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *postID;
         if(responseObject[@"id"] && [responseObject[@"id"] isKindOfClass:[NSNumber class]]){
             postID = responseObject[@"id"];
         }
         
         if (block) block(nil, nil, postID, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, nil, error);
     }
     ];
}

/** 投稿送信 **/
- (void)insertPostRegist:(NSMutableDictionary *)params imageData:(NSData *)imageData imageName:(NSString *)imageName mimeType:(NSString *)mimeType aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSNumber *postID, NSError *error))block
{

//    NSString *vellyToken = [self loadAccessToken];
//    if(![vellyToken length]) vellyToken = @"";
    
    // this api only my account..
    // NSNumber *userPID = [self loadUserPid];
    
    [[PostClient sharedClient]
     insertPostRegist:params
     imageData:(NSData *)imageData
     imageName:(NSString *)imageName
     mimeType:(NSString *)mimeType
     aToken:aToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *postID;
         if(responseObject[@"id"] && [responseObject[@"id"] isKindOfClass:[NSNumber class]]){
             postID = responseObject[@"id"];
         }
         
         if (block) block(nil, nil, postID, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, nil, error);
     }
     ];
}

/** 投稿いいね送信 **/
- (void)postPostLike:(NSString *)postID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{

    [[PostClient sharedClient]
     postPostLike:postID
     aToken:aToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         if (block) block(nil, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, error);
     }
     ];
    
}

/** 投稿いいね解除 **/
- (void)deletePostLike:(NSString *)postID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{
    
    [[PostClient sharedClient]
     deletePostLike:postID
     aToken:aToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         if (block) block(nil, nil, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         //operation.
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         DLog(@"%@", responseBody);
         
         if (block) block(resultCode, nil, error);
     }
     ];
    
}


// ----------
// myGood
// ----------
- (NSNumber *)getIsMyGood:(NSNumber *)myUserPID postID:(NSNumber *)postID isSrvGood:(BOOL)isSrvGood loadingDate:(NSDate *)loadingDate
{
    MyGood *myGood = [MyGood getMyGood:myUserPID postID:postID];
    if(myGood){
        DLog(@"myGood modified : %@", myGood.modified);
        if(myGood.isGood){
            DLog(@"myGood isGood : YES");
        }else{
            DLog(@"myGood isGood : NO");
        }
        NSComparisonResult result = [loadingDate compare:myGood.modified];
        switch(result) {
            case NSOrderedSame: // same
            case NSOrderedAscending:    // loadingDate small
                return myGood.isGood;
                break;
            case NSOrderedDescending:   // loadingDate bigger
                break;
        }
    }
    if(isSrvGood){
        return [NSNumber numberWithInt:VLPOSTLIKEYES];
    }else{
        return [NSNumber numberWithInt:VLPOSTLIKENO];
    }
}

- (NSNumber *)getMyGoodCnt:(NSNumber *)myUserPID postID:(NSNumber *)postID srvGoodCnt:(NSNumber *)srvGoodCnt loadingDate:(NSDate *)loadingDate
{
    MyGood *myGood = [MyGood getMyGood:myUserPID postID:postID];
    if(myGood){
        DLog(@"myGood modified : %@", myGood.modified);
        DLog(@"myGood cntGood : %@", myGood.cntGood);

        NSComparisonResult result = [loadingDate compare:myGood.modified];
        switch(result) {
            case NSOrderedSame: // same
            case NSOrderedAscending:    // loadingDate small
                return myGood.cntGood;
                break;
            case NSOrderedDescending:   // loadingDate bigger
                break;
        }
    }
    return srvGoodCnt;
}

- (void)updateMyGood:(NSNumber *)myUserPID postID:(NSNumber *)postID isGood:(BOOL)isGood cntGood:(NSNumber *)cntGood
{
    [MyGood updateMyGood:myUserPID postID:postID isGood:isGood cntGood:cntGood];
}

@end
