//
//  PostCategoryTableViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostCategoryTableViewController.h"
#import "PostCategoryTableViewCell.h"
#import "TrackingManager.h"
#import "SVProgressHUD.h"
#import "MasterManager.h"
#import "ConfigLoader.h"
#import "CommonUtil.h"
#import "CategoryManager.h"

@interface PostCategoryTableViewController ()

@property (strong, nonatomic) NSMutableArray *categories;

@end

@implementation PostCategoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem
     setTitleView:[CommonUtil getNaviTitle:NSLocalizedString(@"PagePostCategory", nil)]];
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///data sourceを返す
- (NSMutableArray *)categories {
    if (!_categories) {
        _categories = [[NSMutableArray alloc] init];
        for (Category_ *parent in [CategoryManager sharedManager].parentCategories) {
            if (parent.allow_post) {
                [_categories addObject:parent];
            }
        }
    }
    return _categories;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PostCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCategoryTableViewCell"];

    [cell configureCellForCategoryName:[self.categories objectAtIndex:indexPath.row]];
    
    DLog(@"%@",[self.categories objectAtIndex:indexPath.row]);
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    // ハイライトなし
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 前回選択の項目にのみチェックマークを付ける
    if ([cell.categoryLabel.text isEqualToString:self.postEditViewController.categoryLabel.text] ||
        (self.postUpdateViewController && [cell.categoryLabel.text isEqualToString:self.postUpdateViewController.parent.label])
        ) {
        cell.tintColor = INPUT_SEND_BTN_COLOR;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(10, 44 - 1, self.tableView.frame.size.width - 20, 1)];
    separatorLineView.backgroundColor =[UIColor groupTableViewBackgroundColor];
    [cell.contentView addSubview:separatorLineView];
    
    return cell;
}

#pragma mark - Delegate
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    DLog(@"%@", self.categories[indexPath.row]);

    Category_ *selected = self.categories[indexPath.row];
    
    if (self.postUpdateViewController) {
        self.postUpdateViewController.parent = selected;
        [self.postUpdateViewController.postTableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self.postEditViewController.categoryLabel setText:selected.label];
    self.postEditViewController.parent = selected;
    //[self.postEditViewController checkInputData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
