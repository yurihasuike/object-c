//
//  PostUpdateImageViewCellTableViewCell.m
//  myrecoup
//
//  Created by aoponaopon on 2016/03/14.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import "PostUpdateImageTableViewCell.h"

@implementation PostUpdateImageTableViewCell

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
    
    self.postImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width,0 )];
    [self.contentView addSubview:self.postImageView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
