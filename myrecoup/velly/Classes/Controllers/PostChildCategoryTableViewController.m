//
//  PostChildCategoryTableViewController.m
//  myrecoup
//
//  Created by aoponaopon on 2016/05/14.
//  Copyright (c) 2016年 aoi.fukuoka. All rights reserved.
//

#import "PostChildCategoryTableViewController.h"
#import "PostChildCategoryTableViewCell.h"
#import "PostEditViewController.h"
#import "PostUpdateViewController.h"
#import "CategoryManager.h"
#import "CommonUtil.h"

#define EDIT 0
#define UPDATE 1

@interface PostChildCategoryTableViewController ()

@property (nonatomic) NSUInteger type;

@end

@implementation PostChildCategoryTableViewController

- (id)initWithArgs:(UIViewController *)parentView
            parent:(Category_ *)parent
{
    self = [super init];
    if (parent) {
        self.parentView = parentView;
        self.parent = parent;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.parentView isKindOfClass:[PostEditViewController class]]) {
        self.type = EDIT;
    }else if ([self.parentView isKindOfClass:[PostUpdateViewController class]]){
        self.type = UPDATE;
    }
    
    self.navigationItem.titleView = [CommonUtil getNaviTitle:NSLocalizedString(@"childCategorySelect", nil)];
    
    [self.tableView
     registerClass:[PostChildCategoryTableViewCell class]
     forCellReuseIdentifier:@"tableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSMutableArray *)categories {
    if (!_categories) {
        _categories = [[CategoryManager sharedManager] getChildrenByParent:self.parent];
    }
    return _categories;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PostChildCategoryTableViewCell *cell = [tableView
                                            dequeueReusableCellWithIdentifier:@"tableViewCell"
                                            forIndexPath:indexPath];
    
    Category_ *category = [self.categories objectAtIndex:indexPath.row];
    [cell.categoryName setText:category.label];
    [cell setIconImage:self.parent];
    
    //選択済みのカテゴリにチェックマークをつける
    if ((self.type == EDIT &&
        [category.label
         isEqualToString:((PostEditViewController *)self.parentView).childCategoryLabel.text]) ||
        (self.type == UPDATE &&
        [category.label
         isEqualToString:((PostUpdateViewController *)self.parentView).child.label]
        )){
            [cell setTintColor:INPUT_SEND_BTN_COLOR];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Category_ *selected = [self.categories objectAtIndex:indexPath.row];
    if (self.type == EDIT) {
        
        ((PostEditViewController *)self.parentView).child = selected;
        [((PostEditViewController *)self.parentView).childCategoryLabel setText:selected.label];
        
    }else if (self.type == UPDATE){
        
        ((PostUpdateViewController *)self.parentView).child = selected;
        [((PostUpdateViewController *)self.parentView).postTableView reloadData];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
