//
//  RegistInputViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/05.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormTextField.h"

@interface RegistInputViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) UIImage *socialImg;
@property (strong, nonatomic) IBOutlet UIImageView *userIconImgView;
@property (strong, nonatomic) IBOutlet FormTextField *usernameTextField;
@property (strong, nonatomic) IBOutlet FormTextField *emailTextField;
@property (strong, nonatomic) IBOutlet FormTextField *userIdTextField;
@property (strong, nonatomic) IBOutlet FormTextField *passwdTextField;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;

@property (nonatomic) NSString *inputEmail;
@property (nonatomic) NSString *inputUserName;
@property (nonatomic) NSString *inputUserId;

@property (nonatomic) NSString *twToken;
@property (nonatomic) NSString *twTokenSecret;
@property (nonatomic) NSString *fbToken;


@end
