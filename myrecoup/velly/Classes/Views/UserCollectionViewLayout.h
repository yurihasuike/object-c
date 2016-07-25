//
//  UserCollectionViewLayout.h
//  velly
//
//  Created by m_saruwatari on 2015/05/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserCollectionViewLayout;

@protocol UserCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UserCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UserCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UserCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) IBOutlet id<UserCollectionViewDelegate> delegate;
@property (nonatomic) CGFloat itemWidth;

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) BOOL stickyHeader;

@end
