//
//  RssNewsTableViewCell.h
//  myrecoup
//
//  Created by aoponaopon on 2015/12/17.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROW_ADMOB  7
#define admobHeight 110
#define admobUnitId @"ca-app-pub-8515786534720596/5021584069"

@import GoogleMobileAds;

@interface RssNewsTableViewCell : UITableViewCell

@property (nonatomic) UIView *newsInfoView;
@property (nonatomic) UIImageView *newsThumbView;
@property (nonatomic) UILabel *newsTitleLabel;
@property (nonatomic) UILabel *newsCategoryLabel;
@property (nonatomic) UILabel *readMoreLabel;
@property (nonatomic) UIView *imobileSDKView;
@property (nonatomic) UIImageView *imobileSDKImageView;
@property (nonatomic) UILabel *imobileSDKTitleLabel;
@property (nonatomic) UIView *separatorView;
@property (nonatomic) GADNativeExpressAdView *neaView;

@end
