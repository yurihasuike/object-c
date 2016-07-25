//
//  PostUpdateViewController.h
//  myrecoup
//
//  Created by aoponaopon on 2016/03/14.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Category.h"
#import "UIPlaceHolderTextView.h"

@interface PostUpdateViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>


@property (nonatomic) Post *post;
@property (nonatomic) BOOL isMovie;
@property (nonatomic) UIScrollView * postUpdateBaseView;
@property (nonatomic) UITableView * postTableView;
@property (nonatomic) UIPlaceHolderTextView * postUpdateBodyTextView;
@property (nonatomic) CGFloat bottomMargin;
@property (nonatomic) Category_ *category;
@property (nonatomic) Category_ *parent;
@property (nonatomic) Category_ *child;

- (id) initWithPost:(Post*)post;
@end
