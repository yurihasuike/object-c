//
//  DetailActionTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/07/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "DetailActionTableViewCell.h"

@implementation DetailActionTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureCellForAppRecord:(Post *)loadPost
{
    self.cntGood = 0;
    self.goodCntLabel.text = @"0";
    if(loadPost.cntGood){
        self.cntGood = loadPost.cntGood;
        self.goodCntLabel.text = [loadPost.cntGood stringValue];
    }
    self.cntComment = 0;
    self.commentCntLabel.text = @"0";
    if(loadPost.cntComment){
        self.cntComment = loadPost.cntComment;
        self.commentCntLabel.text = [loadPost.cntComment stringValue];
    }
    if([loadPost.isGood isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
        [self.goodImageView setImage:[UIImage imageNamed:@"heart_popup.png"]];
        //self.isLike = [NSNumber numberWithInt:VLPOSTLIKEYES];
    }else{
        [self.goodImageView setImage:[UIImage imageNamed:@"heart_popup_off.png"]];
        //self.isLike = [NSNumber numberWithInt:VLPOSTLIKENO];
    }
    //fit button image to button size.
    self.commentBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.commentBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    //fit button image to button size.
    self.otherBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.otherBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    
}

- (void) plusCntGood
{
    int intCntGood = [self.cntGood intValue];
    intCntGood++;
    self.cntGood = [NSNumber numberWithInt:intCntGood];
    self.goodCntLabel.text = [self.cntGood stringValue];
}

- (void) minusCntGood
{
    int intCntGood = [self.cntGood intValue];
    if(intCntGood > 0){
        intCntGood--;
    }
    self.cntGood = [NSNumber numberWithInt:intCntGood];
    self.goodCntLabel.text = [self.cntGood stringValue];
}


@end
