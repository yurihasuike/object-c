//
//  RegistViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/02/10.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormTextField.h"

@interface RegistViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet FormTextField *mailTextField;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

@end
