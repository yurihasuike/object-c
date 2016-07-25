//
//  PostSelectFromLibraryViewController.h
//  myrecoup
//
//  Created by aoponaopon on 2016/03/19.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostSelectFromLibraryViewController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic)UIViewController * previousTab;
- (id)initWithPreviousTab:(UIViewController *)previousTab;
@end
