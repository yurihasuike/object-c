//
//  RankingTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/03/23.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RankingTableViewCell.h"
#import "Ranking.h"
#import "Post.h"
#import "UIImageView+Networking.h"
#import "CommonUtil.h"
#import "CoreImageHelper.h"
#import "UIImageView+WebCache.h"

@interface RankingTableViewCell()

@property (nonatomic, weak) CommonUtil *commonUtil;
@property (nonatomic) Ranking *ranking;
@property (nonatomic) NSArray *posts;

@end

@implementation RankingTableViewCell

-(id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        
    }
    
    return self;
}

- (void)configureCellForAppRecord:(Ranking *)ranking myUserPID:(NSNumber *)myUserPID
{
    self.hasPosts = NO;
    self.ranking = ranking;
    CommonUtil *commonUtil = [[CommonUtil alloc] init];

    // ユーザPID
    self.userPID = ranking.userPID;
    
    // ユーザID
    self.user_id = ranking.userID;
    if(ranking.userID) {
        [self.userIdBtn setTitle:[@"@" stringByAppendingString:ranking.userID] forState:UIControlStateNormal];
    }
    
    // ユーザアイコン
//    CGSize cgSize = CGSizeMake(50.0f, 50.0f);
//    CGSize radiusSize = CGSizeMake(23.0f, 23.0f);
    CGSize cgSize = CGSizeMake(150.0f, 150.0f);
    CGSize radiusSize = CGSizeMake(69.0f, 69.0f);
    
    if(ranking.iconPath){
        [self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:ranking.iconPath]
            placeholderImage:[UIImage imageNamed:@"ico_noimgs.png"]
            options: SDWebImageCacheMemoryOnly
            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                image = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
                self.userIconImageView.image = image;
                
//                [UIView animateWithDuration:0.8f animations:^{
//                    self.userIconImageView.alpha = 0;
//                    self.userIconImageView.alpha = 1;
//                }];
                
                [UIView transitionWithView:self.userIconImageView
                                  duration:0.2f
                                   options:UIViewAnimationOptionTransitionCrossDissolve |
                 UIViewAnimationOptionCurveLinear |
                 UIViewAnimationOptionAllowUserInteraction
                                animations:nil completion:nil];
                
            }];
    }else{
        UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"ico_noimgs.png"] size:cgSize radiusSize:radiusSize];
        self.userIconImageView.image = image;
    }

    if(myUserPID && [myUserPID isEqualToNumber:ranking.userPID]){
        self.followBtn.hidden = YES;
    }else{
        // フォローボタン
        self.followBtn.hidden = NO;
        UIImage *btnFollowImg = [UIImage imageNamed:@"ico_follow.png"];
        UIImage *btnFollowedImg = [UIImage imageNamed:@"ico_follower.png"];
        if([myUserPID isKindOfClass:[NSNumber class]]){
            if(![ranking.userPID isEqualToNumber:myUserPID]){
                // フォローしているか
                if([ranking.isFollow isKindOfClass:[NSNumber class]]){
                    NSComparisonResult result;
                    result = [ranking.isFollow compare:[NSNumber numberWithInt:0]];
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
                    self.isFollow = [NSNumber numberWithInt:1];
                    self.followBtn.hidden = YES;
                }
            }else{
                // no login
                [self.followBtn setImage:btnFollowImg forState:UIControlStateNormal];
                self.isFollow = [NSNumber numberWithInt:0];
            }
        }else{
            // no login
            [self.followBtn setImage:btnFollowImg forState:UIControlStateNormal];
            self.isFollow = [NSNumber numberWithInt:0];
        }
    }
    
    // ユーザ名前
    if( ranking.username ){
        [self.userNameBtn setTitle:ranking.username forState:UIControlStateNormal];
    }else{
        [self.userNameBtn setTitle:@"" forState:UIControlStateNormal];
    }

//    // いいね数
//    self.goodNumLabel.text = [ranking.cntGood stringValue];
//    
//    // 称号名
//    self.rankingNameLabel.text = ranking.rankTitle;
//    if(![ranking.rankTitle length]){
//        self.rankingNameImageView.hidden = YES;
//    }
    
    // 順位
    self.rankingNumLabel.text = [ranking.rank stringValue];
    self.rankingNumLabel.textColor = [UIColor whiteColor];
    // 順位背景画像
    if(self.rankingNumLabel){
        UIImage *rtImage = [UIImage alloc];
        if([self.rankingNumLabel.text isEqualToString:@"1"]) {
            rtImage = [UIImage imageNamed:@"ico_rank1.png"];
        }else if([self.rankingNumLabel.text isEqualToString:@"2"]){
            rtImage = [UIImage imageNamed:@"ico_rank2.png"];
        }else if([self.rankingNumLabel.text isEqualToString:@"3"]){
            rtImage = [UIImage imageNamed:@"ico_rank3.png"];
        }else {
            rtImage = [UIImage imageNamed:@"ico_rank.png"];
            self.rankingNumLabel.textColor = [UIColor darkGrayColor];
        }
        self.rankinguBgImageView.image = rtImage;
    }

    // 投稿画像
    self.post1ImageView.image = nil;
    self.post2ImageView.image = nil;
    self.post3ImageView.image = nil;
    self.post4ImageView.image = nil;
    self.post1ImageView.alpha = 0;
    self.post2ImageView.alpha = 0;
    self.post3ImageView.alpha = 0;
    self.post4ImageView.alpha = 0;
    
    // 80 x 80
    CGFloat listImgWidth = [UIScreen mainScreen].bounds.size.width / 4;
    if([ranking.posts isKindOfClass:[NSArray class]]){
        //self.posts = (NSArray *)ranking.posts;
        int cnt = 0;
        @try {
            if(ranking.posts && [ranking.posts count] > 0){
            
            //for (Post *post in ranking.posts) {
            for (NSDictionary *data in ranking.posts) {
                
                cnt++;
                NSString *postImgPath = nil;
                //UIImage *postImage = [UIImage alloc];
                //DLog(@"id: %@:%@", post.postID, post.thumbnailPath);
                
                if(cnt == 1){
                    //self.postID1 = post.postID;
                    self.postID1 = data[@"id"];
                    //self.post1ImageView.tag = [post.postID integerValue];
                    self.post1ImageView.tag = [data[@"id"] integerValue];
                    
                    //postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: [data objectForKey:@"img"]]]];
                    //self.post1ImageView.image =postImage;
                    
//                    if(post.thumbnailPath){
//                        postImgPath = post.thumbnailPath;
//                        self.hasPosts = YES;
//                    }else if(post.transcodedPath){
//                        postImgPath = post.transcodedPath;
//                        self.hasPosts = YES;
////                    }else if(post.originalPath){
////                        postImgPath = post.originalPath;
////                        self.hasPosts = YES;
//                    }else{
//                        self.post1ImageView.image = nil;
//                        self.post1ImageView.hidden = YES;
//                    }
                    
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
                                                         [self doTaskAsynchronously:^{
                                                             // 320 : 80.0f
                                                             [CoreImageHelper centerCroppingImageWithImage:image atSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4) completion:^(UIImage *resultImg){
                                                                 
                                                                 self.post1ImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                                                 self.post1ImageView.image = resultImg;
                                                                 
                                                                 [UIView animateWithDuration:0.2f animations:^{
                                                                     self.post1ImageView.alpha = 0;
                                                                     self.post1ImageView.alpha = 1;
                                                                 }];
                                                                 //[self.post1ImageView sizeToFit];
                                                                 
                                                                 CGRect post1ImageFrame = self.post1ImageView.frame;
                                                                 post1ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
                                                                 self.post1ImageView.frame = CGRectMake(0,
                                                                                                        64,
                                                                                                        post1ImageFrame.size.width,
                                                                                                        post1ImageFrame.size.height);
                                                                 
                                                                 DLog(@"post image width %f", resultImg.size.width);
                                                         }];
                                                         
                                                            
                                                             
                                                             
//                                                             [UIView animateWithDuration:0.8f animations:^{
//                                                                 self.post1ImageView.alpha = 0;
//                                                                 self.post1ImageView.alpha = 1;
//                                                             }];
                                                             
//                                                             [UIView transitionWithView:self.post1ImageView
//                                                                               duration:0.8f
//                                                                                options:UIViewAnimationOptionTransitionCrossDissolve |
//                                                                                        UIViewAnimationOptionCurveLinear |
//                                                                                        UIViewAnimationOptionAllowUserInteraction
//                                                                             animations:nil completion:nil];
                                                             
                                                             
                                                             
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
                                                      [self doTaskAsynchronously:^{
                                                          // 320 : 80.0f
                                                          [CoreImageHelper centerCroppingImageWithImage:image atSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4) completion:^(UIImage *resultImg){
                                                              
                                                              
                                                              self.post2ImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                                              self.post2ImageView.image = resultImg;
                                                              
                                                              [UIView animateWithDuration:0.2f animations:^{
                                                                  self.post2ImageView.alpha = 0;
                                                                  self.post2ImageView.alpha = 1;
                                                              }];
                                                              //[self.post2ImageView sizeToFit];
                                                              
                                                              CGRect post2ImageFrame = self.post2ImageView.frame;
                                                              post2ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
                                                              self.post2ImageView.frame = CGRectMake(listImgWidth,
                                                                                                     64,
                                                                                                     post2ImageFrame.size.width,
                                                                                                     post2ImageFrame.size.height);
                                                              
                                                              
                                                              //                                                          [UIView animateWithDuration:0.8f animations:^{
                                                              //                                                              self.post2ImageView.alpha = 0;
                                                              //                                                              self.post2ImageView.alpha = 1;
                                                              //                                                          }];
                                                              
                                                              //                                                          [UIView transitionWithView:self.post2ImageView
                                                              //                                                                            duration:0.8f
                                                              //                                                                             options:UIViewAnimationOptionTransitionCrossDissolve |
                                                              //                                                           UIViewAnimationOptionCurveLinear |
                                                              //                                                           UIViewAnimationOptionAllowUserInteraction
                                                              //                                                                          animations:nil completion:nil];
                                                              
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
                                                      [self doTaskAsynchronously:^{
                                                          // 320 : 80.0f
                                                          [CoreImageHelper centerCroppingImageWithImage:image atSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4) completion:^(UIImage *resultImg){
                                                              
                                                              self.post3ImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                                              self.post3ImageView.image = resultImg;
                                                              
                                                              [UIView animateWithDuration:0.2f animations:^{
                                                                  self.post3ImageView.alpha = 0;
                                                                  self.post3ImageView.alpha = 1;
                                                              }];
                                                              //[self.post3ImageView sizeToFit];
                                                              
                                                              CGRect post3ImageFrame = self.post3ImageView.frame;
                                                              post3ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
                                                              self.post3ImageView.frame = CGRectMake(listImgWidth * 2,
                                                                                                     64,
                                                                                                     post3ImageFrame.size.width,
                                                                                                     post3ImageFrame.size.height);
                                                              
                                                              
                                                              
                                                              //                                                          [UIView animateWithDuration:0.8f animations:^{
                                                              //                                                              self.post3ImageView.alpha = 0;
                                                              //                                                              self.post3ImageView.alpha = 1;
                                                              //                                                          }];
                                                              
                                                              //                                                          [UIView transitionWithView:self.post3ImageView
                                                              //                                                                            duration:0.8f
                                                              //                                                                             options:UIViewAnimationOptionTransitionCrossDissolve |
                                                              //                                                           UIViewAnimationOptionCurveLinear |
                                                              //                                                           UIViewAnimationOptionAllowUserInteraction
                                                              //                                                                          animations:nil completion:nil];
                                                              
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
                                                      [self doTaskAsynchronously:^{
                                                          // 320 : 80.0f
                                                          [CoreImageHelper centerCroppingImageWithImage:image atSize:CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4) completion:^(UIImage *resultImg){
                                                              
                                                              
                                                              self.post4ImageView.translatesAutoresizingMaskIntoConstraints = YES;
                                                              self.post4ImageView.image = resultImg;
                                                              
                                                              [UIView animateWithDuration:0.2f animations:^{
                                                                  self.post4ImageView.alpha = 0;
                                                                  self.post4ImageView.alpha = 1;
                                                              }];
                                                              
                                                              //[self.post4ImageView sizeToFit];
                                                              
                                                              CGRect post4ImageFrame = self.post4ImageView.frame;
                                                              post4ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
                                                              self.post4ImageView.frame = CGRectMake(listImgWidth * 3,
                                                                                                     64,
                                                                                                     post4ImageFrame.size.width,
                                                                                                     post4ImageFrame.size.height);
                                                              
                                                              //                                                          [UIView animateWithDuration:0.8f animations:^{
                                                              //                                                              self.post4ImageView.alpha = 0;
                                                              //                                                              self.post4ImageView.alpha = 1;
                                                              //                                                          }];
                                                              
                                                              //                                                          [UIView transitionWithView:self.post4ImageView
                                                              //                                                                            duration:0.8f
                                                              //                                                                             options:UIViewAnimationOptionTransitionCrossDissolve |
                                                              //                                                           UIViewAnimationOptionCurveLinear |
                                                              //                                                           UIViewAnimationOptionAllowUserInteraction
                                                              //                                                                          animations:nil completion:nil];
                                                              
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
            DLog(@"%@", e);
        }
    }
    
}


-(void) layoutSubviews {
    [super layoutSubviews];
    
//    CGFloat listImgWidth = [UIScreen mainScreen].bounds.size.width / 4;
    
//    if(self.post1ImageView.image != nil){
//        CGRect post1ImageFrame = self.post1ImageView.frame;
//        post1ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
//        [self.post1ImageView setFrame:CGRectMake(0,
//                                             self.bounds.origin.y,
//                                             post1ImageFrame.size.width,
//                                             post1ImageFrame.size.height)];
//    }
//    
//    if(self.post2ImageView.image != nil){
//        CGRect post2ImageFrame = self.post2ImageView.frame;
//        post2ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
//        [self.post2ImageView setFrame:CGRectMake(listImgWidth * 1,
//                                             self.bounds.origin.y,
//                                             post2ImageFrame.size.width,
//                                             post2ImageFrame.size.height)];
//    }
//    
//    if(self.post3ImageView.image != nil){
//        CGRect post3ImageFrame = self.post3ImageView.frame;
//        post3ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
//        [self.post3ImageView setFrame:CGRectMake(listImgWidth * 2,
//                                             self.bounds.origin.y,
//                                             post3ImageFrame.size.width,
//                                             post3ImageFrame.size.height)];
//    }
//    
//    if(self.post4ImageView.image != nil){
//        CGRect post4ImageFrame = self.post4ImageView.frame;
//        post4ImageFrame.size = CGSizeMake(listImgWidth, listImgWidth);
//        [self.post4ImageView setFrame:CGRectMake(listImgWidth * 1,
//                                             self.bounds.origin.y,
//                                             post4ImageFrame.size.width,
//                                             post4ImageFrame.size.height)];
//    }
    
}




- (void)awakeFromNib {
    // Initialization code
}


//-(void) layoutSubviews {
//    [super layoutSubviews];
//
//    //CGRect bounds = self.bounds;
//    //[self sizeThatFits:bounds.size withLayout:YES];
//    
//    // popularLineImageView
//    
//    CGFloat padding = 6.0f;
//    CGFloat totalPadding = 0.0f;
//    CGFloat userIconHeight = 48.0f;
//    CGFloat postImgHeight = 80.0f;
//    //CGRect postImgRect = CGRectMake(0, 0, self.frame.size.width, 0);
////    if(self.userIconImageView && self.userIconImageView.image){
////        totalPadding = self.userIconImageView.image.size.height + (padding * 2);
////    }
//    
//    //DLog(@"%@", self.post1ImageView.image);
//    totalPadding = userIconHeight + (padding * 2);
//
//    
////    if(self.hasPosts){
////        totalPadding = totalPadding + self.post4ImageView.image.size.height + padding;
////    }
//    totalPadding = totalPadding + postImgHeight + padding;
//    self.rankingLineImageView.frame = CGRectMake(0, totalPadding,
//                                                 self.rankingLineImageView.image.size.width,
//                                                 self.rankingLineImageView.image.size.height);
//    //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.fram.origin.y, self.view.frame.size.width, totalPadding + 6);
//}

- (CGFloat) rankingCellHeight
{
    CGFloat cellPostWidth = [[UIScreen mainScreen]bounds].size.width / 4;
    // 64 + 150 + 8 = 222
    CGFloat cellHeight = 64 + cellPostWidth + 8;
    return cellHeight;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///非同期で処理を行う
- (void)doTaskAsynchronously:(void(^)())block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}

@end
