//
//  PostLibCollectionViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/07/01.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostLibCollectionViewController.h"
#import "PostLibCollectionViewCell.h"
#import "VYNotification.h"
#import "CommonUtil.h"

@interface PostLibCollectionViewController () <UINavigationControllerDelegate>
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *assets;
@end

@implementation PostLibCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [CommonUtil getNaviTitle:NSLocalizedString(@"NavTabPostLib", nil)];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    else {
        // ios6
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VYShowModalLoadingNotification object:self];
    
    ALAssetsLibrary *assetsLibrary = [PostLibCollectionViewController defaultAssetsLibrary];
    //[assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if(group){
            
            // 画像のみに絞り込み
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            // カメラロールの写真一覧を取得
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    //NSLog(@"Data: %@", result);
                    // リストに追加
                    [tmpAssets addObject:result];
                }
            }];
        
            // ソートする
          [tmpAssets sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(ALAsset *a, ALAsset *b) {
              NSDate *datea = [a valueForProperty:ALAssetPropertyDate];
              NSDate *dateb = [b valueForProperty:ALAssetPropertyDate];
              return [dateb compare:datea];
          }];
            self.assets = tmpAssets;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:VYHideModalLoadingNotification object:self];
        
        // 表示
        [self.collectionView reloadData];
    }
    failureBlock:^(NSError *error) {
        DLog(@"Error loading images %@", error);
    }];


}

#pragma -
#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostLibCollectionViewCell *cell = (PostLibCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PostLibCollectionViewCell" forIndexPath:indexPath];
    
    ALAsset *asset = self.assets[indexPath.row];
    cell.asset = asset;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

#pragma -
#pragma mark - collection view delegate

// セルがタップされた場合
- (void) collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ALAsset *asset = self.assets[indexPath.row];
    ALAssetRepresentation *defaultRep = [asset defaultRepresentation];
    UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage]
                                         scale:[defaultRep scale] orientation:0];
    
    // 選択された画像
    DLog(@"[%d]%@", (int)indexPath.row, image.description);
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromTop;  // kCATransitionFromLeft kCATransitionFromTop
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
    if(self.postViewController){
        self.postViewController.cameraImage = image;
    }
    
//    double delayInSeconds = 0.4;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        //done 0.4 seconds after.
//        [self.postViewController postEffectActionImage:image];
//    });
    
}

#pragma -
#pragma mark - assets

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


@end
