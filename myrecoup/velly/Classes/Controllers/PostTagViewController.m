//
//  PostTagViewController.m
//  myrecoup
//
//  Created by aoponaopon on 2015/12/01.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostTagViewController.h"
#import "CommonUtil.h"

@interface PostTagViewController ()
@end

static NSString* const HomeCellIdentifier = @"HomeCell";

@implementation PostTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //nav
    self.navigationItem.titleView.alpha = 0;
    [self.navigationItem
     setTitleView:[CommonUtil
                   getNaviTitle:[NSString
                                 stringWithFormat:@"%@%@",@"#",self.HushTagName]]];
    [UIView animateWithDuration:1.2f animations:^{
        self.navigationItem.titleView.alpha = 0;
        self.navigationItem.titleView.alpha = 1;
    }];
    //nav
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//override
- (void)refreshPosts:(BOOL)refreshFlg sortedFlg:(BOOL)sortedFlg
{
    //[self.refreshControl beginRefreshing];
    
    if(sortedFlg){
        self.postManager = [PostManager new];
        [self.cv reloadData];
    }
    if(self.postManager == nil){
        self.postManager = [PostManager new];
    }
    if(refreshFlg){
        [self.refreshControl beginRefreshing];
    }
    
    // param : access_token / user / categories (id int複数可) / page / order_by ( r or p ) 投稿順 / 人気順
    //NSDictionary *params = @{ @"category_id" : @("test"), @"attribute_id" : @(1), @"page" : @(1),};
    NSDictionary *params;
    // おすすめ : categories : パラメタ指定なし
    
    params = @{ @"page" : @(1)};
    
    DLog(@"homeView loadPost : %@", params);
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:VYShowLoadingNotification object:self];
    
    NSString *aToken = [Configuration loadAccessToken];
    
    __weak typeof(self) weakSelf = self;
    
    [self.postManager reloadPostsByWord:params aToken:(NSString *)aToken Word:(NSString*)self.HushTagName Type:@"tag" block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:VYHideLoadingNotification object:self];
        if(refreshFlg){
            [self.refreshControl endRefreshing];
        }
        
        if (error) {
            DLog(@"error = %@", error);
            if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_AUTH]){
                // 401 エラー時 : アクセストークンがあれば、削除 -> logout
                NSString *aToken = [Configuration loadAccessToken];
                if(aToken){
                    // access_token等キーチェーン削除
                    [Configuration saveUserPid:nil];
                    [Configuration saveUserId:nil];
                    [Configuration saveEmail:nil];
                    [Configuration savePassword:nil];
                    [Configuration saveAccessToken:nil];
                    [Configuration saveTWAccessToken:nil];
                    [Configuration saveTWAccessTokenSecret:nil];
                    [Configuration saveFBAccessToken:nil];
                    [Configuration saveSettingFollow:nil];
                    [Configuration saveSettingGood:nil];
                    [Configuration saveSettingRanking:nil];
                    // 元画像の保存可否は端末単位で常に保持させておくので消さない
                    // [Configuration saveSettingPostSave:nil];
                    
                    // MagicalRecord削除
                    [User MR_truncateAll];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    
                    [self refreshPosts:NO sortedFlg:YES];
                }
                
            }else if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_TIMEOUT]){
                // 0 エラー時 : タイムアウト
                UIAlertView *alert = [[UIAlertView alloc]init];
                alert = [[UIAlertView alloc]
                         initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
            }
            
        }else{
            
            strongSelf.postPage = postPage;
            //[strongSelf.cv reloadData];
            strongSelf.canLoadMore = strongSelf.postManager.canLoadPostMore;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.cv reloadData];
                //[self.cv reloadSections:[NSIndexSet indexSetWithIndex:0]];
                //[self.cv reloadItemsAtIndexPaths:[self.cv indexPathsForVisibleItems]];
                [strongSelf.cv reloadData];
                //[self.cv setNeedsDisplay];
            });
            
        }
        
    }];
}

//override
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeCollectionViewCell *waterfallCell = [[collectionView
                                             dequeueReusableCellWithReuseIdentifier:HomeCellIdentifier
                                             forIndexPath:indexPath] initWithSubViews];
    
    waterfallCell.contentView.frame = waterfallCell.bounds;
    waterfallCell.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    Post *jPost = [self.postManager.posts objectAtIndex:(NSUInteger)indexPath.row];
    
    BOOL isSrvGood = NO;
    if([jPost.isGood isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
        isSrvGood = YES;
    }
    NSNumber *myUserPID = [Configuration loadUserPid];
    if(myUserPID){
        jPost.isGood = [self.postManager getIsMyGood:myUserPID postID:jPost.postID isSrvGood:isSrvGood loadingDate:jPost.loadingDate];
        jPost.cntGood = [self.postManager getMyGoodCnt:myUserPID postID:jPost.postID srvGoodCnt:jPost.cntGood loadingDate:jPost.loadingDate];
    }
    [waterfallCell configureCellForAppRecord: jPost];
    
    // 角丸へ
    waterfallCell.layer.cornerRadius = 5.0f;
    // はみだしを制御
    waterfallCell.clipsToBounds = true;
    
    //枠線の幅
    waterfallCell.layer.borderWidth = 0.4f;
    // 枠線の色
    waterfallCell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    // 領域外をマスクで切り取る設定をしない
    // これを解除すると、レイアウト崩れるか、、影が表示されない
    //waterfallCell.layer.masksToBounds = NO;
    // 影のかかる方向を指定する
    waterfallCell.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    // 影の透明度
    waterfallCell.layer.shadowOpacity = 0.7f;
    // 影の色
    waterfallCell.layer.shadowColor = [UIColor grayColor].CGColor;
    // ぼかしの量
    waterfallCell.layer.shadowRadius = 1.0f;
    
    // ユーザアイコンタップ時
    UITapGestureRecognizer *tapUserGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postUserTap:)];
    waterfallCell.postUserImageView.userInteractionEnabled = YES;
    [waterfallCell.postUserImageView addGestureRecognizer:tapUserGestureRecognizer];
    
    [waterfallCell.postUserNameBtn addTarget:self action:@selector(postUserAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [waterfallCell.postUserIdBtn addTarget:self action:@selector(postUserAction:event:) forControlEvents:UIControlEventTouchUpInside];
    
    // 投稿写真ボタンタップ時
    //[waterfallCell.postImageBtn addTarget:self action:@selector(postImgAction:event:) forControlEvents:UIControlEventTouchUpInside];
    //投稿写真ダブルタップ時
    UITapGestureRecognizer *doubletapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTappedimg:)];
    doubletapGestureRecognizer.numberOfTapsRequired = 2;
    [waterfallCell.postImageView addGestureRecognizer:doubletapGestureRecognizer];
    
    // 投稿写真タップ時
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImgTap:)];
    waterfallCell.postImageView.userInteractionEnabled = YES;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    // ダブルタップに失敗した時だけシングルタップとする
    [tapGestureRecognizer requireGestureRecognizerToFail:doubletapGestureRecognizer];
    
    [waterfallCell.postImageView addGestureRecognizer:tapGestureRecognizer];
    
    
    // いいねタップ時
    //    [waterfallCell.postGoodCnt addTarget:self action:@selector(postGoodAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [waterfallCell.postGoodBtn addTarget:self action:@selector(postGoodAction:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //comment tap
    waterfallCell.postCommentBtn.tag = (NSInteger)1838;
    [waterfallCell.postCommentBtn addTarget:self action:@selector(postImgAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [waterfallCell.PostGoodBtnOnImage addTarget:self action:@selector(postGoodAction:event:) forControlEvents:UIControlEventTouchUpInside];
    
    [self layoutGoodCntBtnOnImg:waterfallCell];
    
    
    if(self.postManager.posts && [self.postManager.posts count] > 0){
        
        NSUInteger indexRow = (NSUInteger)indexPath.row;
        
        //if( indexRow + 1 == [self.postManager.posts count] && self.canLoadMore && !_indicator.isAnimating){
        if( indexRow + 1 >= [self.postManager.posts count] && self.canLoadMore && !_indicator.isAnimating){
            
            [LoadingView showInView:self.view];
            self.cv.scrollEnabled = NO;
            // scroll position fix
            [self.cv setContentOffset:self.cv.contentOffset animated:NO];
            [super startIndicator];
            
            NSString *aToken = [Configuration loadAccessToken];
            
            NSDictionary *params;
            params = @{ @"page" : @(self.postManager.postPage)};
            __weak typeof(self) weakSelf = self;
            [self.postManager loadMorePostsByWord:params aToken:aToken Word:self.HushTagName Type:@"tag" block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if (error) {
                    DLog(@"error = %@", error);
                    [LoadingView dismiss];
                    strongSelf.cv.scrollEnabled = YES;
                    
                    if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_TIMEOUT]){
                        // 0 エラー時 : タイムアウト
                        UIAlertView *alert = [[UIAlertView alloc]init];
                        alert = [[UIAlertView alloc]
                                 initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                        [alert show];
                    }
                    
                }else{
                    strongSelf.postPage = postPage;
                    strongSelf.canLoadMore = strongSelf.postManager.canLoadPostMore;
                    double delayInSeconds = 0.3;    // 0.5
                    dispatch_time_t moreTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(moreTime, dispatch_get_main_queue(), ^(void){
                        [strongSelf.cv reloadData];
                        //[strongSelf.cv layoutIfNeeded];
                        [LoadingView dismiss];
                        strongSelf.cv.scrollEnabled = YES;
                    });
                }
                [super endIndicator];
                
            }];
            
        }
    }
    
    return waterfallCell;
    
}

///いいね数ボタンのレイアウト
- (void)layoutGoodCntBtnOnImg:(HomeCollectionViewCell *)cell {
    
    cell.goodCntBtnOnImg.frame = CGRectZero;
    cell.goodCntBtnOnImg.userInteractionEnabled = NO;
    cell.goodCntBtnOnImg.titleLabel.adjustsFontSizeToFitWidth = YES;
    cell.goodCntBtnOnImg.titleLabel.font = JPBFONT(13);
    [cell.goodCntBtnOnImg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cell.goodCntBtnOnImg.layer setShadowOpacity:0.4f];
    [cell.goodCntBtnOnImg.layer setShadowOffset:CGSizeMake(1, 1)];
    
    UIView *superView = [cell.goodCntBtnOnImg superview];
    [superView addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:cell.PostGoodBtnOnImage
                                                             attribute:NSLayoutAttributeTrailingMargin
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:cell.goodCntBtnOnImg
                                                             attribute:NSLayoutAttributeLeadingMargin
                                                            multiplier:1
                                                              constant:-15],
                                [NSLayoutConstraint constraintWithItem:cell.PostGoodBtnOnImage
                                                             attribute:NSLayoutAttributeCenterYWithinMargins
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:cell.goodCntBtnOnImg
                                                             attribute:NSLayoutAttributeCenterYWithinMargins
                                                            multiplier:1
                                                              constant:0],
                                ]];
    [cell.goodCntBtnOnImg setTranslatesAutoresizingMaskIntoConstraints:NO];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
