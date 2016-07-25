//
//  HomeCollectionViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/03/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "HomeCollectionViewCell.h"
#import "CommonUtil.h"
#import "UIImageView+Networking.h"
#import "UIImageView+WebCache.h"

@interface HomeCollectionViewCell ()

@property (nonatomic, weak) CommonUtil *commonUtil;

@end

@implementation HomeCollectionViewCell

@synthesize cellHeight = _cellHeight;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    //[self setNeedsLayout];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

///subviewを作成
- (id)initWithSubViews {
    if(!self) {
        self = [[HomeCollectionViewCell alloc] init];
    }
    //いいね数ボタン設置
    if (!self.goodCntBtnOnImg) {
        self.goodCntBtnOnImg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.contentView addSubview:self.goodCntBtnOnImg];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // init
//    _postImageView.image = nil;
//    _postTitleLabel.text = nil;
//    _postGoodLabel.text = 0;
//    _postCommentLabel.text = 0;
    _postUserNameBtn.titleLabel.text = @"";
    _postUserIdBtn.titleLabel.text = @"";
    
    [self.postGoodCnt setBackgroundImage:[UIImage imageNamed:@"ico_heart.png"] forState:UIControlStateNormal];
    self.postGoodCnt.imageView.image = [UIImage imageNamed:@"ico_heart.png"];
}

//- (void)configureCellForAppRecord
//{
//    CommonUtil *commonUtil = [[CommonUtil alloc] init];
//    
////    UIImage *iconImage = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: info.iconPath]]];
//    UIImageView *userImageView = self.postUserImageView;
//    
////    CGSize cgSize = CGSizeMake(32.0f, 32.0f);
////    CGSize radiusSize = CGSizeMake(16.0f, 16.0f);
//    CGSize cgSize = CGSizeMake(160.0f, 160.0f);
//    CGSize radiusSize = CGSizeMake(80.0f, 80.0f);
//    UIImage *iconEditImage = [commonUtil createRoundedRectImage:userImageView.image size:cgSize radiusSize: radiusSize];
//    
//    [self.postUserImageView setImage:iconEditImage];
//}

- (void)configureCellForAppRecord:(Post *)post
{
    
    //self.post = post;
    
    CommonUtil *commonUtil = [[CommonUtil alloc] init];
    
    // くるくる
    //UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(135,30,50,50)];
    //[spinner startAnimating];
    //[self.view addSubview:spinner];
    // action
    //[spinner stopAnimating];
    
    self.postID = post.postID;
    self.userPID = post.userPID;

    self.originalWidth    = post.originalWidth;
    self.originalHeight   = post.originalHeight;
    self.transcodedWidth  = post.transcodedWidth;
    self.transcodedHeight = post.transcodedHeight;
    self.thumbnailWidth   = post.thumbnailWidth;
    self.thumbnailHeight  = post.thumbnailHeight;
    
//    if(![self.thumbnailWidth isEqualToNumber:[NSNumber numberWithInt:0]] &&
//            ![self.thumbnailHeight isEqualToNumber:[NSNumber numberWithInt:0]]){
//        self.postImgWidth  = self.thumbnailWidth;
//        self.postImgHeight = self.thumbnailHeight;
//#if CGFLOAT_IS_DOUBLE
//        DLog(@"%f", [self.thumbnailWidth doubleValue]);
//        DLog(@"%f", [self.thumbnailHeight doubleValue]);
//        self.postImgeRatio = [self.thumbnailWidth doubleValue] / [self.thumbnailHeight doubleValue];
//#else
//        DLog(@"%f - %f", [self.thumbnailWidth floatValue], [self.thumbnailHeight floatValue]);
//        self.postImgeRatio = [self.thumbnailWidth floatValue] / [self.thumbnailHeight floatValue];
//#endif
//
//        DLog(@" float : %f", self.postImgeRatio);
//        
//    }else if(![self.transcodedWidth isEqualToNumber:[NSNumber numberWithInt:0]] &&
//             ![self.transcodedHeight isEqualToNumber:[NSNumber numberWithInt:0]]){
//        self.postImgWidth  = self.transcodedWidth;
//        self.postImgHeight = self.transcodedHeight;
//        self.postImgeRatio = [self.transcodedWidth floatValue] / [self.transcodedHeight floatValue];
//    
//    }else if(![self.originalWidth isEqualToNumber:[NSNumber numberWithInt:0]] &&
//             ![self.originalHeight isEqualToNumber:[NSNumber numberWithInt:0]]){
//        self.postImgWidth  = self.originalWidth;
//        self.postImgHeight = self.originalHeight;
//        self.postImgeRatio = [self.originalWidth floatValue] / [self.originalHeight floatValue];
//    }
    
    self.postImgWidth  = self.originalWidth;
    self.postImgHeight = self.originalHeight;
    self.postImgeRatio = [self.originalWidth floatValue] / [self.originalHeight floatValue];
//#if CGFLOAT_IS_DOUBLE
//    self.postImgeRatio = [self.thumbnailWidth doubleValue] / [self.thumbnailHeight doubleValue];
//#else
//    self.postImgeRatio = [self.originalWidth floatValue] / [self.originalHeight floatValue];
//#endif
    // 投稿画像
    NSString *postImgPath = [CommonUtil getImgPath:post];
    if(post.thumbnailPath){
        self.postImgWidth  = self.thumbnailWidth;
        self.postImgHeight = self.thumbnailHeight;
        self.postImgeRatio = [self.thumbnailWidth floatValue] / [self.thumbnailHeight floatValue];
        
    }else if(post.transcodedPath){
        self.postImgWidth  = self.transcodedWidth;
        self.postImgHeight = self.transcodedHeight;
        self.postImgeRatio = [self.transcodedWidth floatValue] / [self.transcodedHeight floatValue];
    }
    
    if(self.postImgeRatio){
//#if CGFLOAT_IS_DOUBLE
//        float imgScale = self.bounds.size.width / [self.postImgWidth doubleValue];
//        self.cellPostImgHeight = [self.postImgHeight doubleValue] * imgScale;
//#else
//        float imgScale = self.bounds.size.width / [self.postImgWidth floatValue];
//        self.cellPostImgHeight = [self.postImgHeight floatValue] * imgScale;
//#endif
        float imgScale = self.bounds.size.width / [self.postImgWidth floatValue];
        self.cellPostImgHeight = [self.postImgHeight floatValue] * imgScale;
        DLog(@" height : %f", self.cellPostImgHeight);
        //self.postImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.cellPostImgHeight);
    }

    DLog(@"postImgPath : %@", postImgPath);
    
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:postImgPath]
                          placeholderImage:nil
                                       options: SDWebImageCacheMemoryOnly
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         
                                         if(image){
                                             
                                         // 画像比率変換
                                         int imageW = image.size.width;
                                         int imageH = image.size.height;
                                         CGFloat cellWidth = ([[UIScreen mainScreen]bounds].size.width / 2) - 7.0f;
                                         float scale = cellWidth / imageW;                // A

                                         CGSize resizedSize = CGSizeMake(imageW * scale, imageH * scale);
                                         UIGraphicsBeginImageContext(resizedSize);
                                         [image drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
                                         //self.postImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                         self.postImageView.image = image;

                                         CGRect postImageFrame = self.postImageView.frame;
                                         postImageFrame.size = CGSizeMake(cellWidth, resizedSize.height);
                                         [self.postImageView setFrame:postImageFrame];
                                         
                                         // height : postImage + userIcon
                                         //CGRect rect = CGRectMake(0, 0, resizedSize.width, resizedSize.height);
                                             
                                         //AutoLayout解除
                                         //self.postImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                         //self.postImageView.frame = CGRectMake(0, 0, resizedSize.width, resizedSize.height);
                                             
                                         //image = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
                                         //self.userIconImageView.image = image;
                                             
//                                             self.postImageView.alpha = 0;
//                                             [UIView beginAnimations:@"fadeIn" context:nil];
//                                             [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//                                             [UIView setAnimationDuration:0.5];
//                                             self.postImageView.alpha = 1;
//                                             [UIView commitAnimations];
                                             
                                             if(cacheType == SDImageCacheTypeMemory){
                                                 self.postImageView.alpha = 1;
                                                 self.postUserImageView.hidden = NO;
//                                                 self.postGoodCnt.hidden = NO;
                                                 
                                             }else{
//                                                 [UIView animateWithDuration:0.4f animations:^{
//                                                     self.postImageView.alpha = 0;
//                                                     self.postImageView.alpha = 1;
//                                                 }];
                                                 
                                                 [UIView animateWithDuration:0.4f animations:^{
                                                     self.postImageView.alpha = 0;
                                                     self.postImageView.alpha = 1;
                                                 }completion:^(BOOL finished){
                                                     self.postUserImageView.hidden = NO;
//                                                     self.postGoodCnt.hidden = NO;
                                                 }];
                                                 
                                                 
                                             }
                                             //self.postUserImageView.alpha = 1.0f;
                                             
                                         }
                                     }];
    // 投稿紹介文
//    NSString *descrip = [CommonUtil clearLineBreak:post.descrip];
//    if(descrip != nil && [descrip length] > 20){
//        descrip = [[descrip substringToIndex:20] stringByAppendingString:@"..."];
//    }
//    self.postTitleLabel.text = descrip;
//    self.postTitleLabel.numberOfLines = 0;
//    self.postTitleLabel.lineBreakMode = NSLineBreakByCharWrapping;
//
//    self.postTitleLabel.frame = CGRectMake(8, self.postImageView.bounds.size.height + 6 + 32 + 6,
//                                           self.frame.size.width - 16, 20);
//    CGRect titleFrame = [self.postTitleLabel frame];
//    titleFrame.size = CGSizeMake(124, 5000);
//    [self.postTitleLabel setFrame:titleFrame];
//    [self.postTitleLabel sizeToFit];

    
    // 動画アイコン調整
    self.movieIconImgView.hidden = !post.isMovie;
    
    // いいね有無
    self.cntGood = 0;
    self.postGoodCnt.imageView.image = nil;
    [self.postGoodCnt setBackgroundImage:nil forState:UIControlStateNormal];
    self.postGoodCnt.hidden = YES;
    if([post.isGood isEqualToNumber:[NSNumber numberWithInt:VLISBOOLTRUE]] && ![post.cntGood isEqualToNumber:[NSNumber numberWithInt:0]]){
        [self.postGoodCnt setBackgroundImage:[UIImage imageNamed:@"ico_heart_on.png"] forState:UIControlStateNormal];
        self.postGoodCnt.imageView.image = [UIImage imageNamed:@"ico_heart_on.png"];
        self.isGood = [NSNumber numberWithInt:VLISBOOLTRUE];
    }else{
        [self.postGoodCnt setBackgroundImage:[UIImage imageNamed:@"ico_heart.png"] forState:UIControlStateNormal];
        self.postGoodCnt.imageView.image = [UIImage imageNamed:@"ico_heart.png"];
        self.isGood = [NSNumber numberWithInt:VLISBOOLFALSE];
    }
//    double delayInSeconds = 0.6;
//    dispatch_time_t goodCntTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(goodCntTime, dispatch_get_main_queue(), ^(void){
//        self.postGoodCnt.hidden = NO;
//    });
    
    // いいね数
    self.cntGood = post.cntGood;
    self.postGoodLabel.text = @"";
    self.postGoodLabel.text = [post.cntGood stringValue];
    [self.goodCntBtnOnImg setTitle:[post.cntGood stringValue] forState:UIControlStateNormal];
    self.postGoodBtn.titleLabel.text = @"";
    self.postGoodCnt.titleLabel.text = @"";
    
    // コメント数
    self.cntComment = post.cntComment;
    self.postCommentLabel.text = @"";
    self.postCommentLabel.text = [post.cntComment stringValue];
    self.postCommentCnt.titleLabel.text = @"";
    
    // ユーザID
    DLog(@"%@", [@"@" stringByAppendingFormat:@"%@", post.postID]);
    DLog(@"%@", [@"@" stringByAppendingFormat:@"%@", post.userID]);
    self.postUserIdBtn.titleLabel.text = @"";
    self.postUserIdBtn.titleLabel.text = [@"@" stringByAppendingFormat:@"%@", post.userID];
    [self.postUserIdBtn setTitle:[@"@" stringByAppendingFormat:@"%@", post.userID] forState:UIControlStateNormal];
    
    // ユーザニックネーム
    self.postUserNameBtn.titleLabel.text = @"";
    self.postUserNameBtn.titleLabel.text = post.username;
    [self.postUserNameBtn setTitle:post.username forState:UIControlStateNormal];
    
    // ユーザアイコン
    CGSize cgSize = CGSizeMake(160.0f, 160.0f);
    CGSize radiusSize = CGSizeMake(80.0f, 80.0f);
    DLog(@"%@", post.iconPath);
    if(!self.postUserImageView.image){
        self.postUserImageView.alpha = 0.0f;
        self.postUserImageView.hidden = YES;
    }
    if(post.iconPath && ![post.iconPath isKindOfClass:[NSNull class]]){
        [self.postUserImageView sd_setImageWithURL:[NSURL URLWithString:post.iconPath]
                          placeholderImage:nil
                                   options: SDWebImageCacheMemoryOnly
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     
                                     image = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
                                     self.postUserImageView.image = image;
                                     
                                     // height : postImage
                                     //CGRect rect = CGRectMake(0, 0, image.size.width, self.postImageView.image.size.height);
                                     //self.postUserImageView.frame = rect;
                                     
//                                     self.postUserImageView.alpha = 0;
//                                     [UIView beginAnimations:@"fadeIn" context:nil];
//                                     [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//                                     [UIView setAnimationDuration:0.5];
//                                     self.postUserImageView.alpha = 1;
//                                     [UIView commitAnimations];
                                     
                                     self.postUserImageView.alpha = 1.0f;

                                     if(cacheType == SDImageCacheTypeMemory){
                                         self.postUserImageView.hidden = NO;
                                     }else{
//                                         [UIView animateWithDuration:1.0f animations:^{
//                                             self.postUserImageView.alpha = 0;
//                                             self.postUserImageView.alpha = 1;
//                                         }];
                                     }
                                     
                                     double delayInSeconds = 0.6;
                                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                         self.postUserImageView.hidden = NO;
                                     });
                                     
                                 }];
    }else{
        UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"ico_noimgs.png"] size:cgSize radiusSize:radiusSize];
        self.postUserImageView.image = image;
        self.postUserImageView.alpha = 1.0f;
        
        double delayInSeconds = 0.6;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.postUserImageView.hidden = NO;
        });
        
    }
}


-(void) layoutSubviews {
    [super layoutSubviews];
    [self.PostGoodBtnOnImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if([self.isGood isEqualToNumber:[NSNumber numberWithInt:VLISBOOLTRUE]]){
        [self.postGoodCnt setBackgroundImage:[UIImage imageNamed:@"ico_heart_on.png"]
                                    forState:UIControlStateNormal];
        self.postGoodCnt.imageView.image = [UIImage imageNamed:@"ico_heart_on.png"];
        [self.PostGoodBtnOnImage setImage:[UIImage imageNamed:@"btn2_like_on.png"]
                                 forState:UIControlStateNormal];
        
    }else{
        [self.postGoodCnt setBackgroundImage:[UIImage imageNamed:@"ico_heart.png"]
                                    forState:UIControlStateNormal];
        self.postGoodCnt.imageView.image = [UIImage imageNamed:@"ico_heart.png"];
        [self.PostGoodBtnOnImage setImage:[UIImage imageNamed:@"btn2_like_off.png"]
                                     forState:UIControlStateNormal];
    }
}

///セルの高さを算出
-(CGFloat) homeCellHeight:(Post *)post
{
    CGFloat postImageWidth  = [post.originalWidth floatValue];
    CGFloat postImageHeight = [post.originalHeight floatValue];
    
    CGFloat cellWidth = ([[UIScreen mainScreen] bounds].size.width / 2) - 7.0f;
    
    float scale = cellWidth / postImageWidth;
    CGFloat resizePostImageHeight = 0.0f;
    if(postImageHeight){
        resizePostImageHeight = postImageHeight * scale;
    }else{
        //iphone6 plus
        if ([[UIScreen mainScreen]bounds].size.height > 735) {
            resizePostImageHeight = 188.0f;
        }
        else{
            resizePostImageHeight = 168.0f;
        }
    }
    DLog(@"scale : %f", scale);
    DLog(@"resize post image height: %f", resizePostImageHeight);
    DLog(@"post title frame height : %f", self.postTitleLabel.frame.size.height);
    DLog(@"self bounds width : %f", [[UIScreen mainScreen]bounds].size.width);

    CGRect postImageFrame = self.postImageView.frame;
    postImageFrame.size = CGSizeMake(cellWidth, resizePostImageHeight);
    [self.postImageView setFrame:postImageFrame];
    
    CGFloat totalHeight = resizePostImageHeight + 6 + 32 + 8 + 2;
    DLog(@"totalHeight : %f", totalHeight);

    return totalHeight;

}





- (void) plusCntGood
{
    int intCntGood = [self.cntGood intValue];
    intCntGood++;
    self.cntGood = [NSNumber numberWithInt:intCntGood];
    self.postGoodLabel.text = [CommonUtil getMaxDoubleDigitsStr:self.cntGood];
    [self.goodCntBtnOnImg setTitle:[CommonUtil getMaxDoubleDigitsStr:self.cntGood]
                          forState:UIControlStateNormal];
}

- (void) minusCntGood
{
    int intCntGood = [self.cntGood intValue];
    if(intCntGood > 0){
        intCntGood--;
    }
    self.cntGood = [NSNumber numberWithInt:intCntGood];
    self.postGoodLabel.text = [CommonUtil getMaxDoubleDigitsStr:self.cntGood];
    [self.goodCntBtnOnImg setTitle:[CommonUtil getMaxDoubleDigitsStr:self.cntGood]
                          forState:UIControlStateNormal];
}



@end
