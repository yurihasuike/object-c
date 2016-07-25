//
//  DetailPageViewController.m
//  myrecoup
//
//  Created by aoponaopon on 2016/03/26.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import "DetailPageViewController.h"
#import "DetailViewController.h"
#import "HomeViewController.h"
#import "TextSearchResultViewController.h"
#import "PostTagViewController.h"
#import "Configuration.h"
#import "CommonUtil.h"
#import "LoadingView.h"

#define HOME 0
#define SEARCH_TEXT 1
#define SEARCH_TAG 2

NSString * const formatPostSortType_toString[];
NSString * const formatPostSortType_toString[] = {
    [VLHOMESORTNEW]    = @"r",      // 新着
    [VLHOMESORTPOP]    = @"p"       // 人気
};

@interface DetailPageViewController ()

@end

@implementation DetailPageViewController

- (id)initWithParentAndTappedPost:(UIViewController * )parentViewController tappedPost:(Post * )tappedPost {
    if (self = [[DetailPageViewController alloc] init]) {
        self.parent = parentViewController;
        if ([self.parent isKindOfClass:[TextSearchResultViewController class]]) {
            self.parentClass = SEARCH_TEXT;
        }else if ([self.parent isKindOfClass:[PostTagViewController class]]) {
            self.parentClass = SEARCH_TAG;
        }else if ([self.parent isKindOfClass:[HomeViewController class]]) {
            self.parentClass = HOME;
        }
        self.tappedPost = tappedPost;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setPostManager];
    [self setSortVal];
    [self setCategoryID];
    [self setPageView];
    [self setArrow];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPageViewControllerDataSource

///次のページをめくった時
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((DetailViewController * )viewController).pageViewIndex;
    if (index == NSNotFound) {
        return nil;
    }
    if (index == [self.postManager.posts indexOfObject:[self.postManager.posts lastObject]]) {
        if (self.parentClass == SEARCH_TEXT) {
            [self loadMoreTextSearchPosts:index];
        }else if (self.parentClass == SEARCH_TAG) {
            [self loadMoreTagSearchPosts:index];
        }else if (self.parentClass == HOME) {
            [self loadMoreHomePosts:index];
        }
        return nil;
    }
    index ++;
    return [self getDetailViewNeeded:index];
}

///前のページをめくった時
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((DetailViewController * )viewController).pageViewIndex;
    if (index == NSNotFound || index == 0) {
        return nil;
    }
    index --;
    return [self getDetailViewNeeded:index];
}

#pragma mark UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {

    NSUInteger nextIndex = ((DetailViewController*)pendingViewControllers[0]).pageViewIndex;
    
    //キャッシュ削除のため
    [self.pageView setViewControllers:@[[self getDetailViewNeeded:nextIndex]]
                            direction:UIPageViewControllerNavigationDirectionForward
                             animated:NO
                           completion:nil];
}
- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    //次or前に移動しようとしかけてしなかった時は上の関数で次の投稿が入ってしまっているので元の投稿を入れ直す.
    if (!completed && finished) {
        [self doTaskSynchronously:^{
            NSUInteger currentIndex = ((DetailViewController*)previousViewControllers[0]).pageViewIndex;
            [self.pageView setViewControllers:@[[self getDetailViewNeeded:currentIndex]]
                                    direction:UIPageViewControllerNavigationDirectionForward
                                     animated:NO
                                   completion:nil];
        }];
    }
    if (completed) {
    //矢印のコントロール
        [self controlArrows];
    }
}
#pragma mark CustomMethod

///pageviewをセット.
- (void)setPageView {

    self.pageView = [[UIPageViewController alloc]
                     initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                     navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                     options:nil];
    
    self.pageView.dataSource = self;
    self.pageView.delegate = self;
    
    NSUInteger index = [self.postManager.posts indexOfObject:self.tappedPost];
    DetailViewController * firstDetailView = [self getDetailViewNeeded:index];
    if (self.fromTag) firstDetailView.fromtag = self.fromTag;
    [self.pageView setViewControllers:@[firstDetailView]
                            direction:UIPageViewControllerNavigationDirectionForward
                             animated:YES
                           completion:nil];
    [self addChildViewController:self.pageView];
    [self.view addSubview:self.pageView.view];
    [self.pageView didMoveToParentViewController:self];
}
///指定indexの投稿詳細ページを返す.
- (DetailViewController * )getDetailViewNeeded:(NSUInteger)index {
    
    DetailViewController * detailView = [[UIStoryboard storyboardWithName:@"Home" bundle:nil]
                                         instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    Post * post = [self.postManager.posts objectAtIndex:index];
    
    detailView.post = post;
    detailView.postID = post.postID;
    [detailView loadPost];
    detailView.pageViewIndex = index;
    detailView.parentView = self;
    if (post.isMovie) {
        NSData * imageData = [[NSData alloc]
                              initWithContentsOfURL:
                              [NSURL URLWithString:
                               post.thumbnailPath]];
        UIImage * image = [UIImage imageWithData: imageData];
        detailView.postImageTempView = [[UIImageView alloc] initWithImage:image];
    }
    
    return detailView;
}
///投稿をさらに読みこむ(Homeの場合).
- (void)loadMoreHomePosts:(NSUInteger)index {
    
    [LoadingView showInView:self.view];
    
    //Homeの投稿も同期
    [((HomeViewController * )self.parent).cv reloadData];
    
    NSString *aToken = [Configuration loadAccessToken];
    NSDictionary *params;
    if(self.categoryID && [self.categoryID isKindOfClass:[NSNumber class]] && ![self isAllOrFollowCategory]){
        params = @{ @"categories" : self.categoryID,
                    @"page" : @(self.postManager.postPage),
                    @"order_by" : self.sortVal, };
    }else{
        params = @{ @"page" : @(self.postManager.postPage),
                    @"order_by" : self.sortVal,
                    @"following" : @([self isFollowCategory])};
    }
    __weak typeof(self) weakSelf = self;
    [self.postManager loadMorePostsWithParams:params aToken:aToken block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            DLog(@"error = %@", error);
            [LoadingView dismiss];
            if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_TIMEOUT]){
                [self timeOutErrorAction];
            }
        }else{
            [CommonUtil delay:0.3 block:^{
                [strongSelf.pageView setViewControllers:@[[self getDetailViewNeeded:index]]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:nil];
                [LoadingView dismiss];
            }];
        }
        
    }];
}
///投稿をさらに読みこむ(Text検索の場合).
- (void)loadMoreTextSearchPosts:(NSUInteger)index {
    
    [LoadingView showInView:self.view];
    
    //テキスト検索結果の方も更新
    [((TextSearchResultViewController * )self.parent).cv reloadData];
    
    NSString *aToken = [Configuration loadAccessToken];
    NSDictionary *params = @{ @"page" : @(self.postManager.postPage)};
    NSString * searchWord = ((TextSearchResultViewController * )self.parent).searchWord;
    
    __weak typeof(self) weakSelf = self;
    [self.postManager loadMorePostsByWord:params aToken:aToken Word:searchWord Type:@"word" block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            DLog(@"error = %@", error);
            [LoadingView dismiss];
            if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_TIMEOUT]){
                [self timeOutErrorAction];
            }
        }else{
            [CommonUtil delay:0.3 block:^{
                [strongSelf.pageView setViewControllers:@[[self getDetailViewNeeded:index]]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:nil];
                [LoadingView dismiss];
            }];
        }
    }];
}
///投稿をさらに読みこむ(Tag検索の場合).
- (void)loadMoreTagSearchPosts:(NSUInteger)index {
    
    [LoadingView showInView:self.view];
    
    //タグ検索結果の方も更新
    [((PostTagViewController * )self.parent).cv reloadData];
    
    NSString *aToken = [Configuration loadAccessToken];
    NSDictionary *params = @{ @"page" : @(self.postManager.postPage)};
    NSString * HushTagName = ((PostTagViewController * )self.parent).HushTagName;
    
    __weak typeof(self) weakSelf = self;
    [self.postManager loadMorePostsByWord:params aToken:aToken Word:HushTagName Type:@"tag" block:^(NSMutableArray *posts, NSUInteger *postPage, NSNumber *resultCode, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            DLog(@"error = %@", error);
            [LoadingView dismiss];
            if([resultCode isEqualToNumber:API_RESPONSE_CODE_ERROR_TIMEOUT]){
                [self timeOutErrorAction];
            }
        }else{
            [CommonUtil delay:0.3 block:^{
                [strongSelf.pageView setViewControllers:@[[self getDetailViewNeeded:index]]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:NO
                                             completion:nil];
                [LoadingView dismiss];
            }];
        }
    }];
}
///適切なpostManagerをセットする.
- (void)setPostManager {
    if (self.parentClass == SEARCH_TEXT) {
        self.postManager = ((TextSearchResultViewController * )self.parent).postManager;
    }else if (self.parentClass == SEARCH_TAG){
        self.postManager = ((PostTagViewController * )self.parent).postManager;
    }else if (self.parentClass == HOME) {
        self.postManager = ((HomeViewController * )self.parent).postManager;
    }
}
///適切なsortValをセットする.
- (void)setSortVal {
    if (self.parentClass == SEARCH_TEXT) {
        self.sortVal = formatPostSortType_toString[((TextSearchResultViewController * )self.parent).sortType];
    }else if (self.parentClass == SEARCH_TAG){
        self.sortVal = formatPostSortType_toString[((PostTagViewController * )self.parent).sortType];
    }else if (self.parentClass == HOME) {
        self.sortVal = formatPostSortType_toString[((HomeViewController * )self.parent).sortType];
    }
}
///適切なcategoryIDをセットする.
- (void)setCategoryID {
    if (self.parentClass == SEARCH_TEXT) {
        self.categoryID = ((TextSearchResultViewController * )self.parent).categoryID;
    }else if (self.parentClass == SEARCH_TAG){
        self.categoryID = ((PostTagViewController * )self.parent).categoryID;
    }else if (self.parentClass == HOME) {
        self.categoryID = ((HomeViewController * )self.parent).categoryID;
    }
}
///おすすめかフォローカテゴリーならYESを返す
- (BOOL)isAllOrFollowCategory {
    return ([self isAllCategory] || [self isFollowCategory]);
}
//おすすめカテゴリならYES
- (BOOL)isAllCategory {
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    return (self.categoryID && [[self.categoryID stringValue] isEqualToString:vConfig[@"AllCategoryPk"]]);
}
///フォローカテゴリならYES
- (BOOL)isFollowCategory {
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    return (self.categoryID && [[self.categoryID stringValue] isEqualToString:vConfig[@"FollowCategoryPk"]]);
}
///同期実行
- (void)doTaskSynchronously:(void (^) ())block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}
///スクロール可能を示す矢印を表示.
- (void)setArrow {
    CGSize size_next = CGSizeMake(40, 40);
    CGPoint position_next = CGPointMake(self.view.bounds.size.width - size_next.width - 5, self.view.bounds.size.height / 3);
    UIImage * next_arrow_img = [UIImage imageNamed:@"icon_next_orange.png"];
    self.next_arrow_btn = [[UIButton alloc]
                                initWithFrame:CGRectMake(position_next.x,
                                                         position_next.y,
                                                         size_next.width,
                                                         size_next.height)];
    [self.next_arrow_btn setBackgroundImage:next_arrow_img forState:UIControlStateNormal];
    [self.next_arrow_btn addTarget:self
                            action:@selector(nextPageAction:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.next_arrow_btn];
    
    CGSize size_back = CGSizeMake(40, 40);
    CGPoint position_back = CGPointMake(5, self.view.bounds.size.height / 3);
    UIImage * back_arrow_img = [UIImage imageNamed:@"icon_back_orange.png"];
    self.back_arrow_btn = [[UIButton alloc]
                                initWithFrame:CGRectMake(position_back.x,
                                                         position_back.y,
                                                         size_back.width,
                                                         size_back.height)];
    [self.back_arrow_btn setBackgroundImage:back_arrow_img forState:UIControlStateNormal];
    [self.back_arrow_btn addTarget:self
                            action:@selector(previousPageAction:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.back_arrow_btn];
    
    NSUInteger currentIndex = [self.postManager.posts indexOfObject:self.tappedPost];
    NSUInteger lastIndex = [self.postManager.posts indexOfObject:[self.postManager.posts lastObject]];
    if (currentIndex == 0) {
        self.back_arrow_btn.hidden = YES;
    }
    if (!self.postManager.canLoadPostMore && currentIndex == lastIndex) {
        self.next_arrow_btn.hidden = YES;
    }
}
///矢印のコントロール
- (void)controlArrows {
    NSUInteger currentIndex = ((DetailViewController * )[self.pageView viewControllers][0]).pageViewIndex;
    NSUInteger lastIndex = [self.postManager.posts indexOfObject:[self.postManager.posts lastObject]];
    if (currentIndex == 0) {
        self.back_arrow_btn.hidden = YES;
    }else {
        self.back_arrow_btn.hidden = NO;
    }
    if (!self.postManager.canLoadPostMore && currentIndex == lastIndex) {
        self.next_arrow_btn.hidden = YES;
    }else {
        self.next_arrow_btn.hidden = NO;
    }
}
///通信タイムアウト時の共通処理.
- (void)timeOutErrorAction {
    UIAlertView * alert = [[UIAlertView alloc]
             initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil)
             message:nil
             delegate:nil
             cancelButtonTitle:NSLocalizedString(@"OK", nil)
             otherButtonTitles:nil];
    [alert show];
}
#pragma mark UIButton Action

///次のページへ
- (void)nextPageAction:(UIButton * )sender {
    sender.userInteractionEnabled = NO;
    NSUInteger currentIndex = ((DetailViewController * )self.pageView.viewControllers[0]).pageViewIndex;
    NSUInteger lastIndex = [self.postManager.posts indexOfObject:[self.postManager.posts lastObject]];
    if (currentIndex + 1 == lastIndex && self.postManager.canLoadPostMore) {
        
        if (self.parentClass == SEARCH_TEXT) {
            [self loadMoreTextSearchPosts:currentIndex + 1];
        }else if (self.parentClass == SEARCH_TAG){
            [self loadMoreTagSearchPosts:currentIndex + 1];
        }else if (self.parentClass == HOME) {
            [self loadMoreHomePosts:currentIndex + 1];
        }
        sender.userInteractionEnabled = YES;
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.pageView setViewControllers:@[[self getDetailViewNeeded:currentIndex + 1]]
                            direction:UIPageViewControllerNavigationDirectionForward
                             animated:YES completion:^(BOOL finished) {
                                 [weakSelf controlArrows];
                                 sender.userInteractionEnabled = YES;
                             }];
}
///前のページへ
- (void)previousPageAction:(UIButton * )sender {
    sender.userInteractionEnabled = NO;
    NSUInteger currentIndex = ((DetailViewController * )self.pageView.viewControllers[0]).pageViewIndex;
    __weak typeof(self) weakSelf = self;
    [self.pageView setViewControllers:@[[self getDetailViewNeeded:currentIndex - 1]]
                            direction:UIPageViewControllerNavigationDirectionReverse
                             animated:YES completion:^(BOOL finished) {
                                 [weakSelf controlArrows];
                                 sender.userInteractionEnabled = YES;
                             }];
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
