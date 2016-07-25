//
//  PostUpdateViewController.m
//  myrecoup
//
//  Created by aoponaopon on 2016/03/14.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import "PostUpdateViewController.h"
#import "PostUpdateImageTableViewCell.h"
#import "PostUpdateCategoryTableViewCell.h"
#import "PostUpdateBodyTableViewCell.h"
#import "PostCategoryTableViewController.h"
#import "UIImageView+WebCache.h"
#import "PostClient.h"
#import "Configuration.h"
#import "SVProgressHUD.h"
#import "CategoryManager.h"
#import "PostChildCategoryTableViewController.h"
#import "CommonUtil.h"

@interface PostUpdateViewController ()
@end

@implementation PostUpdateViewController

- (id) initWithPost:(Post*)post {
    
    if(!self) {
        self = [[PostUpdateViewController alloc] init];
    }
    self.post = post;
    self.isMovie = [self checkPostType];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //下の余白
    self.bottomMargin = self.view.bounds.size.height + 50;
    
    [self configureNavigation];
    
    [self setTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // キーボード表示・非表示時のイベント登録
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    //入力モードへ
    if (self.postUpdateBodyTextView) {
        [self makeUserInputMode:self.postUpdateBodyTextView];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    // キーボード表示・非表示時のイベント削除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//キーボードが上がった時TextViewが隠れないようにする.
- (void)keyboardWillShown:(NSNotification *)notification {
    
    if (self.postUpdateBodyTextView) {
        
        
        
        NSDictionary *info  = [notification userInfo];
        CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGPoint scrollPoint = CGPointMake(0.0f, keyboardSize.height);
        
        //余白も余分に設ける
        UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, keyboardSize.height + self.bottomMargin, 0);
        self.postUpdateBaseView.contentInset = inset;
        self.postUpdateBaseView.scrollIndicatorInsets = inset;
        
        //必要な分だけ上にスクロール
        [self.postUpdateBaseView setContentOffset:scrollPoint animated:YES];
    }
}

//キーボードが下がった時元に戻す
- (void)keyboardWillHidden:(NSNotification *)notification {
    
    //余白を元に戻す
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, self.bottomMargin, 0);
    self.postUpdateBaseView.contentInset = inset;
    self.postUpdateBaseView.scrollIndicatorInsets = inset;
    [self.postUpdateBaseView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    
}

- (void)configureNavigation {
    
    //保存ボタン
    UIBarButtonItem * compBtn = [[UIBarButtonItem alloc]
                                 initWithTitle:NSLocalizedString(@"Save", nil)
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = compBtn;
    
    // ナビゲーションタイトル
    self.navigationItem.titleView = [CommonUtil getNaviTitle:NSLocalizedString(@"PostUpdateTitle", nil)];
    self.navigationItem.titleView.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
}

- (void)setTableView {
    self.postUpdateBaseView = [[UIScrollView alloc]
                               initWithFrame:CGRectMake(0,0,
                                                        self.view.bounds.size.width,
                                                        self.view.bounds.size.height)];
    //下に少し余白を設ける
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, self.bottomMargin, 0);
    self.postUpdateBaseView.contentInset = insets;
    self.postUpdateBaseView.scrollIndicatorInsets = insets;
    
    self.postTableView = [[UITableView alloc]
                          initWithFrame:CGRectMake(0,0,
                                                   self.postUpdateBaseView.bounds.size.width,
                                                   self.postUpdateBaseView.bounds.size.height)];
    self.postTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.postTableView setTableFooterView:[[UIView alloc] init]];
    if ([self.postTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.postTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.postTableView respondsToSelector:@selector(layoutMargins)]) {
        self.postTableView.layoutMargins = UIEdgeInsetsZero;
    }
    self.postTableView.delegate = self;
    self.postTableView.dataSource = self;
    
    [self.postTableView registerClass:[PostUpdateImageTableViewCell class]
               forCellReuseIdentifier:@"imageViewCell"];
    [self.postTableView registerClass:[PostUpdateCategoryTableViewCell class]
               forCellReuseIdentifier:@"categoryViewCell"];
    [self.postTableView registerClass:[PostUpdateBodyTableViewCell class]
               forCellReuseIdentifier:@"bodyViewCell"];
    [self.postUpdateBaseView addSubview:self.postTableView];
    [self.view addSubview:self.postUpdateBaseView];
}

#pragma mark TableView data source
//セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

//セクションあたりのセル数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 2;
    }
    return 1;
}

//セルの内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        //画像section
        
        //cellの初期化.
        PostUpdateImageTableViewCell *postUpdateImageTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"imageViewCell"];
        
        //画像のFrame.
        [postUpdateImageTableViewCell.postImageView
         setFrame:CGRectMake(0,
                             0,
                             self.view.bounds.size.width,
                             [self calcImageViewCellHeight:self.post])];
        //画像セット.
        [postUpdateImageTableViewCell.postImageView
         sd_setImageWithURL:[NSURL URLWithString:[self getImageUrlStr:self.post]]
         placeholderImage:nil
         options:SDWebImageCacheMemoryOnly
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
             if (error) {
                 [postUpdateImageTableViewCell.postImageView setImage:[[UIImage alloc] initWithData:
                                                                       [NSData dataWithContentsOfURL:
                                                                        [NSURL URLWithString:
                                                                         [self getImageUrlStr:self.post]]]]];
             }
             else{
                 [postUpdateImageTableViewCell.postImageView setImage:image];
                 if(cacheType == SDImageCacheTypeMemory){
                     postUpdateImageTableViewCell.postImageView.alpha = 1;
                 }else{
                     [UIView animateWithDuration:0.4f animations:^{
                         postUpdateImageTableViewCell.postImageView.alpha = 0;
                         postUpdateImageTableViewCell.postImageView.alpha = 1;
                     }];
                 }
             }
         }];
        return postUpdateImageTableViewCell;

    }else if (indexPath.section == 1){
        //categoryのsection
        
        //cellの初期化.
        PostUpdateCategoryTableViewCell *postUpdateCategoryTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"categoryViewCell"];

        
        
        if (indexPath.row == 0) {
        //親カテゴリ
            [postUpdateCategoryTableViewCell.categoryNameLabel setText:self.parent.label];
        }else if(indexPath.row == 1){
        //子カテゴリ
            if (self.child &&
                [self.child.parent.pk isEqualToNumber:self.parent.pk]) {
                [postUpdateCategoryTableViewCell.categoryNameLabel setText:self.child.label];
            }else{
                [postUpdateCategoryTableViewCell.categoryNameLabel
                 setText:NSLocalizedString(@"childCategorySelect", nil)];
                self.child = nil;
            }
            if ([self canNotSelectChild]) {
                [postUpdateCategoryTableViewCell.categoryView setAlpha:0.5f];
            }else{
                [postUpdateCategoryTableViewCell.categoryView setAlpha:1.0f];
            }
        }
        
        return postUpdateCategoryTableViewCell;
        
        
    }else if (indexPath.section == 2){
        //bodyのsection
        
        //cellの初期化.
        PostUpdateBodyTableViewCell *postUpdateBodyTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"bodyViewCell"];
        postUpdateBodyTableViewCell.bodyTextView.text = self.post.descrip;
        
        //入力モードへ
        if (!self.postUpdateBodyTextView) {
            [self makeUserInputMode:postUpdateBodyTableViewCell.bodyTextView];
        }
        //キーボードが上がった時ようにglobalにしておく
        self.postUpdateBodyTextView = postUpdateBodyTableViewCell.bodyTextView;
        
        return postUpdateBodyTableViewCell;
    }
    
    [self.postTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.clipsToBounds = YES;//frameサイズ外を描画しない
    return cell;
}


//セルの高さ
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
    //投稿画像のCell
        if(self.post && [self.post.postID isKindOfClass:[NSNumber class]]){
            
            return [self calcImageViewCellHeight:self.post];
        }
        return 0;
    }else if (indexPath.section == 1){
    //投稿カテゴリのCell
        return 50.0;
    }else if (indexPath.section == 2){
    //投稿詳細のCell
        return 120.0;
    }
    return 50.0;
}

#pragma mark TableView delegate

//セルがタップされたときに呼ばれる
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //選択状態の解除
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
    //カテゴリー選択.
        if (indexPath.row == 0) {
        //親カテゴリ選択
            PostCategoryTableViewController * postCategoryTableViewController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"PostCategoryTableViewController"];
            self.post.descrip = self.postUpdateBodyTextView.text;
            postCategoryTableViewController.postUpdateViewController = self;
            [self.navigationController pushViewController:postCategoryTableViewController animated:YES];
        
        }else if (indexPath.row == 1) {
        //子カテゴリ選択
            if (self.parent && self.parent.children.count) {
                PostChildCategoryTableViewController *pcctv = [[PostChildCategoryTableViewController alloc]
                                                               initWithArgs:self parent:self.parent];
                [self.navigationController pushViewController:pcctv animated:YES];
            }
        }
    }
}

#pragma mark custom method

///子供カテゴリを選択できなければYES
- (BOOL)canNotSelectChild{
    return (!self.parent || !self.parent.children.count);
}

///子カテゴリが存在すれば子カテゴリを返す(最終的にPOSTするカテゴリ)
- (Category_ *)category {
    _category = (self.child)? self.child : self.parent;
    return _category;
}

///親カテゴリが存在しなければポストから取得
- (Category_ *)parent {
    if (!_parent) {
        Category_ *category = [[CategoryManager sharedManager] getCategoryByPost:self.post];
        
        if (!category.isRoot) {
            self.child = category;
            _parent = [[CategoryManager sharedManager] getParentByChild:category];
        }else{
            _parent = category;
        }
    }
    return _parent;
}

//投稿画像の高さを取得
- (CGFloat)calcImageViewCellHeight:(Post *)post
{
    if(post.originalWidth.intValue == 0){
        return 300;
    }
    
#if CGFLOAT_IS_DOUBLE
    CGFloat postImageWidth  = [post.originalWidth doubleValue];
    CGFloat postImageHeight = [post.originalHeight doubleValue];
#else
    CGFloat postImageWidth  = [post.originalWidth floatValue];
    CGFloat postImageHeight = [post.originalHeight floatValue];
#endif
    
    float scale = [[UIScreen mainScreen] applicationFrame].size.width / postImageWidth;
    CGFloat resizeHeight = postImageHeight * scale;
    return resizeHeight;
}

//投稿画像URLを取得
-(NSString *)getImageUrlStr:(Post *)post
{
    NSString *imageUrlStr;
    if (self.isMovie) {
        imageUrlStr = post.thumbnailPath;
    }else{
        imageUrlStr = post.originalPath;
    }
    return imageUrlStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//更新完了アクション
- (void)saveAction:(UIButton*)sender {

    if ([self validateBody]) {
        
        self.post.descrip = self.postUpdateBodyTextView.text;
        
        NSMutableDictionary * params = [NSMutableDictionary dictionary];
        params[@"body"] = (NSString * ) self.post.descrip;
        params[@"category"] = [self.category.pk stringValue];
        
        [[PostClient sharedClient] updatePost:[self.post.postID stringValue]
                                       params:params
                                       aToken:[Configuration loadAccessToken]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          
                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                          
                                          //メッセージ
                                          [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgDoActionPostUpdateComp", nil)];
                                          
                                      } failed:^(AFHTTPRequestOperation *operation, NSMutableDictionary *responseBody, NSError *error) {
                                          
                                          
                                          NSNumber *resultCode = [NSNumber numberWithInteger:operation.response.statusCode];
                                          DLog(@"body==%@¥n", responseBody);
                                          DLog(@"result==%@¥n",resultCode);
                                          
                                          
                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                          
                                          //メッセージ
                                          [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"MsgDoActionPostUpdateFaild", nil)];
                                      }];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
}

//文字数と行数をチェック
- (NSString *)checkInputData {
    
    __block NSUInteger inputCnt = 0;
    NSRange allGlyphs = [self.postUpdateBodyTextView.layoutManager glyphRangeForTextContainer:self.postUpdateBodyTextView.textContainer];
    [self.postUpdateBodyTextView.layoutManager enumerateLineFragmentsForGlyphRange:allGlyphs
                                                             usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop) {
                                                                 inputCnt++;
                                                             }];
    
    if (self.postUpdateBodyTextView.text.length && self.postUpdateBodyTextView.text.length > 150) {
        // 150 over error
                return NSLocalizedString(@"ValidatePostMaxOverDescrip", nil);
    }else if (inputCnt > 5){
        // line 5 over error
                return NSLocalizedString(@"ValidatePostLineMaxOverDescrip", nil);
    }

    return nil;
}

//バリデーション
- (BOOL)validateBody {
    
    NSString * errMsg = [self checkInputData];
    if (errMsg != nil) {
        UIAlertView *alert = [[UIAlertView alloc]init];
        alert = [[UIAlertView alloc]
                 initWithTitle:errMsg message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
    
}

//キーボードをあげて入力モードにする
- (void)makeUserInputMode:(UITextView*)textView {
    [textView becomeFirstResponder];
}

//動画ならYESを返す
- (BOOL)checkPostType {
    return ([self.post.originalPath hasSuffix:@".mov"] || [self.post.originalPath hasSuffix:@".mp4"]);
}


@end
