//
//  InfoManager.m
//  velly
//
//  Created by m_saruwatari on 2015/03/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "InfoManager.h"
#import "InfoClient.h"
#import "Info.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

@interface InfoManager()

@property (nonatomic, readwrite) NSMutableArray *infos;
@property (nonatomic) NSMutableDictionary *infoIdList;

@property (nonatomic) NSInteger *nextPage;

@end

static NSUInteger const kInfoManagerInfosPerPage = 20;

@implementation InfoManager

static InfoManager *staticManager = nil;

+ (InfoManager *)sharedManager
{
    static InfoManager *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            _instance.infos = [NSMutableArray array];
        }
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.infos = [NSMutableArray array];
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

- (BOOL)canLoadInfoMore
{
    if(self.infoPage > 1){
        return (self.totalInfoPages > kInfoManagerInfosPerPage * (self.infoPage - 1));
    }else{
        return NO;
    }
}



// お知らせ一覧
- (void)reloadInfosWithParams:(NSDictionary *)params aToken:(NSString *)aToken dToken:(NSString *)dToken attributeParams:(NSArray*)attributeParams block:(void (^)(NSMutableArray *infos, NSUInteger *infoPage, NSError *error))block
{
    self.infoPage = 1;
    self.totalInfoPages = 0;
    self.infos = [[NSMutableArray alloc] init];
    
    //終了判定用
    __strong NSMutableArray *attrs = [[NSMutableArray alloc] init];
    
    [attributeParams enumerateObjectsUsingBlock:^(NSString* attr, NSUInteger idx, BOOL *stop) {
        
        
        __weak typeof(self) weakSelf = self;
        
        //parameterにattributeをセット
        NSMutableDictionary * sortedParams = [[NSMutableDictionary alloc] initWithDictionary:@{@"attribute":attr}];
        
        //device tokenが渡されていたら（非ログイン）パラメーターにセット.
        if (dToken) [sortedParams setObject:dToken forKey:@"device"];
        [self loadInfosWithParams:sortedParams
                           aToken:aToken
                             page:1 // 最初のページ固定
                       completion:^(NSArray *apiInfos, NSUInteger infoPage, NSError *error) {
                           
                           
                           __strong typeof(weakSelf) strongSelf = weakSelf;
                           
                           if(!error){
                               
                               [attrs addObject:attr];
                               
                               NSMutableArray *l_infos = (strongSelf.infos) ? strongSelf.infos.mutableCopy : @{}.mutableCopy;
                               NSMutableDictionary *l_infoIdList = (strongSelf.infoIdList) ? strongSelf.infoIdList.mutableCopy : @{}.mutableCopy;
                               
                               for (Info *i in apiInfos) {
                                   
                                   DLog(@"%@", [i description]);
                                   
                                   NSUInteger f_infoID = (unsigned long)[i.infoID integerValue];
                                   if (l_infoIdList[@(f_infoID)] && l_infos[[l_infoIdList[@(f_infoID)] integerValue]] ) {
                                       [l_infos replaceObjectAtIndex:[strongSelf.infoIdList[@(f_infoID)] integerValue] withObject:i];
                                   } else {
                                       [l_infos addObject:i];
                                       l_infoIdList[@(f_infoID)] = @([l_infos count] - 1);
                                   }
                                   
                               }
                               [strongSelf.infoIdList addEntriesFromDictionary:l_infoIdList];
                               
                               //取得したお知らせ情報を追加
                               //取得した別タイプのおしらせがなくて新おしらせがあるとき->代入
                               if (apiInfos && !strongSelf.infos.count){
                                   strongSelf.infos = [apiInfos mutableCopy];
                                
                               }//取得済みの別タイプのおしらせがあって新おしらせがある時->追加
                               else if(apiInfos && strongSelf.infos.count){
                                   
                                   @try {
                                       [strongSelf.infos addObjectsFromArray:[apiInfos mutableCopy]];
                                   }
                                   @catch (NSException *exception) {
                                       
                                       NSLog(@"[ERROR]\ninfos[%@]\napiinfos[%@]\nexception[%@]", [strongSelf.infos class], [apiInfos class],exception);
                                       return ;
                                       @throw exception;
                                   }
                               }
                               
                               //日付でソート
                                strongSelf.infos = [[strongSelf.infos sortedArrayUsingComparator:^NSComparisonResult(Info* info1, Info* info2) {
                                    return [info2.created compare:info1.created];
                                }] mutableCopy];
                               
                               
                                //処理終了でcell更新.
                                if (block && attrs.count == attributeParams.count) block(l_infos, &infoPage, error);
                               
                               
                               
                           }else{
                               DLog(@"Error: %@", error);
                               block(nil, nil, error);
                           }
                           
                           //処理終了ならloading消去.
                           if (attrs.count == attributeParams.count) {
                               [SVProgressHUD dismiss];
                           }
                       }];

    }];
    }

- (void)loadMoreInfosWithParams:(NSDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSMutableArray *infos, NSUInteger *infoPage, NSError *error))block
{
    self.infoPage = [params[@"page"] integerValue];
    
    __weak typeof(self) weakSelf = self;
    [self loadInfosWithParams:params
                       aToken:aToken
                         page:self.infoPage // 次のページを読み込む.
                     completion:^(NSArray *apiInfos, NSUInteger infoPage, NSError *error) {
                         
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         
                         NSMutableArray *l_infos = (strongSelf.infos) ? strongSelf.infos.mutableCopy : @{}.mutableCopy;
                         NSMutableDictionary *l_infoIdList = (strongSelf.infoIdList) ? strongSelf.infoIdList : @{}.mutableCopy;
                         
                         if (!error && apiInfos) {
                             
                             for (Info *i in apiInfos) {
                                 
                                 NSUInteger f_infoID = (unsigned long)[i.infoID integerValue];
                                 if (l_infoIdList[@(f_infoID)] && l_infos[[l_infoIdList[@(f_infoID)] integerValue]] ) {
                                     [l_infos replaceObjectAtIndex:[strongSelf.infoIdList[@(f_infoID)] integerValue] withObject:i];
                                 } else {
                                     [l_infos addObject:i];
                                     l_infoIdList[@(f_infoID)] = @([l_infos count] - 1);
                                 }
                                 
                             }
                         }
                         strongSelf.infos = l_infos;
                         strongSelf.infoIdList = l_infoIdList;
                         
//                         if (apiInfos) {
//                             NSArray *newInfos = [self updateInfos:apiInfos];
//                             // 次のページは下に追加.
//                             // KVO 発火のため `mutableArrayValueForKey:` を介して add する.
//                             [[self mutableArrayValueForKey:@"infos"]
//                              addObjectsFromArray:newInfos];
//                         }
//                         if (infoPage)
//                             self.infoPage = (NSInteger *)infoPage;
//                         if (block) block(error);
                         
                         if (block) block(l_infos, &infoPage, error);

                         
                     }];
}


/* お知らせを読み込む
 `reloadFollowsWithBlock:` や `loadMoreFollowsWithBlock:` から呼び出される.
 @param page 読み込むページ.
 @param block 完了時に呼び出される blocks.
 @see reloadFollowsWithBlock:
 @see loadMoreFollowsWithBlock:
 */

- (void)loadInfosWithParams:(NSDictionary *)params aToken:(NSString *)aToken page:(NSUInteger)page completion:(void (^)(NSArray *infos, NSUInteger nextPage, NSError *error))block
{
    NSString *vellyToken = aToken;
    if(![vellyToken length]) vellyToken = @"";

    __weak typeof(self) weakSelf = self;
    [[InfoClient sharedClient]
     getInfosWithParams:params
     aToken:vellyToken
     page:page
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         NSMutableArray *api_infos;
         NSArray *infosJSON = responseObject[@"results"];
         if ([infosJSON isKindOfClass:[NSArray class]] && [infosJSON count] > 0) {
             api_infos = [self parseInfos:infosJSON];
         }
         // count
         NSNumber *count = responseObject[@"count"];
         if(count && [count isKindOfClass:[NSNumber class]]){
             strongSelf.totalInfoPages = [count integerValue];
         }
         // next
         NSString *nextPageURL = responseObject[@"next"];
         if (nextPageURL && [nextPageURL isKindOfClass:[NSString class]]) {
             if ([infosJSON isKindOfClass:[NSArray class]]) {
                 strongSelf.infoPage++;
             }else{
                 // no next page
                 strongSelf.infoPage = 0;
             }
         }else{
             // no next page
             strongSelf.infoPage = 0;
         }
         
         DLog(@"%ld", (long)strongSelf.infoPage);
         
         if (block) block(api_infos, strongSelf.infoPage, nil);
         
//         _cntInfo = responseObject[@"count"];
//         NSArray *infosJSON = responseObject[@"results"];
//         if ([infosJSON isKindOfClass:[NSArray class]]) {
//             infos = [self parseInfos:infosJSON];
//         }
//         // 次のページ.
//         NSString *nextPageURL = responseObject[@"next_page"];
//         if ([nextPageURL isKindOfClass:[NSNull class]]) {
//             // last page
//             nextPage = 0;
//         }else{
//             // next page
//             if ([infosJSON isKindOfClass:[NSArray class]]) {
//                 nextPage++;
//             }
//         }
//         if (block) block(infos, nextPage, nil);
         
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         if (block) block(nil, 0, error);
     }
     ];
}


/* お知らせの情報が保存された `JSON` 辞書を `Info` にパースする
 @param infos お知らせを表す `NSDictionary` の配列.
 @return `Info` の配列.
 */
- (NSMutableArray *)parseInfos:(NSArray *)infos
{
    NSMutableArray *mutableInfos = [NSMutableArray array];
    [infos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            Info *info = [[Info alloc] initWithJSONDictionary:obj];
            //DLog(@"%@", info.infoID);
            [mutableInfos addObject:info];
        }
    }];
    return [mutableInfos mutableCopy];
}


/* `infos` に存在するお知らせを新しいものに置き換える
 `infos` に存在するお知らせを新しいもので置き換え, いままで存在しなかったものを返すメソッド.
 返された新しいお知らせを `infos` に追加するのは呼び出し元の責任.
 @param infos 置き換えたい `Info` の配列.
 @return `infos` に存在しなかった、新しいお知らせの配列が返る.
 */
- (NSArray *)updateInfos:(NSArray *)infos
{
    NSMutableArray *newInfos = [NSMutableArray array];
    NSMutableArray *updatedInfos = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [infos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [self.infos indexOfObject:obj];
        if (index == NSNotFound) {
            // 見つからないときは新しいお知らせ.
            [newInfos addObject:obj];
        }
        else {
            // 見つかったときは置き換える.
            [indexSet addIndex:index];
            [updatedInfos addObject:obj];
        }
    }];
    
    // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
    [[self mutableArrayValueForKey:@"infos"]
     replaceObjectsAtIndexes:indexSet withObjects:updatedInfos];
    
    // return remain rankings
    return newInfos;
}

///未読おしらせ数を取得.
- (void)getUnreadInfoCount:(NSMutableDictionary * )params
                           aToken:(NSString * )aToken
                           dToken:(NSString * )dToken
                     block:(void (^)(NSNumber * unreadInfoCount, NSError *error))block {
    
    __weak typeof(self) weakSelf = self;
    [[InfoClient sharedClient] getunreadInfoCountWithParams:params
                               aToken:aToken
                               dToken:dToken
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.unreadInfoCount = responseObject[@"count"];
        block(strongSelf.unreadInfoCount, nil);
    }
    failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
        DLog(@"error=%@, opreation=%@, responseBody=%@", error, operation, responseBody);
        block(nil, error);
    }];
}

@end
