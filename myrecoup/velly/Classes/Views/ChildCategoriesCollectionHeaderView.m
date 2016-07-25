//
//  ChildCategoriesCollectionHeaderView.m
//  myrecoup
//
//  Created by aoponaopon on 2016/05/12.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import "ChildCategoriesCollectionHeaderView.h"

@implementation ChildCategoriesCollectionHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self addSubview:self.title];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_title);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_title]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    return self;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] initWithFrame:self.bounds];
        [_title setFont:JPFONT(12)];
        [_title setTextColor:[UIColor darkGrayColor]];
        [_title setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _title;
}
@end
