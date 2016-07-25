//
//  CoreImageHelper.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CoreImageHelper : NSObject

/* アスペクトサイズを維持してリサイズ */
+ (void)resizeAspectFitImageWithImage:(UIImage*)img atSize:(CGFloat)size completion:(void(^)(UIImage*))completion;

/* 画像の中央からトリミング */
+ (void)centerCroppingImageWithImage:(UIImage*)img atSize:(CGSize)size completion:(void(^)(UIImage*))completion;

/* CIImageからUIImageを作成 */
//+ (UIImage*)uiImageFromCIImage:(CIImage*)ciImage;
+ (void)uiImageFromCIImage:(CIImage*)ciImage completion:(void(^)(UIImage*))completion;


@end
