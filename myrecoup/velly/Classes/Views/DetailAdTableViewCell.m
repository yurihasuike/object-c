//
//  DetailAdTableViewCell.m
//  myrecoup
//
//  Created by aoponaopon on 2016/02/19.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import "DetailAdTableViewCell.h"

@implementation DetailAdTableViewCell

//ここでViewをaddすべき.
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self configureCell];
    }
    
    
    return self;
}

//cellに追加.
-(void)configureCell{
    self.imobileAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.contentView addSubview:self.imobileAdView];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
