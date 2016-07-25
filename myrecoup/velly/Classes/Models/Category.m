//
//  Category.m
//  myrecoup
//
//  Created by aoponaopon on 2016/05/09.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import "Category.h"

@implementation Category_

- (instancetype)initWithJSONDictionary:(NSDictionary *)json {
    
    NSNumber *pk;
    if (json[@"id"] && [json[@"id"] isKindOfClass:[NSNumber class]]) pk = json[@"id"];
    
    NSString *key;
    if (json[@"key"] && [json[@"key"] isKindOfClass:[NSString class]]) key = json[@"key"];
    
    NSString *label;
    if (json[@"label"] && [json[@"label"] isKindOfClass:[NSString class]]) label = json[@"label"];
    
    Category_ *parent;
    if (json[@"parent"] && [json[@"parent"] isKindOfClass:[NSDictionary class]]) {
        parent = [[Category_ alloc] initWithJSONDictionary:json[@"parent"]];
    }
    
    NSMutableArray *children = [[NSMutableArray alloc] init];
    if (json[@"children"] && [json[@"children"] isKindOfClass:[NSArray class]]) {
        for (NSDictionary *c in json[@"children"]) {
            Category_ *child = [[Category_ alloc] initWithJSONDictionary:c];
            [children addObject:child];
        }
    }
    
    BOOL allow_post;
    if (json[@"allow_post"]) {
        allow_post = [json[@"allow_post"] boolValue];
    }
    
    NSNumber *nice;
    if (json[@"nice"] && [json[@"nice"] isKindOfClass:[NSNumber class]]) {
        nice = json[@"nice"];
    }
    
    NSString *url;
    if (json[@"url"] && [json[@"url"] isKindOfClass:[NSString class]]) {
        url = json[@"url"];
    }
    
    NSString *reamdmore_url;
    if (json[@"readmore_url"] && [json[@"readmore_url"] isKindOfClass:[NSString class]]) {
        reamdmore_url = json[@"readmore_url"];
    }
    
    return [self initWith:pk
                      key:key
                    label:label
                   parent:parent
                 children:children
               allow_post:allow_post
                     nice:nice
                      url:url
             readmore_url:reamdmore_url];
}

- (instancetype)initWith:(NSNumber *)pk key:(NSString *)key label:(NSString *)label parent:(Category_ *)parent children:(NSMutableArray *)children allow_post:(BOOL)allow_post nice:(NSNumber *)nice url:(NSString *)url readmore_url:(NSString *)readmore_url{
    
    self = [super init];
    if (self) {
        if (pk) self.pk = pk;
        if (key) self.key = key;
        if (label) self.label = label;
        if (parent) self.parent = parent;
        if (children) self.children = children;
        if (allow_post) self.allow_post = allow_post;
        if (nice) self.nice = nice;
        if (url) self.url = url;
        if (readmore_url) self.readmore_url = readmore_url;
    }
    return self;
}

- (BOOL)isAncestorOf:(Category_ *)category {
    if (category.isRoot) {
        return NO;
    }
    if ([self.pk isEqualToNumber:category.parent.pk]) {
        return YES;
    }
    return [self isAncestorOf:category.parent];
}

- (BOOL)isDescendantOf:(Category_ *)category {
    if (self.isRoot) {
        return NO;
    }
    return [category isAncestorOf:self];
}

- (BOOL)isRoot {
    return (self.parent) ? NO : YES;
}

- (BOOL)isRSS {
    if (!self.allow_post
        && [self.url isKindOfClass:[NSString class]]
        && [self.readmore_url isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}

@end
