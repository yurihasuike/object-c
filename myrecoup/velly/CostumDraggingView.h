//
//  CostumDraggingView.h
//  NewVideoRecorder
//
//  Created by VCJPCM012 on 2015/08/25.
//  Copyright (c) 2015年 KZito. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MovieEditViewController.h"

@protocol CostumDraggingDelegate

@required
-(void)changeThumnail:(int)x;  //サムネイル変更プロトコル

@end

@interface CostumDraggingView : UIView

@property(nonatomic,assign) int startTime;
@property(nonatomic,assign) int endTime;
@property (nonatomic, assign) id<CostumDraggingDelegate> delegate;


-(Float64)getStart;
-(Float64)getEnd;
-(void)cuttingMode;

@end
