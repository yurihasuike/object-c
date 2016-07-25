//
//  CSFlexibleTapAreaButton.m
//  LargerTapArea
//
//  Created by griffin_stewie on 2013/09/14.
//  Copyright (c) 2013年 cyan-stivy.net. All rights reserved.
//

#import "CSFlexibleTapAreaButton.h"

@implementation CSFlexibleTapAreaButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = self.bounds;
    // 自身の bounds を tappableInsets 分大きさを変える
    rect.origin.x += self.tappableInsets.left;
    rect.origin.y += self.tappableInsets.top;
    rect.size.width -= (self.tappableInsets.left + self.tappableInsets.right);
    rect.size.height -= (self.tappableInsets.top + self.tappableInsets.bottom);
    // 変更した rect に point が含まれるかどうかを返す
    return CGRectContainsPoint(rect, point);
}

@end
