//
//  ProfileEditViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormTextField.h"
#import "UIPlaceHolderTextView.h"
#import "IQActionSheetPickerView.h"
#import "User.h"
#import "ProfileViewController.h"

@interface ProfileEditViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, IQActionSheetPickerViewDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) ProfileViewController *profileViewController;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet FormTextField *userNameField;
@property (strong, nonatomic) IBOutlet FormTextField *mailField;
@property (strong, nonatomic) IBOutlet FormTextField *userIdField;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *descripTextView;

@property (nonatomic) IBOutlet UILabel *passwdEditTitleLabel;
@property (nonatomic) IBOutlet UIButton *passwdEditBtn;

@property (nonatomic) IBOutlet UILabel *userInfoLabel;

@property (nonatomic) IBOutlet UIButton *AreaBtn;
@property (nonatomic) IBOutlet UILabel *areaLabel;
@property (nonatomic) IBOutlet UILabel *areaTitleLabel;

@property (nonatomic) IBOutlet UIButton *BirthBtn;
@property (nonatomic) IBOutlet UILabel *birthLabel;
@property (nonatomic) IBOutlet UILabel *birthTitleLabel;

@property (nonatomic) IBOutlet UIButton *SeiBtn;
@property (nonatomic) IBOutlet UILabel *seiLabel;
@property (nonatomic) IBOutlet UILabel *seiTitleLabel;

@property (nonatomic) IBOutlet UILabel *socialLabel;

@property (nonatomic) IBOutlet UIButton *twBtn;
@property (nonatomic) IBOutlet UILabel *twStatusLabel;
@property (nonatomic) IBOutlet UILabel *twNoLabel;
@property (nonatomic) IBOutlet UIImageView *twOnImageView;
@property (nonatomic) IBOutlet UIButton *fbBtn;
@property (nonatomic) IBOutlet UILabel *fbStatusLabel;
@property (nonatomic) IBOutlet UILabel *fbNoLabel;
@property (nonatomic) IBOutlet UIImageView *fbOnImageView;


@property (nonatomic) IBOutlet UIButton *saveBtn;

@property (nonatomic, strong) NSNumber *userPID;
@property (nonatomic, strong) NSString *userID;
@property (strong, nonatomic) User *user;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

@end
