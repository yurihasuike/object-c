//
//  ChildCategoriesCollectionViewCell.m
//  myrecoup
//
//  Created by aoponaopon on 2016/05/09.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import "ChildCategoriesCollectionViewCell.h"

@implementation ChildCategoriesCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    
    [self.contentView addSubview:self.postImgView];
    [self.contentView addSubview:self.categoryLabel];
    [self.contentView addSubview:self.countLabel];
    
    
    NSNumber *labelhp = @5;
    NSNumber *labelw  = @70;
    NSNumber *labelh  = @30;
    NSDictionary *metrics = NSDictionaryOfVariableBindings(labelhp, labelh, labelw);
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_postImgView, _categoryLabel, _countLabel);
    
    [self.contentView
     addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"|-0-[_postImgView]-0-|"
                     options:0
                     metrics:nil
                     views:views]];
    [self.contentView
     addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"|-labelhp-[_categoryLabel]-labelhp-|"
                     options:0
                     metrics:metrics
                     views:views]];
    [self.contentView
     addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|-0-[_postImgView]"
                     options:0
                     metrics:nil
                     views:views]];
    [self.contentView
     addConstraints:[NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:[_postImgView]-0-[_categoryLabel(labelh)]-0-|"
                     options:0
                     metrics:metrics
                     views:views]];
    return self;
}

- (UIImageView *)postImgView {
    if (!_postImgView) {
        _postImgView = [[UIImageView alloc] init];
        [_postImgView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_postImgView setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _postImgView;
}

- (UILabel *)categoryLabel {
    if (!_categoryLabel) {
        _categoryLabel = [[UILabel alloc] init];
        [_categoryLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_categoryLabel setFont:JPFONT(12)];
        [_categoryLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return _categoryLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        [_countLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_countLabel setFont:JPFONT(12)];
        [_countLabel setTextAlignment:NSTextAlignmentRight];
        [_countLabel setAdjustsFontSizeToFitWidth:YES];
        [_countLabel setHidden:YES];
    }
    return _countLabel;
}

@end