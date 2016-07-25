//
//  FollowManager.m
//  velly
//
//  Created by m_saruwatari on 2015/03/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FollowManager.h"
#import "FollowClient.h"
#import "Follow.h"
#import "Follower.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

@interface FollowManager()

@property (nonatomic, readwrite) NSMutableArray *follows;
@property (nonatomic) NSMutableDictionary *followIdList;

@property (nonatomic, readwrite) NSMutableArray *followers;
@property (nonatomic) NSMutableDictionary *followerIdList;

@property (nonatomic) NSInteger *nextPage;

@end

static NSUInteger const kFollowManagerFollowsPerPage = 20;
static NSUInteger const kFollowManagerFollowersPerPage = 20;

@implementation FollowManager

+ (FollowManager *)sharedManager
{
    static FollowManager *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            _instance.follows = [NSMutableArray array];
            _instance.followers = [NSMutableArray array];
        }
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.follows = [NSMutableArray array];
        self.followers = [NSMutableArray array];
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

- (BOOL)canLoadFollowMore
{
    if(self.followPage > 1){
        return (self.totalFollowPages > kFollowManagerFollowsPerPage * (self.followPage - 1));
    }else{
        return NO;
    }
}

// フォロー一覧
- (void)reloadFollowsWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *follows, NSUInteger *followPage, NSError *error))block
{
    
    self.followPage = 1;
    self.totalFollowPages = 0;
    
    __weak typeof(self) weakSelf = self;
    
    [self loadFollowsWithParams:params
                            aToken:aToken
                            page:1 // 最初のページ固定
                      completion:^(NSArray *apiFollows, NSUInteger followPage, NSError *error) {
                          
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          
                          if(!error){
                              
                              NSMutableArray *l_follows = (strongSelf.follows) ? strongSelf.follows.mutableCopy : @{}.mutableCopy;
                              NSMutableDictionary *l_followIdList = (strongSelf.followIdList) ? strongSelf.followIdList.mutableCopy : @{}.mutableCopy;
                          
                              for (Follow *f in apiFollows) {
                                  
                                  DLog(@"%@", [f description]);
                                  
                                  NSUInteger f_userPID = (unsigned long)[f.userPID integerValue];
                                  if (l_followIdList[@(f_userPID)] && l_follows[[l_followIdList[@(f_userPID)] integerValue]] ) {
                                      [l_follows replaceObjectAtIndex:[strongSelf.followIdList[@(f_userPID)] integerValue] withObject:f];
                                  } else {
                                      [l_follows addObject:f];
                                      l_followIdList[@(f_userPID)] = @([l_follows count] - 1);
                                  }
                                  
                              }
                              DLog(@"%@", l_followIdList);
                              strongSelf.follows = l_follows;
                              strongSelf.followIdList = l_followIdList;
                              
                              if (block) block(l_follows, &followPage, error);
                              
                              
//                              if (apiFollows) {
//                                  // `follows` 全てを置き換える.
//                                  // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
//                                  [[self mutableArrayValueForKey:@"follows"]
//                                    replaceObjectsInRange:NSMakeRange(0, self.follows.count)
//                                    withObjectsFromArray:follows];
//                              }else{
//                                  // zero
//                                  [[self mutableArrayValueForKey:@"follows"]
//                                    replaceObjectsInRange:NSMakeRange(0, self.follows.count)
//                                    withObjectsFromArray:[NSMutableArray array]];
//                              }
//                              if (nextPage)
//                                  self.nextPage = (NSInteger *)nextPage;
                          
                          
                        }else {
                              DLog(@"Error: %@", error);
                              block(nil, nil, error);
                          }
                      }];
}

- (void)loadMoreFollowsWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *follows, NSUInteger *followPage, NSError *error))block
{
    
    self.followPage = [params[@"page"] integerValue];
    
    __weak typeof(self) weakSelf = self;
    [self loadFollowsWithParams:params
                        aToken:aToken
                        page:self.followPage // 次のページを読み込む.
                      completion:^(NSArray *apiFollows, NSUInteger followPage, NSError *error) {
                          
                          __strong typeof(weakSelf) strongSelf = weakSelf;
                          
                          NSMutableArray *l_follows = (strongSelf.follows) ? strongSelf.follows.mutableCopy : @{}.mutableCopy;
                          NSMutableDictionary *l_followIdList = (strongSelf.followIdList) ? strongSelf.followIdList : @{}.mutableCopy;
                          
                          if (!error && apiFollows) {
                              
                              for (Follow *f in apiFollows) {
                                  
                                  NSUInteger f_userPID = (unsigned long)[f.userPID integerValue];
                                  if (l_followIdList[@(f_userPID)] && l_follows[[l_followIdList[@(f_userPID)] integerValue]] ) {
                                      [l_follows replaceObjectAtIndex:[strongSelf.followIdList[@(f_userPID)] integerValue] withObject:f];
                                  } else {
                                      [l_follows addObject:f];
                                      l_followIdList[@(f_userPID)] = @([l_follows count] - 1);
                                  }
                                  
                              }
                          }
                          strongSelf.follows = l_follows;
                          strongSelf.followIdList = l_followIdList;
                          
                          
//                          if (apiFollows) {
//                              NSArray *newFollows = [self updateFollows:apiFollows];
//                              // 次のページは下に追加.
//                              // KVO 発火のため `mutableArrayValueForKey:` を介して add する.
//                              [[self mutableArrayValueForKey:@"follows"]
//                               addObjectsFromArray:newFollows];
//                          }
//                          if (nextPage)
//                              self.nextPage = (NSInteger *)nextPage;
                          
                          if (block) block(l_follows, &followPage, error);

                      }];
}


- (BOOL)canLoadFollowerMore
{
    if(self.followerPage > 1){
        return (self.totalFollowerPages > kFollowManagerFollowersPerPage * (self.followerPage - 1));
    }else{
        return NO;
    }
}

// フォロワー一覧
- (void)reloadFollowersWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *followers, NSUInteger *followerPage, NSError *error))block
{
    self.followerPage = 1;
    self.totalFollowerPages = 0;
    
     __weak typeof(self) weakSelf = self;
    
    [self loadFollowersWithParams:params
                        aToken:aToken
                        page:1 // 最初のページ固定
                     completion:^(NSArray *apiFollowers, NSUInteger followerPage, NSError *error) {
                         
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         
                         if(!error){
                             
                             NSMutableArray *l_followers = (strongSelf.followers) ? strongSelf.followers.mutableCopy : @{}.mutableCopy;
                             NSMutableDictionary *l_followerIdList = (strongSelf.followerIdList) ? strongSelf.followerIdList.mutableCopy : @{}.mutableCopy;
                             
                             for (Follower *f in apiFollowers) {
                                 
                                 DLog(@"%@", [f description]);
                                 
                                 NSUInteger f_userPID = (unsigned long)[f.userPID integerValue];
                                 if (l_followerIdList[@(f_userPID)] && l_followers[[l_followerIdList[@(f_userPID)] integerValue]] ) {
                                     [l_followers replaceObjectAtIndex:[strongSelf.followerIdList[@(f_userPID)] integerValue] withObject:f];
                                 } else {
                                     [l_followers addObject:f];
                                     l_followerIdList[@(f_userPID)] = @([l_followers count] - 1);
                                 }
                                 
                             }
                             DLog(@"%@", l_followerIdList);
                             strongSelf.followers = l_followers;
                             strongSelf.followerIdList = l_followerIdList;
                             
                             if (block) block(l_followers, &followerPage, error);
                             
//                             if (followers) {
//                                 // `follower` 全てを置き換える.
//                                 // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
//                                 [[self mutableArrayValueForKey:@"followers"]
//                                  replaceObjectsInRange:NSMakeRange(0, self.followers.count)
//                                  withObjectsFromArray:followers];
//                             }else{
//                                 // zero
//                                 [[self mutableArrayValueForKey:@"follows"]
//                                  replaceObjectsInRange:NSMakeRange(0, self.followers.count)
//                                  withObjectsFromArray:[NSMutableArray array]];
//                             }
//                             if (nextPage)
//                                 self.nextPage = (NSInteger *)nextPage;
                             
                         }else {
                             DLog(@"Error: %@", error);
                             block(nil, nil, error);
                         }

                     }];
}

- (void)loadMoreFollowersWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *followers, NSUInteger *followerPage, NSError *error))block
{
    self.followerPage = [params[@"page"] integerValue];
    
    __weak typeof(self) weakSelf = self;
    
    [self loadFollowersWithParams:params
                            aToken:aToken
                           page:self.followerPage // 次のページを読み込む.
                     completion:^(NSArray *apiFollowers, NSUInteger followerPage, NSError *error) {
                         
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         
                         NSMutableArray *l_followers = (strongSelf.followers) ? strongSelf.followers.mutableCopy : @{}.mutableCopy;
                         NSMutableDictionary *l_followerIdList = (strongSelf.followerIdList) ? strongSelf.followerIdList : @{}.mutableCopy;
                         
                         if (!error && apiFollowers) {
                             
                             for (Follower *f in apiFollowers) {
                                 
                                 NSUInteger f_userPID = (unsigned long)[f.userPID integerValue];
                                 if (l_followerIdList[@(f_userPID)] && l_followers[[l_followerIdList[@(f_userPID)] integerValue]] ) {
                                     [l_followers replaceObjectAtIndex:[strongSelf.followerIdList[@(f_userPID)] integerValue] withObject:f];
                                 } else {
                                     [l_followers addObject:f];
                                     l_followerIdList[@(f_userPID)] = @([l_followers count] - 1);
                                 }
                                 
                             }
                         }
                         strongSelf.followers = l_followers;
                         strongSelf.followerIdList = l_followerIdList;
                         
//                         if (apiFollowers) {
//                             NSArray *newFollowers = [self updateFollows:apiFollowers];
//                             // 次のページは下に追加.
//                             // KVO 発火のため `mutableArrayValueForKey:` を介して add する.
//                             [[self mutableArrayValueForKey:@"followers"]
//                              addObjectsFromArray:newFollowers];
//                         }
//                         if (followerPage)
//                             self.nextPage = (NSInteger *)followerPage;
                         
                         if (block) block(l_followers, &followerPage, error);
                         
                     }];
}



/* フォローを読み込む
 `reloadFollowsWithBlock:` や `loadMoreFollowsWithBlock:` から呼び出される.
 @param page 読み込むページ.
 @param block 完了時に呼び出される blocks.
 @see reloadFollowsWithBlock:
 @see loadMoreFollowsWithBlock:
 */

- (void)loadFollowsWithParams:(NSDictionary *)params aToken:(NSString *)aToken page:(NSUInteger)page completion:(void (^)(NSMutableArray *follows, NSUInteger nextPage, NSError *error))block
{
    NSString *userPID = params[@"userPID"];
    
    __weak typeof(self) weakSelf = self;
    [[FollowClient sharedClient]
     getFollowsWithParams:userPID
     aToken: aToken
     page:page
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         __strong typeof(weakSelf) strongSelf = weakSelf;

         NSMutableArray *api_follows;
         NSArray *followsJSON = responseObject[@"results"];
         if ([followsJSON isKindOfClass:[NSArray class]] && [followsJSON count] > 0) {
             api_follows = [self parseFollows:followsJSON];
         }
         // count
         NSNumber *count = responseObject[@"count"];
         if(count && [count isKindOfClass:[NSNumber class]]){
             strongSelf.totalFollowPages = [count integerValue];
         }
         // next
         NSString *nextPageURL = responseObject[@"next"];
         if (nextPageURL && [nextPageURL isKindOfClass:[NSString class]]) {
             if ([followsJSON isKindOfClass:[NSArray class]]) {
                 strongSelf.followPage++;
             }else{
                 // no next page
                 strongSelf.followPage = 0;
             }
         }else{
             // no next page
             strongSelf.followPage = 0;
         }
         
         DLog(@"%ld", (long)strongSelf.followPage);
         
         if (block) block(api_follows, strongSelf.followPage, nil);

     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         if (block) block(nil, 0, error);
     }
     ];
}

/* フォロワーを読み込む
 `reloadFollowersWithBlock:` や `loadMoreFollowersWithBlock:` から呼び出される.
 @param page 読み込むページ.
 @param block 完了時に呼び出される blocks.
 @see reloadFollowersWithBlock:
 @see loadMoreFollowersWithBlock:
 */

- (void)loadFollowersWithParams:(NSDictionary *)params aToken:(NSString *)aToken page:(NSUInteger)page completion:(void (^)(NSMutableArray *followers, NSUInteger nextPage, NSError *error))block
{

    NSString *userPID = params[@"userPID"];
    
    __weak typeof(self) weakSelf = self;
    [[FollowClient sharedClient]
     getFollowersWithParams:userPID
     aToken:aToken
     page:page
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         NSMutableArray *api_followers;
         NSArray *followersJSON = responseObject[@"results"];
         if ([followersJSON isKindOfClass:[NSArray class]] && [followersJSON count] > 0) {
             api_followers = [self parseFollowers:followersJSON];
         }
         // count
         NSNumber *count = responseObject[@"count"];
         if(count && [count isKindOfClass:[NSNumber class]]){
             strongSelf.totalFollowerPages = [count integerValue];
         }
         // next
         NSString *nextPageURL = responseObject[@"next"];
         if (nextPageURL && [nextPageURL isKindOfClass:[NSString class]]) {
             if ([followersJSON isKindOfClass:[NSArray class]]) {
                 strongSelf.followerPage++;
             }else{
                 // no next page
                 strongSelf.followerPage = 0;
             }
         }else{
             // no next page
             strongSelf.followerPage = 0;
         }
         
         DLog(@"%ld", (long)strongSelf.followerPage);
         
         if (block) block(api_followers, strongSelf.followerPage, nil);
         

     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {

         if (block) block(nil, 0, error);
     }
     ];
}



/* フォローの情報が保存された `JSON` 辞書を `Follow` にパースする
 @param follows フォローを表す `NSDictionary` の配列.
 @return `Follow` の配列.
 */
- (NSMutableArray *)parseFollows:(NSArray *)follows
{
    NSMutableArray *mutableFollows = [NSMutableArray array];
    [follows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            Follow *follow = [[Follow alloc] initWithJSONDictionary:obj];
            DLog(@"%@", follow.username);
            [mutableFollows addObject:follow];
        }
    }];
    return [mutableFollows mutableCopy];
}

/* フォロワーの情報が保存された `JSON` 辞書を `Follower` にパースする
 @param followers フォローを表す `NSDictionary` の配列.
 @return `Follower` の配列.
 */
- (NSMutableArray *)parseFollowers:(NSArray *)followers
{
    NSMutableArray *mutableFollows = [NSMutableArray array];
    [followers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            Follower *follower = [[Follower alloc] initWithJSONDictionary:obj];
            DLog(@"%@", follower.username);
            [mutableFollows addObject:follower];
        }
    }];
    return [mutableFollows mutableCopy];
}


/* `follows` に存在するフォローを新しいものに置き換える
 `follows` に存在するフォローを新しいもので置き換え, いままで存在しなかったものを返すメソッド.
 返された新しいフォローを `follows` に追加するのは呼び出し元の責任.
 
 @param follows 置き換えたい `Follow` の配列.
 @return `follows` に存在しなかった、新しいフォローの配列が返る.
 */
- (NSArray *)updateFollows:(NSArray *)follows
{
    NSMutableArray *newFollows = [NSMutableArray array];
    NSMutableArray *updatedFollows = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [follows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [self.follows indexOfObject:obj];
        if (index == NSNotFound) {
            // 見つからないときは新しいブックマーク.
            [newFollows addObject:obj];
        }
        else {
            // 見つかったときは置き換える.
            [indexSet addIndex:index];
            [updatedFollows addObject:obj];
        }
    }];
    
    // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
    [[self mutableArrayValueForKey:@"follows"]
     replaceObjectsAtIndexes:indexSet withObjects:updatedFollows];
    
    // return remain rankings
    return newFollows;
}



/* `followers` に存在するフォロワーを新しいものに置き換える
 `followers` に存在するフォロワーを新しいもので置き換え, いままで存在しなかったものを返すメソッド.
 返された新しいフォロワーを `followers` に追加するのは呼び出し元の責任.
 
 @param followers 置き換えたい `Follower` の配列.
 @return `followers` に存在しなかった、新しいフォロワーの配列が返る.
 */
- (NSArray *)updateFollowers:(NSArray *)followers
{
    NSMutableArray *newFollowers = [NSMutableArray array];
    NSMutableArray *updatedFollowers = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [followers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [self.followers indexOfObject:obj];
        if (index == NSNotFound) {
            // 見つからないときは新しいブックマーク.
            [newFollowers addObject:obj];
        }
        else {
            // 見つかったときは置き換える.
            [indexSet addIndex:index];
            [updatedFollowers addObject:obj];
        }
    }];
    
    // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
    [[self mutableArrayValueForKey:@"followers"]
     replaceObjectsAtIndexes:indexSet withObjects:updatedFollowers];
    
    // return remain rankings
    return newFollowers;
}



/** フォロー送信 **/
- (void)putFollow:(NSNumber *)userPID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{
    
    [[FollowClient sharedClient]
     putFollow:userPID
     aToken:(NSString *)aToken
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


/** フォロー解除 **/
- (void)deleteFollow:(NSNumber *)userPID aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{

    [[FollowClient sharedClient]
     deleteFollow:userPID
     aToken:(NSString *)aToken
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



@end
