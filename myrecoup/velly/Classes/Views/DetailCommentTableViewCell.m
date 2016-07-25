//
//  DetailCommentTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "DetailCommentTableViewCell.h"
#import "Comment.h"
#import "UIImageView+Networking.h"
#import "CommonUtil.h"
#import "UIImageView+WebCache.h"

@interface DetailCommentTableViewCell()
    @property (nonatomic, weak) CommonUtil *commonUtil;
    @property (nonatomic) Comment *comment;
@end

@implementation DetailCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellForAppRecord:(Comment *)comment
{
    self.comment = comment;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    CommonUtil *commonUtil = [[CommonUtil alloc] init];

    // ユーザID
//    self.user_id = comment.userID;
//    if(comment.userID) {
//        self.u.text = [@"@" stringByAppendingString:comment.userID];
//    }
    
    self.userPID = comment.userPID;
    self.userID  = comment.userID;
    
    // ユーザ名前
    self.userNameLabel.text = comment.username;
    
    self.commentLabel.text = comment.comment;
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.commentLabel.frame = CGRectMake(52, 26,
                                        screenWidth -52 -10 -20, 20);
    CGRect titleFrame = [self.commentLabel frame];
    titleFrame.size.height = 5000;
    [self.commentLabel setFrame:titleFrame];
    [self.commentLabel sizeToFit];
    
    
    // ユーザアイコン
//    CGSize cgSize = CGSizeMake(50.0f, 50.0f);
//    CGSize radiusSize = CGSizeMake(23.0f, 23.0f);
    CGSize cgSize = CGSizeMake(200.0f, 200.0f);
    CGSize radiusSize = CGSizeMake(92.0f, 92.0f);
    if(comment.iconPath && ![comment.iconPath isKindOfClass:[NSNull class]]){
        
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:comment.iconPath]
                              placeholderImage:nil
                                       options: SDWebImageCacheMemoryOnly
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         image = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
                                         self.iconImageView.image = image;
                                     }];
    }else{
        UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"ico_noimgs.png"] size:cgSize radiusSize:radiusSize];
        self.iconImageView.image = image;
    }
    
    // 作成時間
    self.commentDateLabel.text = [CommonUtil dateToExchangeString:comment.created];
    
//    NSTimeInterval since = [[NSDate date] timeIntervalSinceDate:comment.created];
//    //NSLog(@"%f時",round(since/(60*60)));
//    //NSLog(@"%f日",round(since/(24*60*60)));
//    NSNumber *days   = [NSNumber numberWithFloat:round(since/(24*60*60))];
//    NSNumber *hours  = [NSNumber numberWithFloat:round(since/(60*60))];
//    NSNumber *target = [NSNumber numberWithInt:0.9];
//    NSComparisonResult result;
//    result = [days compare:target];
//    switch(result) {
//        case NSOrderedSame: // 一致したとき
//        case NSOrderedAscending: // daysが小さいとき
//            //NSLog(@"%f時",round(since/(60*60)));
//            self.commentDateLabel.text =  [NSString stringWithFormat:@"%@時間前", [hours stringValue]];
//            break;
//        case NSOrderedDescending: // daysが大きいとき
//            //NSLog(@"%f日",round(since/(24*60*60)));
//            self.commentDateLabel.text =  [NSString stringWithFormat:@"%@日前", [days stringValue]];
//            break;
//    }
    
    
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    //[self calcCellHeight];
    
}

- (CGFloat)calcCellHeight:(Comment *)comment
{
//    CGFloat padding = 6;
//    CGRect commentRect = CGRectMake(0, 0, self.frame.size.width, 0);
//    
//    // user Icon
//    CGRect userImgRect = CGRectMake(padding, commentRect.size.height + padding,
//                                    self.iconImageView.bounds.size.width, self.iconImageView.bounds.size.height);
//    self.iconImageView.frame = userImgRect;
//    
//    // nickName
//    CGRect nicknameRect = CGRectMake(padding * 2 + userImgRect.size.width, commentRect.size.height + padding,
//                                     self.userNameLabel.frame.size.width, self.userNameLabel.bounds.size.height);
//    self.userNameLabel.frame = nicknameRect;
//    
//    // coment
//    self.commentLabel.numberOfLines = 0;
//    self.commentLabel.lineBreakMode = NSLineBreakByCharWrapping;
//    
//    
//    CGRect commentDescripRect = CGRectMake(padding * 2 + userImgRect.size.width, nicknameRect.size.height + (padding * 2),
//                                           self.frame.size.width - (padding * 3) - userImgRect.size.width, self.commentLabel.bounds.size.height);
//    self.commentLabel.frame = commentDescripRect;
//    [self.commentLabel sizeToFit];
//    
//    // date
//    CGRect commentDateRect = CGRectMake(padding * 2 + userImgRect.size.width, nicknameRect.size.height + commentDescripRect.size.height + (padding * 3),
//                                        self.commentDateLabel.frame.size.width, self.commentDateLabel.bounds.size.height);
//    self.commentDateLabel.frame = commentDateRect;
//    
//    CGFloat fCellHeigt = nicknameRect.size.height + commentDescripRect.size.height + (padding * 4) + self.commentDateLabel.bounds.size.height;
//    self.cellHeight = [NSNumber numberWithFloat:fCellHeigt];
    
    
    NSString *commentStr = comment.comment;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;

    DLog(@"descrip %@", commentStr);
    self.commentLabel.text = commentStr;
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.commentLabel.frame = CGRectMake(52, 26,
                                         screenWidth -52 -10 -20, 20);
    CGRect titleFrame = [self.commentLabel frame];
    titleFrame.size = CGSizeMake(screenWidth -52 -10 -20, 5000);
    [self.commentLabel setFrame:titleFrame];
    [self.commentLabel sizeToFit];
    
    
    CGSize maxSize = CGSizeMake(screenWidth -52 -10 -20, 5000);
    //フォントを大きめに設定
    UIFont * commentFont = JPFONT(14);
    CGSize commentSize;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect commentSizeRect
        = [self.commentLabel.text boundingRectWithSize:maxSize
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:commentFont}
                                   context:nil];
        commentSize = commentSizeRect.size;
    }
    else{
        commentSize = [self.commentLabel.text
                              sizeWithFont:commentFont
                              constrainedToSize:maxSize
                              lineBreakMode:self.commentLabel.lineBreakMode];
    }
    
    DLog("screeen%f",[[UIScreen mainScreen] bounds].size.width);
    DLog(@"self.frame.size.width : %f", self.frame.size.width);
    DLog(@"commentSize width : %f", commentSize.width);
    DLog(@"commentSize height : %f", commentSize.height);
    
    CGFloat resizeCommentHeight = commentSize.height;
    if(comment.comment == nil || [comment.comment length] == 0){
        resizeCommentHeight = 0;
    }else if(resizeCommentHeight < 20){
        resizeCommentHeight = 20;
    }
    
    CGFloat totalHeight = resizeCommentHeight + 26 + 26;
    DLog(@"totalHeight : %f", totalHeight);
    
    return totalHeight;
}

@end
