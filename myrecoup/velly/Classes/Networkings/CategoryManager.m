//
//  CategoryManager.m
//  myrecoup
//
//  Created by aoponaopon on 2016/05/09.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import "CategoryManager.h"
#import "CategoryClient.h"

@implementation CategoryManager

static CategoryManager *sharedData_ = nil;

///シングルトン管理のインスタンスを返す
+ (CategoryManager *)sharedManager {
    @synchronized(self){
        if (!sharedData_) {
            sharedData_ = [CategoryManager new];
        }
    }
    return sharedData_;
}

///親カテゴリ取得後に子カテゴリも取得することによってすべてのカテゴリを取得
- (void)getCategories:(void (^)(NSNumber *result_code,
                                NSMutableDictionary *responseBody,
                                NSMutableArray *parents,
                                NSMutableArray *children,
                                NSError *error))block
{
    [[CategoryClient sharedClient]
     getCategories:0
     page:0
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         NSDictionary *ret = [self parseCategories:responseObject[@"results"]];
         
         self.parentCategories = ret[@"parents"];
         self.childCategories = ret[@"children"];
         
         if (block) block(resultCode, responseObject, self.parentCategories, self.childCategories, nil);
     
     } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
         
         NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
         
         if (block) block(resultCode, responseBody, nil, nil, error);
     }
     ];
}

/*パラメーターとして送られたカテゴリの人気一番の投稿と投稿数を返す
 * @param params リクエストするURLパラメーター
 * @param category 該当カテゴリ
 */
- (void)getRelatedPost:(NSDictionary *)params category:(Category_ *)category
{
    [[PostManager sharedManager]
     getPostsAndCount:params
     aToken:[Configuration loadAccessToken]
     block:^(NSMutableArray *posts, NSNumber *count, NSError *error) {
         if (posts.count && [count intValue]) {
             NSDictionary *childWithjPost = [NSDictionary dictionaryWithObjectsAndKeys:
                                             category, @"category",
                                             [posts objectAtIndex:0], @"post",
                                             count, @"postcount",
                                             nil];
             [self.childCategoriesWithPost addObject:childWithjPost];
             
             //niceが若い順に並び替え
             self.childCategoriesWithPost = [[self.childCategoriesWithPost
                                              sortedArrayUsingComparator:
            ^NSComparisonResult (NSMutableDictionary *c1,
                                 NSMutableDictionary* c2) {
                return [((Category_ *)c1[@"category"]).nice
                        compare:
                        ((Category_ *)c2[@"category"]).nice];
             }] mutableCopy];
         }
         
     }];
}

///初期化されていなければ初期化
- (NSMutableArray *)childCategoriesWithPost {
    if (!_childCategoriesWithPost) {
        _childCategoriesWithPost = [[NSMutableArray alloc] init];
    }
    return _childCategoriesWithPost;
}

///子カテゴリから親カテゴリを取得
- (Category_ *)getParentByChild:(Category_ *)child {
    Category_ *ret;
    if (self.parentCategories && child.parent) {
        for (Category_ *parent in self.parentCategories) {
            if ([parent isAncestorOf:child]) {
                ret = parent;
                return ret;
            }
        }
    }
    return ret;
}

///親カテゴリから子カテゴリを取得
- (NSMutableArray *)getChildrenByParent:(Category_ *)parent {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    if (parent && self.childCategories) {
        for (Category_ *child in self.childCategories) {
            if ([child isDescendantOf:parent]) {
                [ret addObject:child];
            }
        }
    }
    return ret;
}

///投稿からカテゴリのインスタンスを取得
- (Category_ *)getCategoryByPost:(Post *)post {
    
    Category_ *ret;
    NSMutableArray *all = [self.parentCategories mutableCopy];
    
    if (self.childCategories) {
        [all addObjectsFromArray:self.childCategories];
    }
    for (Category_ *c in all) {
        if ([[c.pk stringValue] isEqualToString:post.categoryID]) {
            ret = c;
            return c;
        }
    }
    return ret;
}

/*JSONをパースしてカテゴリオブジェクトへ変換
 * @param jsonCategories(NSDictinary): パースするjson配列
 */
- (NSDictionary *)parseCategories:(NSArray *)jsonCategories{
    
    NSMutableArray *parents = [[NSMutableArray alloc] init];
    NSMutableArray *children = [[NSMutableArray alloc] init];
    
    for (NSDictionary *json in jsonCategories) {
        [parents addObject:[[Category_ alloc] initWithJSONDictionary:json]];
        if ([json[@"children"] count]) {
            for (NSDictionary *c in json[@"children"]) {
                [children addObject:[[Category_ alloc] initWithJSONDictionary:c]];
            }
        }
    }
    return @{@"parents" : parents,
             @"children" : children};
}

@end
