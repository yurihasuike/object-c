//
//  CoreImageHelper.m
//  velly
//
//  Created by m_saruwatari on 2015/03/30.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "CoreImageHelper.h"

@implementation CoreImageHelper

+ (void)resizeAspectFitImageWithImage:(UIImage*)img atSize:(CGFloat)size completion:(void(^)(UIImage*))completion
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:img];
    
    // リサイズする倍率を求める
    // CGFloat scale = img.size.width < img.size.height ? size/img.size.height : size/img.size.width;
    CGFloat scale = size/img.size.width;
    // CGAffineTransformでサイズ変更
    CIImage *filteredImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeScale(scale,scale)];
    // UIImageに変換
//    UIImage *newImg = [self uiImageFromCIImage:filteredImage];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        completion(newImg);
//    });
    
    [self uiImageFromCIImage:filteredImage completion:^(UIImage *newImg){
        DLog(@"%f", newImg.size.width);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(newImg);
        });
    }];
}

+ (void)centerCroppingImageWithImage:(UIImage*)img atSize:(CGSize)size completion:(void(^)(UIImage*))completion
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:img];
    /* 画像のサイズ */
//    CGSize imgSize = CGSizeMake(img.size.width * img.scale,
//                                img.size.height * img.scale);
    CGSize imgSize = CGSizeMake(img.size.width, img.size.height);
    
    /* トリミングするサイズ */
//    CGSize croppingSize = CGSizeMake(size.width * [UIScreen mainScreen].scale,
//                                     size.height * [UIScreen mainScreen].scale);
    CGSize croppingSize;
//    if( (size.width * [UIScreen mainScreen].scale) < imgSize.width &&
//       (size.height * [UIScreen mainScreen].scale) < imgSize.height ){
    if( (size.width) < imgSize.width && (size.height) < imgSize.height ){
        
        // 倍率をギリギリまでチェック
        CGFloat scaleRateWidth  = size.width / imgSize.width;
        CGFloat scaleRateHeight = size.height / imgSize.height;
        CGFloat checkScale = (scaleRateWidth > scaleRateHeight) ? scaleRateWidth : scaleRateHeight;
        croppingSize = CGSizeMake(size.width / checkScale,
                                  size.height / checkScale);
    }else{
        // 小さい画像の為、そのサイズのまま
        croppingSize = CGSizeMake(size.width, size.height);
        imgSize = CGSizeMake(img.size.width, img.size.height);
    }
    
    
    /* 中央でトリミング */
    CIImage *filteredImage = [ciImage imageByCroppingToRect:CGRectMake(imgSize.width/2.f - croppingSize.width/2.f,
                                                                       imgSize.height/2.f - croppingSize.height/2.f,
                                                                       croppingSize.width,
                                                                       croppingSize.height)];
    /* UIImageに変換する */
//    UIImage *newImg = [self uiImageFromCIImage:filteredImage];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        completion(newImg);
//    });
    
    [self uiImageFromCIImage:filteredImage completion:^(UIImage *newImg){
        DLog(@"newImg width %f", newImg.size.width);
        DLog(@"newImg height %f", newImg.size.height);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(newImg);
        });
    }];
    
}

//+ (UIImage*)uiImageFromCIImage:(CIImage*)ciImage
+ (void)uiImageFromCIImage:(CIImage*)ciImage completion:(void(^)(UIImage*))completion
{
    CIContext *ciContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @NO }];
    CGImageRef imgRef = [ciContext createCGImage:ciImage fromRect:[ciImage extent]];
    UIImage *newImg  = [UIImage imageWithCGImage:imgRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imgRef);
    //return newImg;
    
    /* iOS6.0以降だと以下が使用可能 */
    //  [[UIImage alloc] initWithCIImage:ciImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(newImg);
    });
    
}

@end
