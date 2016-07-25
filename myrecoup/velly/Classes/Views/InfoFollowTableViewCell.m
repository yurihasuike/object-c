//
//  InfoTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/03/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "InfoFollowTableViewCell.h"
#import "Info.h"
#import "UIImageView+Networking.h"
#import "UIImageView+WebCache.h"
#import "CommonUtil.h"

extern NSString * const FormatInfoType_toString[];
NSString * const FormatInfoType_toString[] = {
    [VLINFOTYPEFOLLOWED]    = @"f",
    [VLINFOTYPERANKUP]      = @"r",
    [VLINFOTYPELIKED]       = @"l",
    [VLINFOTYPECOMMENTED]   = @"c",
    [VLINFOTYPEOFFICIALNEWS] = @"n",
    [VLINFOTYPEOFFICIALIMPORTANTNEWS] = @"i",
    
};
// ex) NSString *str = FormatInfoType_toString[theEnumValue];

@interface InfoFollowTableViewCell ()

@property (nonatomic, weak) CommonUtil *commonUtil;
@property (nonatomic) Info *info;

@end

@implementation InfoFollowTableViewCell

- (void)configureCellForAppRecord:(Info *)info
{
    
    //self.info = info;
    CommonUtil *commonUtil = [[CommonUtil alloc] init];
    
    // infoType  f: followed, r: rankup, l: liked, c: commented
    self.infoType = info.infoType;
    
    // userPID
    self.userPID = info.userPID;
    // userID
    self.user_id = info.userID;
    // postPID
    self.postID  = info.postID;
    
    // ユーザ名前
    DLog(@"%@",info.username);
    if(info.username){
        self.userNameLabel.text = info.username;
    }else{
        self.userNameLabel.text = @"";
    }
    self.userNameLabel.hidden = YES;

    // cell 高さベース
    self.cellHeight = 10 + 20 + 21 + 3;    // 10 + resizeTitle + 21 + 3   min 64;
    
    
    // ユーザアイコン
    // infoType : f,l,c other user  r my_user
    //
    //UIImage *iconImage = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: info.iconPath]]];
//    CGSize cgSize = CGSizeMake(50.0f, 50.0f);
//    CGSize radiusSize = CGSizeMake(23.0f, 23.0f);
    CGSize cgSize = CGSizeMake(200.0f, 200.0f);
    CGSize radiusSize = CGSizeMake(92.0f, 92.0f);

    //UIImage *iconEditImage = [commonUtil createRoundedRectImage:iconImage size:cgSize radiusSize:radiusSize];
    //self.iconImageView.image = iconEditImage;
    //[self.iconImageView setImageURL:[NSURL URLWithString:info.iconPath]];

    self.iconImageView.tag = [info.userPID integerValue];
    if(info.iconPath){
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:info.iconPath]
                              placeholderImage:[UIImage imageNamed:@"ico_noimgs.png"]
                                       options: SDWebImageCacheMemoryOnly
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         
                                         __block UIImage *bImage = image;
                                         [CommonUtil doTaskAsynchronously:^{
                                             bImage = [commonUtil createRoundedRectImage:bImage
                                                                                   size:cgSize
                                                                             radiusSize:radiusSize];
                                             [CommonUtil doTaskSynchronously:^{
                                                 self.iconImageView.image = bImage;
                                                 self.iconImageView.alpha = 0;
                                                 [UIView animateWithDuration:0.4f animations:^{
                                                     self.iconImageView.alpha = 0;
                                                     self.iconImageView.alpha = 1;
                                                 }];
                                             }];
                                         }];
                                     }];
    }else{
        self.iconImageView.image = [UIImage imageNamed:@"ico_noimgs.png"];
    }

    // infoType
    // 2 f : 自分がフォローされた場合
    // 3 l : 自分の投稿にいいねされた場合
    // 4 r : 自分の順位が50以内で変動した時
    // c : 自分の投稿にコメントされて時
    self.iconImageView.hidden = YES;
    self.userNameLabel.hidden = YES;
    //self.infoDateLabel.hidden = YES;
    self.infoFollowBtn.hidden = YES;
    self.infoFollowTextSuffixLabel.hidden = YES;        // いいね / フォロー テキスト語尾
    self.infoGoodPostImageView.hidden = YES;            // いいね投稿画像
    self.infoRankUpImageView.hidden = YES;              // ランキング変更アイコン画像
    self.infoRankUpLabel.hidden = YES;                  // ランキング変更テキスト
    self.infoOfficialNewsLabel.hidden = YES;            // 公式ニュース/公式ニュース（重要）
    
    if ( self.infoType && [self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPEFOLLOWED]] ){
        // f : 自分がフォローされた場合
        self.iconImageView.hidden = NO;
        self.userNameLabel.hidden = NO;
        self.infoFollowBtn.hidden = NO;
        self.infoFollowTextSuffixLabel.text = nil;
        self.infoFollowTextSuffixLabel.hidden = NO;
        
        CGFloat nameLength = [info.username length];
        NSString *followMsg = [info.username stringByAppendingString:@" "];
        followMsg = [followMsg stringByAppendingString:NSLocalizedString(@"InfoFollowUserSuffix", nil)];
        
//        NSMutableAttributedString *attrStr;
//        attrStr = [[NSMutableAttributedString alloc] initWithString:followMsg];
        
        CGFloat lineHeight = 14.0f;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [paragraphStyle setMinimumLineHeight:lineHeight] ;
        [paragraphStyle setMaximumLineHeight:lineHeight] ;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:followMsg attributes:attributes];
        
        [attributedText addAttribute:NSFontAttributeName
                        value:JPBFONT(11)
                        range:NSMakeRange(0, nameLength)];
        [attributedText addAttribute:NSForegroundColorAttributeName
                        value:USER_DISPLAY_NAME_COLOR
                        range:NSMakeRange(0, nameLength)];
        
        [self.infoFollowTextSuffixLabel setAttributedText:attributedText];
        self.infoFollowTextSuffixLabel.numberOfLines = 0;
        
        [self.infoFollowTextSuffixLabel sizeToFit];
        self.cellHeight += self.infoFollowTextSuffixLabel.frame.size.height;
        
        self.userNameLabel.hidden = YES;

    }else if ( self.infoType && [self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPELIKED]] ){
        // l : 自分の投稿にいいねされた場合
        self.iconImageView.hidden = NO;
        self.userNameLabel.hidden = NO;
        self.infoFollowTextSuffixLabel.text = nil;
        self.infoFollowTextSuffixLabel.hidden = NO;
        self.infoGoodPostImageView.hidden = NO;
        
        CGFloat nameLength = [info.username length];
        NSString *likewMsg = [info.username stringByAppendingString:@" "];
        likewMsg = [likewMsg stringByAppendingString:NSLocalizedString(@"InfoLikeUserSuffix", nil)];
        
//        NSMutableAttributedString *attrStr;
//        attrStr = [[NSMutableAttributedString alloc] initWithString:likewMsg];
        
        CGFloat lineHeight = 14.0f;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [paragraphStyle setMinimumLineHeight:lineHeight] ;
        [paragraphStyle setMaximumLineHeight:lineHeight] ;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:likewMsg attributes:attributes];
        
        [attributedText addAttribute:NSFontAttributeName
                        value:JPBFONT(11)
                        range:NSMakeRange(0, nameLength)];
        [attributedText addAttribute:NSForegroundColorAttributeName
                        value:USER_DISPLAY_NAME_COLOR
                        range:NSMakeRange(0, nameLength)];
        [self.infoFollowTextSuffixLabel setAttributedText:attributedText];
        
        [self.infoFollowTextSuffixLabel sizeToFit];
        self.cellHeight += self.infoFollowTextSuffixLabel.frame.size.height;
        
        
        self.userNameLabel.hidden = YES;
        
        
    }else if ( self.infoType && [self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPERANKUP]] ){
        // r : 自分の順位が50以内で変動した時
        self.userNameLabel.hidden = YES;
        self.infoRankUpImageView.hidden = NO;
        self.infoRankUpLabel.hidden = NO;
        self.iconImageView.hidden = YES;

    }else if ( self.infoType && [self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPECOMMENTED]] ){
        // c : 自分の投稿にコメントされた場合
        self.iconImageView.hidden = NO;
        self.userNameLabel.hidden = NO;
        self.infoFollowTextSuffixLabel.text = nil;
        self.infoFollowTextSuffixLabel.hidden = NO;
        self.infoGoodPostImageView.hidden = NO;
        
        CGFloat nameLength = [info.username length];
        NSString *commentMsg = [info.username stringByAppendingString:@" "];
        commentMsg = [commentMsg stringByAppendingString:NSLocalizedString(@"InfoCommentUserSuffix", nil)];
        
//        NSMutableAttributedString *attrStr;
//        attrStr = [[NSMutableAttributedString alloc] initWithString:commentMsg];
        
        CGFloat lineHeight = 14.0f;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [paragraphStyle setMinimumLineHeight:lineHeight] ;
        [paragraphStyle setMaximumLineHeight:lineHeight] ;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:commentMsg attributes:attributes];
        
        [attributedText addAttribute:NSFontAttributeName
                        value:JPBFONT(11)
                        range:NSMakeRange(0, nameLength)];
        [attributedText addAttribute:NSForegroundColorAttributeName
                        value:USER_DISPLAY_NAME_COLOR
                        range:NSMakeRange(0, nameLength)];
        [self.infoFollowTextSuffixLabel setAttributedText:attributedText];
        
        [self.infoFollowTextSuffixLabel sizeToFit];
        self.cellHeight += self.infoFollowTextSuffixLabel.frame.size.height;
        
        self.userNameLabel.hidden = YES;
        
    }else if ( self.infoType && ([self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPEOFFICIALNEWS]] || [self.infoType isEqualToString:FormatInfoType_toString[VLINFOTYPEOFFICIALIMPORTANTNEWS]] )){
        // n : 公式ニュース
        // i :　公式ニュース（重要）
        self.iconImageView.hidden = NO;
        self.userNameLabel.hidden = NO;
        self.infoOfficialNewsLabel.text = nil;
        self.infoOfficialNewsLabel.hidden = NO;
        self.infoGoodPostImageView.hidden = NO;
        
        //非同期で画像加工して同期で設置
        [CommonUtil doTaskAsynchronously:^{
            UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"contact_icon.png"]
                                                           size:cgSize
                                                     radiusSize:radiusSize];
            [CommonUtil doTaskSynchronously:^{
                self.iconImageView.image = image;
            }];
        }];
        
        if ([self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPEOFFICIALNEWS]]) {

            self.iconImageView.hidden = YES;
            [[self.infoOfficialNewsLabel superview] addConstraint:[self getOfficialCaptionConstraint]];
            [[self.infoDateLabel superview] addConstraint:[self getOfficialDateConstraint]];
            
        }else{
            [[self.infoOfficialNewsLabel superview] removeConstraint:[self getOfficialCaptionConstraint]];
            [[self.infoDateLabel superview] removeConstraint:[self getOfficialDateConstraint]];
        }
        
        CGFloat lineHeight = 14.0f;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [paragraphStyle setMinimumLineHeight:lineHeight] ;
        [paragraphStyle setMaximumLineHeight:lineHeight] ;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:info.caption attributes:attributes];
        [attributedText addAttribute:NSForegroundColorAttributeName
                               value:USER_DISPLAY_NAME_COLOR
                               range:NSMakeRange(0, info.caption.length)];
        
        [self.infoOfficialNewsLabel setAttributedText:attributedText];
        
        [self.infoOfficialNewsLabel sizeToFit];
        self.cellHeight += self.infoOfficialNewsLabel.frame.size.height;
        
        
        self.userNameLabel.hidden = YES;
        
        
    }
    
    // フォローボタン
    if(info.isFollow){
        UIImage *btnFollowImg = [UIImage imageNamed:@"ico_follow.png"];
        UIImage *btnFollowedImg = [UIImage imageNamed:@"ico_follower.png"];
        // フォローしているか
        if([info.isFollow isKindOfClass:[NSNumber class]]){
            NSComparisonResult result;
            result = [info.isFollow compare:[NSNumber numberWithInt:0]];
            switch(result) {
                case NSOrderedSame: // 一致 : フォローしていない
                case NSOrderedAscending: // 謎パターン： フォローしていないとする
                    [self.infoFollowBtn setImage:btnFollowImg forState:UIControlStateNormal];
                    self.isFollow = [NSNumber numberWithInt:0];
                    break;
                case NSOrderedDescending: // dispFollowが大きい: フォローしている
                    [self.infoFollowBtn setImage:btnFollowedImg forState:UIControlStateNormal];
                    self.isFollow = [NSNumber numberWithInt:1];
                    break;
            }
        }else{
            [self.infoFollowBtn setImage:btnFollowImg forState:UIControlStateNormal];
            self.isFollow = [NSNumber numberWithInt:1];
        }
    }
    
    // ランキングアップテキスト
    if(self.infoType && [self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPERANKUP]]){
        // rank up
        if(!info.categoryName || [info.categoryName length] == 0){
            info.categoryName = NSLocalizedString(@"InfoRankUpItemNameAll", nil);
        }
        if(info.categoryName && info.rankNew && info.rankOld){
            
            // NSLocalizedString(@"InfoRankUpUserSuffix", nil)  <?categoryName> <?rankOld> <?rankNew>
            NSString *rankUpLabelBase = NSLocalizedString(@"InfoRankUpUserSuffix", nil);
            NSString *rankUpLabelReplace = [rankUpLabelBase stringByReplacingOccurrencesOfString:@"<?categoryName>" withString:info.categoryName];
            rankUpLabelReplace = [rankUpLabelReplace stringByReplacingOccurrencesOfString:@"<?rankNew>" withString:[info.rankNew stringValue]];
            // update -> no item
//            rankUpLabelReplace = [rankUpLabelReplace stringByReplacingOccurrencesOfString:@"<?rankOld>" withString:[info.rankOld stringValue]];
            
            //self.infoRankUpLabel.text = rankUpLabelReplace;
            self.infoRankUpLabel.numberOfLines = 0;
            self.infoRankUpLabel.lineBreakMode = NSLineBreakByCharWrapping;
            self.infoRankUpLabel.attributedText = [CommonUtil uiLabelHeight:14.0f label:rankUpLabelReplace];
            self.infoRankUpLabel.hidden = NO;
            [self.infoRankUpLabel setFrame:CGRectMake(self.infoRankUpLabel.frame.origin.x, self.infoRankUpLabel.frame.origin.y,
                                                      self.infoRankUpLabel.frame.size.width, 1000)];
            
            [self.infoRankUpLabel sizeToFit];
            self.cellHeight += self.infoRankUpLabel.frame.size.height;

        }else{
            self.infoRankUpLabel.text = @"";
            self.infoRankUpLabel.hidden = YES;
        }
    }else{
        self.infoRankUpLabel.text = @"";
        self.infoRankUpLabel.hidden = YES;
    }
    
    // 投稿画像
    self.infoGoodPostImageView.tag = [info.postID integerValue];
    if(info.imgPath){
        [self.infoGoodPostImageView sd_setImageWithURL:[NSURL URLWithString:info.imgPath]
                              placeholderImage:nil
                                       options: SDWebImageCacheMemoryOnly
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         
                                         if(cacheType == SDImageCacheTypeMemory){
                                             self.infoGoodPostImageView.alpha = 1;
                                         }else{
                                             [UIView animateWithDuration:0.4f animations:^{
                                                 self.infoGoodPostImageView.alpha = 0;
                                                 self.infoGoodPostImageView.alpha = 1;
                                             }];
                                         }
                                         
                                     }];
    }else{
        self.infoGoodPostImageView.hidden = YES;
    }
    
    // 作成時間
    self.infoDateLabel.text = [CommonUtil dateToExchangeString:info.created];
    
    // cell 高さ
    if(self.cellHeight < 64){
        self.cellHeight = 64;
    }else{
        DLog(@"cell height : %f", self.cellHeight);
    }
    
}

//公式ニュースなら日付の左のスペースなくす.
-(NSLayoutConstraint*)getOfficialDateConstraint{
    
    if (!self.infoOfficialDateTrailing) {
        self.infoOfficialDateTrailing = [NSLayoutConstraint constraintWithItem:self.infoDateLabel
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:[self.infoDateLabel superview]
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1
                                                                      constant:10];
    }
    return self.infoOfficialDateTrailing;
}
//公式ニュースならタイトルの左のスペースなくす.
-(NSLayoutConstraint*)getOfficialCaptionConstraint{
    
    if (!self.infoOfficialCaptionTrailing ) {
        self.infoOfficialCaptionTrailing = [NSLayoutConstraint constraintWithItem:self.infoOfficialNewsLabel
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:[self.infoOfficialNewsLabel superview]
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1
                                                                         constant:10];
    }
    return self.infoOfficialCaptionTrailing;
}

- (CGFloat)calcCellHeight:(Info *)info
{
    // cell 高さベース
    self.cellHeight = 10 + 12 + 21 + 3;    // 10 + resizeTitle + 21 + 3   min 64;
    
    if ( info.infoType && [info.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPEFOLLOWED]] ){
        // f : 自分がフォローされた場合
        
        CGFloat nameLength = [info.username length];
        NSString *followMsg = [info.username stringByAppendingString:@" "];
        followMsg = [followMsg stringByAppendingString:NSLocalizedString(@"InfoFollowUserSuffix", nil)];

        CGFloat lineHeight = 14.0f;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [paragraphStyle setMinimumLineHeight:lineHeight] ;
        [paragraphStyle setMaximumLineHeight:lineHeight] ;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:followMsg attributes:attributes];
        
        [attributedText addAttribute:NSFontAttributeName
                               value:JPBFONT(11)
                               range:NSMakeRange(0, nameLength)];
        [attributedText addAttribute:NSForegroundColorAttributeName
                               value:USER_DISPLAY_NAME_COLOR
                               range:NSMakeRange(0, nameLength)];
        
        [self.infoFollowTextSuffixLabel setAttributedText:attributedText];
        self.infoFollowTextSuffixLabel.numberOfLines = 0;
        self.infoFollowTextSuffixLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        [self.infoFollowTextSuffixLabel sizeToFit];
        self.cellHeight += self.infoFollowTextSuffixLabel.frame.size.height;
        
        
    }else if ( self.infoType && [self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPELIKED]] ){
        // l : 自分の投稿にいいねされた場合
        
        CGFloat nameLength = [info.username length];
        NSString *likewMsg = [info.username stringByAppendingString:@" "];
        likewMsg = [likewMsg stringByAppendingString:NSLocalizedString(@"InfoLikeUserSuffix", nil)];
        
        CGFloat lineHeight = 14.0f;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [paragraphStyle setMinimumLineHeight:lineHeight] ;
        [paragraphStyle setMaximumLineHeight:lineHeight] ;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:likewMsg attributes:attributes];
        
        [attributedText addAttribute:NSFontAttributeName
                               value:JPBFONT(11)
                               range:NSMakeRange(0, nameLength)];
        [attributedText addAttribute:NSForegroundColorAttributeName
                               value:USER_DISPLAY_NAME_COLOR
                               range:NSMakeRange(0, nameLength)];
        [self.infoFollowTextSuffixLabel setAttributedText:attributedText];
        self.infoFollowTextSuffixLabel.numberOfLines = 0;
        self.infoFollowTextSuffixLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        [self.infoFollowTextSuffixLabel sizeToFit];
        self.cellHeight += self.infoFollowTextSuffixLabel.frame.size.height;
        
        
    }else if ( self.infoType && [self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPERANKUP]] ){
        // r : 自分の順位が50以内で変動した時
        
        if(!info.categoryName || [info.categoryName length] == 0){
            info.categoryName = NSLocalizedString(@"InfoRankUpItemNameAll", nil);
        }
        if(info.categoryName && info.rankNew && info.rankOld){
            
            NSString *rankUpLabelBase = NSLocalizedString(@"InfoRankUpUserSuffix", nil);
            NSString *rankUpLabelReplace = [rankUpLabelBase stringByReplacingOccurrencesOfString:@"<?categoryName>" withString:info.categoryName];
            rankUpLabelReplace = [rankUpLabelReplace stringByReplacingOccurrencesOfString:@"<?rankNew>" withString:[info.rankNew stringValue]];
            self.infoRankUpLabel.numberOfLines = 0;
            self.infoRankUpLabel.lineBreakMode = NSLineBreakByCharWrapping;
            self.infoRankUpLabel.attributedText = [CommonUtil uiLabelHeight:14.0f label:rankUpLabelReplace];
            [self.infoRankUpLabel setFrame:CGRectMake(self.infoRankUpLabel.frame.origin.x, self.infoRankUpLabel.frame.origin.y,
                                                      self.infoRankUpLabel.frame.size.width, 1000)];
            [self.infoRankUpLabel sizeToFit];
            self.cellHeight += self.infoRankUpLabel.frame.size.height;
            
            DLog(@"frame height : %f", self.infoRankUpLabel.frame.size.height);
            DLog(@"rankup height : %f", self.cellHeight);
        }
        
    }else if ( self.infoType && [self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPECOMMENTED]] ){
        // c : 自分の投稿にコメントされた場合
        
        CGFloat nameLength = [info.username length];
        NSString *commentMsg = [info.username stringByAppendingString:@" "];
        commentMsg = [commentMsg stringByAppendingString:NSLocalizedString(@"InfoCommentUserSuffix", nil)];

        CGFloat lineHeight = 14.0f;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [paragraphStyle setMinimumLineHeight:lineHeight] ;
        [paragraphStyle setMaximumLineHeight:lineHeight] ;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:commentMsg attributes:attributes];
        
        [attributedText addAttribute:NSFontAttributeName
                               value:JPBFONT(11)
                               range:NSMakeRange(0, nameLength)];
        [attributedText addAttribute:NSForegroundColorAttributeName
                               value:USER_DISPLAY_NAME_COLOR
                               range:NSMakeRange(0, nameLength)];
        [self.infoFollowTextSuffixLabel setAttributedText:attributedText];
        self.infoFollowTextSuffixLabel.numberOfLines = 0;
        self.infoFollowTextSuffixLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        [self.infoFollowTextSuffixLabel sizeToFit];
        self.cellHeight += self.infoFollowTextSuffixLabel.frame.size.height;
        
    }else if ( self.infoType && ([self.infoType isEqualToString: FormatInfoType_toString[VLINFOTYPEOFFICIALNEWS]] || [self.infoType isEqualToString:FormatInfoType_toString[VLINFOTYPEOFFICIALIMPORTANTNEWS]] )){
        // i : 自分の投稿にいいねされた場合
        
        
        CGFloat lineHeight = 14.0f;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [paragraphStyle setMinimumLineHeight:lineHeight] ;
        [paragraphStyle setMaximumLineHeight:lineHeight] ;
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:info.caption attributes:attributes];
        [attributedText addAttribute:NSForegroundColorAttributeName
                               value:USER_DISPLAY_NAME_COLOR
                               range:NSMakeRange(0, info.caption.length)];
        
        [self.infoOfficialNewsLabel setAttributedText:attributedText];
        self.infoOfficialNewsLabel.numberOfLines = 0;
        self.infoOfficialNewsLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        [self.infoOfficialNewsLabel sizeToFit];
        self.cellHeight += self.infoOfficialNewsLabel.frame.size.height;
        
        
    }
    
    // cell 高さ
    if(self.cellHeight < 64){
        self.cellHeight = 64;
    }else{
        DLog(@"cell height : %f", self.cellHeight);
    }
    
    return self.cellHeight;
}

//- (UIEdgeInsets)layoutMargins
//{
//    return UIEdgeInsetsMake(0, 0, 0, 0);
//}


@end
