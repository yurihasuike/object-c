//
//  DetailImageTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/07/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "DetailImageTableViewCell.h"
#import "UIImageView+Networking.h"
#import "CommonUtil.h"
#import "UIImageView+WebCache.h"

@implementation DetailImageTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureCellForAppRecord:(Post *)loadPost UIImage:(UIImage *)postTempImage
{
    NSString *postImgPath = loadPost.thumbnailPath;
    if(loadPost.transcodedPath){
        postImgPath = loadPost.transcodedPath;
    }else if(loadPost.originalPath){
        postImgPath = loadPost.originalPath;
    }
    
    if (loadPost.isMovie)
    {
        postImgPath = nil;
        self.postImageView.image = postTempImage;
        self.postImageView.userInteractionEnabled = YES;
        self.postImageView.tag = 999;
        [self.playIconImgView setHidden:NO];
    
    }else{
        self.postImageView.image = nil;
        [self.playIconImgView setHidden:YES];
    }
    //self.postImageView = nil;
    //self.postImageView.contentMode = UIViewContentModeScaleToFill;
    if(postImgPath && ![postImgPath isKindOfClass:[NSNull class]]){
        
        // postImageView
        [self.postImageView sd_setImageWithURL:[NSURL URLWithString:postImgPath]
                              placeholderImage:postTempImage
                                       options: SDWebImageCacheMemoryOnly
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         
//                                         if(cacheType == SDImageCacheTypeMemory){
//                                             self.postImageView.alpha = 1;
//                                         }else{
//                                             [UIView animateWithDuration:0.6f animations:^{
//                                                 self.postImageView.alpha = 0;
//                                                 self.postImageView.alpha = 1;
//                                             }];
//                                         }


                                     }];
    }

}

-(void) layoutSubviews {
    [super layoutSubviews];
    
}

- (CGFloat)calcCellHeight:(Post *)post
{
    if(post.originalWidth.intValue == 0){
        return 300;
    }
    
#if CGFLOAT_IS_DOUBLE
    CGFloat postImageWidth  = [post.originalWidth doubleValue];
    CGFloat postImageHeight = [post.originalHeight doubleValue];
#else
    CGFloat postImageWidth  = [post.originalWidth floatValue];
    CGFloat postImageHeight = [post.originalHeight floatValue];
#endif
    
    DLog(@"post image org width : %@", post.originalWidth);
    DLog(@"post image org height : %@", post.originalHeight);
    
    float scale = [[UIScreen mainScreen] applicationFrame].size.width / postImageWidth;
    CGFloat resizeHeight = postImageHeight * scale;
    self.cellHeight = resizeHeight;
    return self.cellHeight;
}


@end
