//
//  LoginViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/02/09.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormTextField.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

@end
