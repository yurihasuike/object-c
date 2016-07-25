//
//  ProfileDecorationCollectionReusableView.h
//  velly
//
//  Created by m_saruwatari on 2015/04/01.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileDecorationCollectionReusableView : UICollectionReusableView
{
    @private UIActivityIndicatorView *indicator;// インジケーター
}

+ (CGSize)defaultSize;

@end
