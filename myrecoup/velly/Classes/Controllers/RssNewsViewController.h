//
//  RssNewsViewController.h
//  myrecoup
//
//  Created by aoponaopon on 2015/12/15.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"
#import "ImobileSdkAds/ImobileSdkAds.h"
#import <ADG/ADGManagerViewController.h>
#import <FBAudienceNetwork/FBNativeAd.h>
#import <ADG/ADGNativeAd.h>

typedef enum : NSUInteger
{
    ADGENEADTYPENORMAL = 0,
    ADGENEADTYPEFB,
    
}ADGENEADTYPE;

@interface RssNewsViewController : UIViewController

<NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource, IMobileSdkAdsDelegate, ADGManagerViewControllerDelegate>

@property (nonatomic) Category_ *category;
@property (nonatomic) NSMutableArray *news;
@property (nonatomic) NSRegularExpression *regexpForThumbPath;
@property (nonatomic,strong) UITableView *newsTableView;

@property (nonatomic) NSMutableString *newsTitle;
@property (nonatomic) NSMutableArray *newsTitles;
@property (nonatomic) NSMutableString *link;
@property (nonatomic) NSMutableArray *links;
@property (nonatomic) NSMutableString *newsCategory;
@property (nonatomic) NSMutableArray *newsCategories;
@property (nonatomic) NSMutableString *thumbPath;
@property (nonatomic) NSMutableArray *thumbPaths;
@property (nonatomic) NSMutableString *pubDate;
@property (nonatomic) NSMutableArray *pubDates;

@property (nonatomic) BOOL isTitle;
@property (nonatomic) BOOL isLink;
@property (nonatomic) BOOL isCategory;
@property (nonatomic) BOOL isThumbPath;
@property (nonatomic) BOOL isPubDate;

@property (nonatomic) ImobileSdkAdsNativeObject *imobileSDK;
@property (nonatomic, retain) ADGManagerViewController *adg;
@property (nonatomic, retain) ADGNativeAd *adgNativeAd;
@property (retain, nonatomic) FBNativeAd *fbNativeAd;
@property (nonatomic) NSUInteger adGeneAdType;

- (id)initWithCategory:(Category_ *)category;

@end
