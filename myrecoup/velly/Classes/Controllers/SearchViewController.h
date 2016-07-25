//
//  SearchViewController.h
//  myrecoup
//
//  Created by aoponaopon on 2015/12/11.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCollectionViewLayout.h"
#import "CHTCollectionViewWaterfallLayout.h"

@interface SearchViewController : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CHTCollectionViewDelegateWaterfallLayout>


@property (nonatomic)UISearchBar *searchBar;
@property (nonatomic)UIButton *dummybtn;
@property (nonatomic)UILabel *recommendLabel;
@property (nonatomic)NSUserDefaults *userDefaults;
@property (nonatomic)NSArray *searchHistories;
@property (nonatomic)UITableView *searchResultTable;
@property (nonatomic)UIButton *deleteAllBtn;
@property (nonatomic)UIView *headerView;
@property (nonatomic)UICollectionView *catCollectionView;

@end
