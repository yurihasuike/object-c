//
//  FLBrightnessToolbar.m
//  velly
//
//  Created by m_saruwatari on 2015/07/11.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FLBrightnessToolbar.h"

@interface FLBrightnessToolbar()

@property (nonatomic, strong) UIButton *doneTextButton;
@property (nonatomic, strong) UIButton *doneIconButton;

@property (nonatomic, strong) UIButton *cancelTextButton;
@property (nonatomic, strong) UIButton *cancelIconButton;

@property (nonatomic, strong) UIButton *resetButton;



- (void)setup;
- (void)buttonTapped:(id)button;
- (void)sliderDidChange:(id)slider;


+ (UIImage *)doneImage;
+ (UIImage *)cancelImage;
+ (UIImage *)resetImage;

@end

@implementation FLBrightnessToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:1.0f];   // 0.12f
    
    _doneTextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _doneTextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_doneTextButton setTitle:NSLocalizedStringFromTable(@"Done", @"TOCropViewControllerLocalizable", nil) forState:UIControlStateNormal];
    [_doneTextButton setTitleColor:[UIColor colorWithRed:1.0f green:0.8f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
    [_doneTextButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [_doneTextButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneTextButton];
    
    _doneIconButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_doneIconButton setImage:[FLBrightnessToolbar doneImage] forState:UIControlStateNormal];
    [_doneIconButton setTintColor:[UIColor colorWithRed:1.0f green:0.8f blue:0.0f alpha:1.0f]];
    [_doneIconButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneIconButton];
    
    _cancelTextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelTextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_cancelTextButton setTitle:NSLocalizedStringFromTable(@"Cancel", @"TOCropViewControllerLocalizable", nil) forState:UIControlStateNormal];
    [_cancelTextButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [_cancelTextButton setTintColor:[UIColor colorWithRed:1.0f green:1.8f blue:1.0f alpha:1.0f]];
    [_cancelTextButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelTextButton];
    
    _cancelIconButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancelIconButton setImage:[FLBrightnessToolbar cancelImage] forState:UIControlStateNormal];
    [_cancelIconButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelIconButton];
    
    _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _resetButton.contentMode = UIViewContentModeCenter;
    _resetButton.tintColor = [UIColor whiteColor];
    _resetButton.enabled = NO;
    [_resetButton setImage:[FLBrightnessToolbar resetImage] forState:UIControlStateNormal];
    [_resetButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_resetButton];
    
    
    _brightnessSlider = [self sliderWithValue:0 minimumValue:-1.0f maximumValue:1.0f action:@selector(sliderDidChange:)];
    //_brightnessSlider.superview.center = CGPointMake(20, _saturationSlider.superview.top - 150);
    _brightnessSlider.superview.transform = CGAffineTransformMakeRotation(-M_PI * 90 / 180.0f);
    [_brightnessSlider setThumbImage:[UIImage imageNamed:@"ico_end.png"] forState:UIControlStateNormal];
    [_brightnessSlider setThumbImage:[UIImage imageNamed:@"ico_end.png"] forState:UIControlStateHighlighted];
    
    
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40.f, 30.f)];
    // labelの細かい設定は省略
    sliderLabel.textColor = [UIColor whiteColor];
    sliderLabel.userInteractionEnabled = NO;
    sliderLabel.tag = 1979;    // *1
    sliderLabel.hidden = YES;
    sliderLabel.textAlignment = NSTextAlignmentLeft;
    [_brightnessSlider addSubview:sliderLabel];

    [_brightnessSlider addTarget:self action:@selector(sliderChanging:) forControlEvents:UIControlEventValueChanged];
    [_brightnessSlider addTarget:self action:@selector(sliderHasChanged:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    [self addSubview:_brightnessSlider];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    BOOL verticalLayout = (CGRectGetWidth(self.bounds) < CGRectGetHeight(self.bounds));
    CGSize boundsSize = self.bounds.size;
    
    self.cancelIconButton.hidden = (!verticalLayout);
    self.cancelTextButton.hidden = (verticalLayout);
    self.doneIconButton.hidden   = (!verticalLayout);
    self.doneTextButton.hidden   = (verticalLayout);
    
    if (verticalLayout == NO) {
        CGRect frame = CGRectZero;
        frame.size.height = 44.0f;
        frame.size.width = [self.cancelTextButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.cancelTextButton.titleLabel.font}].width + 10;
        self.cancelTextButton.frame = frame;
        
        frame.size.width = [self.doneTextButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.doneTextButton.titleLabel.font}].width + 10;
        frame.origin.x = boundsSize.width - CGRectGetWidth(frame);
        self.doneTextButton.frame = frame;
        
        CGRect containerRect = (CGRect){0,0,165.0f,44.0f};
        containerRect.origin.x = (CGRectGetWidth(self.bounds) - (CGRectGetWidth(containerRect))) * 0.5f;
        
        CGRect buttonFrame = (CGRect){0,0,44.0f,44.0f};
        
        buttonFrame.origin.x = CGRectGetMinX(containerRect);
        buttonFrame.origin.x = CGRectGetMidX(containerRect) -  22.0f;
        //self.resetButton.frame = buttonFrame;
        
        buttonFrame.origin.x = CGRectGetMaxX(containerRect) - 44.0f;
        
        
        //self.brightnessSlider.superview.center = CGPointMake(20, buttonFrame.origin.y);
        self.brightnessSlider.frame = CGRectMake(CGRectGetWidth(frame) + 20,
                                                 0,
                                                 boundsSize.width - CGRectGetWidth(frame) - CGRectGetWidth(buttonFrame) - 40,
                                                 CGRectGetHeight(self.brightnessSlider.frame));
    }
    else {
        CGRect frame = CGRectZero;
        frame.size.height = 44.0f;
        frame.size.width = 44.0f;
        frame.origin.y = CGRectGetHeight(self.bounds) - 44.0f;
        self.cancelIconButton.frame = frame;
        
        frame.origin.y = 0.0f;
        frame.size.width = 44.0f;
        frame.size.height = 44.0f;
        self.doneIconButton.frame = frame;
        
        CGRect containerRect = (CGRect){0,0,44.0f,165.0f};
        containerRect.origin.y = (CGRectGetHeight(self.bounds) - (CGRectGetHeight(containerRect))) * 0.5f;
        
        CGRect buttonFrame = (CGRect){0,0,44.0f,44.0f};
        
        buttonFrame.origin.y = CGRectGetMinY(containerRect);
            
        buttonFrame.origin.y = CGRectGetMidY(containerRect) -  22.0f;
        //self.resetButton.frame = buttonFrame;
        
        buttonFrame.origin.y = CGRectGetMaxY(containerRect) - 44.0f;

        //self.brightnessSlider.superview.center = CGPointMake(20, buttonFrame.origin.y);
        self.brightnessSlider.frame = CGRectMake(CGRectGetWidth(frame) + 20,
                                                 0,
                                                 boundsSize.width - CGRectGetWidth(frame) - CGRectGetWidth(buttonFrame) - 40,
                                                 CGRectGetHeight(self.brightnessSlider.frame));
    }
    
}

- (UISlider*)sliderWithValue:(CGFloat)value minimumValue:(CGFloat)min maximumValue:(CGFloat)max action:(SEL)action
{
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 0, 240, 35)];
    
//    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, slider.height)];
//    container.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
//    container.layer.cornerRadius = slider.height/2;
    
    slider.continuous = YES;
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    
    slider.maximumValue = max;
    slider.minimumValue = min;
    slider.value = value;
    slider.tintColor = [UIColor redColor];
    slider.minimumTrackTintColor = [UIColor redColor];
    slider.maximumTrackTintColor = [UIColor whiteColor];
    
//    [container addSubview:slider];
//    [self.editor.view addSubview:container];
    
    return slider;
}

- (void)sliderDidChange:(id)sender
//- (void)sliderDidChange:(UISlider*)sender
{
    
    if (self.sliderChange)
        self.sliderChange();

}


- (void)sliderChanging:(UISlider*)sender {
    //sender.value = round(sender.value);
    
    float num = sender.value;
    NSDecimalNumber *decimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",num]];
    // 小数点第2位を四捨五入
    int scale = 1;
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:scale raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
    decimal = [decimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    DLog(@"%@",[decimal stringValue]);
    sender.value = [decimal doubleValue];
    
    // ハンドルの中心x座標を取得
    //CGFloat ind_x = [[UIScreen mainScreen]bounds].size.width / 2;
    CGFloat ind_x = [[sender.subviews objectAtIndex:3] center].x + 15.0f;
    //CGFloat ind_x = [sender center].x;
    //CGFloat ind_x = [[sender.subviews objectAtIndex:0] bounds].origin.x;
    
    // viewWithTag: でスライダー内のインジケーターに当たるビューを取得
    UILabel *label = (UILabel*)[sender viewWithTag:1979];
    
    // インジケーターの位置をハンドルの中心座標に合わせて調節
    [label setCenter:(CGPoint){ind_x, -10.f}];
//    CGRect labelFrame = label.frame;
//    labelFrame.origin.x = [sender bounds].size.width / 2 - 15;
//    labelFrame.origin.y =  -20.f;
//    [label setFrame:labelFrame];
    
    // インジケーターを表示し、現在値に合わせてテキストを変更する
    label.hidden = NO;
    //label.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    label.text = [NSString stringWithFormat:@"%@", [decimal stringValue]];
    
}

- (void)sliderHasChanged:(UISlider*)sender {
    // 指が離れたらインジケーターを非表示にする
    [[sender viewWithTag:1979] setHidden:YES];
}



- (void)buttonTapped:(id)button
{
    if (button == self.cancelTextButton || button == self.cancelIconButton) {
        if (self.cancelButtonTapped)
            self.cancelButtonTapped();
    }
    else if (button == self.doneTextButton || button == self.doneIconButton) {
        if (self.doneButtonTapped)
            self.doneButtonTapped();
    }
    else if (button == self.resetButton && self.resetButtonTapped) {
        self.resetButtonTapped();
    }
}


- (BOOL)resetButtonEnabled
{
    return self.resetButton.enabled;
}

- (void)setResetButtonEnabled:(BOOL)resetButtonEnabled
{
    self.resetButton.enabled = resetButtonEnabled;
}


- (CGRect)doneButtonFrame
{
    if (self.doneIconButton.hidden == NO)
        return self.doneIconButton.frame;
    
    return self.doneTextButton.frame;
}

#pragma mark - Image Generation -
+ (UIImage *)doneImage
{
    UIImage *doneImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){17,14}, NO, 0.0f);
    {
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = UIBezierPath.bezierPath;
        [rectanglePath moveToPoint: CGPointMake(1, 7)];
        [rectanglePath addLineToPoint: CGPointMake(6, 12)];
        [rectanglePath addLineToPoint: CGPointMake(16, 1)];
        [UIColor.whiteColor setStroke];
        rectanglePath.lineWidth = 2;
        [rectanglePath stroke];
        
        doneImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return doneImage;
}

+ (UIImage *)cancelImage
{
    UIImage *cancelImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){16,16}, NO, 0.0f);
    {
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(15, 15)];
        [bezierPath addLineToPoint: CGPointMake(1, 1)];
        [UIColor.whiteColor setStroke];
        bezierPath.lineWidth = 2;
        [bezierPath stroke];
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(1, 15)];
        [bezier2Path addLineToPoint: CGPointMake(15, 1)];
        [UIColor.whiteColor setStroke];
        bezier2Path.lineWidth = 2;
        [bezier2Path stroke];
        
        cancelImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return cancelImage;
}


+ (UIImage *)resetImage
{
    UIImage *resetImage = nil;
    
    UIGraphicsBeginImageContextWithOptions((CGSize){22,18}, NO, 0.0f);
    {
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(22, 9)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 18) controlPoint1: CGPointMake(22, 13.97) controlPoint2: CGPointMake(17.97, 18)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 16) controlPoint1: CGPointMake(13, 17.35) controlPoint2: CGPointMake(13, 16.68)];
        [bezier2Path addCurveToPoint: CGPointMake(20, 9) controlPoint1: CGPointMake(16.87, 16) controlPoint2: CGPointMake(20, 12.87)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 2) controlPoint1: CGPointMake(20, 5.13) controlPoint2: CGPointMake(16.87, 2)];
        [bezier2Path addCurveToPoint: CGPointMake(6.55, 6.27) controlPoint1: CGPointMake(10.1, 2) controlPoint2: CGPointMake(7.62, 3.76)];
        [bezier2Path addCurveToPoint: CGPointMake(6, 9) controlPoint1: CGPointMake(6.2, 7.11) controlPoint2: CGPointMake(6, 8.03)];
        [bezier2Path addLineToPoint: CGPointMake(4, 9)];
        [bezier2Path addCurveToPoint: CGPointMake(4.65, 5.63) controlPoint1: CGPointMake(4, 7.81) controlPoint2: CGPointMake(4.23, 6.67)];
        [bezier2Path addCurveToPoint: CGPointMake(7.65, 1.76) controlPoint1: CGPointMake(5.28, 4.08) controlPoint2: CGPointMake(6.32, 2.74)];
        [bezier2Path addCurveToPoint: CGPointMake(13, 0) controlPoint1: CGPointMake(9.15, 0.65) controlPoint2: CGPointMake(11, 0)];
        [bezier2Path addCurveToPoint: CGPointMake(22, 9) controlPoint1: CGPointMake(17.97, 0) controlPoint2: CGPointMake(22, 4.03)];
        [bezier2Path closePath];
        [UIColor.whiteColor setFill];
        [bezier2Path fill];
        
        
        //// Polygon Drawing
        UIBezierPath* polygonPath = UIBezierPath.bezierPath;
        [polygonPath moveToPoint: CGPointMake(5, 15)];
        [polygonPath addLineToPoint: CGPointMake(10, 9)];
        [polygonPath addLineToPoint: CGPointMake(0, 9)];
        [polygonPath addLineToPoint: CGPointMake(5, 15)];
        [polygonPath closePath];
        [UIColor.whiteColor setFill];
        [polygonPath fill];
        
        
        resetImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    
    return resetImage;
}



@end
