//
//  PostEffectViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostViewController.h"
#import "Category.h"

@interface PostEffectViewController : UIViewController

@property (strong, nonatomic) PostViewController *postViewController;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) UIImage *cameraImage;
@property (strong, nonatomic) UIImage *cropedimage;
@property (strong, nonatomic) UIImage *brightedimage;
@property (strong, nonatomic) UIImage *filteredImage;
@property (strong, nonatomic) NSArray *filteredImages;

@property (weak, nonatomic) IBOutlet UIView *displayView;

@property (nonatomic, strong) NSString *descrip;
@property (nonatomic, strong) Category_ *category;

@property (nonatomic, assign) BOOL isSendTw;
@property (nonatomic, assign) BOOL isSendFb;

@property (weak, nonatomic) IBOutlet UIView *CtrlView;
@property (weak, nonatomic) IBOutlet UIView *ActionView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *backBtn;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *cropBtn;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *brightBtn;
@property (weak, nonatomic) IBOutlet UIButton *recSubmitBtn;
@property (weak, nonatomic) IBOutlet UIImageView *recSubmitBkImageView;

@property (retain, nonatomic)UICollectionViewFlowLayout *filteredImageCollectionLayout;
@property (retain, nonatomic) UICollectionView *filteredImageCollectionView;
@property (nonatomic) CIFilter *ciFilter;
@property (nonatomic) NSInteger *shouldBeBarRow;
@property (weak, nonatomic) IBOutlet UIView *PostEffectCollectionBaseView;

@property (nonatomic) BOOL wasPostSelectFromLibraryView;

- (id) initWithPostImage:(UIImage *)t_postImage;
- (NSMutableArray *) getFilteredImages:(UIImage *)t_postImage;

@end
