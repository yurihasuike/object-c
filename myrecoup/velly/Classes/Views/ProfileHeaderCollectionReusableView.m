//
//  ProfileHeaderCollectionReusableView.m
//  velly
//
//  Created by m_saruwatari on 2015/04/01.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "ProfileHeaderCollectionReusableView.h"

@implementation ProfileHeaderCollectionReusableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    [self configureSubViews];
    return self;
}

-(void)configureSubViews{
    
    //新規メッセージボタン設置.
    self.n_messageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.n_messageBtn.hidden = YES;
    [self addSubview:self.n_messageBtn];
    
    //「プロ」ボタン設置.
    self.proBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.proBtn.hidden = YES;
    self.proBtn.userInteractionEnabled = NO;
    [self addSubview:self.proBtn];
    
}
@end
