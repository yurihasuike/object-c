//
//  CategoryManager.h
//  myrecoup
//
//  Created by aoponaopon on 2016/05/09.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Category.h"
#import "Post.h"

@interface CategoryManager : NSObject

@property (nonatomic) NSMutableArray *parentCategories;
@property (nonatomic) NSMutableArray *childCategories;
@property (nonatomic) NSMutableArray *childCategoriesWithPost;


+(CategoryManager *)sharedManager;
- (void)getCategories:(void (^)(NSNumber *result_code,
                                NSMutableDictionary *responseBody,
                                NSMutableArray *parents,
                                NSMutableArray *children,
                                NSError *error))block;
- (void)getRelatedPost:(NSDictionary *)params category:(Category_ *)category;
- (Category_ *)getParentByChild:(Category_ *)child;
- (NSMutableArray *)getChildrenByParent:(Category_ *)parent;
- (Category_ *)getCategoryByPost:(Post *)post;
@end
