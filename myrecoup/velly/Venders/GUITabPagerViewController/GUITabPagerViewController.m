//
//  GUITabPagerViewController.m
//  GUITabPagerViewController
//
//  Created by Guilherme Araújo on 26/02/15.
//  Copyright (c) 2015 Guilherme Araújo. All rights reserved.
//

#import "GUITabPagerViewController.h"
#import "GUITabScrollView.h"
#import "AppConstant.h"
#import "HomeViewController.h"
#import "HomeTabPagerViewController.h"

@interface GUITabPagerViewController () <GUITabScrollDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) GUITabScrollView *header;
@property (assign, nonatomic) NSInteger currentIndex;

@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) NSMutableArray *tabTitles;
@property (strong, nonatomic) UIColor *headerColor;
@property (assign, nonatomic) CGFloat headerHeight;

@end

@implementation GUITabPagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
  
    [self setPageViewController:[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil]];
  
    for (UIView *view in [[[self pageViewController] view] subviews]) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setCanCancelContentTouches:YES];
            [(UIScrollView *)view setDelaysContentTouches:NO];
       
            // scroll stop
            // [(UIScrollView *)view setBounces:NO];
        }
    }
    
    [[self pageViewController] setDataSource:self];
    [[self pageViewController] setDelegate:self];

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

     DLog(@"height : %f)", self.view.frame.size.height);
    
    //初期タブをindex 1に設定
    [self setCurrentIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    // self.view.frame.size.height : 435 になっている
//    CGRect frame = self.view.frame;
//    frame.size.height = frame.size.height + 20;
//    [self.view setFrame:frame];
//DLog(@"frame size height : %f", self.view.frame.size.height);
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self reloadTabs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
    return pageIndex > 0 ? [self viewControllers][pageIndex - 1]: nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
    return pageIndex < [[self viewControllers] count] - 1 ? [self viewControllers][pageIndex + 1]: nil;
}

#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {

   
    
    NSInteger index = [[self viewControllers] indexOfObject:pendingViewControllers[0]];
    [[self header] animateToTabAtIndex:index];

}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    
    HomeTabPagerViewController *homeTabPagerView = (HomeTabPagerViewController*)[[previousViewControllers[0] parentViewController] parentViewController];
    
    if (completed && [homeTabPagerView isKindOfClass:[HomeTabPagerViewController class]]) {
        //ナビゲーションのタイトルをカテゴリーによって変える(スライド完了時)
        [self changeNavigationItem:[[[[self pageViewController] viewControllers][0] view] subviews][0] :homeTabPagerView];
    }
    
    
    [self setCurrentIndex:[[self viewControllers] indexOfObject:[[self pageViewController] viewControllers][0]]];
    [[self header] animateToTabAtIndex:[self currentIndex]];
}

//ナビゲーションのタイトルをカテゴリーによって変える(スライド完了時)
- (void)changeNavigationItem:(HomeViewController *)NextView :(HomeTabPagerViewController *)homeTabPagerView
{
    //sortSegmentedControlなら前のtitleViewが入る(状態保存のため)
    if ([homeTabPagerView.navigationItem.titleView isKindOfClass:[UISegmentedControl class]]) {
        self.superSortSegmentControl = (UISegmentedControl*)homeTabPagerView.navigationItem.titleView;
    }
    //change navigation item.
    if(![NextView isKindOfClass:[UICollectionView class]]){
        if ([homeTabPagerView.navigationItem.titleView isKindOfClass:[UISegmentedControl class]]) {
            
            homeTabPagerView.navigationItem.titleView = self.superMyrecoTitleView;
            [UIView animateWithDuration:1.0f animations:^{
                homeTabPagerView.navigationItem.titleView.alpha = 0;
                homeTabPagerView.navigationItem.titleView.alpha = 1;
            }];
        }
        else{
            homeTabPagerView.navigationItem.titleView = self.superMyrecoTitleView;
        }
    }else{
        if ([homeTabPagerView.navigationItem.titleView isKindOfClass:[UILabel class]]) {
            
            homeTabPagerView.navigationItem.titleView = self.superSortSegmentControl;
            [UIView animateWithDuration:1.0f animations:^{
                homeTabPagerView.navigationItem.titleView.alpha = 0;
                homeTabPagerView.navigationItem.titleView.alpha = 1;
            }];
        }
        else{
            homeTabPagerView.navigationItem.titleView = self.superSortSegmentControl;
        }
    }
    
}

#pragma mark - Tab Scroll View Delegate

// tab direct click action
- (void)tabScrollView:(GUITabScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index {
    
    if (index != [self currentIndex]) {
        HomeViewController *targetView = [[self dataSource] changeViewControllerForIndex:[self viewControllers][index]];
        
        //現在開いているHomeTapViewを取得しsort typeを取得
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        UINavigationController *topNavi = topController.childViewControllers[0];
        HomeTabPagerViewController *homeTabPagerView = topNavi.childViewControllers[0];
        
        //取得したsort typeの現在値をセット
        targetView.sortType = homeTabPagerView.sortType;
        homeTabPagerView.sortSegmentedControl.selectedSegmentIndex = homeTabPagerView.sortType;
        
        //[[self pageViewController]  setViewControllers:@[[self viewControllers][index]]
        [[self pageViewController]  setViewControllers:@[targetView]
                                         direction:(index > [self currentIndex]) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                                          animated:YES
                                        completion:nil];
        [self setCurrentIndex:index];
        // custom : tab reload
        //[self reloadTabs];
        // 左によるので、せんたくしたものを中央へ
    }
}

- (void)reloadData {
    
    DLog(@"height : %f)", self.view.frame.size.height);
    
    [self setViewControllers:[NSMutableArray array]];
    [self setTabTitles:[NSMutableArray array]];
  
    for (int i = 0; i < [[self dataSource] numberOfViewControllers]; i++) {
        [[self viewControllers] addObject:[[self dataSource] viewControllerForIndex:i]];
        if ([[self dataSource] respondsToSelector:@selector(titleForTabAtIndex:)]) {
            [[self tabTitles] addObject:[[self dataSource] titleForTabAtIndex:i]];
        }
    }
    
    DLog(@"height : %f)", self.view.frame.size.height);
    
    [self reloadTabs];
    
    // activie to statusbar tap -> scroll top
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setScrollsToTop:NO];
        }
    }
    
    CGRect frame = [[self view] frame];
    frame.origin.y = [self headerHeight];
    frame.size.height -= [self headerHeight];
  
    [[[self pageViewController] view] setFrame:frame];
  
    //初期タブを index 0に設定
    [self.pageViewController setViewControllers:@[[self viewControllers][0]]
                                    direction:UIPageViewControllerNavigationDirectionReverse
                                     animated:NO
                                   completion:nil];

    [self setCurrentIndex:0];
}

- (void)reloadTabs {
    
     DLog(@"height : %f)", self.view.frame.size.height);
    
    if ([[self dataSource] numberOfViewControllers] == 0)
        return;
  
    if ([[self dataSource] respondsToSelector:@selector(tabHeight)]) {
        [self setHeaderHeight:[[self dataSource] tabHeight]];
    } else {
        [self setHeaderHeight:44.0f];
    }
  
    if ([[self dataSource] respondsToSelector:@selector(tabColor)]) {
        [self setHeaderColor:[[self dataSource] tabColor]];
    } else {
        [self setHeaderColor:[UIColor orangeColor]];
    }
  
    NSMutableArray *tabViews = [NSMutableArray array];
  
    if ([[self dataSource] respondsToSelector:@selector(viewForTabAtIndex:)]) {
        for (int i = 0; i < [[self viewControllers] count]; i++) {
            [tabViews addObject:[[self dataSource] viewForTabAtIndex:i]];
        }
    } else {
      
        //NSLog(@"%ld", (long)self.currentIndex);
        //for (NSString *title in [self tabTitles]) {
        for (int j = 0; j < [[self tabTitles] count]; j++) {
            NSString *title = [[self tabTitles] objectAtIndex:j];

            // custom
            UILabel *label = [UILabel new];
            //UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, self.view.frame.size.width, 4)];
            //label.frame = CGRectMake(10, 20, 60, 80);

            [label setText:title];
            [label setTextAlignment:NSTextAlignmentCenter];

            //[label setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f]];
            [label setFont: HOME_HEADER_NAVI_FONT];
    
            // 文字が長い場合に自動で文字サイズを縮小
            //[label setAdjustsFontSizeToFitWidth:YES];
            //[label setMinimumFontSize:10];//最小フォントサイズ
        
            if (self.currentIndex == j){
                [label setTextColor: HEADER_BG_COLOR];
            }else{
                //[label setTextColor: [UIColor whiteColor]];
                [label setTextColor: [UIColor lightGrayColor]];
                //[label setTextColor: [UIColor darkGrayColor]];
                //[label sizeToFit];
            }
//          CGRect frame = [label frame];
//          frame.size.width = MAX(frame.size.width + 20, 65);
            //frame.size.width = self.view.frame.size.width;

            // 表示ラベルの文字による幅チェック
            // 表示最大サイズ
            CGSize bounds = CGSizeMake(label.frame.size.width, 200);
            UIFont *font = label.font;
            CGSize size;
            if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                CGRect rect
                = [label.text boundingRectWithSize:bounds
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil];
                size = rect.size;
            }
            else {
                //UILineBreakMode mode = label.lineBreakMode;
                size = [label.text sizeWithFont:font
                                 constrainedToSize:bounds
                                     lineBreakMode:label.lineBreakMode];
            }
            size.width  = ceilf(size.width);
            size.height = ceilf(size.height);
            label.frame = CGRectMake(label.frame.origin.x,
                                 label.frame.origin.y,
                                 size.width + 20, size.height);
        
        
            //frame.size.height = frame.size.height - 30;

//          [label setFrame:frame];
            [tabViews addObject:label];
        }
    }
  
    if ([self header]) {
        [[self header] removeFromSuperview];
    }

    DLog(@"frame : %f", self.view.frame.size.height);
    
    CGRect frame = self.view.frame;
    
    frame.size.height = frame.size.height + 20;
    [self.view setFrame:frame];
    
    frame.origin.y = 0;
    frame.size.height = [self headerHeight];
    [self setHeader:[[GUITabScrollView alloc] initWithFrame:frame tabViews:tabViews tabBarHeight:[self headerHeight] tabColor:[self headerColor]]];
    [[self header] setTabScrollDelegate:self];
    
    //[[self header] setBackgroundColor: HEADER_BG_COLOR];
    [[self header] setBackgroundColor: [UIColor whiteColor]];
  
    [[self view] addSubview:[self header]];
}

@end

