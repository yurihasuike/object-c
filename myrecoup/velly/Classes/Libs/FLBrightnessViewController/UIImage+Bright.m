//
//  UIImage+Bright.m
//  velly
//
//  Created by m_saruwatari on 2015/09/21.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "UIImage+Bright.h"

@implementation UIImage (Bright)

- (UIImage *)brightImage:(CGFloat)sliderVal
{

    sliderVal = MAX(sliderVal, -1.0);
    sliderVal = MIN(sliderVal, 1.0);
    
    //CIImage *ciImage = [[CIImage alloc] initWithImage:brightImage];
    CIImage *ciImage = [[CIImage alloc] initWithImage:self];
    
    //    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, @"inputBrightness", [NSNumber numberWithFloat:sliderVal], nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                                  keysAndValues:kCIInputImageKey, ciImage,
                        //@"inputSaturation", [NSNumber numberWithFloat:sliderVal],
                        @"inputBrightness", [NSNumber numberWithFloat:sliderVal / 10],
                        //@"inputContrast", [NSNumber numberWithFloat:sliderVal],
                        nil];
    
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:sliderVal / 10] forKey:@"inputEV"];
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];

    UIImage *result = [UIImage imageWithCGImage:cgImage scale:2.0f orientation:UIImageOrientationUp];
    
    CGImageRelease(cgImage);
    
    return result;
}

- (UIImage *)brightImageWithFrame:(CGRect)frame sliderVal:(CGFloat)sliderVal
{

    sliderVal = MAX(sliderVal, -1.0);
    sliderVal = MIN(sliderVal, 1.0);
    
    //CIImage *ciImage = [[CIImage alloc] initWithImage:brightImage];
    CIImage *ciImage = [[CIImage alloc] initWithImage:self];
    
//    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, @"inputBrightness", [NSNumber numberWithFloat:sliderVal], nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                                  keysAndValues:kCIInputImageKey, ciImage,
                        //@"inputSaturation", [NSNumber numberWithFloat:sliderVal],
                        @"inputBrightness", [NSNumber numberWithFloat:sliderVal / 10],
                        //@"inputContrast", [NSNumber numberWithFloat:sliderVal],
                        nil];
    
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:sliderVal / 10] forKey:@"inputEV"];
    
//    CIFilter *filter = [CIFilter filterWithName:@"CIExposureAdjust"
//                                  keysAndValues:kCIInputImageKey, ciImage,
//                        @"inputEV", [NSNumber numberWithFloat:sliderVal],
//                        nil];
    
//    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
//    [filter setDefaults];
//    [filter setValue:[NSNumber numberWithFloat:sliderVal] forKey:@"inputPower"];
    
//    CIFilter *filter = [CIFilter filterWithName:@"CIGammaAdjust"
//                                  keysAndValues:kCIInputImageKey, ciImage,
//                        @"inputPower", [NSNumber numberWithFloat:sliderVal],
//                        nil];
    
    
//    // sepia
//    CIFilter *ciFilter = [CIFilter filterWithName:@"CISepiaTone" //フィルター名
//                                    keysAndValues:kCIInputImageKey, ciImage,
//                          @"inputIntensity", [NSNumber numberWithFloat:0.8], //パラメータ
//                          nil
//                          ];
//    // グレースケール
//    CIFilter *ciFilter = [CIFilter filterWithName:@"CIColorMonochrome" //フィルター名
//                                    keysAndValues:kCIInputImageKey, ciImage,
//                          @"inputColor", [CIColor colorWithRed:0.75 green:0.75 blue:0.75], //パラメータ
//                          @"inputIntensity", [NSNumber numberWithFloat:1.0], //パラメータ
//                          nil
//                          ];

//    // トーンカーブ
//    CIFilter *ciFilter = [CIFilter filterWithName:@"CIToneCurve" //フィルター名
//                                    keysAndValues:kCIInputImageKey, ciImage,
//                          　　@"inputPoint0", [CIVector vectorWithX:0.0 Y:0.0],
//                          　　@"inputPoint1", [CIVector vectorWithX:0.25 Y:0.1],
//                          　　@"inputPoint2", [CIVector vectorWithX:0.5 Y:0.5],
//                          　　@"inputPoint3", [CIVector vectorWithX:0.75 Y:0.9],
//                          　　@"inputPoint4", [CIVector vectorWithX:1 Y:1],
//                          　　nil
//                          　　];

    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage scale:2.0f orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    
    
    return result;
    
//    UIImage *brightImage = nil;
//    CGPoint drawPoint = CGPointZero;
//    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 2.0f);
//    {
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
//        [result drawAtPoint:drawPoint];
//        brightImage = UIGraphicsGetImageFromCurrentImageContext();
//    }
//    UIGraphicsEndImageContext();
//    
//    return brightImage;

}

@end
