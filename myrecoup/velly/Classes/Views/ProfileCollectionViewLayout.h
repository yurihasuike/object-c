//
//  ProfileCollectionViewLayout.h
//  velly
//
//  Created by m_saruwatari on 2015/03/14.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileCollectionViewLayout;

@protocol ProfileCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(ProfileCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(ProfileCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ProfileCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) IBOutlet id<ProfileCollectionViewDelegate> delegate;
@property (nonatomic) CGFloat itemWidth;

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) BOOL stickyHeader;

@end
