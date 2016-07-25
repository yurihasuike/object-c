//
//  DetailViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HFStretchableTableHeaderView.h"
#import "Post.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "CommentManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PostTagViewController.h"
#import "DetailPageViewController.h"

@interface DetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) CommentManager *commentManager;
@property (weak, nonatomic) IBOutlet UIImageView*stretchView;
@property (nonatomic, strong) HFStretchableTableHeaderView* stretchableTableHeaderView;
@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) NSNumber *postID;
@property (nonatomic, strong) NSNumber *userPID;
@property (nonatomic, strong) NSNumber *cntComment;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *descrip;
@property (nonatomic, strong) UIImageView *postImageTempView;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic) BOOL isLoadingApi;
@property (nonatomic) BOOL isLoadingToolBar;
@property (nonatomic, assign) BOOL canLoadMore;
@property (strong, nonatomic) MPMoviePlayerController *player;
@property (nonatomic) NSInteger fromtag;
@property (nonatomic) NSMutableDictionary *TagNameAndRange;
@property (nonatomic) PostTagViewController *postTagView;
@property (nonatomic) DetailPageViewController * parentView;
@property (nonatomic) NSUInteger pageViewIndex;
@property (nonatomic) UINavigationController * NavigationController;
@property (nonatomic) NSString *userChatToken;
@property (nonatomic) NSString *myChatToken;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *userIconPath;
@property (nonatomic) NSString *myIconPath;

- (id) initWithPostID:(NSNumber *)postID;
- (id) initWithPost:(Post *)post;
- (void)loadingPostWidthPost:(NSNumber *)t_postID post:(Post *)post;
- (void)loadingPostWidthPostID:(NSNumber *)t_postID;
- (void)Tappedimg:(UIGestureRecognizer *)recognizer;
- (void)CommenttextBeginEditing:(id)sender;
- (void)loadPost;

@end
