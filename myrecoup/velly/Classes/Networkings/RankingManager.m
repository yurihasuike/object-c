//
//  rankingManager.m
//  velly
//
//  Created by m_saruwatari on 2015/03/25.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RankingManager.h"
#import "RankingClient.h"
#import "Ranking.h"
#import "Popular.h"
#import "UserManager.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

@interface  RankingManager()

@property (nonatomic, readwrite) NSMutableArray *rankings;
@property (nonatomic) NSMutableDictionary *rankingIdList;

@property (nonatomic, readwrite) NSMutableArray *populars;
@property (nonatomic) NSMutableDictionary *popularIdList;

@end

static NSUInteger const kRankingManagerRankingsPerPage = 20;
static NSUInteger const kRankingManagerPopularsPerPage = 20;

@implementation RankingManager

//@synthesize populars = _populars;
//@synthesize popularIdList = _popularIdList;

+ (RankingManager *)sharedManager
{
    static RankingManager *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            _instance.rankings = [NSMutableArray array];
            _instance.populars = [NSMutableArray array];
        }
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.rankings = [NSMutableArray array];
        self.populars = [NSMutableArray array];
        self.nextPage = 1;
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


- (BOOL)canLoadRankingMore
{
    if(self.rankingPage > 1){
        return (self.totalRankingPages > kRankingManagerRankingsPerPage * (self.rankingPage - 1));
    }else{
        return NO;
    }
}

- (void)reloadRankingsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *rankings, NSUInteger *rankingPage, NSError *error))block
{
    
    self.rankingPage = 1;
    self.totalRankingPages = 0;
    self.lastFetchedRankingIndex = 0;
    
    __weak typeof(self) weakSelf = self;
    [self loadRankingsWithParams:params
                 page:1 // 最初のページ固定
                 completion:^(NSMutableArray *api_rankings, NSUInteger rankingPage, NSError *error) {
                     
                     __strong typeof(weakSelf) strongSelf = weakSelf;

//                     if (rankings) {
//                         // `rankings` 全てを置き換える.
//                         // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
//                         [[self mutableArrayValueForKey:@"rankings"]
//                          replaceObjectsInRange:NSMakeRange(0, self.rankings.count)
//                          withObjectsFromArray:rankings];
//                     }
//                     if (block) block(rankings, error);
                     
                     if(!error){
                         
                         NSMutableArray *l_rankings = (strongSelf.rankings) ? strongSelf.rankings.mutableCopy : @{}.mutableCopy;
                         NSMutableDictionary *l_rankingIdList = (strongSelf.rankingIdList) ? strongSelf.rankingIdList.mutableCopy : @{}.mutableCopy;
                         
                         for (Ranking *r in api_rankings) {
                             
                             DLog(@"%@", [r description]);
                             
                             NSUInteger f_userPID = (unsigned long)[r.userPID integerValue];
                             if (l_rankingIdList[@(f_userPID)] && l_rankings[[l_rankingIdList[@(f_userPID)] integerValue]] ) {
                                 [l_rankings replaceObjectAtIndex:[strongSelf.rankingIdList[@(f_userPID)] integerValue] withObject:r];
                             } else {
                                 [l_rankings addObject:r];
                                 l_rankingIdList[@(f_userPID)] = @([l_rankings count] - 1);
                             }
                         }
                         
                         DLog(@"%@", l_rankingIdList);
                         strongSelf.rankings = l_rankings;
                         strongSelf.rankingIdList = l_rankingIdList;
                         
                         if (block) block(l_rankings, &rankingPage, error);
                         
                     }else{
                         DLog(@"Error: %@", error);
                         block(nil, nil, error);
                     }

                 }];
}


- (void)loadMoreRankingsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *rankings, NSUInteger *rankingPage, NSError *error))block
{
    
    self.rankingPage = [params[@"page"] integerValue];
    
    __weak typeof(self) weakSelf = self;
    [self loadRankingsWithParams:params
                 page:self.rankingPage // 次のページを読み込む.
                 completion:^(NSMutableArray *api_rankings, NSUInteger rankingPage, NSError *error) {
                     
                     __strong typeof(weakSelf) strongSelf = weakSelf;
                     
//                     if (rankings) {
//                         NSArray *newRankings = [self updateRankings:rankings];
//                         // 次のページは下に追加.
//                         // KVO 発火のため `mutableArrayValueForKey:` を介して add する.
//                         [[self mutableArrayValueForKey:@"rankings"]
//                          addObjectsFromArray:newRankings];
//                     }
//                     if (nextPage)
//                         self.nextPage = nextPage;
//                     if (block) block(rankings, error);
                     
                     NSMutableArray *l_rankings = (strongSelf.rankings) ? strongSelf.rankings.mutableCopy : @{}.mutableCopy;
                     NSMutableDictionary *l_rankingIdList = (strongSelf.rankingIdList) ? strongSelf.rankingIdList : @{}.mutableCopy;
                     
                     if (!error && api_rankings) {
                     
                         for (Ranking *r in api_rankings) {
                             
                             NSUInteger f_userPID = (unsigned long)[r.userPID integerValue];
                             if (l_rankingIdList[@(f_userPID)] && l_rankings[[l_rankingIdList[@(f_userPID)] integerValue]] ) {
                                 [l_rankings replaceObjectAtIndex:[strongSelf.rankingIdList[@(f_userPID)] integerValue] withObject:r];
                             } else {
                                 [l_rankings addObject:r];
                                 l_rankingIdList[@(f_userPID)] = @([l_rankings count] - 1);
                             }
                             
                         }
                     }
                     strongSelf.rankings = l_rankings;
                     strongSelf.rankingIdList = l_rankingIdList;
                     
                     if (block) block(l_rankings, &rankingPage, error);
                         
                 }];
    
}


// Popular


- (BOOL)canLoadPopularMore
{
    if(self.popularPage > 1){
        return (self.totalPopularPages > kRankingManagerPopularsPerPage * (self.popularPage - 1));
    }else{
        return NO;
    }
}

- (void)reloadPopularsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *populars, NSUInteger *popularPage, NSError *error))block
{
    
    self.popularPage = 1;
    self.totalPopularPages = 0;
    self.lastFetchedPopularIndex = 0;
    
    __weak typeof(self) weakSelf = self;
    [self loadPopularsWithParams:params
            completion:^(NSMutableArray *api_populars, NSUInteger popularPage, NSError *error) {

            __strong typeof(weakSelf) strongSelf = weakSelf;
                
            if(!error){
                
                NSMutableArray *l_populars = (strongSelf.populars) ? strongSelf.populars.mutableCopy : @{}.mutableCopy;
                NSMutableDictionary *l_popularIdList = (strongSelf.popularIdList) ? strongSelf.popularIdList.mutableCopy : @{}.mutableCopy;
                
                for (Popular *p in api_populars) {
                                  
                    DLog(@"%@", [p description]);
                                  
                    NSUInteger f_userPID = (unsigned long)[p.userPID integerValue];
                    if (l_popularIdList[@(f_userPID)] && l_populars[[l_popularIdList[@(f_userPID)] integerValue]] ) {
                        [l_populars replaceObjectAtIndex:[strongSelf.popularIdList[@(f_userPID)] integerValue] withObject:p];
                    } else {
                        [l_populars addObject:p];
                        l_popularIdList[@(f_userPID)] = @([l_populars count] - 1);
                    }

                    // `populars` 全てを置き換える.
                    // KVO 発火のため `mutableArrayValueForKey:` を介して replace する
                              
//                  if([strongSelf.populars count] > [populars count]){
//                      [[strongSelf mutableArrayValueForKey:@"populars"]
//                          replaceObjectsInRange:NSMakeRange(0, [strongSelf.populars count])
//                          withObjectsFromArray:api_populars];
//                              
////                    [[strongSelf mutableArrayValueForKey:@"populars"] addObjectsFromArray:api_populars];
//                              
//                   }else{
//                      //self.populars = [NSMutableArray array];
//                      strongSelf.populars = [api_populars mutableCopy];
//                   }
                    
                }
                DLog(@"%@", l_popularIdList);
                strongSelf.populars = l_populars;
                strongSelf.popularIdList = l_popularIdList;
                
                if (block) block(l_populars, &popularPage, error);

            } else {
                DLog(@"Error: %@", error);
                block(nil, nil, error);
            }

        }];
}


- (void)loadMorePopularsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *populars, NSUInteger *popularPage, NSError *error))block
{
    
    self.popularPage = [params[@"page"] integerValue];
    
    __weak typeof(self) weakSelf = self;
    [self loadPopularsWithParams:params
            completion:^(NSMutableArray *api_populars, NSUInteger popularPage, NSError *error) {
                
            __strong typeof(weakSelf) strongSelf = weakSelf;
                          
            NSMutableArray *l_populars = (strongSelf.populars) ? strongSelf.populars.mutableCopy : @{}.mutableCopy;
            NSMutableDictionary *l_popularIdList = (strongSelf.popularIdList) ? strongSelf.popularIdList : @{}.mutableCopy;

            if (!error && api_populars) {
                              
//              NSArray *newPopulars = [self updatePopulars:api_populars];
//              // 次のページは下に追加.
//              // KVO 発火のため `mutableArrayValueForKey:` を介して add する.
//              [[self mutableArrayValueForKey:@"populars"] addObjectsFromArray:newPopulars];

                for (Ranking *p in api_populars) {
                                  
//                  NSUInteger f_userPID = (unsigned long)[p.userPID integerValue];
//                  [populars addObject:p];
//                  DLog(@"%lu", (unsigned long)f_userPID);
//                  popularIdList[@(f_userPID)] = @([populars count] - 1);
//                  cnt++;
                                  
                    NSUInteger f_userPID = (unsigned long)[p.userPID integerValue];
                    if (l_popularIdList[@(f_userPID)] && l_populars[[l_popularIdList[@(f_userPID)] integerValue]] ) {
                        [l_populars replaceObjectAtIndex:[strongSelf.popularIdList[@(f_userPID)] integerValue] withObject:p];
                    } else {
                        [l_populars addObject:p];
                        l_popularIdList[@(f_userPID)] = @([l_populars count] - 1);
                    }

                }
            }
            strongSelf.populars = l_populars;
            strongSelf.popularIdList = l_popularIdList;
                          
            if (block) block(l_populars, &popularPage, error);
    }];
}





/* ランキングを読み込む
 `reloadRankingsWithBlock:` や `loadMoreRankingsWithBlock:` から呼び出される.
 @param page 読み込むページ.
 @param block 完了時に呼び出される blocks.
 @see reloadRankingsWithBlock:
 @see loadMoreRankingsWithBlock:
 */

- (void)loadRankingsWithParams:(NSDictionary *)params page:(NSUInteger)page completion:(void (^)(NSMutableArray *rankings, NSUInteger nextPage, NSError *error))block
{

    NSString *vellyToken = [Configuration loadAccessToken];
    if(![vellyToken length]) vellyToken = @"";

    __weak typeof(self) weakSelf = self;
    [[RankingClient sharedClient]
//    [[RankingClient sharedDevClient]
        getRankingsWithParams:params
        aToken:vellyToken
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
//            NSMutableArray *rankings;
//            NSUInteger nextPage = 0;
//            NSArray *rankingsJSON = responseObject[@"results"];
//            if ([rankingsJSON isKindOfClass:[NSArray class]]) {
//                rankings = [self parseRankings:rankingsJSON];
//            }
//            // 次のページ.
//            NSNumber *nextPageNumber = responseObject[@"next_page"];
//            if ([nextPageNumber isKindOfClass:[NSNumber class]]) {
//                nextPage = [nextPageNumber unsignedIntegerValue];
//             
//                //NSString *str = [NSString stringWithFormat:@"%d", nextPage];
//             
//                if ([rankingsJSON isKindOfClass:[NSArray class]]) {
//                    nextPage++;
//                }
//            }else{
//                if ([rankingsJSON isKindOfClass:[NSArray class]]) {
//                    nextPage++;
//                }
//            }
//            if (block) block(rankings, nextPage, nil);
            
            NSMutableArray *api_rankings;
            NSArray *rankingsJSON = responseObject[@"results"];
            if ([rankingsJSON isKindOfClass:[NSArray class]]) {
                api_rankings = [strongSelf parseRankings:rankingsJSON];
            }
            // count
            NSNumber *count = responseObject[@"count"];
            if(count && [count isKindOfClass:[NSNumber class]]){
                strongSelf.totalRankingPages = [count integerValue];
            }
            // next
            NSString *nextPageURL = responseObject[@"next"];
            if (nextPageURL && [nextPageURL isKindOfClass:[NSString class]]) {
                if ([rankingsJSON isKindOfClass:[NSArray class]]) {
                    strongSelf.rankingPage++;
                }else{
                    // no next page
                    strongSelf.rankingPage = 0;
                }
            }else{
                // no next page
                strongSelf.rankingPage = 0;
            }
            
            DLog(@"%ld", (long)strongSelf.rankingPage);
            
            if (block) block(api_rankings, strongSelf.rankingPage, nil);
            
            
        } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
            if (block) block(nil, 0, error);
        }
     ];
}


/* おすすめを読み込む
 `reloadPopularsWithBlock:` や `loadMorePopularsWithBlock:` から呼び出される.
 @param block 完了時に呼び出される blocks.
 @see reloadPopularsWithBlock:
 @see loadMorePopularsWithBlock:
 */

- (void)loadPopularsWithParams:(NSDictionary *)params completion:(void (^)(NSMutableArray *populars, NSUInteger nextPage, NSError *error))block
{

    NSString *vellyToken = [Configuration loadAccessToken];
    if(![vellyToken length]) vellyToken = @"";
    
    __weak typeof(self) weakSelf = self;
    [[RankingClient sharedClient]
     getPopularsWithParams:params
     aToken:vellyToken
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         NSMutableArray *api_populars;
         NSArray *popularsJSON = responseObject[@"results"];
         if ([popularsJSON isKindOfClass:[NSArray class]]) {
             api_populars = [strongSelf parseRankings:popularsJSON];
         }
         // count
         NSNumber *count = responseObject[@"count"];
         if(count && [count isKindOfClass:[NSNumber class]]){
             strongSelf.totalPopularPages = [count integerValue];
         }
         // next
         NSString *nextPageURL = responseObject[@"next"];
         if (nextPageURL && [nextPageURL isKindOfClass:[NSString class]]) {
             if ([popularsJSON isKindOfClass:[NSArray class]]) {
                 strongSelf.popularPage++;
             }else{
                 // no next page
                 strongSelf.popularPage = 0;
             }
         }else{
             // no next page
             strongSelf.popularPage = 0;
         }
         
         DLog(@"%ld", (long)strongSelf.popularPage);
         
         if (block) block(api_populars, strongSelf.popularPage, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         if (block) block(nil, 0, error);
     }
     ];
}


/* ランキングの情報が保存された `JSON` 辞書を `Ranking` にパースする
 @param rankings ランキングを表す `NSDictionary` の配列.
 @return `Ranking` の配列.
 */
- (NSMutableArray *)parseRankings:(NSArray *)rankings
{
    NSMutableArray *mutableRankings = [NSMutableArray array];
    [rankings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            Ranking *ranking = [[Ranking alloc] initWithJSONDictionary:obj];
            [mutableRankings addObject:ranking];
        }
    }];
    return [mutableRankings mutableCopy];
}


/* おすすめの情報が保存された `JSON` 辞書を `Popular` にパースする
 @param populars おすすめを表す `NSDictionary` の配列.
 @return `Popular` の配列.
 */
- (NSMutableArray *)parsePopulars:(NSArray *)populars
{
    NSMutableArray *mutablePopurlars = [NSMutableArray array];
    [populars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            Popular *popular = [[Popular alloc] initWithJSONDictionary:obj];
            [mutablePopurlars addObject:popular];
        }
    }];
    return [mutablePopurlars mutableCopy];
}


/* `rankings` に存在するランキングを新しいものに置き換える
 `rankings` に存在するランキングを新しいもので置き換え, いままで存在しなかったものを返すメソッド.
 返された新しいランキングを `rankings` に追加するのは呼び出し元の責任.
 
 @param rankings 置き換えたい `Ranking` の配列.
 @return `rankings` に存在しなかった、新しいランキングの配列が返る.
 */
- (NSMutableArray *)updateRankings:(NSArray *)rankings
{
    NSMutableArray *newRankings = [NSMutableArray array];
    NSMutableArray *updatedRankings = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [rankings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [self.rankings indexOfObject:obj];
        if (index == NSNotFound) {
            // 見つからないときは新しいランキング.
            [newRankings addObject:obj];
        }
        else {
            // 見つかったときは置き換える.
            [indexSet addIndex:index];
            [updatedRankings addObject:obj];
        }
    }];
    
    // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
    [[self mutableArrayValueForKey:@"rankings"]
     replaceObjectsAtIndexes:indexSet withObjects:updatedRankings];
    
    // return remain rankings
    return newRankings;
}


/* `populars` に存在するおすすめを新しいものに置き換える
 `populars` に存在するおすすめを新しいもので置き換え, いままで存在しなかったものを返すメソッド.
 返された新しいおすすめを `populars` に追加するのは呼び出し元の責任.
 
 @param populars 置き換えたい `Popular` の配列.
 @return `populars` に存在しなかった、新しいおすすめの配列が返る.
 */
- (NSMutableArray *)updatePopulars:(NSMutableArray *)populars
{
    NSMutableArray *newPopulars = [NSMutableArray array];
    NSMutableArray *updatedPopulars = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [populars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [self.populars indexOfObject:obj];
        if (index == NSNotFound) {
            // 見つからないときは新しいおすすめ.
            [newPopulars addObject:obj];
        }
        else {
            // 見つかったときは置き換える.
            [indexSet addIndex:index];
            [updatedPopulars addObject:obj];
        }
    }];
    
    // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
    [[self mutableArrayValueForKey:@"populars"]
     replaceObjectsAtIndexes:indexSet withObjects:updatedPopulars];
    
    // return remain rankings
    return newPopulars;
}


@end
