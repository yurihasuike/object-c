//
//  PostEffectCollectionViewCell.m
//  myrecoup
//
//  Created by aoponaopon on 2015/11/21.
//  Copyright © 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostEffectCollectionViewCell.h"

@implementation PostEffectCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    //ここでのFrame Point はダミー。PostEffectViewで行っている。
    
    //フィルター後画像設置。
    self.filteredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.filteredImageView.layer.position = CGPointMake(0, 0);
    [self.contentView addSubview:self.filteredImageView];
    
    //アンダーバー設置
    self.underBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.underBar.layer.position = CGPointMake(0, 0);
    [self.contentView addSubview:self.underBar];
    
    return self;
}

@end
