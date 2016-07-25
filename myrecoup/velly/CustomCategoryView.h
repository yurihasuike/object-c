//
//  CustomCategory.h
//  velly
//
//  Created by VCJPCM012 on 2015/10/10.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCategoryView : UIView

@property(nonatomic,assign) id parrentController;

- (id)initWithFrame:(CGRect)frame target:(id)parrentController;
-(void)changeLabel:(NSString*)string;

@end
