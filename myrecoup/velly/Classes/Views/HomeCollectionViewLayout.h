//
//  HomeCollectionViewLayout.h
//  velly
//
//  Created by m_saruwatari on 2015/03/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeCollectionViewLayout;

@protocol HomeCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(HomeCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;


@optional

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(HomeCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(HomeCollectionViewLayout *)collectionViewLayout
heightForFooterAtIndexPath:(NSIndexPath *)indexPath;


//- (CGSize) collectionView:(UICollectionView *)collectionView
//                  layout:(HomeCollectionViewLayout*)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface HomeCollectionViewLayout : UICollectionViewLayout //<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet id<HomeCollectionViewDelegate> delegate;
@property (nonatomic) CGFloat itemWidth;

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) BOOL stickyHeader;

@end
