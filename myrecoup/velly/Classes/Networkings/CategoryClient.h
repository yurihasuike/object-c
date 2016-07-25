//
//  CategoryClient.h
//  myrecoup
//
//  Created by aoponaopon on 2016/05/09.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperationManager+Timeout.h"

@interface CategoryClient : AFHTTPRequestOperationManager

+(CategoryClient *)sharedClient;

/** 投稿カテゴリ一覧を取得する
 @param perPage ページ当たりのアイテム個数.
 @param page ページ番号.
 @param block 完了時に呼び出される blocks.
 */
- (void)getCategories:(NSUInteger)perPage
                       page:(NSUInteger)page
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failed:(void (^)(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error))failed;
@end
