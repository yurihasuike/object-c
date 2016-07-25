//
//  PopularTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PopularTableViewCell.h"
#import "Popular.h"
#import "Post.h"
#import "UIImageView+Networking.h"
#import "CommonUtil.h"
#import "CoreImageHelper.h"
#import "UIImageView+WebCache.h"

@interface PopularTableViewCell()

@property (nonatomic, weak) CommonUtil *commonUtil;
//@property (strong, nonatomic) NSMutableArray *posts;

@end

@implementation PopularTableViewCell

- (void)configureCellForAppRecord:(Popular *)popular
{

    self.popular = popular;
    CommonUtil *commonUtil = [[CommonUtil alloc] init];
    
    // userPID
    if(popular.userPID){
        self.userPID = popular.userPID;
    }
    
    // user_id
    self.user_id = popular.userID;
    if(popular.userID) {
        //self.userIdLabel.text = [@"@" stringByAppendingString:popular.userID];
        [self.userIdBtn setTitle:[@"@" stringByAppendingString:popular.userID] forState:UIControlStateNormal];
    }

    // ユーザアイコン
//    CGSize cgSize = CGSizeMake(50.0f, 50.0f);
//    CGSize radiusSize = CGSizeMake(23.0f, 23.0f);
    CGSize cgSize = CGSizeMake(200.0f, 200.0f);
    CGSize radiusSize = CGSizeMake(92.0f, 92.0f);
    if(popular.iconPath && ![popular.iconPath isKindOfClass:[NSNull class]]){
        [self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:popular.iconPath]
                                  placeholderImage:[UIImage imageNamed:@"ico_noimgs.png"]
                                           options: SDWebImageCacheMemoryOnly
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             [CommonUtil doTaskAsynchronously:^{
                                                 
                                                 // 320 : 80.0f
                                                 [CoreImageHelper centerCroppingImageWithImage:image atSize:cgSize completion:^(UIImage *resultImg){
                                                     
                                                     resultImg = [commonUtil createRoundedRectImage:resultImg size:cgSize radiusSize:radiusSize];
                                                     self.userIconImageView.alpha = 1;
                                                     self.userIconImageView.image = resultImg;
                                                     
                                                     [UIView animateWithDuration:0.3f animations:^{
                                                         self.userIconImageView.alpha = 0;
                                                         self.userIconImageView.alpha = 1;
                                                     }];
                                                 }];
                                             }];
                                         }];
    }else{
        UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"ico_noimgs.png"] size:cgSize radiusSize:radiusSize];
        self.userIconImageView.image = image;
    }

    // フォローボタン
    UIImage *btnFollowImg = [UIImage imageNamed:@"ico_follow.png"];
    UIImage *btnFollowedImg = [UIImage imageNamed:@"ico_follower.png"];
    
    // フォローしているか
    if([popular.isFollow isKindOfClass:[NSNumber class]]){
        NSComparisonResult result;
        result = [popular.isFollow compare:[NSNumber numberWithInt:0]];
        switch(result) {
            case NSOrderedSame: // 一致 : フォローしていない
            case NSOrderedAscending: // 謎パターン： フォローしていないとする
                [self.followBtn setImage:btnFollowImg forState:UIControlStateNormal];
                self.isFollow = [NSNumber numberWithInt:0];
                break;
            case NSOrderedDescending: // dispFollowが大きい: フォローしている
                [self.followBtn setImage:btnFollowedImg forState:UIControlStateNormal];
                self.isFollow = [NSNumber numberWithInt:1];
                break;
        }
    }else{
        [self.followBtn setImage:btnFollowImg forState:UIControlStateNormal];
        self.isFollow = [NSNumber numberWithInt:0];
    }

    // ユーザ名前
    if( popular.username ){
        [self.userNameBtn setTitle:popular.username forState:UIControlStateNormal];
    }else{
        [self.userNameBtn setTitle:@"" forState:UIControlStateNormal];
    }

    DLog(@"pop userID : %@", popular.userID);
    DLog(@"pop userName : %@", popular.username);
    DLog(@"pop iconPath : %@", popular.iconPath);
    DLog(@"pop isFollow : %@", popular.isFollow);
    DLog(@"pop post_cnt : %lu", (unsigned long)[popular.posts count]);
    
    // 投稿画像
    self.post1ImageView.image = nil;
    self.post2ImageView.image = nil;
    self.post3ImageView.image = nil;
    self.post4ImageView.image = nil;
    self.post1ImageView.alpha = 0;
    self.post2ImageView.alpha = 0;
    self.post3ImageView.alpha = 0;
    self.post4ImageView.alpha = 0;

    self.hasPosts = NO;
    CGFloat listImgWidth = [UIScreen mainScreen].bounds.size.width / 4;
    if([popular.posts isKindOfClass:[NSMutableArray class]]){
        //self.posts = [(NSMutableArray *)popular.posts mutableCopy];
        int cnt = 0;
        @try {
            if(popular.posts && [popular.posts count] > 0){
            
            //for (Post *post in popular.posts) {
            for (NSDictionary *data in popular.posts) {
                cnt++;
                NSString *postImgPath = nil;
                
                if(cnt == 1){
                    //self.postID1 = post.postID;
                    self.postID1 = data[@"id"];
                    //self.post1ImageView.tag = [post.postID integerValue];
                    self.post1ImageView.tag = [data[@"id"] integerValue];
                    
                    //postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: [data objectForKey:@"img"]]]];
                    //self.post1ImageView.image =postImage;
                    
                    if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                            ![data[@"medium"][@"thumbnail"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"thumbnail"];
                        self.hasPosts = YES;
                    }else if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                             ![data[@"medium"][@"transcoded_file"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"transcoded_file"];
                        self.hasPosts = YES;
                    }else if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                                ![data[@"medium"][@"original_file"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"original_file"];
                        self.hasPosts = YES;
                    }else{
                        self.post1ImageView.image = nil;
                        self.post1ImageView.hidden = YES;
                    }
                    if(postImgPath){
                        [self.post1ImageView sd_setImageWithURL:[NSURL URLWithString: postImgPath]
                                           placeholderImage: nil
                                                    options: SDWebImageCacheMemoryOnly
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                      [CommonUtil doTaskAsynchronously:^{
                                                          [CoreImageHelper centerCroppingImageWithImage:image atSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4) completion:^(UIImage *resultImg){
                                                              
                                                              
                                                              self.post1ImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                                              self.post1ImageView.image = resultImg;
                                                              self.post1ImageView.alpha = 1;
                                                              //[self.post1ImageView sizeToFit];
                                                              
                                                              CGRect post1ImageFrame = self.post1ImageView.frame;
                                                              post1ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
                                                              self.post1ImageView.frame = CGRectMake(0,
                                                                                                     64,
                                                                                                     post1ImageFrame.size.width,
                                                                                                     post1ImageFrame.size.height);
                                                              self.post1ImageView.alpha = 0;
                                                              [UIView animateWithDuration:0.3f animations:^{
                                                                  self.post1ImageView.alpha = 0;
                                                                  self.post1ImageView.alpha = 1;
                                                              }];
                                                          }];
 
                                                      }];
                                                  }];
                    }else{
                        self.post1ImageView.image = nil;
                        self.post1ImageView.alpha = 1;
                    }
                    
                }else if(cnt == 2){

                    self.postID2 = data[@"id"];
                    self.post2ImageView.tag = [data[@"id"] integerValue];
                    //postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: [data objectForKey:@"img"]]]];
                    //self.post2ImageView.image =postImage;
                    
                    if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                       ![data[@"medium"][@"thumbnail"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"thumbnail"];
                        self.hasPosts = YES;
                    }else if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                             ![data[@"medium"][@"transcoded_file"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"transcoded_file"];
                        self.hasPosts = YES;
                    }else if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                             ![data[@"medium"][@"original_file"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"original_file"];
                        self.hasPosts = YES;
                    }else{
                        self.post2ImageView.image = nil;
                        self.post2ImageView.hidden = YES;
                    }
                    
                    if(postImgPath){
                    
                        [self.post2ImageView sd_setImageWithURL:[NSURL URLWithString: postImgPath]
                                           placeholderImage: nil
                                                    options: SDWebImageCacheMemoryOnly
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                      [CommonUtil doTaskAsynchronously:^{
                                                          [CoreImageHelper centerCroppingImageWithImage:image atSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4) completion:^(UIImage *resultImg){
                                                              
                                                              self.post2ImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                                              self.post2ImageView.image = resultImg;
                                                              self.post2ImageView.alpha = 1;
                                                              //[self.post2ImageView sizeToFit];
                                                              
                                                              CGRect post2ImageFrame = self.post2ImageView.frame;
                                                              post2ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
                                                              self.post2ImageView.frame = CGRectMake(listImgWidth,
                                                                                                     64,
                                                                                                     post2ImageFrame.size.width,
                                                                                                     post2ImageFrame.size.height);
                                                              self.post2ImageView.alpha = 0;
                                                              [UIView animateWithDuration:0.3f animations:^{
                                                                  self.post2ImageView.alpha = 0;
                                                                  self.post2ImageView.alpha = 1;
                                                              }];
                                                          }];
                                                      }];
                        }];
                    }else{
                        self.post2ImageView.image = nil;
                        self.post2ImageView.alpha = 1;
                    }

                }else if (cnt == 3){

                    self.postID3 = data[@"id"];
                    self.post3ImageView.tag = [data[@"id"] integerValue];
                    //postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: [data objectForKey:@"img"]]]];
                    //self.post3ImageView.image =postImage;
                    
                    if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                       ![data[@"medium"][@"thumbnail"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"thumbnail"];
                        self.hasPosts = YES;
                    }else if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                             ![data[@"medium"][@"transcoded_file"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"transcoded_file"];
                        self.hasPosts = YES;
                    }else if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                             ![data[@"medium"][@"original_file"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"original_file"];
                        self.hasPosts = YES;
                    }else{
                        self.post3ImageView.image = nil;
                        self.post3ImageView.hidden = YES;
                    }
                    
                    if(postImgPath){
                    
                        [self.post3ImageView sd_setImageWithURL:[NSURL URLWithString: postImgPath]
                                           placeholderImage: nil
                                                    options: SDWebImageCacheMemoryOnly
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                      [CommonUtil doTaskAsynchronously:^{
                                                          [CoreImageHelper centerCroppingImageWithImage:image atSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4) completion:^(UIImage *resultImg){
                                                              
                                                              
                                                              self.post3ImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                                              self.post3ImageView.image = resultImg;
                                                              self.post3ImageView.alpha = 1;
                                                              //[self.post3ImageView sizeToFit];
                                                              
                                                              CGRect post3ImageFrame = self.post3ImageView.frame;
                                                              post3ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
                                                              self.post3ImageView.frame = CGRectMake(listImgWidth*2,
                                                                                                     64,
                                                                                                     post3ImageFrame.size.width,
                                                                                                     post3ImageFrame.size.height);
                                                              
                                                              self.post3ImageView.alpha = 0;
                                                              [UIView animateWithDuration:0.3f animations:^{
                                                                  self.post3ImageView.alpha = 0;
                                                                  self.post3ImageView.alpha = 1;
                                                              }];
                                                          }];
 
                                                      }];
                                                  }];
                    }else{
                        self.post3ImageView.image = nil;
                        self.post3ImageView.alpha = 1;
                    }

                }else if (cnt == 4){
                    
                    self.postID4 = data[@"id"];
                    self.post4ImageView.tag = [data[@"id"] integerValue];
                    //postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: [data objectForKey:@"img"]]]];
                    //self.post4ImageView.image =postImage;
                    
                    if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                       ![data[@"medium"][@"thumbnail"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"thumbnail"];
                        self.hasPosts = YES;
                    }else if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                             ![data[@"medium"][@"transcoded_file"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"transcoded_file"];
                        self.hasPosts = YES;
                    }else if(![data[@"medium"] isKindOfClass:[NSNull class]] &&
                             ![data[@"medium"][@"original_file"] isKindOfClass:[NSNull class]]){
                        postImgPath = data[@"medium"][@"original_file"];
                        self.hasPosts = YES;
                    }else{
                        self.post4ImageView.image = nil;
                        self.post4ImageView.hidden = YES;
                    }
                    
                    if(postImgPath){
                    
                        [self.post4ImageView sd_setImageWithURL:[NSURL URLWithString: postImgPath]
                                           placeholderImage: nil
                                                    options: SDWebImageCacheMemoryOnly
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                      [CommonUtil doTaskAsynchronously:^{
                                                          [CoreImageHelper centerCroppingImageWithImage:image atSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4) completion:^(UIImage *resultImg){
                                                              
                                                              
                                                              self.post4ImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                                              self.post4ImageView.image = resultImg;
                                                              self.post4ImageView.alpha = 1;
                                                              
                                                              CGRect post4ImageFrame = self.post4ImageView.frame;
                                                              post4ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
                                                              self.post4ImageView.frame =
                                                                  CGRectMake(listImgWidth*3,
                                                                             64,
                                                                             post4ImageFrame.size.width,
                                                                             post4ImageFrame.size.height);
                                                              self.post4ImageView.alpha = 0;
                                                              [UIView animateWithDuration:0.3f animations:^{
                                                                  self.post4ImageView.alpha = 0;
                                                                  self.post4ImageView.alpha = 1;
                                                              }];
                                                          }];

                                                      }];
                                                  }];
                    }else{
                        self.post4ImageView.image = nil;
                        self.post4ImageView.alpha = 1;
                    }

                }
            }
            }
        }
        @catch (NSException *e) {
            NSLog(@"%@", e);
        }
    }

}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    //CGRect bounds = self.bounds;
    //[self sizeThatFits:bounds.size withLayout:YES];
    
    // popularLineImageView
    
//    CGFloat padding = 6.0f;
//    CGFloat totalPadding = 0.0f;
//    CGFloat userIconHeight = 48.0f;
//    CGFloat postImgHeight = 80.0f;
//
//    totalPadding = userIconHeight + (padding * 2);
//
//    totalPadding = totalPadding + postImgHeight + padding;
//    self.popularLineView.frame = CGRectMake(8, totalPadding,
//                                            self.popularLineView.frame.size.width,
//                                            self.popularLineView.frame.size.height);
    
    //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.fram.origin.y, self.view.frame.size.width, totalPadding + 6);
}

//- (CGSize)sizeThatFits:(CGSize)size
//{
//    return [self sizeThatFits:size withLayout:NO];
//}
//
//- (CGSize)sizeThatFits:(CGSize)size withLayout:(BOOL)withLayout
//{
//    CGRect imageViewFrame;
//    imageViewFrame.origin.x = STMargin;
//    imageViewFrame.origin.y = STMargin;
//    imageViewFrame.size.width = size.width - STMargin*2;
//    imageViewFrame.size.height = self.imageView.image.size.height * imageViewFrame.size.width / self.imageView.image.size.width;
//    if (withLayout) {
//        self.imageView.frame = imageViewFrame;
//    }
//    
//    CGRect captionLabelFrame;
//    captionLabelFrame.origin.x = STMargin;
//    captionLabelFrame.origin.y = imageViewFrame.origin.y + imageViewFrame.size.height;
//    captionLabelFrame.size.width = size.width - STMargin*2;
//    captionLabelFrame.size.height = size.height;
//    captionLabelFrame.size = [self.textLabel sizeThatFits:captionLabelFrame.size];
//    if (withLayout) {
//        self.textLabel.frame = captionLabelFrame;
//    }
//    
//    size.height = captionLabelFrame.origin.y + captionLabelFrame.size.height + STMargin;
//    return size;
//}


- (void)awakeFromNib {
    // Initialization code
}

- (CGFloat) popularCellHeight
{
    CGFloat cellPostWidth = [[UIScreen mainScreen]bounds].size.width / 4;
    // 64 + 150 + 8 = 222
    CGFloat cellHeight = 64 + cellPostWidth + 8;
    return cellHeight;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
