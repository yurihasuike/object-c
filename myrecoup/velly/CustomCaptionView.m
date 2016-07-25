//
//  CustomCaptionView.m
//  velly
//
//  Created by VCJPCM012 on 2015/10/10.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "CustomCaptionView.h"
#import "UIPlaceHolderTextView.h"


@implementation CustomCaptionView{
    
    UIImageView * imageView;
    UIPlaceHolderTextView* textView;

}

const int margin = 20;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup:image];
    }
    return self;
}

-(void)setup:(UIImage*)image{
    
    NSLog(@"width = %f",self.frame.size.width);
    
    //サムネイメージ領域の作製
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(margin, margin, self.frame.size.width*0.20, self.frame.size.height -margin*2)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    if(image){
        imageView.image = image;
    }
    [self addSubview:imageView];

    
    //プレースホルダ領域の作製
    textView = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(margin*2+imageView.frame.size.width, margin, self.frame.size.width - imageView.frame.size.width -margin*3, self.frame.size.height -margin*2)];
    textView.placeholder = NSLocalizedString(@"TFPHolderPostEditDescription", nil);
    UIFont *font = [UIFont fontWithName:@"ヒラギノ角ゴ ProN W3" size:12];
    [textView setFont:font];
    [textView setUpKeyBoard];
    textView.textColor = [UIColor darkGrayColor];
    [self addSubview:textView];
    
    

}


-(NSString*)getText{
    return textView.text;
}

@end
