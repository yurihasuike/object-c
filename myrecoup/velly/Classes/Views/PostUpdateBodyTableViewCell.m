//
//  PostUpdateBodyTableViewCell.m
//  myrecoup
//
//  Created by aoponaopon on 2016/03/16.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import "PostUpdateBodyTableViewCell.h"

@implementation PostUpdateBodyTableViewCell

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
    
    self.bodyTextView = [[UIPlaceHolderTextView alloc] init];
    [self.contentView addSubview:self.bodyTextView];
    
    //contents viewいっぱいに広げる.
    [[self.bodyTextView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.bodyTextView
                    attribute:NSLayoutAttributeTop
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.bodyTextView superview]
                    attribute:NSLayoutAttributeTop
                    multiplier:1
                    constant:0]];
    
    [[self.bodyTextView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.bodyTextView
                    attribute:NSLayoutAttributeBottom
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.bodyTextView superview]
                    attribute:NSLayoutAttributeBottom
                    multiplier:1
                    constant:0]];
    
    [[self.bodyTextView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.bodyTextView
                    attribute:NSLayoutAttributeLeading
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.bodyTextView superview]
                    attribute:NSLayoutAttributeLeading
                    multiplier:1
                    constant:0]];
    
    [[self.bodyTextView superview]
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.bodyTextView
                    attribute:NSLayoutAttributeTrailing
                    relatedBy:NSLayoutRelationEqual
                    toItem:[self.bodyTextView superview]
                    attribute:NSLayoutAttributeTrailing
                    multiplier:1
                    constant:0]];
    [self.bodyTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
