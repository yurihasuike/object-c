//
//  CostumDraggingView.m
//  NewVideoRecorder
//
//  Created by VCJPCM012 on 2015/08/25.
//  Copyright (c) 2015年 KZito. All rights reserved.
//

#import "Defines.h"
#import "CostumDraggingView.h"

@implementation CostumDraggingView{
    
    UIView* draggingViewLeft;
    UIView* draggingViewRight;
    UIImageView* imageleft;
    UIImageView* imageright;
    
    UIView* colorView;
    

}

const int BAR_WIDTH = 35;
const int LEFT_TAG = 1;
const int RIGHT_TAG = 2;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init:(CGRect)frame
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.startTime = 0;
    self.endTime =DEFINES_MAX_TIME;
    
    [self createBorder:self interval:10];
    
    //左にドラッギング用のViewを準備
    draggingViewLeft  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, BAR_WIDTH, self.frame.size.height)];
    draggingViewLeft.backgroundColor = [UIColor colorWithRed:0.93 green:0.67 blue:0.49 alpha:1.0];
    draggingViewLeft.tag = LEFT_TAG;
    imageleft = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, draggingViewLeft.frame.size.width, draggingViewLeft.frame.size.height)];
    imageleft.image = [UIImage imageNamed:@"left_bar.png"];
    [draggingViewLeft addSubview:imageleft];
    
    //右にドラッギング用のViewを準備
    draggingViewRight = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width-BAR_WIDTH, 0, BAR_WIDTH, self.frame.size.height)];
    draggingViewRight.backgroundColor = [UIColor colorWithRed:0.93 green:0.67 blue:0.49 alpha:1.0];
    draggingViewRight.tag = RIGHT_TAG;
    imageright = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, draggingViewLeft.frame.size.width, draggingViewLeft.frame.size.height)];
    imageright.image = [UIImage imageNamed:@"right_bar.png"];
    [draggingViewRight addSubview:imageright];
    
    UIPanGestureRecognizer *panGesture1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    UIPanGestureRecognizer *panGesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [draggingViewLeft  addGestureRecognizer:panGesture1];
    [draggingViewRight addGestureRecognizer:panGesture2];
    
    //真ん中Viewの準備
    if(!colorView){
        colorView = [[UIView alloc]initWithFrame:CGRectMake(draggingViewLeft.frame.origin.x+BAR_WIDTH, 0, self.frame.size.width - draggingViewLeft.frame.size.width - draggingViewRight.frame.size.width, self.frame.size.height)];
        colorView.backgroundColor = [UIColor blackColor];
        //枠線
        colorView.layer.borderWidth = 10.0f;
        //枠線の色
        colorView.layer.borderColor = [[UIColor colorWithRed:0.98 green:0.71 blue:0.54 alpha:1.0] CGColor];
        [self createBorder:colorView interval:20];
        [self addSubview:colorView];
    }
    
    
    //View追加
    [self addSubview:draggingViewLeft];
    [self addSubview:draggingViewRight];
    
    //便利な省略形
    self.startTime = 10;
}

-(void) createBorder:(UIView*)targetView interval:(int)interval{
    
    //縦ラインViewの初期化
    [[targetView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int viewWidth = targetView.frame.size.width;
    
    for (int i = 10; i < viewWidth; i+=interval) {
        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(i, 30, 2, targetView.frame.size.height - 60)];
        view.backgroundColor = [UIColor whiteColor];
        [targetView addSubview:view];
    }

}

-(void)dragged:(UIPanGestureRecognizer*) sender{
    
    UIView *draggedView = sender.view;
    CGPoint delta = [sender translationInView:draggedView];
    CGPoint movedPoint = CGPointMake(draggedView.center.x + delta.x, draggedView.center.y/*+ delta.y*/);
    
    
    if(draggedView.tag == LEFT_TAG){
        
        //画面端で止める
        if(movedPoint.x <= (0+BAR_WIDTH/2) ){
            movedPoint.x = BAR_WIDTH/2;
        }
        
        //RightBarを越えないように制御
        if(movedPoint.x >= (draggingViewRight.frame.origin.x -BAR_WIDTH/2 )){
            movedPoint.x = (draggingViewRight.frame.origin.x -BAR_WIDTH/2 );
        }
        
        
    }else{
        
        //画面端で止める
        if(movedPoint.x >= (self.frame.size.width - BAR_WIDTH/2) ){
            movedPoint.x = (self.frame.size.width - BAR_WIDTH/2);
        }
        
        //LeftBarを越えないように制御
        if(movedPoint.x <= (draggingViewLeft.frame.origin.x + BAR_WIDTH + BAR_WIDTH/2 )){
            movedPoint.x = (draggingViewLeft.frame.origin.x + BAR_WIDTH + BAR_WIDTH/2 );
        }
        
        
    }
    
    
    draggedView.center = movedPoint;
    [sender setTranslation:CGPointZero inView:draggedView];
    [self changedState:draggedView];
    
//    if(sender.state != UIGestureRecognizerStateEnded){
//
//
//
//    }
    
}


-(void)changedState:(UIView*)view{

//    if(!colorView){
//        colorView = [[UIView alloc]initWithFrame:CGRectMake(draggingViewLeft.frame.origin.x+BAR_WIDTH, 0, self.frame.size.width - draggingViewRight.frame.origin.x, self.frame.size.height)];
//        //colorView.backgroundColor = [UIColor yellowColor];
//        //枠線
//        colorView.layer.borderWidth = 2.0f;
//        //枠線の色
//        colorView.layer.borderColor = [[UIColor redColor] CGColor];
//        [self addSubview:colorView];
//    }else{
        colorView.frame = CGRectMake(draggingViewLeft.frame.origin.x+BAR_WIDTH, 0, draggingViewRight.frame.origin.x - draggingViewLeft.frame.origin.x-BAR_WIDTH, self.frame.size.height);
    [self createBorder:colorView interval:20];
    //}
    
    if(view.tag == LEFT_TAG){
        [self.delegate changeThumnail:draggingViewLeft.frame.origin.x];
    }else{
        [self.delegate changeThumnail:draggingViewRight.frame.origin.x];
    }

}

-(Float64)getStart{
    return draggingViewLeft.frame.origin.x / self.frame.size.width;
}

-(Float64)getEnd{
    return (draggingViewRight.frame.origin.x + draggingViewRight.frame.size.width) / self.frame.size.width;
}

-(void)cuttingMode{
//    colorView = [[UIView alloc]initWithFrame:CGRectMake(draggingViewLeft.frame.origin.x+BAR_WIDTH, 0, self.frame.size.width - draggingViewRight.frame.origin.x, self.frame.size.height)];
//    colorView.backgroundColor = [UIColor yellowColor];
//    [self addSubview:colorView];
    draggingViewRight.alpha = 0;
    colorView.alpha = 0;
    [imageleft removeFromSuperview];
    [imageright removeFromSuperview];
    colorView.layer.borderWidth = 0.0f;
}

@end
