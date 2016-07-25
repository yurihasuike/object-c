//
//  RssNewsViewController.m
//  myrecoup
//
//  Created by aoponaopon on 2015/12/15.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "RssNewsViewController.h"
#import "RssNewsTableViewCell.h"
#import "HomeViewController.h"
#import "InfoWebViewController.h"
#import "UIImageView+WebCache.h"
#import "ConfigLoader.h"
#import "TrackingManager.h"
#import "Defines.h"
#import "CommonUtil.h"

#import <FBAudienceNetwork/FBAdSettings.h>
#import <FBAudienceNetwork/FBAdChoicesView.h>
#import <FBAudienceNetwork/FBMediaView.h>

#define IMOBILE_NATIVE_PID     @"39673"
#define IMOBILE_NATIVE_MID     @"243011"
#define IMOBILE_NATIVE_SID     @"825846"
#define ROW_IMOBILE            3
#define ROW_ADGENERATION       11
#define ADGENERATION_ID        @"38670"

@interface RssNewsViewController ()

@property(nonatomic) RssNewsTableViewCell *adMobCell;

@end

static const NSUInteger cellHeight = 90;
static const NSUInteger margin = 2.5;
static const CGFloat borderHeight = 0.8;
static const NSUInteger readMoreCellHeight = 55;


@implementation RssNewsViewController

- (id)initWithCategory:(Category_ *)category
{
    if(!self) {
        self = [[RssNewsViewController alloc] init];
    }
    self.category = category;
    
    //imobile SDK情報取得
    [self setImobileAds];
    
    
    [self setADGToTableView];
    
    return self;
}

- (void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.newsTableView];
    
    //非同期で諸処理を行う
    [self doTaskAsynchronously:^{
        //初期化
        [self initializeArrays];
        
        //情報セット
        [self getInfomation];
        
        //セルの更新は同期的に.
        [self doTaskSynchronously:^{
            [self.newsTableView reloadData];
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.adMobCell.neaView loadRequest:[GADRequest request]];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(_adg)
    {
        [_adg resumeRefresh];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self setImobileAds];
    if(_adg)
    {
        [_adg pauseRefresh];
    }
}

//それぞれを格納するStringとArrayを初期化
- (void)initializeArrays
{
    self.news = [[NSMutableArray alloc] init];
    
    self.regexpForThumbPath = [NSRegularExpression regularExpressionWithPattern:@"src=(.+?)\\/>" options:0 error:nil];
    
    self.newsTitle = [[NSMutableString alloc] init];
    self.newsTitles = [[NSMutableArray alloc] init];
    
    self.link = [[NSMutableString alloc] init];
    self.links = [[NSMutableArray alloc] init];
    
    self.newsCategory = [[NSMutableString alloc] init];
    self.newsCategories = [[NSMutableArray alloc] init];
    
    self.thumbPath = [[NSMutableString alloc] init];
    self.thumbPaths = [[NSMutableArray alloc] init];
    
    self.pubDate = [[NSMutableString alloc] init];
    self.pubDates = [[NSMutableArray alloc] init];
}

//XMLのパースを実行し情報を取得
- (void)getInfomation
{
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:
                           [NSURL URLWithString:self.category.url]];
    
    parser.delegate = self;
    
    //パース実行
    [parser parse];
    
    //余分に入っている分を削除
    if ([self.newsTitles count]) {
        
        [self.newsTitles removeObjectAtIndex:0];
        [self.links removeObjectAtIndex:0];
        [self.thumbPaths removeObjectAtIndex:0];
        
    }
    
    //一つでも数が一致していなければエラー回避のため抜ける
    if ([self.newsTitles count] != [self.links count]
        || [self.links count] != [self.thumbPaths count]
        || [self.thumbPaths count] != [self.pubDates count]) {
        
        return;
    }
    
    //newsの情報を配列へ格納
    [self.newsTitles enumerateObjectsUsingBlock:^(id newsTitle, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *new;
        
        @try {
            //カテゴリ別の場合はカテゴリ情報がないため切り分け
            if ([self.newsCategories count]) {
                new = [NSDictionary dictionaryWithObjectsAndKeys:
                       newsTitle,@"title",
                       self.links[idx],@"link",
                       self.newsCategories[idx],@"category",
                       self.thumbPaths[idx] ,@"thumb",
                       self.pubDates[idx] ,@"pubdate",
                       nil];
            }
            else{
                new = [NSDictionary dictionaryWithObjectsAndKeys:
                       newsTitle,@"title",
                       self.links[idx],@"link",
                       self.thumbPaths[idx],@"thumb",
                       self.pubDates[idx] ,@"pubdate",
                       nil];
            }
            [self.news addObject:new];
            
        } @catch (NSException *exception) {
            DLog(@"Failed to add news.");
        }
    }];
    
    //imobile SDKのために4番目に空要素挿入
    if (self.news.count > ROW_IMOBILE) [self.news insertObject:[[NSDictionary alloc ] init] atIndex:ROW_IMOBILE];
    //Fire Base
    if (self.news.count > ROW_ADMOB) [self.news insertObject:[[NSDictionary alloc ] init] atIndex:ROW_ADMOB];
    //Ad generation
    if (self.news.count > ROW_ADGENERATION) [self.news insertObject:[[NSDictionary alloc ] init] atIndex:ROW_ADGENERATION];
}

- (UITableView *)newsTableView
{
    if (!_newsTableView) {
        _newsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-140)];
        _newsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if ([_newsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_newsTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([_newsTableView respondsToSelector:@selector(layoutMargins)]) {
            _newsTableView.layoutMargins = UIEdgeInsetsZero;
        }
        _newsTableView.delegate = self;
        _newsTableView.dataSource = self;
        _newsTableView.tableFooterView = [[UIView alloc] init];
        _newsTableView.backgroundColor = [UIColor whiteColor];
    }
    return _newsTableView;
}

//任意の正規表現で文字を抽出
- (NSMutableString*)getStringByRegexp:(NSRegularExpression*)regexp string:(NSMutableString *)string
{
    NSArray *regexpArray = [regexp matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    NSRange matchRange;
    for (NSTextCheckingResult *match in regexpArray) {
        matchRange = [match rangeAtIndex:0];
        string = (NSMutableString*)[string substringWithRange:matchRange];
    }
    return string;
}

- (RssNewsTableViewCell *)adMobCell
{
    if (!_adMobCell) {
        [self.newsTableView
         registerClass:[RssNewsTableViewCell class]
         forCellReuseIdentifier:@"adMobCell"];
        _adMobCell = [self.newsTableView dequeueReusableCellWithIdentifier:@"adMobCell"];
        [_adMobCell.separatorView setFrame:CGRectMake(0,0,
                                                     self.view.bounds.size.width,
                                                     borderHeight)];
        [_adMobCell.neaView setRootViewController:self];
        [_adMobCell.neaView setHidden:NO];
    }
    return _adMobCell;
}

#pragma mark - ADGENERATION

- (void)setADGToTableView
{
    [self.adg loadRequest];
}

- (ADGManagerViewController *)adg
{
    if (!_adg) {
        NSDictionary *adgparam = @{
                                   @"locationid" : ADGENERATION_ID,
                                   @"adtype" : @(kADG_AdType_Free),
                                   @"originx" : @(0),
                                   @"originy" : @(-1000),
                                   @"w" : @(self.view.bounds.size.width),
                                   @"h" : @(cellHeight)
                                   };
        _adg = [[ADGManagerViewController alloc]
                initWithAdParams:adgparam adView:self.view];
        _adg.rootViewController = self;
        [self addChildViewController:_adg];
        [_adg setDelegate:self];
        [_adg setUsePartsResponse:YES];
        [_adg setFillerRetry:NO];
    }
    return _adg;
}

#pragma mark ADGENERATION delegate

- (void)ADGManagerViewControllerFailedToReceiveAd:(ADGManagerViewController *)adgManagerViewController code:(kADGErrorCode)code {
    switch (code) {
        case kADGErrorCodeExceedLimit:
        case kADGErrorCodeNeedConnection:
            break;
        default:
            [adgManagerViewController loadRequest];
            break;
    }
}

- (void) dealloc {
    _adg.delegate = nil;
    _adg.rootViewController = nil;
    _adg = nil;
    _adgNativeAd = nil;
    _fbNativeAd = nil;
}

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController
                        mediationNativeAd:(id)mediationNativeAd
{
    if ([mediationNativeAd isKindOfClass:[FBNativeAd class]]) {
        self.adGeneAdType = ADGENEADTYPEFB;
        self.fbNativeAd = (FBNativeAd *)mediationNativeAd;
        [self.newsTableView reloadData];
    }
    
    if ([mediationNativeAd isKindOfClass:[ADGNativeAd class]]) {
        self.adGeneAdType = ADGENEADTYPENORMAL;
        self.adgNativeAd = (ADGNativeAd *)mediationNativeAd;
        [self.newsTableView reloadData];
    }
}

- (void)setImobileAds{
    
    // スポット情報の登録をします
    [ImobileSdkAds registerWithPublisherID:IMOBILE_NATIVE_PID MediaID:IMOBILE_NATIVE_MID SpotID:IMOBILE_NATIVE_SID];
    // スポット情報の取得を開始します
    [ImobileSdkAds startBySpotID:IMOBILE_NATIVE_SID];
    
    // 広告の情報を取得します
    [ImobileSdkAds getNativeAdData:IMOBILE_NATIVE_SID Delegate:self];
    
}

// ネイティブ広告の読み込みが完了した際に呼ばれます
- (void)onNativeAdDataReciveCompleted:(NSString *)spotId nativeArray:(NSArray *)nativeArray{
    // 広告リストから広告を読み込みます
    self.imobileSDK = (ImobileSdkAdsNativeObject *)[nativeArray objectAtIndex:0];
    [self.newsTableView reloadData];
}

//セクション数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

//セルの数をかえす
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 1) {
        return 1;
    }
    return [self.news count];
}

//セルの内容を返す
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //続きを読むの場合
    if (indexPath.section == 1) {
        
        [self.newsTableView registerClass:[RssNewsTableViewCell class] forCellReuseIdentifier:@"readMoreCell"];
        RssNewsTableViewCell *readMoreCell = [tableView dequeueReusableCellWithIdentifier:@"readMoreCell"];
        readMoreCell.newsInfoView.hidden = YES;
        [readMoreCell.readMoreLabel setFrame:CGRectMake(
                                                        0,
                                                        0,
                                                        self.view.bounds.size.width,
                                                        readMoreCellHeight)];
        readMoreCell.readMoreLabel.hidden = NO;
        readMoreCell.separatorView.frame = CGRectMake(0,
                                              0,
                                              self.view.bounds.size.width,
                                              borderHeight);
        return readMoreCell;
    }
    
    //セルのイメージ
    //|-------cell--------------------------
    //|2.5 ______newsInfoView____________  |
    //| |10_____                        |  |
    //| | |     |                       |  |
    //| | |     |                       |  |
    //| | |_____|                       |  |
    //| |_______________________________|  |
    //|                                    |
    //--------------------------------------
    
    //imobile SDKの場合
    if (indexPath.section == 0 && indexPath.row == ROW_IMOBILE) {
        
        [self.newsTableView registerClass:[RssNewsTableViewCell class] forCellReuseIdentifier:@"imobileSDKCell"];
        
        RssNewsTableViewCell *imobileSDKCell = [tableView dequeueReusableCellWithIdentifier:@"imobileSDKCell"];
        
        imobileSDKCell.newsInfoView.hidden = YES;
        imobileSDKCell.imobileSDKView.hidden = NO;
        
        //imobileをリロードしておく
        [self.imobileSDK reloadInputViews];
        
        //imobile body
        [imobileSDKCell.imobileSDKView setFrame:CGRectMake(
                                               margin,
                                               margin,
                                               self.view.bounds.size.width - margin*3,
                                               cellHeight - margin*2)];
        
        //imobile thumb
        [self.imobileSDK getAdImageCompleteHandler:^(UIImage *loadimg) {
            [imobileSDKCell.imobileSDKImageView setImage:loadimg];
        }];
        
        //imobile text
        [imobileSDKCell.imobileSDKTitleLabel setFrame:CGRectMake(
                                                 imobileSDKCell.imobileSDKImageView.bounds.size.width + margin*9,
                                                 margin*3,
                                                 imobileSDKCell.imobileSDKView.bounds.size.width - (imobileSDKCell.imobileSDKImageView.bounds.size.width + margin*9),
                                                 imobileSDKCell.imobileSDKView.bounds.size.height-margin*5)];
        imobileSDKCell.imobileSDKTitleLabel.text = [NSString stringWithFormat:@"%@%@",
                                                    @"【PR】",
                                                    [self.imobileSDK getAdDescription]
                                                    ];
        //仕切り線
        imobileSDKCell.separatorView.frame = CGRectMake(0,
                                              0,
                                              self.view.bounds.size.width,
                                              borderHeight);
        
        //タッチイベント追加
        [self.imobileSDK addClickFunction:imobileSDKCell];

        return imobileSDKCell;
    }else if (indexPath.section == 0 && indexPath.row == ROW_ADMOB) {
        
        return self.adMobCell;
        
    }else if (indexPath.section == 0 && indexPath.row == ROW_ADGENERATION) {
        
        [self.newsTableView
         registerClass:[RssNewsTableViewCell class]
         forCellReuseIdentifier:@"adGeneCell"];
        RssNewsTableViewCell *adGeneCell = [tableView dequeueReusableCellWithIdentifier:@"adGeneCell"];
        
        NSString *iconUrl;
        NSString *title;
        NSString *sponsoreInfo;
        switch (self.adGeneAdType)
        {
            case ADGENEADTYPEFB:
                [self.fbNativeAd registerViewForInteraction:adGeneCell
                                         withViewController:self.view.window.rootViewController
                                         withClickableViews:@[adGeneCell]];
                [self.adg addMediationNativeAdView:adGeneCell];
                iconUrl      = self.fbNativeAd.icon.url.absoluteString;
                title        = self.fbNativeAd.title;
                break;
            case ADGENEADTYPENORMAL:
            default:
                [self.adgNativeAd setTapEvent:adGeneCell];
                iconUrl      = self.adgNativeAd.iconImage.url;
                title        = self.adgNativeAd.title.text;
                sponsoreInfo = self.adgNativeAd.sponsored.value;
                break;
        }
        
        [adGeneCell.separatorView setFrame:CGRectMake(0,0,
                                                     self.view.bounds.size.width,
                                                     borderHeight)];
        //記事情報
        [adGeneCell.newsInfoView setFrame:CGRectMake(
                                               margin,
                                               margin,
                                               self.view.bounds.size.width - margin*3,
                                               cellHeight - margin*2)];
        
        //サムネイル画像(キャッシュを使用)
        [adGeneCell.newsThumbView sd_setImageWithURL:[NSURL URLWithString:iconUrl]
                              placeholderImage:nil
                                       options: SDWebImageCacheMemoryOnly
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         
                                         if (error) {
                                             [adGeneCell.newsThumbView setImage:[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:
                                                                            [NSURL URLWithString:iconUrl]]]];
                                         }
                                         else{
                                             [adGeneCell.newsThumbView setImage:image];
                                             
                                             if(cacheType == SDImageCacheTypeMemory){
                                                 adGeneCell.newsThumbView.alpha = 1;
                                             }else{
                                                 [UIView animateWithDuration:0.4f animations:^{
                                                     adGeneCell.newsThumbView.alpha = 0;
                                                     adGeneCell.newsThumbView.alpha = 1;
                                                 }];
                                             }
                                         }
                                     }];
        
        //タイトル
        [adGeneCell.newsTitleLabel setFrame:CGRectMake(
                                                 adGeneCell.newsThumbView.bounds.size.width + margin*9,
                                                 margin*3,
                                                 adGeneCell.newsInfoView.bounds.size.width - (adGeneCell.newsThumbView.bounds.size.width + margin*9),
                                                 adGeneCell.newsInfoView.bounds.size.height-margin*5)];
        adGeneCell.newsTitleLabel.text = [NSString stringWithFormat:@"【PR】%@", title];
        [adGeneCell.newsCategoryLabel setFrame:CGRectMake(
                                                    adGeneCell.newsThumbView.bounds.size.width + margin*9,
                                                    adGeneCell.newsThumbView.bounds.size.height - margin*2,
                                                    adGeneCell.newsInfoView.bounds.size.width - (adGeneCell.newsThumbView.bounds.size.width + margin*9),
                                                    20)];
        
        adGeneCell.newsCategoryLabel.text = sponsoreInfo;
        [adGeneCell.newsCategoryLabel sizeToFit];
        return adGeneCell;
        
    }
    
    
    
    [self.newsTableView registerClass:[RssNewsTableViewCell class] forCellReuseIdentifier:@"Cell"];
    RssNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    //記事情報
    [cell.newsInfoView setFrame:CGRectMake(
                                           margin,
                                           margin,
                                           self.view.bounds.size.width - margin*3,
                                           cellHeight - margin*2)];
    
    //サムネイル画像(キャッシュを使用)
    [cell.newsThumbView sd_setImageWithURL:[NSURL URLWithString:
                                            [self.news[indexPath.row] objectForKey:@"thumb"]]
                              placeholderImage:nil
                                       options: SDWebImageCacheMemoryOnly
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         
                                         if (error) {
                                             [cell.newsThumbView setImage:[[UIImage alloc] initWithData:
                                                                           [NSData dataWithContentsOfURL:
                                                                            [NSURL URLWithString:
                                                                             [self.news[indexPath.row] objectForKey:@"thumb"]]]]];
                                         }
                                         else{
                                             [cell.newsThumbView setImage:image];
                                             
                                             if(cacheType == SDImageCacheTypeMemory){
                                                 cell.newsThumbView.alpha = 1;
                                             }else{
                                                 [UIView animateWithDuration:0.4f animations:^{
                                                     cell.newsThumbView.alpha = 0;
                                                     cell.newsThumbView.alpha = 1;
                                                 }];
                                             }
                                         }
                                     }];

    //タイトル
    [cell.newsTitleLabel setFrame:CGRectMake(
                                             cell.newsThumbView.bounds.size.width + margin*9,
                                             margin*3,
                                             cell.newsInfoView.bounds.size.width - (cell.newsThumbView.bounds.size.width + margin*9),
                                             cell.newsInfoView.bounds.size.height-margin*5)];
    cell.newsTitleLabel.text = [self.news[indexPath.row] objectForKey:@"title"];
    
    //カテゴリーがあればカテゴリーセット
    if ([self.news[indexPath.row] objectForKey:@"category"]) {
        
        [cell.newsCategoryLabel setFrame:CGRectMake(
                                                    cell.newsThumbView.bounds.size.width + margin*9,
                                                    cell.newsThumbView.bounds.size.height - margin*2,
                                                    cell.newsInfoView.bounds.size.width - (cell.newsThumbView.bounds.size.width + margin*9),
                                                    20)];
        
        cell.newsCategoryLabel.text = [self.news[indexPath.row] objectForKey:@"category"];
        [cell.newsCategoryLabel sizeToFit];
        
    }
    //仕切り線
    if (indexPath.row == 0){//一番上はなし
        cell.separatorView.hidden = YES;
    }else{
        cell.separatorView.hidden = NO;
    }
    cell.separatorView.frame = CGRectMake(0,
                                          0,
                                          self.view.bounds.size.width,
                                          borderHeight);
    
    return cell;
}
//セルがタップされたときに呼ばれる
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Send repro Event
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[OPENMYRECO]
                         properties:@{DEFINES_REPROEVENTPROPNAME[VIEW]:
                                          NSStringFromClass([self class])}];
    
    
    NSDictionary * vConfig = [ConfigLoader mixIn];
    
    //選択状態の解除
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Myrecoへ遷移
    InfoWebViewController *newsView;
    
    if (indexPath.section == 1) {
        //3ページ目へ
        newsView = [[InfoWebViewController alloc] initWithURL:
                    [NSString stringWithFormat:@"%@%@",
                     self.category.readmore_url,
                     vConfig[@"MyReco"][@"suffix"]]];
    }
    else{
        //記事へ
        newsView = [[InfoWebViewController alloc] initWithURL:
                     [NSString stringWithFormat:
                      @"%@%@",
                      [self.news[indexPath.row] objectForKey:@"link"],
                      vConfig[@"MyReco"][@"suffix"]]];
    }
    
    //現在開いているViewのnavigation Controller取得
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    UINavigationController * homeNavi = topController.childViewControllers[0];
    
    [homeNavi pushViewController:newsView animated:YES];
    
}

//セルの高さを返す
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        return readMoreCellHeight;
    }else if (indexPath.section == 0 && indexPath.row == ROW_ADMOB) {
        return admobHeight;
    }
    return cellHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//解析開始時に呼ばれる
-(void) parserDidStartDocument:(NSXMLParser *)parser{
    
    //ステータスを初期化
    self.isTitle = NO;
    self.isLink = NO;
    self.isCategory = NO;
    self.isThumbPath = NO;
    self.isPubDate = NO;
    
}

//開始タグごとに呼ばれる
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    //NSLog(@"要素の開始タグを読み込んだ:%@",elementName);
    
    //開始タグに応じて文字の格納方法を決定
    if ([elementName isEqualToString:@"title"]){
        self.isTitle = YES;
    }
    else if ([elementName isEqualToString:@"link"]){
        self.isLink = YES;
    }
    else if ([elementName isEqualToString:@"category"]){
        self.isCategory = YES;
    }
    else if([elementName isEqualToString:@"description"]){
        self.isThumbPath = YES;
    }
    else if([elementName isEqualToString:@"pubDate"]){
        self.isPubDate = YES;
    }
}

//閉じタグ時に呼ばれる
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"要素の終了タグを読み込んだ:%@",elementName);
    
    //タイトルを取得
    if ([elementName isEqualToString:@"title"]){
        
        [self.newsTitles addObject:self.newsTitle];
        self.isTitle = NO;
        self.newsTitle = [[NSMutableString alloc] init];
    }
    //リンク取得
    else if ([elementName isEqualToString:@"link"]){
        [self.links addObject:self.link];
        self.isLink = NO;
        self.link= [[NSMutableString alloc] init];
    }
    //カテゴリー取得
    else if ([elementName isEqualToString:@"category"]){
        [self.newsCategories addObject:self.newsCategory];
        self.isCategory = NO;
        self.newsCategory = [[NSMutableString alloc] init];
    }
    //サムネイル画像のパスを取得
    else if ([elementName isEqualToString:@"description"]) {
        
        NSDictionary *vConfig = [ConfigLoader mixIn];
        
        //正規表現でパスを抽出
        self.thumbPath = [self getStringByRegexp:self.regexpForThumbPath string:self.thumbPath];
        
        //パスの整形
        self.thumbPath = (NSMutableString*)[self.thumbPath stringByReplacingOccurrencesOfString:@"src=" withString:@""];
        self.thumbPath = (NSMutableString*)[self.thumbPath stringByReplacingOccurrencesOfString:@"/>" withString:@""];
        self.thumbPath = (NSMutableString*)[self.thumbPath stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.thumbPath = (NSMutableString*)[vConfig[@"MyReco"][@"top"] stringByAppendingString:self.thumbPath];
        
        [self.thumbPaths addObject:self.thumbPath];
        self.isThumbPath = NO;
        self.thumbPath = [[NSMutableString alloc] init];
        
    }
    else if ([elementName isEqualToString:@"pubDate"]){
        
        [self.pubDates addObject:self.pubDate];
        self.isPubDate = NO;
        self.pubDate= [[NSMutableString alloc] init];
    }
}

//解析文字ごとに呼ばれる
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //NSLog(@"タグ以外のテキストを読み込んだ:%@", string);
    
    //それぞれのタグが終わるまで文字をつなげていく
    if (self.isTitle){
        
        [self.newsTitle appendString:string];
    }
    else if(self.isLink){
        
        [self.link appendString:string];
    }
    else if(self.isCategory){
        
        [self.newsCategory appendString:string];
    }
    else if(self.isThumbPath){
        
        [self.thumbPath appendString:string];
    }
    else if(self.isPubDate){
        
        [self.pubDate appendString:string];
    }
}

//解析終了時に呼ばれる
-(void) parserDidEndDocument:(NSXMLParser *)parser{
    
}

//エラー時に呼ばれる
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {

}

///非同期処理
- (void)doTaskAsynchronously:(void(^)())block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        block();
    });
}

///同期処理
- (void)doTaskSynchronously:(void(^)())block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
