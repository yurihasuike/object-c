//
//  Category.h
//  myrecoup
//
//  Created by aoponaopon on 2016/05/09.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category_ : NSObject

@property (nonatomic) NSNumber *pk;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *label;
@property (nonatomic) Category_ *parent;
@property (nonatomic) NSMutableArray *children;
@property (nonatomic) BOOL allow_post;
@property (nonatomic) NSNumber *nice;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *readmore_url;

- (instancetype)initWithJSONDictionary:(NSDictionary *)json;
- (instancetype)initWith:(NSNumber *)pk key:(NSString *)key label:(NSString *)label parent:(Category_ *)parent children:(NSMutableArray *)children allow_post:(BOOL)allow_post nice:(NSNumber *)nice url:(NSString *)url readmore_url:(NSString *)readmore_url;
- (BOOL)isAncestorOf:(Category_ *)category;
- (BOOL)isDescendantOf:(Category_ *)category;
- (BOOL)isRoot;
- (BOOL)isRSS;
@end
