//
//  PostLibCollectionViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/07/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostLibCollectionViewCell.h"

@implementation PostLibCollectionViewCell

- (void) setAsset:(ALAsset *)asset
{
    _asset = asset;
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

@end
