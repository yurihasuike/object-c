//
//  UIPlaceHolderTextView.h
//  velly
//
//  Created by m_saruwatari on 2015/03/13.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic) BOOL required;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;
@property (nonatomic, readonly) BOOL isValid;

-(void)textChanged:(NSNotification*)notification;
-(BOOL) validate;

- (void) setNeedsAppearance:(id)sender;
-(void)setUpKeyBoard;

@end
