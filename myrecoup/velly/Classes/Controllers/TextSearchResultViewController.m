//
//  TextSearchResultViewController.m
//  myrecoup
//
//  Created by aoponaopon on 2015/12/11.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "TextSearchResultViewController.h"
#import "TrackingManager.h"

@interface TextSearchResultViewController ()

@end

static NSString* const HomeCellIdentifier = @"HomeCell";

@implementation TextSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureSearchArea];
    //キーボードの表示・非表示時のイベントを登録
    [self registerForKeyboardNotifications];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.dummybtn];
    DLog("TextSearchResultViewController");
}
- (void)viewWillAppear:(BOOL)animated
{
    //navi bar のタイトルへ
    self.navigationItem.titleView = self.searchBar;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureSearchArea
{
    //右にスペースを空けるためのダミー
    self.dummybtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 18, 1)];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.prompt = @"タイトル";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.barStyle = UIBarStyleBlackTranslucent;
    self.searchBar.text = self.searchWord;
    
    self.navigationItem.titleView.backgroundColor = [UIColor clearColor];
    
    for (UIView *subView in self.searchBar.subviews) {
        for (UIView *secondSubview in subView.subviews){
            if ([secondSubview isKindOfClass:[UITextField class]]) {
                UITextField *searchBarTextField = (UITextField *)secondSubview;
                
                //ここで検索テキストフィールドの設定をする
                searchBarTextField.backgroundColor = [UIColor whiteColor];
                searchBarTextField.textColor = [UIColor darkGrayColor];
                searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"検索" attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
                searchBarTextField.tintColor = [UIColor darkGrayColor];
                break;
            }
        }
    }
    
    //検索結果が0件の場合に表示
    self.noPostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/5)];
    self.noPostLabel.hidden = YES;
    self.noPostLabel.text = @"0件の検索結果";
    self.noPostLabel.textAlignment = NSTextAlignmentCenter;
    self.noPostLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:self.noPostLabel];
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
    
    [self.postManager reloadPostsByWord:params aToken:(NSString *)aToken Word:(NSString*)self.searchWord Type:@"word" block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
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
            
            //検索結果が0件の場合
            if([posts count] == 0){
                self.noPostLabel.hidden = NO;
            }
            else{
                self.noPostLabel.hidden = YES;
            }
            
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
            [self.postManager loadMorePostsByWord:params aToken:aToken Word:self.searchWord Type:@"word" block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
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

//search bar delegate

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWasShown:(NSNotification*)aNotification
{
}

//検索フィールドにフォーカスが当てられたら呼ばれる
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    //右スペースなくす
    self.navigationItem.rightBarButtonItem = nil;
    
    //戻るボタン消去
    [self.navigationItem setHidesBackButton:YES];
    //キャンセルボタン表示
    self.searchBar.showsCancelButton = YES;
    //サイズ調整
    [self.searchBar sizeToFit];
    
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
}

//検索ボタンが押された時に呼ばれる
-(void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    // ---------------------------------------
    // GA EVENT
    // ---------------------------------------
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapSubmit" value:nil screen:@"SearchPost"];
    
    [self saveSearchHistrories:searchBar];
    
    TextSearchResultViewController *textSearchResultView = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"TextSearchResultViewController"];
    textSearchResultView.searchWord = searchBar.text;
    
    //戻るボタンのタイトルをなくすために作り直し
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    
    [UIView transitionFromView:self.view
                        toView:textSearchResultView.view
                      duration:0.1
                       options:UIViewAnimationOptionTransitionNone
                    completion:
     ^(BOOL finished) {
         [self.navigationController pushViewController:textSearchResultView animated:YES];
     }];
    
}
//検索履歴を保存
-(void)saveSearchHistrories:(UISearchBar*)searchBar
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *searchHistories = [userDefaults arrayForKey:@"search_histories"];
    
    //すでに保存されている情報を取得し重複しなければ追加し再保存
    NSMutableArray *storedHistories = [searchHistories mutableCopy];
    
    //重複すれば保存しない
    if ([storedHistories containsObject:searchBar.text]) {
        return;
    }
    
    //最初に挿入
    [storedHistories insertObject:searchBar.text atIndex:0];
    
    //15個以上なら古いものを削除
    if ([storedHistories count] > 15) {
        [storedHistories removeLastObject];
    }
    
    NSArray *storeHistories = [storedHistories copy];
    
    [userDefaults setObject:storeHistories forKey:@"search_histories"];
    if ([userDefaults synchronize]) {
        //保存成功
    }
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


#pragma mark Search Bar Delegate

//キャンセルボタンが押されたら呼ばれる
-(void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    
    //右スペース
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.dummybtn];
    //戻るボタン表示
    [self.navigationItem setHidesBackButton:NO];
    //キャンセルボタンなくす
    self.searchBar.showsCancelButton = NO;
    //フォーカスはずす
    [self.searchBar resignFirstResponder];
    
    
}
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
    
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
