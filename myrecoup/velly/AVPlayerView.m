//
//  AVPlayer.m
//  myrecoup
//
//  Created by VCJPCM012 on 2015/11/15.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVPlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (Class)layerClass
{
    return AVPlayerLayer.class;
}

@end
