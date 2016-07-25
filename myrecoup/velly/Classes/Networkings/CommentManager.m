//
//  CommentManager.m
//  velly
//
//  Created by m_saruwatari on 2015/02/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "CommentManager.h"
#import "CommentClient.h"
#import "Comment.h"
#import "SVProgressHUD.h"
#import "Reachability.h"

@interface  CommentManager()

@property (nonatomic, readwrite) NSMutableArray *comments;
@property (nonatomic) NSMutableDictionary *commentIdList;

@property (nonatomic) NSInteger nextPage;

@end

static NSUInteger const kCommentManagerPostsPerPage = 20;

@implementation CommentManager

+ (CommentManager *)sharedManager
{
    static CommentManager *_instance = nil;
    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.comments = [NSMutableArray array];
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


- (BOOL)canLoadCommentMore {
    if(self.commentPage > 1){
        return (self.totalCommentPages > kCommentManagerPostsPerPage * (self.commentPage - 1));
    }else{
        return NO;
    }
}


- (void)reloadCommentsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *comments, NSUInteger commentPage, NSError *error))block
{
    
    self.commentPage = 1;
    self.totalCommentPages = 0;
    
    __weak typeof(self) weakSelf = self;
    [self loadCommentsWithParams:params
                         page:1 // 最初のページ固定
                   completion:^(NSArray *api_comments, NSUInteger commentPage, NSError *error) {
                       
                       __strong typeof(weakSelf) strongSelf = weakSelf;
                       
                       if(!error){
                           
                           NSMutableArray *l_comments = (strongSelf.comments) ? strongSelf.comments.mutableCopy : @{}.mutableCopy;
                           NSMutableDictionary *l_commentIdList = (strongSelf.commentIdList) ? strongSelf.commentIdList.mutableCopy : @{}.mutableCopy;
                           
                           for (Comment *c in api_comments) {
                               
                               DLog(@"%@", [c description]);
                               
                               NSUInteger f_commentID = (unsigned long)[c.commentID integerValue];
                               if (l_commentIdList[@(f_commentID)] && l_comments[[l_commentIdList[@(f_commentID)] integerValue]] ) {
                                   [l_comments replaceObjectAtIndex:[strongSelf.commentIdList[@(f_commentID)] integerValue] withObject:c];
                               } else {
                                   [l_comments addObject:c];
                                   l_commentIdList[@(f_commentID)] = @([l_comments count] - 1);
                               }
                           }
                           
                           DLog(@"%@", l_commentIdList);
                           strongSelf.comments = l_comments;
                           strongSelf.commentIdList = l_commentIdList;
                           
                           if (block) block(l_comments, commentPage, error);
                           
                       }else{
                           DLog(@"Error: %@", error);
                           block(nil, 0, error);
                       }

                   }];
}


//- (void)loadMoreCommentsWithParams:(NSDictionary *)params block:(void (^)(NSError *error))block
- (void)loadMoreCommentsWithParams:(NSDictionary *)params block:(void (^)(NSMutableArray *comments, NSUInteger commentPage, NSError *error))block
{
    
    self.commentPage = [params[@"page"] integerValue];
    
    __weak typeof(self) weakSelf = self;
    [self loadCommentsWithParams:params
                         page:self.commentPage // 次のページを読み込む.
                   completion:^(NSArray *api_comments, NSUInteger commentPage, NSError *error) {
                       
                       __strong typeof(weakSelf) strongSelf = weakSelf;
                       
//                       NSMutableArray *newComments = [NSMutableArray array];
//                       if (comments) {
//                           newComments = [self updateComments:comments];
//                           // 次のページは下に追加.
//                           // KVO 発火のため `mutableArrayValueForKey:` を介して add する.
//                           [[self mutableArrayValueForKey:@"comments"]
//                            addObjectsFromArray:newComments];
//                       }
//                       if (commentPage){
//                           self.nextPage = commentPage;
//                           self.commentPage = commentPage;
//                       }
//                       if (block) block(newComments, commentPage, error);
                       

                       NSMutableArray *l_comments = (strongSelf.comments) ? strongSelf.comments.mutableCopy : @{}.mutableCopy;
                       NSMutableDictionary *l_commentIdList = (strongSelf.commentIdList) ? strongSelf.commentIdList.mutableCopy : @{}.mutableCopy;
                       
                       if (!error && api_comments) {
                           
                           for (Comment *c in api_comments) {
                               
                               NSUInteger f_commentID = (unsigned long)[c.commentID integerValue];
                               if (l_commentIdList[@(f_commentID)] && l_comments[[l_commentIdList[@(f_commentID)] integerValue]] ) {
                                   [l_comments replaceObjectAtIndex:[strongSelf.commentIdList[@(f_commentID)] integerValue] withObject:c];
                               } else {
                                   [l_comments addObject:c];
                                   l_commentIdList[@(f_commentID)] = @([l_comments count] - 1);
                               }
                               
                           }
                       }
                       strongSelf.comments = l_comments;
                       strongSelf.commentIdList = l_commentIdList;
                       
                       if (block) block(l_comments, commentPage, error);
                       
                   }];
}



/* 投稿コメントを読み込む
 `reloadCommentsWithBlock:` や `loadMoreCommentsWithBlock:` から呼び出される.
 @param page 読み込むページ.
 @param block 完了時に呼び出される blocks.
 @see reloadCommentsWithBlock:
 @see loadMoreCommentsWithBlock:
 */

- (void)loadCommentsWithParams:(NSDictionary *)params page:(NSUInteger)page completion:(void (^)(NSArray *comments, NSUInteger nextPage, NSError *error))block
{
    
    NSNumber *postID = params[@"postID"];
    
    __weak typeof(self) weakSelf = self;
    [[CommentClient sharedClient]
     getCommentsWithParams:postID
     aToken: nil
     perPage:kCommentManagerPostsPerPage
     page:page
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         NSArray *api_comments;
         if(responseObject && [responseObject count] > 0){
             
             NSArray *commentsJSON = responseObject[@"results"];
             if ([commentsJSON isKindOfClass:[NSArray class]]) {
                 api_comments = [self parseComments:commentsJSON];
             }
             // count
             NSNumber *count = responseObject[@"count"];
             if(count && [count isKindOfClass:[NSNumber class]]){
                 strongSelf.totalCommentPages = [count integerValue];
             }
             // next
             NSString *nextPageURL = responseObject[@"next"];
             if (nextPageURL && [nextPageURL isKindOfClass:[NSString class]]) {
                 if ([commentsJSON isKindOfClass:[NSArray class]]) {
                     strongSelf.commentPage++;
                 }else{
                     // no next page
                     strongSelf.commentPage = 0;
                 }
             }else{
                 // no next page
                 strongSelf.commentPage = 0;
             }
             
         }
         if (block) block(api_comments, strongSelf.commentPage, nil);
         
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         if (block) block(nil, 0, error);
     }
     ];
}


/* 投稿コメントの情報が保存された `JSON` 辞書を `Comment` にパースする
 @param comments 投稿コメントを表す `NSDictionary` の配列.
 @return `Comment` の配列.
 */
- (NSArray *)parseComments:(NSArray *)comments
{
    NSMutableArray *mutableComments = [NSMutableArray array];
    [comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            Comment *comment = [[Comment alloc] initWithJSONDictionary:obj];
            [mutableComments addObject:comment];
        }
    }];
    return [mutableComments copy];
}


/* `comments` に存在する投稿コメントを新しいものに置き換える
 `comments` に存在する投稿コメントを新しいもので置き換え, いままで存在しなかったものを返すメソッド.
 返された新しい投稿を `comments` に追加するのは呼び出し元の責任.
 
 @param comments 置き換えたい `Comment` の配列.
 @return `comments` に存在しなかった、新しい投稿コメントの配列が返る.
 */
- (NSMutableArray *)updateComments:(NSArray *)comments
{
    NSMutableArray *newComments = [NSMutableArray array];
    NSMutableArray *updatedComments = [NSMutableArray array];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [self.comments indexOfObject:obj];
        if (index == NSNotFound) {
            // 見つからないときは新しいブックマーク.
            [newComments addObject:obj];
        }
        else {
            // 見つかったときは置き換える.
            [indexSet addIndex:index];
            [updatedComments addObject:obj];
        }
    }];
    // KVO 発火のため `mutableArrayValueForKey:` を介して replace する.
    [[self mutableArrayValueForKey:@"comments"]
     replaceObjectsAtIndexes:indexSet withObjects:updatedComments];
    // return remain rankings
    return newComments;
}



/* 投稿コメント送信 */
- (void)postComment:(NSNumber *)postID params:(NSMutableDictionary *)params aToken:(NSString *)aToken block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{

    [[CommentClient sharedClient]
     postComment:postID
     params:params
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


/* 投稿コメント削除 */
- (void)deleteComment:(NSNumber *)postID aToken:(NSString *)aToken commentID:(NSNumber *)commentID block:(void (^)(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error))block
{

    [[CommentClient sharedClient]
     deleteComment:postID
     commentID:commentID
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



@end
