//
//  ProfileDecorationCollectionReusableView.m
//  velly
//
//  Created by m_saruwatari on 2015/04/01.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "ProfileDecorationCollectionReusableView.h"

@implementation ProfileDecorationCollectionReusableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        //        UIImage *image = [UIImage imageNamed:@"btn_info_post.png"];
        //        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        //        imageView.frame = self.bounds;
        //        [self addSubview:imageView];
        
        //indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];// インジケーターの大きさ

//        indicator = [[UIActivityIndicatorView alloc] init];
//        //indicator.center = CGPointMake(120, 140);// 下地での位置
//        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;// スタイル
//        indicator.color = [UIColor blackColor];// indicatorの色
//        indicator.frame = CGRectMake(self.bounds.size.width/2-10, self.bounds.size.height/2-10,20,20);
//        indicator.startAnimating;
//        [self addSubview:indicator];
        
    }
    return self;
}

+ (CGSize)defaultSize {
    return [UIImage imageNamed:@"btn_info_post.png"].size;
}

@end
