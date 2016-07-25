//
//  DeailUserTableViewCell.m
//  velly
//
//  Created by m_saruwatari on 2015/07/18.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "DeailUserTableViewCell.h"
#import "UIImageView+Networking.h"
#import "CommonUtil.h"
#import "UIImageView+WebCache.h"
#import "VYNotification.h"
#import "ConfigLoader.h"
#import "SVProgressHUD.h"
#import "UserManager.h"
#import "FollowManager.h"
#import "Defines.h"
#import "TrackingManager.h"

@implementation DeailUserTableViewCell
@synthesize userPID, userID;
- (id) initWithUserPID:(NSNumber *)t_userPID userID:(NSString *)t_userID {
    
    if(!self) {
        self = [[DeailUserTableViewCell alloc] init];
    }
    self.userPID = t_userPID;
    self.userID = t_userID;
    if([self.postManager isKindOfClass:[NSNull class]]){
        self.postManager = [PostManager new];
    }
    
    //メッセージボタン設置
    if (!self.msgBtn) {
        self.msgBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.msgBtn.hidden = YES;
        [self.contentView addSubview:self.msgBtn];
        [self layoutMsgBtn];
    }
    
    //フォローボタン設置
    if (!self.followBtn) {
        self.followBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.followBtn.hidden = YES;
        [self.contentView addSubview:self.followBtn];
        [self styleFollowBtn];
    }
    
    //「プロ」ラベル設置
    if (!self.proBtn) {
        self.proBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.proBtn.hidden = YES;
        self.proBtn.userInteractionEnabled = NO;
        [self addSubview:self.proBtn];
        [self layoutProBtn];
    }
    
    [self setFandMConstraint];
    return self;
}
- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureFollow:(Post *)loadPost{
    
    //フォロー確認
    self.userPID = loadPost.userPID;
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    
    NSString *isLoding = vConfig[@"LoadingDetailDisplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    
    NSNumber *myUserPID = [Configuration loadUserPid];
    __weak typeof(self) weakSelf = self;
    
    [[UserManager sharedManager] getUserInfo:loadPost.userPID block:^(NSNumber *result_code, User *srvUser, NSMutableDictionary *responseBody, NSError *error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
        
        //自分の投稿でなければフォローボタンを表示
        if(loadPost.userPID && !([myUserPID isEqualToNumber:loadPost.userPID])){
            
            self.followBtn.hidden = NO;
            
            if([srvUser.is_followed_by_me isEqualToNumber:[NSNumber numberWithInt:VLPOSTLIKEYES]]){
                // followed
                self.isFollow = [NSNumber numberWithInt:VLPOSTLIKEYES];
                [self.followBtn setTitle:NSLocalizedString(@"UserFollowed", nil) forState:UIControlStateNormal];
            }else{
                // no follow
                self.isFollow = [NSNumber numberWithInt:VLPOSTLIKENO];
                [self.followBtn setTitle:NSLocalizedString(@"UserFollow", nil) forState:UIControlStateNormal];
            
            }
        
        
        }else{
            self.followBtn.hidden = YES;
        }
            
        if(!error){
            strongSelf.user = srvUser;
                
        }else{
            DLog(@"%@", error);
                
            // have a 404 ?
            if([result_code isEqualToNumber:API_RESPONSE_CODE_ERROR_NOT_FOUND]){
            }
                
            // エラー
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                        initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}
- (void)configureCellForAppRecord:(Post *)loadPost
{
    if(loadPost && [loadPost isKindOfClass:[Post class]]){
        
        CommonUtil *commonUtil = [[CommonUtil alloc] init];
        
        if(loadPost.userID) {
            //self.userIdLabel.text = [@"@" stringByAppendingString:loadPost.userID];
            [self.userIdBtn setTitle:[@"@" stringByAppendingString:loadPost.userID] forState:UIControlStateNormal];
        }else{
            //self.userIdLabel.text = @"";
            [self.userIdBtn setTitle:@"" forState:UIControlStateNormal];
        }
        if(loadPost.username){
            //self.userNameLabel.text = loadPost.username;
            [self.userNameBtn setTitle:loadPost.username forState:UIControlStateNormal];
        }else{
            //self.userNameLabel.text = @"";
            [self.userNameBtn setTitle:@"" forState:UIControlStateNormal];
        }
        if(loadPost.created){
            //self.postDateLabel.text = [commonUtil dateToString:loadPost.created formatString:@"yyyy.MM.dd"];
            self.postDateLabel.text = [CommonUtil dateToExchangeString:loadPost.created];
        }
        //        CGSize cgSize = CGSizeMake(32.0f, 32.0f);
        //        CGSize radiusSize = CGSizeMake(16.0f, 16.0f);
        CGSize cgSize = CGSizeMake(160.0f, 160.0f);
        CGSize radiusSize = CGSizeMake(80.0f, 80.0f);
        self.userImageView.image = nil;
        if(loadPost.iconPath && ![loadPost.iconPath isKindOfClass:[NSNull class]]){
            [self.userImageView sd_setImageWithURL:[NSURL URLWithString:loadPost.iconPath]
                                  placeholderImage:nil
                                           options: SDWebImageCacheMemoryOnly
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             image = [commonUtil createRoundedRectImage:image size:cgSize radiusSize:radiusSize];
                                             self.userImageView.image = image;
                                             
                                             if(cacheType == SDImageCacheTypeMemory){
                                                 self.userImageView.alpha = 1;
                                             }else{
                                                 [UIView animateWithDuration:0.4f animations:^{
                                                     self.userImageView.alpha = 0;
                                                     self.userImageView.alpha = 1;
                                                 }];
                                             }
                                         }];
        }else{
            //UIImage *image = [commonUtil createRoundedRectImage:[UIImage imageNamed:@"ico_noimgs.png"] size:cgSize radiusSize:radiusSize];
            self.userImageView.image = [UIImage imageNamed:@"ico_noimgs.png"];
            self.userImageView.alpha = 1;
        }
    }
    
    //フォローボタン表示等
    [self configureFollow:loadPost];
}

///フォローボタンのスタイル
- (void)styleFollowBtn {
    self.followBtn.titleLabel.font =  JPFONT(9);
    [self.followBtn.layer setBorderColor:[HEADER_UNDER_BG_COLOR CGColor]];
    [self.followBtn.layer setBorderWidth:1.0];
    [self.followBtn.layer setCornerRadius:3.0];
    [self.followBtn.layer setShadowOpacity:0.1f];
    [self.followBtn.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.followBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.followBtn addTarget:self
                       action:@selector(followAction:)
             forControlEvents:UIControlEventTouchUpInside];
    self.followBtn.tintColor = HEADER_UNDER_BG_COLOR;
}

///メッセージボタンのレイアウト
- (void)layoutMsgBtn {
    
    self.msgBtn.titleLabel.font = JPFONT(10);
    [self.msgBtn.layer setBorderColor:[HEADER_UNDER_BG_COLOR CGColor]];
    [self.msgBtn.layer setBorderWidth:1.0];
    [self.msgBtn.layer setCornerRadius:3.0];
    [self.msgBtn.layer setShadowOpacity:0.1f];
    [self.msgBtn.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.msgBtn setBackgroundColor:HEADER_UNDER_BG_COLOR];
    [self.msgBtn setTitle:NSLocalizedString(@"MakeAppointment", nil)
                                forState:UIControlStateNormal];
    [self.msgBtn setTitleColor:[UIColor whiteColor]
                                     forState:UIControlStateNormal];
    self.msgBtn.tintColor = HEADER_UNDER_BG_COLOR;
}

- (void)setFandMConstraint{
    
    UIView *superView = [self.followBtn superview];
    
    NSNumber *p = @5;
    NSNumber *m = @5;
    NSNumber *h = [NSNumber numberWithInt:
                   (superView.bounds.size.height
                    - [m intValue] - [p intValue] - [m intValue]
                    )/2
                   ];
    
    NSDictionary *constraints = NSDictionaryOfVariableBindings(m, p, h);
    NSDictionary *targets;
    
    targets = NSDictionaryOfVariableBindings(_followBtn, _userNameBtn);
    [superView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"[_userNameBtn]-p-[_followBtn]-m-|"
                               options:0
                               metrics:constraints
                               views:targets]];
    
    targets = NSDictionaryOfVariableBindings(_msgBtn, _userNameBtn);
    [superView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"[_userNameBtn]-p-[_msgBtn]-m-|"
                               options:0
                               metrics:constraints
                               views:targets]];
    
    self.fheight = [NSLayoutConstraint constraintWithItem:self.followBtn
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:nil
                                                attribute:NSLayoutAttributeHeight
                                               multiplier:1
                                                 constant:[h intValue]];
    
    self.fmTop = [NSLayoutConstraint constraintWithItem:self.followBtn
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:superView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1
                                               constant:20];
    self.fmBottom = [NSLayoutConstraint constraintWithItem:self.followBtn
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:superView
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1
                                               constant:-20];
    
    [superView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.msgBtn
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:[m intValue]],
                                [NSLayoutConstraint constraintWithItem:self.msgBtn
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.followBtn
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1
                                                              constant:-[p intValue]],
                                [NSLayoutConstraint constraintWithItem:self.msgBtn
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1
                                                              constant:[h intValue]],
                                self.fheight,
                                ]];
    
    [self.followBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.msgBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
}


///「プロ」のレイアウト設定
- (void)layoutProBtn {
    
    self.proBtn.frame = CGRectZero;
    self.proBtn.titleLabel.font = JPBFONT(8);
    [self.proBtn.layer setBorderColor:[USER_DISPLAY_NAME_COLOR CGColor]];
    [self.proBtn.layer setBorderWidth:1.0];
    [self.proBtn.layer setCornerRadius:5.0];
    [self.proBtn.layer setShadowOpacity:0.1f];
    [self.proBtn.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.proBtn setBackgroundColor:USER_DISPLAY_NAME_COLOR];
    [self.proBtn setTitle:NSLocalizedString(@"Pro", nil)
                                forState:UIControlStateNormal];
    [self.proBtn setTitleColor:[UIColor whiteColor]
                                     forState:UIControlStateHighlighted];
    [self.proBtn setTitleColor:[UIColor whiteColor]
                                     forState:UIControlStateNormal];
    self.proBtn.tintColor = HEADER_UNDER_BG_COLOR;
    
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:self.proBtn
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.userImageView
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1
                                                         constant:2],
                           [NSLayoutConstraint constraintWithItem:self.proBtn
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1
                                                         constant:5],
                           [NSLayoutConstraint constraintWithItem:self.proBtn
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.userNameBtn
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1
                                                         constant:2],
                           [NSLayoutConstraint constraintWithItem:self.proBtn
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:0
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1
                                                         constant:10],
                                          ]];
    [self.proBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
}


-(void)followAction:(id)sender{
    
    //Send Repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[FOLLOWTAP]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]   : NSStringFromClass([self class]),
                                      DEFINES_REPROEVENTPROPNAME[SENDER] : [Configuration loadUserPid],
                                      DEFINES_REPROEVENTPROPNAME[RECEIVER] : self.userPID,}];
    
    // ------------------
    // login check
    // ------------------
    if(![[Configuration checkLogined] length]){
        // 未ログイン
        [[NSNotificationCenter defaultCenter] postNotificationName:VYShowUserRegistNotification object:self];
        
    }else{
        // **********
        // send Follow
        // **********
        NSDictionary *vConfig   = [ConfigLoader mixIn];
        NSString *isLoding = vConfig[@"LoadingPostDisplay"];
        if( isLoding && [isLoding boolValue] == YES ){
            // Loading
            [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
        }
        NSString *vellyToken = [Configuration loadAccessToken];
        NSNumber *targetUserPID = self.userPID;
        if(self.isFollow && [self.isFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
            DLog("already follow");
            // followed -> no follow
            
            __weak typeof(self) weakSelf = self;
            [[FollowManager sharedManager] deleteFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorNoFollow", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    
                    // no follow
                    //self.headerView.followBtn.titleLabel.text = NSLocalizedString(@"UserFollow", nil);
                    [strongSelf.followBtn setTitle:NSLocalizedString(@"UserFollow", nil) forState:UIControlStateNormal];
                    strongSelf.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    strongSelf.user.isFollow = [NSNumber numberWithInt:VLISBOOLFALSE];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[UserManager sharedManager] updateMyFollow:myUserPID userPID:targetUserPID isFollow:VLISBOOLFALSE];
                    }
                    
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"MsgNoFollowed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }else{
            // no follow -> follow
            
            DLog(@"%@", targetUserPID);
            __weak typeof(self) weakSelf = self;
            [[FollowManager sharedManager] putFollow:targetUserPID aToken:vellyToken block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error){
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if( isLoding && [isLoding boolValue] == YES ){
                    // clear loading
                    [SVProgressHUD dismiss];
                }
                UIAlertView *alert = [[UIAlertView alloc] init];
                if (error) {
                    DLog(@"error = %@", error);
                    // エラー
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"ApiErrorFollow", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    [alert show];
                }else{
                    
                    // followed
                    //self.headerView.followBtn.titleLabel.text = NSLocalizedString(@"UserFollowed", nil);
                    [strongSelf.followBtn setTitle:NSLocalizedString(@"UserFollowed", nil) forState:UIControlStateNormal];
                    strongSelf.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    strongSelf.user.isFollow = [NSNumber numberWithInt:VLISBOOLTRUE];
                    
                    NSNumber *myUserPID = [Configuration loadUserPid];
                    if(myUserPID){
                        [[UserManager sharedManager] updateMyFollow:myUserPID userPID:targetUserPID isFollow:VLISBOOLTRUE];
                    }
                    
                    alert = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"MsgFollowed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    
                    [alert show];
                }
            }];
        }
    }
}


@end
