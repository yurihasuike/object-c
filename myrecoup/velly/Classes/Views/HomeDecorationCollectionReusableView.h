//
//  HomeDecorationCollectionReusableView.h
//  velly
//
//  Created by m_saruwatari on 2015/03/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeDecorationCollectionReusableView : UICollectionReusableView
{
    @private UIActivityIndicatorView *indicator;// インジケーター
}

+ (CGSize)defaultSize;

@end
