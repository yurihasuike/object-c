//
//  PostEditTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/06/16.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostCategoryTableViewCell.h"

@implementation PostCategoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configureCellForCategoryName:(Category_ *)category
{
    self.category = category;
    
    // categoryName
    self.categoryLabel.text = category.label;
    
    // category image
    
    if([category.label isEqualToString:@"ヘアアレンジ"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_arrange.png"];
    
    }else if([category.label isEqualToString:@"ヘアスタイル"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_style.png"];
        
    }else if([category.label isEqualToString:@"ネイルアート"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_nail.png"];

    }else if([category.label isEqualToString:@"メイク"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_make.png"];

    }else if([category.label isEqualToString:@"コスメ"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_cosme.png"];

    }else if([category.label isEqualToString:@"ダイエット"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_diet.png"];

    }else if([category.label isEqualToString:@"スキンケア"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_skin.png"];

    }else if([category.label isEqualToString:@"ボディケア"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_body.png"];

    }else if([category.label isEqualToString:@"エクササイズ"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_exercise.png"];

    }else if([category.label isEqualToString:@"ネイル"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_nail.png"];
        
    }else if([category.label isEqualToString:@"ヘアスタイル・アレンジ"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_style.png"];
        
    }else if([category.label isEqualToString:@"メイク・コスメ"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_make.png"];

    }else if([category.label isEqualToString:@"その他"]){
        self.categoryImageView.image = [UIImage imageNamed:@"ico_etc.png"];

    }else{
        self.categoryImageView.image = [UIImage imageNamed:@"ico_etc.png"];
        
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}


@end
