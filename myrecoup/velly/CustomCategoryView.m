//
//  CustomCategory.m
//  velly
//
//  Created by VCJPCM012 on 2015/10/10.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "CustomCategoryView.h"

@implementation CustomCategoryView{
    
    UIImage* iconImage;
    UIImage* lineImage;
    UIImage* selectImage;
    
    UILabel* titleLabel;
    UIButton* button;
    UIImageView* iconImageView;
    UIImageView* lineImageView;
    UIImageView* selectImageView;

}

const int category_margin = 12;

- (id)initWithFrame:(CGRect)frame target:(id)parrentController
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parrentController = parrentController;
        [self setup];
    }
    return self;
}

-(void)setup{
    
    //遷移ボタン準備
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [btn setTitle:@"" forState:UIControlStateNormal];
    [btn setTitle:@"" forState:UIControlStateHighlighted];
    [btn setTitle:@"" forState:UIControlStateDisabled];
    [btn addTarget:self.parrentController action:@selector(test) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn];
    
    //画像準備
    iconImage = [UIImage imageNamed:@"ico_category.png"];
    lineImage = [UIImage imageNamed:@"ranking_line.png"];
    selectImage = [UIImage imageNamed:@"ico_arrow.png"];
    
    /*各Viewの配置*/
    //アイコンビューの配置
    iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(category_margin, category_margin, self.frame.size.height - category_margin*2,self.frame.size.height - category_margin*2)];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.image = iconImage;
    [self addSubview:iconImageView];
    
    //ラベルの配置
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImageView.frame.origin.x+iconImageView.frame.size.width+category_margin, category_margin, self.frame.size.width - ((iconImageView.frame.size.width+category_margin)*2 + category_margin*2), self.frame.size.height - category_margin*2)];
    UIFont *font = [UIFont fontWithName:@"ヒラギノ角ゴ ProN W3" size:16];
    [titleLabel setFont:font];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.text = @"カテゴリを選択（必須）";
    [self addSubview:titleLabel];
    
    //カテゴリビューの配置
    selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(titleLabel.frame.origin.x + titleLabel.frame.size.width + category_margin, category_margin, self.frame.size.height - category_margin*2,self.frame.size.height - category_margin*2)];
    selectImageView.contentMode = UIViewContentModeScaleAspectFit;
    selectImageView.image = selectImage;
    [self addSubview:selectImageView];
    
    //境界線ラインの追加
    UIImageView* imageView_line1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 5)];
    imageView_line1.contentMode = UIViewContentModeScaleAspectFill;
    imageView_line1.image = lineImage;
    UIImageView* imageView_line2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-5, self.frame.size.width, 5)];
    imageView_line2.contentMode = UIViewContentModeScaleAspectFill;
    imageView_line2.image = lineImage;
    [self addSubview:imageView_line1];
    [self addSubview:imageView_line2];
    
    
    
    //ico_category.png
    //ranking_line.png
    //ico_arrow.png
    //カテゴリを選択（必須）
    
}

-(void)changeLabel:(NSString*)string{
    
    
    titleLabel.text = string;

}
@end
