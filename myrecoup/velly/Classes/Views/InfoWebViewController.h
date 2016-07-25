//
//  InfoWebViewController.h
//  myrecoup
//
//  Created by aoponaopon on 2015/12/04.
//  Copyright © 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoWebViewController : UIViewController<UIWebViewDelegate>


@property (nonatomic) NSString*url;
@property (nonatomic) UIWebView*newsView;
- (id)initWithURL:(NSString*)url;
@end
