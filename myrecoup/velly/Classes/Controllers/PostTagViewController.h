//
//  PostTagViewController.h
//  myrecoup
//
//  Created by aoponaopon on 2015/12/01.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "ConfigLoader.h"
#import "UserManager.h"
#import "SVProgressHUD.h"
#import "HomeCollectionViewCell.h"
#import "LoadingView.h"

@interface PostTagViewController : HomeViewController

@property (nonatomic) NSUInteger *postPage;
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic) NSString *HushTagName;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

- (void)refreshPosts:(BOOL)refreshFlg sortedFlg:(BOOL)sortedFlg;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end
