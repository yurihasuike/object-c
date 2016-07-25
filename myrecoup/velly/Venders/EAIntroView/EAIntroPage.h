//
//  EAIntroPage.h
//
//  Copyright (c) 2013-2014 Evgeny Aleksandrov. License: MIT.

#import <Foundation/Foundation.h>

typedef void (^VoidBlock)();

@interface EAIntroPage : NSObject

// background used for cross-dissolve
@property (nonatomic, strong) UIImage *bgImage;
// show or hide EAIntroView titleView on this page (default YES)
@property (nonatomic, assign) bool showTitleView;


// properties for default EAIntroPage layout
//
// title image Y position - from top of the screen
// title and description labels Y position - from bottom of the screen
// all items from subviews array will be added on page

/**
* The title view that is presented above the title label.
* The view can be a normal UIImageView or any other kind uf
* UIView. This allows to attach animated views as well.
*/
@property (nonatomic, strong) UIView * titleIconView;
@property (nonatomic, assign) CGFloat titleIconPositionY;

@property (nonatomic, strong) UIView * pageIconView;
@property (nonatomic, assign) CGFloat pageIconPositionY;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) CGFloat titlePositionY;

@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) UIFont *descFont;
@property (nonatomic, strong) UIColor *descColor;
@property (nonatomic, assign) CGFloat descWidth;
@property (nonatomic, assign) CGFloat descPositionY;

@property (nonatomic, strong) NSString *navimsg;
@property (nonatomic, strong) UIFont *navimsgFont;
@property (nonatomic, strong) UIColor *navimsgColor;
@property (nonatomic, assign) CGFloat navimsgWidth;
@property (nonatomic, assign) CGFloat navimsgPositionY;

@property (nonatomic, strong) NSString *btnmsg;
@property (nonatomic, strong) NSString *btnclosemsg;


@property (nonatomic, strong) NSArray *subviews;

@property (nonatomic,copy) VoidBlock onPageDidLoad;
@property (nonatomic,copy) VoidBlock onPageDidAppear;
@property (nonatomic,copy) VoidBlock onPageDidDisappear;


// if customView is set - all other default properties are ignored
@property (nonatomic, strong) UIView *customView;

@property(nonatomic, strong, readonly) UIView *pageView;

+ (instancetype)page;
+ (instancetype)pageWithCustomView:(UIView *)customV;
+ (instancetype)pageWithCustomViewFromNibNamed:(NSString *)nibName;

@end