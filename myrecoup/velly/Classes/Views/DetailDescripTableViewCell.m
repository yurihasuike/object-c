//
//  DetailDescripTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/07/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "DetailDescripTableViewCell.h"
#import "UIImageView+Networking.h"
#import "CommonUtil.h"
#import "UIImageView+WebCache.h"

@implementation DetailDescripTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureCellForAppRecord:(Post *)loadPost
{
    if(loadPost.descrip){
        
        //CommonUtil *commonUtil = [[CommonUtil alloc] init];
        
        //self.postDescripLabel.text = loadPost.descrip;
        //self.postDescripLabel.attributedText = [CommonUtil uiLabelHeight:16.0f label:loadPost.descrip];
        //self.postDescripLabel.text = [CommonUtil uiLabelNoBreakHeight:16.0f label:loadPost.descrip];
        self.postDescripLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.postDescripLabel.numberOfLines = 0;
        [self.postDescripLabel setFrame:CGRectMake(10, 6, self.bounds.size.width - 20, 5000)];
        [self.postDescripLabel sizeToFit];
        self.cellHeight = self.postDescripLabel.frame.size.height + 12;
        
        DLog(@"height : %f", self.cellHeight);
    }

}

- (CGFloat)calcCellHeight
{
    return self.cellHeight;
}

- (CGFloat)calcCellHeight:(Post *)loadPost
{
    if(loadPost.descrip){
        
        //CommonUtil *commonUtil = [[CommonUtil alloc] init];
        
        //DLog(@"bounds width : %f", [[UIScreen mainScreen]bounds].size.width);
        
        //self.postDescripLabel.text = loadPost.descrip;
        //self.postDescripLabel.attributedText = [CommonUtil uiLabelHeight:16.0f label:loadPost.descrip];
        //self.postDescripLabel.text = [CommonUtil uiLabelNoBreakHeight:16.0f label:loadPost.descrip];
        self.postDescripLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.postDescripLabel.numberOfLines = 0;
        [self.postDescripLabel setFrame:CGRectMake(10, 6, [[UIScreen mainScreen]bounds].size.width - 20, 5000)];
        [self.postDescripLabel sizeToFit];
        self.cellHeight = self.postDescripLabel.frame.size.height + 12;
        
        DLog(@"height : %f", self.cellHeight);
    }
    return self.cellHeight;
}

@end
