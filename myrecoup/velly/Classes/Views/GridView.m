//
//  GridView.m
//  velly
//
//  Created by m_saruwatari on 2015/08/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "GridView.h"

@implementation GridView

#pragma mark - Singleton

+ (GridView *)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (instancetype)init {
    self = [super init];
    
    [self setupSubviews];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self setupSubviews];
    
    return self;
}

#pragma mark - Creating subviews

- (void)setupSubviews {
    self.alpha = 0.0;
    self.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.0];
    
    CGFloat frameW = [[UIScreen mainScreen]bounds].size.width - 20;
    CGFloat frameH = self.frame.size.height;
    
    CGFloat partW = frameW / 4;
    CGFloat partH = frameH / 5;
    
    self.v1 = [[UIView alloc]initWithFrame:CGRectMake(partW, 0, 1, frameH)];
    self.v1.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.v1];
    
    self.v2 = [[UIView alloc]initWithFrame:CGRectMake(partW * 2, 0, 1, frameH)];
    self.v2.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.v2];
    
    self.v3 = [[UIView alloc]initWithFrame:CGRectMake(partW * 3, 0, 1, frameH)];
    self.v3.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.v3];
    
    self.h1 = [[UIView alloc]initWithFrame:CGRectMake(0, partH, frameW, 1)];
    self.h1.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.h1];
    
    self.h2 = [[UIView alloc]initWithFrame:CGRectMake(0, partH * 2, frameW, 1)];
    self.h2.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.h2];

    self.h3 = [[UIView alloc]initWithFrame:CGRectMake(0, partH * 3, frameW, 1)];
    self.h3.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.h3];

    self.h4 = [[UIView alloc]initWithFrame:CGRectMake(0, partH * 4, frameW, 1)];
    self.h4.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.h4];
    
}

@end
