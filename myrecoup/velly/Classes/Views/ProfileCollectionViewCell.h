//
//  ProfileCollectionViewCell.h
//  velly
//
//  Created by m_saruwatari on 2015/03/27.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@class Post;
@interface ProfileCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *postImageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UIImageView *movieIconImgView;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *postGoodBtn;
@property (weak, nonatomic) IBOutlet UIButton *postGoodCnt;
@property (weak, nonatomic) IBOutlet UILabel *postGoodLabel;
@property (weak, nonatomic) IBOutlet UIButton *postCommentBtn;
@property (weak, nonatomic) IBOutlet UIButton *postCommentCnt;
@property (weak, nonatomic) IBOutlet UILabel *postCommentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postUserImageView;
@property (weak, nonatomic) IBOutlet UIButton *postUserNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *postUserIdBtn;

@property (nonatomic) NSNumber *originalWidth;
@property (nonatomic) NSNumber *originalHeight;
@property (nonatomic) NSNumber *transcodedWidth;
@property (nonatomic) NSNumber *transcodedHeight;
@property (nonatomic) NSNumber *thumbnailWidth;
@property (nonatomic) NSNumber *thumbnailHeight;

@property (nonatomic) float cellPostImgHeight;
@property (nonatomic) NSNumber *postImgWidth;
@property (nonatomic) NSNumber *postImgHeight;
@property (nonatomic) float postImgeRatio;

//@property (nonatomic) Post *post;
@property (nonatomic) NSNumber *postID;
@property (nonatomic) NSNumber *userPID;

@property (weak, nonatomic) NSNumber *isGood;
@property (weak, nonatomic) NSString *user_id;

@property (nonatomic) NSNumber *cntGood;
@property (nonatomic) NSNumber *cntComment;

@property (nonatomic, assign) CGFloat cellHeight;

//- (void)configureCellForAppRecord;
//- (void)configureCellForAppRecord:(Info *)info;
- (void)configureCellForAppRecord:(Post *)post;

- (CGFloat) profileCellHeight:(Post *)post;

- (void) plusCntGood;
- (void) minusCntGood;

@end
