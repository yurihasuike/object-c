//
//  PostEditViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface PostMovieViewController : UIViewController <UITextViewDelegate>


@property (weak, nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic) UIImage *cameraImage;
@property (weak, nonatomic) UIImageView *postThumbImageView;
@property (weak, nonatomic) UIPlaceHolderTextView *descripView;

@property (weak, nonatomic) UIButton *postBtn;

@property (weak, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (weak, nonatomic) IBOutlet UILabel *postDataTimeLabel;

@property (nonatomic, strong) NSNumber *categoryId;
@property (nonatomic, strong) NSNumber *categoryName;


@property (weak, nonatomic) UILabel *categoryLabel;
@property (weak, nonatomic) UIButton *categoryBtn;
@property (weak, nonatomic) UIImageView *selectedCategoryImageView;

@property (weak, nonatomic) UIImageView *twImageView;
@property (weak, nonatomic) UIButton *twBtn;
@property (weak, nonatomic) UIImageView *twStatusImageView;

@property (weak, nonatomic) UIImageView *fbImageView;
@property (weak, nonatomic) UIButton *fbBtn;
@property (weak, nonatomic) UIImageView *fbStatusImageView;


//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//
//@property (weak, nonatomic) UIImage *cameraImage;
//@property (weak, nonatomic) IBOutlet UIImageView *postThumbImageView;
//@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *descripView;
//
//@property (weak, nonatomic) IBOutlet UIButton *postBtn;
//
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic, strong) NSArray *dataSource;
//
//@property (weak, nonatomic) IBOutlet UILabel *postDataTimeLabel;
//
//@property (nonatomic, strong) NSNumber *categoryId;
//@property (nonatomic, strong) NSNumber *categoryName;
//
//
//@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
//@property (weak, nonatomic) IBOutlet UIButton *categoryBtn;
//@property (weak, nonatomic) IBOutlet UIImageView *selectedCategoryImageView;
//
//@property (weak, nonatomic) IBOutlet UIImageView *twImageView;
//@property (weak, nonatomic) IBOutlet UIButton *twBtn;
//@property (weak, nonatomic) IBOutlet UIImageView *twStatusImageView;
//
//@property (weak, nonatomic) IBOutlet UIImageView *fbImageView;
//@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
//@property (weak, nonatomic) IBOutlet UIImageView *fbStatusImageView;


- (id) initWithPostImage:(UIImage *)t_postImage;

- (NSString *) checkInputData:(BOOL)noAlertCategory;

@end
