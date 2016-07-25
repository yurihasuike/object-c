//
//  PostChildCategoryTableViewCell.m
//  myrecoup
//
//  Created by aoponaopon on 2016/05/14.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import "PostChildCategoryTableViewCell.h"

@implementation PostChildCategoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.categoryIcon];
        [self.contentView addSubview:self.categoryName];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self layout];
    }
    return self;
}

- (UIImageView *)categoryIcon{
    if (!_categoryIcon) {
        _categoryIcon = [[UIImageView alloc] init];
        [_categoryIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_categoryIcon setImage:[UIImage imageNamed:@"ico_arrange.png"]];
    }
    return _categoryIcon;
}

- (UILabel *)categoryName{
    if (!_categoryName) {
        _categoryName = [[UILabel alloc] init];
        [_categoryName setFont:JPFONT(16)];
        [_categoryName setTextColor:[UIColor darkGrayColor]];
        [_categoryName setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _categoryName;
}

- (void)layout{
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_categoryIcon, _categoryName);
    [self.contentView
     addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"|-10-[_categoryIcon(26)]-14-[_categoryName(280)]"
                     options:0
                     metrics:nil
                     views:views]];
    [self.contentView
     addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|-(>=10)-[_categoryIcon(26)]-(>=10)-|"
                     options:0
                     metrics:nil
                     views:views]];
    [self.contentView
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.categoryName
                    attribute:NSLayoutAttributeCenterY
                    relatedBy:NSLayoutRelationEqual
                    toItem:self.categoryIcon
                    attribute:NSLayoutAttributeCenterY
                    multiplier:1
                    constant:0]];
}

///親カテゴリから子カテゴリのアイコンを取得してセット
- (void)setIconImage:(Category_ *)category {
    UIImage *icon;
    if([category.label isEqualToString:@"ネイル"]){
        icon = [UIImage imageNamed:@"ico_nail.png"];
        
    }else if([category.label isEqualToString:@"ヘアスタイル・アレンジ"]){
        icon = [UIImage imageNamed:@"ico_style.png"];
        
    }else if([category.label isEqualToString:@"メイク・コスメ"]){
        icon = [UIImage imageNamed:@"ico_make.png"];
        
    }else if([category.label isEqualToString:@"その他"]){
        icon = [UIImage imageNamed:@"ico_etc.png"];
        
    }else{
        icon = [UIImage imageNamed:@"ico_etc.png"];
        
    }
    [self.categoryIcon setImage:icon];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
