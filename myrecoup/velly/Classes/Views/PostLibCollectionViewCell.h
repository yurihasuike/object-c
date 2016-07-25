//
//  PostLibCollectionViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/07/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PostLibCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;


@property(nonatomic, strong) ALAsset *asset;
@end
