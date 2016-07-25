//
//  SearchViewController.m
//  myrecoup
//
//  Created by aoponaopon on 2015/12/11.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "SearchViewController.h"
#import "TextSearchResultViewController.h"
#import "TrackingManager.h"
#import "Defines.h"
#import "CategoryManager.h"
#import "PostManager.h"
#import "ChildCategoriesCollectionViewCell.h"
#import "ChildCategoriesCollectionHeaderView.h"
#import "Category.h"
#import "Post.h"
#import "CommonUtil.h"
#import "UIImageView+WebCache.h"


@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //検索バー
    [self configureSearchArea];
    
    //キーボードの表示・非表示時のイベントを登録
    [self registerForKeyboardNotifications];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.dummybtn];
    
    //子カテゴリ一覧を設置
    [self.view addSubview:self.catCollectionView];
    
    //検索履歴のtable viewを設置
    [self.view addSubview:self.searchResultTable];
}

#pragma mark UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView;
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        ChildCategoriesCollectionHeaderView *headerView = [collectionView
                                                           dequeueReusableSupplementaryViewOfKind:kind
                                                           withReuseIdentifier:@"collectionHeader"
                                                           forIndexPath:indexPath];
        [headerView.title setText:NSLocalizedString(@"SearchViewCategoryCollectionTitle", nil)];
        reusableView = headerView;
    }
    return reusableView;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [CategoryManager sharedManager].childCategoriesWithPost.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChildCategoriesCollectionViewCell *cell = [collectionView
                                               dequeueReusableCellWithReuseIdentifier:@"collectionCell"
                                               forIndexPath:indexPath];
    cell.layer.cornerRadius = 5.0f;
    cell.clipsToBounds = true;
    
    NSDictionary *data = [[CategoryManager sharedManager].childCategoriesWithPost objectAtIndex:indexPath.row];
    
    [cell.postImgView
     sd_setImageWithURL:[NSURL URLWithString:[CommonUtil getImgPath:(Post *)data[@"post"]]]
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
     }];
    
    [cell.categoryLabel setText:((Category_ *)data[@"category"]).label];
    
    NSString *countText = [NSString
                           stringWithFormat:@"%@%@",
                           [data[@"postcount"] stringValue],
                           NSLocalizedString(@"SearchViewCategoryPostCount", nil)];
    [cell.countLabel setText:countText];
    return cell;
}

///セルのサイズを返す(30は投稿数などのラベル)
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(CHTCollectionViewWaterfallLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    NSUInteger space = collectionViewLayout.minimumInteritemSpacing +
                       collectionViewLayout.sectionInset.left +
                       collectionViewLayout.sectionInset.right;
    
    CGFloat cellWidth = self.view.bounds.size.width - space;
    
    return CGSizeMake(cellWidth, cellWidth + 30);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *selected = [[CategoryManager sharedManager].childCategoriesWithPost objectAtIndex:indexPath.row];
    HomeViewController *homeView    = [[UIStoryboard storyboardWithName:@"Home" bundle:nil]
                                       instantiateViewControllerWithIdentifier:@"HomeViewController"];
    
    Category_ *cat = (Category_ *)selected[@"category"];
    homeView.categoryID = cat.pk;
    homeView.sortType = VLHOMESORTPOP;
    
    //navigation bar setting
    homeView.navigationItem.titleView = [CommonUtil getNaviTitle:cat.label];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    
    
    [self.navigationController pushViewController:homeView animated:YES];
}

#pragma mark CustomMethod(UICollectionView)

- (UICollectionView *)catCollectionView {
    if (!_catCollectionView) {
        
        CGFloat marginBottom = self.view.bounds.size.height / 6;
        
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        layout.columnCount = 2;
        layout.minimumColumnSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.headerHeight = 20;
        layout.headerInset = UIEdgeInsetsMake(10, 0, 0, 0);
        layout.sectionInset = UIEdgeInsetsMake(0, 5, marginBottom, 5);
        
        _catCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                collectionViewLayout:layout];
        [_catCollectionView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [_catCollectionView setDataSource:self];
        [_catCollectionView setDelegate:self];
        [_catCollectionView registerClass:[ChildCategoriesCollectionViewCell class]
            forCellWithReuseIdentifier:@"collectionCell"];
        [_catCollectionView registerClass:[ChildCategoriesCollectionHeaderView class]
               forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
                      withReuseIdentifier:@"collectionHeader"];
    }
    return _catCollectionView;
}

#pragma mark UITableView Delegate

//セクション数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

//セルの数をかえす
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //検索履歴のヘッダ
    if (section == 0) {
        return 1;
    }
    else{
       return [self.searchHistories count];
    }
    
}

//セルの内容を返す
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    //検索履歴のヘッダ
    if (indexPath.section == 0) {
        
        //ヘッダの他の部分をタップしたらdeleteall選択解除
        UITapGestureRecognizer *cancelDeleteAll = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelDeleteAll:)];
        [cell addGestureRecognizer:cancelDeleteAll];
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, cell.viewForBaselineLayout.bounds.size.height+1)];
        self.headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        //ヘッダのタイトル
        UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, self.headerView.bounds.size.width/4, self.headerView.bounds.size.height)];
        headerTitleLabel.text = @"最近の検索";
        headerTitleLabel.font = JPFONT(12);
        headerTitleLabel.textColor = [UIColor darkGrayColor];
        [self.headerView addSubview:headerTitleLabel];
        
        //全削除ボタン
        self.deleteAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.deleteAllBtn.layer.position = CGPointMake(self.headerView.bounds.size.width -25, self.headerView.bounds.size.height/2);
        [self.deleteAllBtn setImage:[UIImage imageNamed:@"ico_delete_all.png"] forState:UIControlStateNormal];
        self.deleteAllBtn.layer.cornerRadius = 10.0f;
        self.deleteAllBtn.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1.0];
        [self.deleteAllBtn addTarget:self action:@selector(deleteAllBefore:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.deleteAllBtn];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:self.headerView];
        
    }
    else{
        
        //検索履歴
        UIView *historyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
        
        //検索アイコン
        UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 18, 18)];
        searchIcon.image = [UIImage imageNamed:@"ico_search_gray.png"];
        [historyView addSubview:searchIcon];
        
        //履歴
        UILabel *history = [[UILabel alloc] initWithFrame:CGRectMake(37, 0, cell.bounds.size.width-24, cell.bounds.size.height-6)];
        history.text = self.searchHistories[indexPath.row];
        history.font = JPFONT(13);
        [historyView addSubview:history];
        
        [cell addSubview:historyView];
        
    }
    cell.clipsToBounds = YES;//frameサイズ外を描画しない
    return cell;
}

//セルがタップされたときに呼ばれる
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //選択状態の解除
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        return;
    }
    
    TextSearchResultViewController *textSearchResultViewController = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"TextSearchResultViewController"];
    textSearchResultViewController.searchWord = self.searchHistories[indexPath.row];
    
    //戻るボタンのタイトルをなくすために作り直し
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                                  initWithCustomView:backBtn];
    
    
    [UIView transitionFromView:self.view
                        toView:textSearchResultViewController.view
                      duration:0.1
                       options:UIViewAnimationOptionTransitionNone
                    completion:
     ^(BOOL finished) {
         [self.navigationController pushViewController:textSearchResultViewController animated:YES];
     }];
}

//編集可能なセルを指定
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        return NO;
    }
    
    return YES;
}
//削除処理
-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath{
    
    //削除のとき
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self deleteSearchHistories:NO indexPath:indexPath];
    }
}

//セルの高さを返す
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 45;
    }
    else{
        return 40;
    }
    
}


#pragma mark Custom Method (UITableView)

- (void)configureSearchArea
{
    //右にスペースを空けるためのダミー
    self.dummybtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 18, 1)];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.prompt = @"タイトル";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.barStyle = UIBarStyleBlackTranslucent;
    
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
    
    //タグの予測機能ができるまでの間検索窓の下に表示
    /*self.recommendLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/5)];
     self.recommendLabel.text = @"投稿を検索しよう";
     self.recommendLabel.textAlignment = UITextAlignmentCenter;
     self.recommendLabel.textColor = [UIColor darkGrayColor];
     [self.view addSubview:self.recommendLabel];
     */
}

- (UITableView *)searchResultTable
{
    if (!_searchResultTable) {
        //検索履歴のtable viewを設定
        _searchResultTable = [[UITableView alloc] initWithFrame:self.view.bounds];
        _searchResultTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        if ([_searchResultTable respondsToSelector:@selector(setSeparatorInset:)]) {
            [_searchResultTable setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([_searchResultTable respondsToSelector:@selector(layoutMargins)]) {
            _searchResultTable.layoutMargins = UIEdgeInsetsZero;
        }
        _searchResultTable.delegate = self;
        _searchResultTable.dataSource = self;
        _searchResultTable.tableFooterView = [[UIView alloc] init];
        _searchResultTable.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _searchResultTable.hidden = YES;
    }
    return _searchResultTable;
}

//全削除ボタンを実行可能状態へ変える
-(void)deleteAllBefore:(UIButton*)button{
    
    [UIView animateWithDuration:0.15f animations:^{
        [self.deleteAllBtn setImage:nil forState:UIControlStateNormal];
        self.deleteAllBtn.layer.cornerRadius = 8.0f;
        [self.deleteAllBtn setFrame:CGRectMake(0, 0, 35, 21)];
        self.deleteAllBtn.layer.position = CGPointMake(self.headerView.bounds.size.width -30, self.headerView.bounds.size.height/2);
        [self.deleteAllBtn setTitle:@"消去" forState:UIControlStateNormal];
        self.deleteAllBtn.font = JPBFONT(12);
    }];
    
    
    [self.deleteAllBtn removeTarget:self action:@selector(deleteAllBefore:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteAllBtn addTarget:self action:@selector(deleteAllAfter:) forControlEvents:UIControlEventTouchUpInside];
    
}

//全削除も行う
-(void)deleteAllAfter:(UIButton*)button{
    
    //全削除ボタンを戻す
    [self backToDeleteBefore];
    
    //全削除
    //検索履歴のsectionでrowは先頭の0を渡す。
    NSIndexPath *sectionOfHistories = [NSIndexPath indexPathForRow:0 inSection:1];
    [self deleteSearchHistories:YES indexPath:sectionOfHistories];
    [self changeTarget];
    
}
- (void)changeTarget
{
    [self.deleteAllBtn removeTarget:self action:@selector(deleteAllAfter:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteAllBtn addTarget:self action:@selector(deleteAllBefore:) forControlEvents:UIControlEventTouchUpInside];
}

//全削除ボタンを戻す
-(void)backToDeleteBefore
{
    
    [UIView animateWithDuration:0.15f animations:^{
        [self.deleteAllBtn setTitle:@"" forState:UIControlStateNormal];
        self.deleteAllBtn.layer.cornerRadius = 10.0f;
        [self.deleteAllBtn setFrame:CGRectMake(0, 0, 20, 20)];
        self.deleteAllBtn.layer.position = CGPointMake(self.headerView.bounds.size.width -25, self.headerView.bounds.size.height/2);
        [self.deleteAllBtn setImage:[UIImage imageNamed:@"ico_delete_all.png"] forState:UIControlStateNormal];
    }];
}
//他のところをタップするとキャンセル
-(void)cancelDeleteAll:(UITapGestureRecognizer *)tapGesture
{
    [self backToDeleteBefore];
    [self changeTarget];
}

//検索履歴を表示
- (void)setSearchHistory
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.searchHistories = [userDefaults arrayForKey:@"search_histories"];
    if (!self.searchHistories) {
        self.searchHistories = [[NSArray alloc] init];
    }
    [self.searchResultTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    //戻るの矢印色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //navi bar のタイトルへ
    self.navigationItem.titleView = self.searchBar;
    
    [self setSearchHistory];
}
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



- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
}

//検索履歴を削除
- (void)deleteSearchHistories:(BOOL)deleteAll indexPath:(NSIndexPath*)indexPath
{
    NSMutableArray *storedHistories = [self.searchHistories mutableCopy];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //全削除
    if (deleteAll) {
        
        NSUInteger historyCount = [storedHistories count];
        
        //削除&保存
        for (int row = 0; row < historyCount; row ++) {
            
            //戦闘から順に削除していく
            [storedHistories removeObjectAtIndex:0];
                
            //削除してからtableviewのデータ元を更新
            NSArray *storeHistories = [storedHistories copy];
                
            self.searchHistories = storedHistories;
            [userDefaults setObject:storeHistories forKey:@"search_histories"];
            
            if ([userDefaults synchronize]) {
                //セル削除。先頭を削除すれば良いから常に同じ
                [self.searchResultTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            }
            
        }
    
    }
    else{
        
        //ひとつだけ削除
        [storedHistories removeObjectAtIndex:indexPath.row];
        
        //削除してからtableviewのデータ元を更新
        NSArray *storeHistories = [storedHistories copy];
        self.searchHistories = storedHistories;
        
        //保存
        [userDefaults setObject:storeHistories forKey:@"search_histories"];
        
        if ([userDefaults synchronize]) {
        
            //セル更新
            [self.searchResultTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
        }
    }
    
}

//検索履歴を保存
-(void)saveSearchHistrories:(UISearchBar*)searchBar
{
    //すでに保存されている情報を取得し重複しなければ追加し再保存
    NSMutableArray *storedHistories = [self.searchHistories mutableCopy];
    
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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:storeHistories forKey:@"search_histories"];
    
    if ([userDefaults synchronize]) {
        //更新成功
    }
}

#pragma mark CustomMethod(Common)
///カテゴリを表示
- (void)switchToCategory {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.searchResultTable.alpha = 0;
                         self.catCollectionView.alpha = 1;
                     } completion:^(BOOL finished) {
                         self.searchResultTable.hidden = YES;
                         self.catCollectionView.hidden = NO;
                     }];
}
///検索履歴を表示
- (void)switchToSearchHistory {
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.searchResultTable.alpha = 1;
                         self.catCollectionView.alpha = 0;
                     } completion:^(BOOL finished) {
                         self.searchResultTable.hidden = NO;
                         self.catCollectionView.hidden = YES;
                     }];
}

#pragma mark UISearchBar Delegate

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
    //検索履歴を表示
    [self switchToSearchHistory];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    //カテゴリを表示
    [self switchToCategory];
    return YES;
}

//検索ボタンが押された時に呼ばれる
-(void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    
    // ---------------------------------------
    // GA EVENT
    // ---------------------------------------
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"tapSubmit" value:nil screen:@"SearchPost"];
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[SEARCHBUTTONTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[WORD] : searchBar.text}];
    
    //検索履歴を保存
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
