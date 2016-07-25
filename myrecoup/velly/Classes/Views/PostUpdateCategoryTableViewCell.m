//
//  PostUpdateCategoryTableViewCell.m
//  myrecoup
//
//  Created by aoponaopon on 2016/03/14.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import "PostUpdateCategoryTableViewCell.h"

@implementation PostUpdateCategoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self configureCell];
    }
    return self;
}

-(void)configureCell{
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    //カテゴリーのベースView
    self.categoryView = [[UIView alloc] init];
    [self.contentView addSubview:self.categoryView];
    [[self.categoryView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.categoryView
                    attribute:NSLayoutAttributeTop
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.categoryView superview]
                    attribute:NSLayoutAttributeTop
                    multiplier:1
                    constant:0]];
    [[self.categoryView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.categoryView
                    attribute:NSLayoutAttributeLeading
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.categoryView superview]
                    attribute:NSLayoutAttributeLeading
                    multiplier:1
                    constant:0]];
    [[self.categoryView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.categoryView
                    attribute:NSLayoutAttributeTrailing
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.categoryView superview]
                    attribute:NSLayoutAttributeTrailing
                    multiplier:1
                    constant:0]];
    [[self.categoryView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.categoryView
                    attribute:NSLayoutAttributeBottom
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.categoryView superview]
                    attribute:NSLayoutAttributeBottom
                    multiplier:1
                    constant:0]];
    [self.categoryView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //icon image view
    self.categoryIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [self.categoryIconImageView setImage:[UIImage imageNamed:@"ico_category.png"]];
    [self.categoryView addSubview:self.categoryIconImageView];
    [[self.categoryIconImageView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.categoryIconImageView
                    attribute:NSLayoutAttributeLeading
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.categoryIconImageView superview]
                    attribute:NSLayoutAttributeLeading
                    multiplier:1
                    constant:15]];
    [[self.categoryIconImageView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.categoryIconImageView
                    attribute:NSLayoutAttributeTop
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.categoryIconImageView superview]
                    attribute:NSLayoutAttributeTop
                    multiplier:1
                    constant:15]];
    [self.categoryIconImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //右のarrow
    self.selectedCategoryIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 15)];
    [self.selectedCategoryIconImageView setImage:[UIImage imageNamed:@"ico_arrow.png"]];
    [self.categoryView addSubview:self.selectedCategoryIconImageView];
    [[self.selectedCategoryIconImageView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.selectedCategoryIconImageView
                    attribute:NSLayoutAttributeTop
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.selectedCategoryIconImageView superview]
                    attribute:NSLayoutAttributeTop
                    multiplier:1
                    constant:15]];
    [[self.selectedCategoryIconImageView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.selectedCategoryIconImageView
                    attribute:NSLayoutAttributeTrailing
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.selectedCategoryIconImageView superview]
                    attribute:NSLayoutAttributeTrailing
                    multiplier:1
                    constant:-20]];
    [self.selectedCategoryIconImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //カテゴリーテキスト
    self.categoryNameLabel  = [[UILabel alloc] init];
    [self.categoryNameLabel setTextColor:[UIColor grayColor]];
    [self.categoryNameLabel setFont:[UIFont fontWithName:@"ヒラギノ角ゴ ProN W3" size:16.0]];
    [self.categoryView addSubview:self.categoryNameLabel];
    [[self.categoryNameLabel superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.categoryNameLabel
                    attribute:NSLayoutAttributeLeft
                    relatedBy:NSLayoutRelationEqual
                    toItem:self.categoryIconImageView
                    attribute:NSLayoutAttributeRight
                    multiplier:1
                    constant:15]];
    [[self.categoryNameLabel superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.categoryNameLabel
                    attribute:NSLayoutAttributeTop
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.categoryNameLabel superview]
                    attribute:NSLayoutAttributeTop
                    multiplier:1
                    constant:15]];
    [self.categoryNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
