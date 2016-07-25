//
//  PostEditViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "PostEffectViewController.h"
#import "Category.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PostEditViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) PostEffectViewController *postEffectViewController;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIImage *cameraImage;
@property (weak, nonatomic) IBOutlet UIImageView *postThumbImageView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *descripView;

@property (weak, nonatomic) IBOutlet UIView *socialSecView;
@property (weak, nonatomic) IBOutlet UIView *twitterView;
@property (weak, nonatomic) IBOutlet UIView *faceBookView;
@property (weak, nonatomic) IBOutlet UIImageView *categoryBottomLineImg;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (weak, nonatomic) IBOutlet UILabel *postDataTimeLabel;

@property (nonatomic, strong) NSString *descrip;
@property (nonatomic) Category_ *category;
@property (nonatomic) Category_ *parent;
@property (nonatomic) Category_ *child;

@property (nonatomic, assign) BOOL isSendTw;
@property (nonatomic, assign) BOOL isSendFb;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *childCategoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *categoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *childCategoryBtn;
@property (weak, nonatomic) IBOutlet UIImageView *selectedCategoryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *icoChildCategoryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *childSelectedImageView;

@property (weak, nonatomic) IBOutlet UIImageView *twImageView;
@property (weak, nonatomic) IBOutlet UIButton *twBtn;
@property (weak, nonatomic) IBOutlet UIImageView *twStatusImageView;

@property (weak, nonatomic) IBOutlet UIImageView *fbImageView;
@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
@property (weak, nonatomic) IBOutlet UIImageView *fbStatusImageView;

@property (nonatomic) BOOL isMovie;
@property (nonatomic, strong) NSData *Movie;
@property (nonatomic, strong) AVURLAsset *assetMaster;


- (id) initWithPostImage:(UIImage *)t_postImage;

- (NSString *) checkInputData:(BOOL)noAlertCategory;

@end
