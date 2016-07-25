//
//  SettingTableViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/07.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "SettingTableViewController.h"
#import "ConfigLoader.h"
#import "NSDictionary+Sort.h"
#import "SettingWebViewController.h"
#import "PopularViewController.h"
#import "HomeTabPagerViewController.h"
#import "CSNLINEOpenerActivity.h"
#import "SVProgressHUD.h"
#import "UserManager.h"
#import "SettingManager.h"
#import "TrackingManager.h"
#import "User.h"
#import "MyGood.h"
#import "MyFollow.h"
#import "ConfigLoader.h"
#import "NaviViewController.h"
#import "Defines.h"
#import "CommonUtil.h"

static NSString * const formatToString[] = {
    [VLUSERATTRPRO] = @"p",
    [VLUSERATTRGENERAL] = @"g",
};
@interface SettingTableViewController ()

@property (nonatomic, strong) NSArray *cellItems;
@property (nonatomic, strong) NSArray *sectionList;
@property (nonatomic, strong) NSDictionary *dataSource;

@property (nonatomic, strong) UISwitch *switchFollow;
@property (nonatomic, strong) UISwitch *switchGood;
@property (nonatomic, strong) UISwitch *switchComment;
@property (nonatomic, strong) UISwitch *switchRanking;

@property (nonatomic, strong) UISwitch *switchImgSave;

@property (nonatomic, strong) NSNumber *settingFollow;
@property (nonatomic, strong) NSNumber *settingGood;
@property (nonatomic, strong) NSNumber *settingComment;
@property (nonatomic, strong) NSNumber *settingRanking;
@property (nonatomic, strong) NSNumber *settingImgSave;

@property (nonatomic) User *user;
@property (nonatomic) NSNumber *userPid;

@end

@implementation SettingTableViewController

-(id)initWithUserPid:(NSNumber*)userPid{
    if (!self) {
        self = [self init];
    }
    self.userPid = userPid;
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAndSetUser];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // init
    [Configuration loadSettingFollow];
    _settingFollow  = [NSNumber numberWithInt:0];
    _settingGood    = [NSNumber numberWithInt:0];
    _settingComment = [NSNumber numberWithInt:0];
    _settingRanking = [NSNumber numberWithInt:0];
    _settingImgSave = [NSNumber numberWithInt:0];

    [self.navigationItem setTitleView:[CommonUtil getNaviTitle:NSLocalizedString(@"NavTabSetting", nil)]];
    
    // 背景色
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    // セクション背景色
    [[UITableView appearance] setSectionIndexBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [UITableView appearance].sectionIndexBackgroundColor = [UIColor groupTableViewBackgroundColor];

    // ナビゲーションタイトル色
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    // ナビゲーションボタン色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // ナビゲーション背景色
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.950 green:0.950 blue:0.950 alpha:0.950];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        //[self.navigationController.navigationBar setBarTintColor:NAVBAR_BACKGROUNDCOLOR];
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
    }
    else {
        // ios6
        //[self.navigationController.navigationBar setTintColor:NAVBAR_BACKGROUNDCOLOR];
        self.navigationController.navigationBar.barTintColor = HEADER_BG_COLOR;
        
    }

    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    self.navigationController.navigationItem.backBarButtonItem = barButton;
    self.navigationItem.backBarButtonItem = barButton;
    
    UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:@""
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:nil];
    self.navigationItem.backBarButtonItem = btn;
    
    // 利き腕一覧を取得して、セルの表示に使用する
    NSDictionary *Config = [ConfigLoader mixIn];
    NSDictionary *cellItems   = Config[@"settingCellItems"];
    self.cellItems      = [cellItems keyCompareSortedAllValues];
    
    // セクション項目名
    _sectionList =  [NSArray arrayWithObjects:
                                        @"",
                                        NSLocalizedString(@"PageSettingSectionTitleSupport", nil),
                                        NSLocalizedString(@"PageSettingSectionTitlePushAlert", nil),
                                        NSLocalizedString(@"PageSettingSectionTitleImageSetting", nil),
                                        @" ",
                                        nil];
    // セル項目名
    NSArray *one = [NSArray arrayWithObjects:
                                        NSLocalizedString(@"PageSettingSectionItemFindFollowing", nil),
                                        NSLocalizedString(@"PageSettingSectionItemInviteMail", nil),
                                        nil];
    NSArray *two = [NSArray arrayWithObjects:
                                        NSLocalizedString(@"PageSettingSectionItemProAccount", nil),
                                        NSLocalizedString(@"PageSettingSectionItemInquiry", nil),
                                        NSLocalizedString(@"PageSettingSectionItemPolicy", nil),
                                        NSLocalizedString(@"PageSettingSectionItemTerms", nil),
                                        //NSLocalizedString(@"PageSettingSectionItemVersion", nil),
                                        nil];
    NSArray *three = [NSArray arrayWithObjects:
                                        NSLocalizedString(@"PageSettingSectionItemPushFollowed", nil),
                                        NSLocalizedString(@"PageSettingSectionItemPushGood", nil),
                                        NSLocalizedString(@"PageSettingSectionItemPushComment", nil),
                                        NSLocalizedString(@"PageSettingSectionItemPushChangeRanking", nil),
                                        nil];
    NSArray *four = [NSArray arrayWithObjects:
                                        NSLocalizedString(@"PageSettingSectionItemSavePostImage", nil),
                                        nil];
    NSArray *five = [NSArray arrayWithObjects:
                                        NSLocalizedString(@"PageSettingSectionItemLogout", nil),
                                        nil];

    NSArray *datas = [NSArray arrayWithObjects:one, two, three, four, five, nil];
    
    _dataSource = [NSDictionary dictionaryWithObjects:datas forKeys: _sectionList];

    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 40)];
    view.backgroundColor = [UIColor clearColor];
    // ---------------------
    // display version
    // ---------------------
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *appVer = vConfig[@"AppVersion"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,5,self.view.bounds.size.width,30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = appVer;
    label.font = JPBFONT(12);
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.6f;
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    self.tableView.tableFooterView = view;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"Setting"];
    
    // ---------------------------------------
    // get setting
    // ---------------------------------------
    [self loadSetting:self];
    
    
}

- (void)loadAndSetUser{
    
    [[UserManager sharedManager] getUserInfo:self.userPid block:^(NSNumber *result_code, User *srvUser, NSMutableDictionary *responseBody, NSError *error) {
        self.user = srvUser;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ステータスバー設定
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


// 上がのめり込むので、レイアウト調整
//-(void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    
//    // StatusBarのBottomの値をviewのOffsetとして使う
//    CGFloat topOffset = self.topLayoutGuide.length;
//    // Offset値からViewのframeを調整
//    CGRect rect      = self.view.frame;
//    rect.size.height = rect.size.height - topOffset;
//    rect.origin.y    = rect.origin.y    + topOffset;
//    self.view.frame  = rect;
//    
//    [self.view layoutIfNeeded];
//}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}


#pragma mark - DataSource
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_sectionList objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [_sectionList objectAtIndex:section];
    return [[_dataSource objectForKey:sectionName ]count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    //プロなら隠す.
    if (indexPath.section == 1 && indexPath.row == 0 && self.user && [self.user.attribute isEqualToString:formatToString[0]] ) {
        return 0;
    }
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"SettingTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *sectionName = [_sectionList objectAtIndex:indexPath.section];
    NSArray *items = [_dataSource objectForKey:sectionName];
    //cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    cell.textLabel.font = JPFONT(14);
    
    if(indexPath.section == 0) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.section == 1) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //プロなら隠す.
        if (indexPath.row == 0 && self.user && [self.user.attribute isEqualToString:formatToString[0]] ) {
            cell.hidden = YES;
        }
        
        
    }else if(indexPath.section == 2) {
        // ラジオ
        CGRect frame = CGRectMake(254.0, 6.0, 94.0, 27.0);
        UISwitch *tsw = [[UISwitch alloc] initWithFrame:frame];
        if(indexPath.row == 0){
            // フォローされた時
            cell.accessoryType = UITableViewCellAccessoryNone;
            //[cell.contentView addSubview:tsw];
            _switchFollow = tsw;
            
            NSInteger *mySettingFollow = [Configuration loadSettingFollow];
            if(mySettingFollow && mySettingFollow == (NSInteger *)VLISACTIVEDOIT){
                // フラグON
                _switchFollow.on = YES;
            }
            if(_settingFollow == [NSNumber numberWithInt:1]){
                // フラグON
                _switchFollow.on = YES;
            }
            cell.accessoryView = _switchFollow;
            [_switchFollow addTarget:self action:@selector(switchFollow:) forControlEvents:UIControlEventValueChanged];
            
        }else if(indexPath.row == 1){
            // いいねされた時
            cell.accessoryType = UITableViewCellAccessoryNone;
            //[cell.contentView addSubview:tsw];
            _switchGood = tsw;
            
            NSInteger *mySettingGood = [Configuration loadSettingGood];
            if(mySettingGood && mySettingGood == (NSInteger *)VLISACTIVEDOIT){
                // フラグON
                _switchGood.on = YES;
            }
            if(_settingGood == [NSNumber numberWithInt:1]){
                // フラグON
                _switchGood.on = YES;
            }
            cell.accessoryView = _switchGood;
            [_switchGood addTarget:self action:@selector(switchGood:) forControlEvents:UIControlEventValueChanged];

        }else if(indexPath.row == 2){
            // コメントされた時
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            //[cell.contentView addSubview:tsw];
            _switchComment = tsw;
            
            NSInteger *mySettingComment = [Configuration loadSettingComment];
            if(mySettingComment && mySettingComment == (NSInteger *)VLISACTIVEDOIT){
                // フラグON
                _switchComment.on = YES;
            }
            if(_settingComment == [NSNumber numberWithInt:1]){
                // フラグON
                _switchComment.on = YES;
            }
            cell.accessoryView = _switchComment;
            [_switchComment addTarget:self action:@selector(switchComment:) forControlEvents:UIControlEventValueChanged];
            

        }else if(indexPath.row == 3){
            // 順位が変更された時
            cell.accessoryType = UITableViewCellAccessoryNone;
            //[cell.contentView addSubview:tsw];
            _switchRanking = tsw;
            
            NSInteger *mySettingRanking = [Configuration loadSettingRanking];
            if(mySettingRanking && mySettingRanking == (NSInteger *)VLISACTIVEDOIT){
                // フラグON
                _switchRanking.on = YES;
            }
            if(_settingRanking == [NSNumber numberWithInt:1]){
                // フラグON
                _switchRanking.on = YES;
            }
            cell.accessoryView = _switchRanking;
            [_switchRanking addTarget:self action:@selector(switchRanking:) forControlEvents:UIControlEventValueChanged];
        }
        
    }else if(indexPath.section == 3) {
        // ラジオ
        if(indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            CGRect frame = CGRectMake(254.0, 6.0, 94.0, 27.0);
            UISwitch *tsw = [[UISwitch alloc] initWithFrame:frame];
            //[cell.contentView addSubview:tsw];
            _switchImgSave = tsw;
            
            NSInteger *mySettingImgSave = [Configuration loadSettingPostSave];
            if(mySettingImgSave && mySettingImgSave == (NSInteger *)VLISACTIVEDOIT){
                // フラグON
                _switchImgSave.on = YES;
            }
            if(_settingImgSave == [NSNumber numberWithInt:1]){
                // フラグON
                _switchImgSave.on = YES;
            }
            cell.accessoryView = _switchImgSave;
            [_switchImgSave addTarget:self action:@selector(switchImgSave:) forControlEvents:UIControlEventValueChanged];
        }
        
    }else if(indexPath.section == 4) {
        // 無し
        if(indexPath.row == 0){
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;

    // ハイライト非表示
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    
//    // 前回選択の項目にのみチェックマークを付ける
//    //if ([cell.textLabel.text isEqualToString:self.inputViewController.handedButton.titleLabel.text]) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    //}
    
    return cell;
    
}



//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    static NSString *HeaderIdentifier = @"Header";
//    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
//    
//    if (!view) {
//        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:HeaderIdentifier];
//    }
//
//    UIView *sectionView = [[UIView alloc] init];
//    sectionView.frame = CGRectMake(10.0f, 0.0f, 320.0f, 64.0f);
//    sectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//
//    UILabel *secLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 320.0f, 64.0f)];
//    //UILabel *secLabel = [UILabel new];
//    secLabel.font = [UIFont boldSystemFontOfSize:13];
//    
//    secLabel.textColor = [UIColor darkGrayColor];
//    secLabel.text = [_sectionList objectAtIndex:section];
//    [sectionView addSubview:secLabel];
//    
//    //view.textLabel.text = @"テスト１";
//    
//    return sectionView;
//}


// ヘッター / フッターで余白を作成
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 24.0f;
    }else{
        return 36.0f;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 24)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 36)];
        view.backgroundColor = [UIColor clearColor];
        
        if(section == 1 || section == 2 || section == 3){
            UILabel *label = [[UILabel alloc] init];
            label.frame = CGRectMake(10, 10, 200, 30);
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor darkGrayColor];
            label.font = JPFONT(12);
            label.textAlignment = NSTextAlignmentLeft;
            if(section == 1){
                label.text = NSLocalizedString(@"PageSectionSupport", nil);
            }else if(section == 2){
                label.text = NSLocalizedString(@"PageSectionSettingPush", nil);
            }else if(section == 3){
                label.text = NSLocalizedString(@"PageSectionSettingPhoto", nil);
            }
            
            [view addSubview:label];
        }
        
        return view;
    }
    //return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == _sectionList.count - 1){
        //return 44.0f;
        return 4.0f;
    }else{
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    if(section == _sectionList.count - 1){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 4)];
        view.backgroundColor = [UIColor clearColor];
//        // ---------------------
//        // display version
//        // ---------------------
//        NSDictionary *vConfig   = [ConfigLoader mixIn];
//        NSString *appVer = vConfig[@"AppVersion"];
//
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,5,self.view.bounds.size.width,30)];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.text = appVer;
//        label.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:12];
//        label.adjustsFontSizeToFitWidth = YES;
//        label.minimumScaleFactor = 0.6f;
//        label.textColor = [UIColor grayColor];
//        [view addSubview:label];
        
        
//        // diplay : device_token
//        
//        NSString *dToken = [Configuration loadDevToken];
//        UILabel *dTokenlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,15,self.view.bounds.size.width,30)];
//        dTokenlabel.textAlignment = NSTextAlignmentCenter;
//        dTokenlabel.text = dToken;
//        dTokenlabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:12];
//        dTokenlabel.adjustsFontSizeToFitWidth = YES;
//        dTokenlabel.minimumScaleFactor = 0.4f;
//        dTokenlabel.textColor = [UIColor grayColor];
//        [view addSubview:dTokenlabel];
        
        return view;
    }else{
        return nil;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 36;
    if (scrollView.contentOffset.y == 0) {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    } else if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
        //scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, sectionHeaderHeight * 3, 0);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        //scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, sectionHeaderHeight * 3, 0);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get section name
    NSString *sectionName = [_sectionList objectAtIndex:indexPath.section];
    
    // セクション名をキーにしてそのセクションの項目をすべて取得
    NSArray *items = [_dataSource objectForKey:sectionName];
    
    DLog(@"「%@」が選択されました", [items objectAtIndex:indexPath.row]);
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            // フォローするユーザを見つける

            DLog(@"SettingView popularViewAction");
            
            PopularViewController *popularView = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"PopularViewController"];
            
            [self.navigationController pushViewController:popularView animated:YES];
            
            
        }else if(indexPath.row == 1){
            // メールで招待する
            DLog(@"メールで招待する");
            // メールビュー生成
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            // メール件名
            [picker setSubject:NSLocalizedString(@"InviteMailSubject", nil)];
            // To
            //NSArray * toAddressList = [NSArray arrayWithObjects:@"report@velly.jp", nil];
            //[picker setToRecipients:toAddressList];
            // 添付画像
            //NSData *myData = [[NSData alloc] initWithData:UIImageJPEGRepresentation([UIImage imageNamed:@"Pandora_744_1392.jpg"], 1)];
            //[picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:@"image"];
            // メール本文
            
            NSString *nickName = [Configuration loadUserId];
            if(!nickName || ![nickName length] > 0){
                nickName = @" ";
            }
            NSString *mailBody = NSLocalizedString(@"InviteMailBody", nil);
            mailBody = [mailBody stringByReplacingOccurrencesOfString:@"<?username>" withString:nickName];

//// test write device_token
//NSString *dToken = [Configuration loadDevToken];
//if(dToken != nil && [dToken length] > 0){
//mailBody = [mailBody stringByAppendingString:dToken];
//}
            
            NSMutableArray *activityItems = [[NSMutableArray alloc] init];
            [activityItems addObject:mailBody];
            NSArray *applicationActivities = @[[[CSNLINEOpenerActivity alloc] initWithTitle:nil icon:[UIImage imageNamed:@"ico_line43.png"]]];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                                 applicationActivities:applicationActivities];
            [self presentViewController:activityViewController animated:YES completion:NULL];
            
//            [picker setMessageBody:mailBody isHTML:NO];
//            // メールビュー表示
//            [self presentViewController:picker animated:YES completion:nil];

        }

    }else if(indexPath.section == 1){
        // サポート
        if (indexPath.row == 0) {
            DLog(@"SettingTableView ProAccount");
            SettingWebViewController *webcontroller = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingWebViewController"];
            
            NSDictionary *vConfig   = [ConfigLoader mixIn];
            NSString *baseApiUrl = vConfig[@"WebViewURLProAccount"];
            NSString *nickName = [Configuration loadUserId];

            NSString *strUrl = [NSString stringWithFormat:@"%@%@%@",baseApiUrl,@"&username=",nickName];

            webcontroller.webURLPath = strUrl;
            webcontroller.title = NSLocalizedString(@"PageProAccount", nil);
            
            [self.navigationController pushViewController:webcontroller animated:YES];
            
        }else if(indexPath.row == 1){

            DLog(@"SettingTableView Contact");
            
            SettingWebViewController *webcontroller = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingWebViewController"];

            NSDictionary *vConfig   = [ConfigLoader mixIn];
            NSString *strUrl = vConfig[@"WebViewURLContact"];
            webcontroller.webURLPath = strUrl;
            webcontroller.title = NSLocalizedString(@"PageContact", nil);
            
            [self.navigationController pushViewController:webcontroller animated:YES];

        }else if(indexPath.row == 2){

            DLog(@"SettingTableView Policy");
            
            SettingWebViewController *webcontroller = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingWebViewController"];

            NSDictionary *vConfig   = [ConfigLoader mixIn];
            NSString *strUrl = vConfig[@"WebViewURLPolicy"];
            webcontroller.webURLPath = strUrl;
            webcontroller.title = NSLocalizedString(@"PagePolicy", nil);
            
            [self.navigationController pushViewController:webcontroller animated:YES];

        }else if(indexPath.row == 3){

            DLog(@"SettingTableView Terms");
            
            SettingWebViewController *webcontroller = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingWebViewController"];
            
            NSDictionary *vConfig   = [ConfigLoader mixIn];
            NSString *strUrl = vConfig[@"WebViewURLTerms"];
            webcontroller.webURLPath = strUrl;
            webcontroller.title = NSLocalizedString(@"PageTerms", nil);
            
            [self.navigationController pushViewController:webcontroller animated:YES];
            
        }else if(indexPath.row == 4){

            DLog(@"SettingTableView Version");
            
            SettingWebViewController *webcontroller = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingWebViewController"];
            
            NSDictionary *vConfig   = [ConfigLoader mixIn];
            NSString *strUrl = vConfig[@"WebViewURLVersion"];
            webcontroller.webURLPath = strUrl;
            webcontroller.title = NSLocalizedString(@"PageVersion", nil);
            
            [self.navigationController pushViewController:webcontroller animated:YES];
            
        }
        
    }else if(indexPath.section == 2){
        // プッシュ通知
        if(indexPath.row == 0){
            // フォローされた時
        }else if(indexPath.row == 1){
            // いいねされた時
        }else if(indexPath.row == 2){
            // 順位が変動した時
        }
    }else if(indexPath.section == 3){
        // 写真設定
        if(indexPath.row == 0){
            // 元の画像を保存
        }
    }else if(indexPath.section == 4){
        // ログアウト
        [self logoutAction:self];
    }
    
}



- (void)loadSetting:(id)sender
{

    NSString *aToken = [Configuration loadAccessToken];

    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }

    [[SettingManager sharedManager] getSettingInfo:aToken block:^(NSNumber *result_code, Setting *setting, NSMutableDictionary *responseBody, NSError *error) {

        if(setting){
            if(setting.pushOnFollow && [setting.pushOnFollow isEqualToNumber:[NSNumber numberWithInt:1]]){
                // フラグON
                _switchFollow.on = YES;
                _settingFollow = [NSNumber numberWithInt:1];
                [Configuration saveSettingFollow:(NSInteger *)VLISACTIVEDOIT];
            }else{
                // フラグOFF
                _switchFollow.on = NO;
                _settingFollow = [NSNumber numberWithInt:0];
                [Configuration saveSettingFollow:(NSInteger *)VLISACTIVENON];
            }
            if(setting.pushOnLike && [setting.pushOnLike isEqualToNumber:[NSNumber numberWithInt:1]]){
                // フラグON
                _switchGood.on = YES;
                _settingGood = [NSNumber numberWithInt:1];
                [Configuration saveSettingGood:(NSInteger *)VLISACTIVEDOIT];
            }else{
                // フラグOFF
                _switchGood.on = NO;
                _settingGood = [NSNumber numberWithInt:0];
                [Configuration saveSettingGood:(NSInteger *)VLISACTIVENON];
            }
            if(setting.pushOnComment && [setting.pushOnComment isEqualToNumber:[NSNumber numberWithInt:1]]){
                // フラグON
                _switchComment.on = YES;
                _settingComment = [NSNumber numberWithInt:1];
                [Configuration saveSettingComment:(NSInteger *)VLISACTIVEDOIT];
            }else{
                // フラグOFF
                _switchComment.on = NO;
                _settingComment = [NSNumber numberWithInt:0];
                [Configuration saveSettingComment:(NSInteger *)VLISACTIVENON];
            }
            if(setting.pushOnRanking && [setting.pushOnRanking isEqualToNumber:[NSNumber numberWithInt:1]]){
                // フラグON
                _switchRanking.on = YES;
                _settingRanking = [NSNumber numberWithInt:1];
                [Configuration saveSettingRanking:(NSInteger *)VLISACTIVEDOIT];
            }else{
                // フラグOFF
                _switchRanking.on = NO;
                _settingRanking = [NSNumber numberWithInt:0];
                [Configuration saveSettingRanking:(NSInteger *)VLISACTIVENON];
            }
            
        }
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)postSetting:(id)sender
{
    
    NSString *aToken = [Configuration loadAccessToken];
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingListDsiplay"];
    // must
    isLoding = @"YES";
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    
    NSNumber *pushOnFollow  = _settingFollow;
    NSNumber *pushOnLike    = _settingGood;
    NSNumber *pushOnComment = _settingComment;
    NSNumber *pushOnRanking = _settingRanking;
    
    [[SettingManager sharedManager] putUserInfo:aToken pushOnFollow:pushOnFollow pushOnLike:pushOnLike pushOnComment:pushOnComment pushOnRanking:pushOnRanking block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
        
        if(error){
            
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ApiErrorNetwork", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
        }else{
            // save
            //[Configuration saveSettingFollow:pushOnFollow];
        }
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }
    }];
}



- (void) switchFollow:(id)sender
{
    DLog(@"SettingTableView switchFollow");
    
    if(_settingFollow == [NSNumber numberWithInt:0]){
        // フラグON
        _switchFollow.on = YES;
        _settingFollow = [NSNumber numberWithInt:1];
        [Configuration saveSettingFollow:(NSInteger *)VLISACTIVEDOIT];
        
    }else{
        // フラグOFF
        _switchFollow.on = NO;
        _settingFollow = [NSNumber numberWithInt:0];
        [Configuration saveSettingFollow:(NSInteger *)VLISACTIVENON];
    }

    // setting 更新
    [self postSetting:self];

}

- (void) switchGood:(id)sender
{
    DLog(@"SettingTableView switchGood");
    
    if(_settingGood == [NSNumber numberWithInt:0]){
        // フラグON
        _switchGood.on = YES;
        _settingGood = [NSNumber numberWithInt:1];
        [Configuration saveSettingGood:(NSInteger *)VLISACTIVEDOIT];
    }else{
        // フラグOFF
        _switchGood.on = NO;
        _settingGood = [NSNumber numberWithInt:0];
        [Configuration saveSettingGood:(NSInteger *)VLISACTIVENON];
    }

    // setting 更新
    [self postSetting:self];

}

- (void) switchComment:(id)sender
{
    DLog(@"SettingTableView switchComment");
    
    if(_settingComment == [NSNumber numberWithInt:0]){
        // フラグON
        _switchComment.on = YES;
        _settingComment = [NSNumber numberWithInt:1];
        [Configuration saveSettingComment:(NSInteger *)VLISACTIVEDOIT];
    }else{
        // フラグOFF
        _switchComment.on = NO;
        _settingComment = [NSNumber numberWithInt:0];
        [Configuration saveSettingComment:(NSInteger *)VLISACTIVENON];
    }
    
    // setting 更新
    [self postSetting:self];

}

- (void) switchRanking:(id)sender
{
    DLog(@"SettingTableView switchRanking");
    
    if(_settingRanking == [NSNumber numberWithInt:0]){
        // フラグON
        _switchRanking.on = YES;
        _settingRanking = [NSNumber numberWithInt:1];
        [Configuration saveSettingRanking:(NSInteger *)VLISACTIVEDOIT];
    }else{
        // フラグOFF
        _switchRanking.on = NO;
        _settingRanking = [NSNumber numberWithInt:0];
        [Configuration saveSettingRanking:(NSInteger *)VLISACTIVENON];
    }

    // setting 更新
    [self postSetting:self];

}

- (void) switchImgSave:(id)sender
{
    DLog(@"SettingTableView switchImgSave");
    
    if(_settingImgSave == [NSNumber numberWithInt:0]){
        // フラグON
        _switchImgSave.on = YES;
        _settingImgSave = [NSNumber numberWithInt:1];
        [Configuration saveSettingPostSave:(NSInteger *)VLISACTIVEDOIT];
    }else{
        // フラグOFF
        _switchImgSave.on = NO;
        _settingImgSave = [NSNumber numberWithInt:0];
        [Configuration saveSettingPostSave:(NSInteger *)VLISACTIVENON];
    }

}


- (void) logoutAction:(id)sender {
    
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        // iOS8
        
        // コントローラを生成
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MsgConfLogout", nil)
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
        //[[UIAlertController alloc] preferredStyle:UIAlertControllerStyleActionSheet]:
    
        // Cancel用のアクションを生成
        UIAlertAction * cancelAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * action) {
                               // ボタンタップ時の処理
                               DLog(@"Cancel button tapped.");
                           }];
        // OK用のアクションを生成
        UIAlertAction * okAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"MsgDoLogout", nil)
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               // ボタンタップ時の処理
                               DLog(@"OK button tapped.");
                               [self logoutSend];
                               
                           }];
        // コントローラにアクションを追加
        [ac addAction:cancelAction];
        //[ac addAction:destructiveAction];
        [ac addAction:okAction];
    
        // アクションシート表示処理
        [self presentViewController:ac animated:YES completion:nil];
        
    }else{
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = NSLocalizedString(@"MsgConfLogout", nil);
        [as addButtonWithTitle:NSLocalizedString(@"MsgDoLogout", nil)];
        [as addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        as.destructiveButtonIndex = 0;
        as.cancelButtonIndex = 1;
        as.tag = 0;
        [as showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 0){
        // logout
        switch (buttonIndex) {
            case 0:
                // logout
                [self logoutSend];
                break;
        }
    }
}

- (void) logoutSend
{
    DLog(@"SettingTableView logoutSend");

    // Loading
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    NSString *isLoding = vConfig[@"LoadingPostDisplay"];
    if( isLoding && [isLoding boolValue] == YES ){
        // Loading
        [SVProgressHUD showWithStatus:NSLocalizedString(@"ApiWaitingSend", nil) maskType:SVProgressHUDMaskTypeBlack];
    }
    
    [[UserManager sharedManager] sendLogOut:nil block:^(NSNumber *result_code, NSMutableDictionary *responseBody, NSError *error) {
        
        if( isLoding && [isLoding boolValue] == YES ){
            // clear loading
            [SVProgressHUD dismiss];
        }

        if(result_code.longLongValue == API_RESPONSE_CODE_SUCCESS.longLongValue){
            // success
            
            // SEND REPRO EVENT
            [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[LOGOUT]
                                 properties:@{DEFINES_REPROEVENTPROPNAME[USER_PID] :
                                                  [Configuration loadUserPid]}];

            // access_token等キーチェーン削除
            [Configuration saveUserPid:nil];
            [Configuration saveUserId:nil];
            [Configuration saveEmail:nil];
            [Configuration savePassword:nil];
            [Configuration saveAccessToken:nil];
            [Configuration saveTWAccessToken:nil];
            [Configuration saveTWAccessTokenSecret:nil];
            [Configuration saveFBAccessToken:nil];
            [Configuration saveSettingFollow:nil];
            [Configuration saveSettingGood:nil];
            [Configuration saveSettingRanking:nil];
            // 元画像の保存可否は端末単位で常に保持させておくので消さない
            // [Configuration saveSettingPostSave:nil];

            // MagicalRecord削除
            [User MR_truncateAll];
            [MyGood MR_truncateAll];
            [MyFollow MR_truncateAll];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
            // ホームへ移動
            HomeTabPagerViewController *homeTabPagerViewController = (HomeTabPagerViewController *)self.tabBarController.childViewControllers[0];
            // タブを選択済みにする
            [UIView transitionFromView:self.view
                                toView:homeTabPagerViewController.view
                              duration:0.1
             //options:UIViewAnimationOptionTransitionCrossDissolve
                               options:UIViewAnimationOptionTransitionNone
                            completion:
             ^(BOOL finished) {
                 
                 [self resetInfoIfExists];
                 
                 self.tabBarController.selectedViewController = homeTabPagerViewController;
            
                 // tab背景
                 UIImage *tabBarHomeImg = [UIImage imageNamed:@"bg_nav-on01.png"];
                 UIGraphicsBeginImageContextWithOptions(CGSizeMake([[UIScreen mainScreen] bounds].size.width, kTabBarHeight), NO, 0.0);
                 [tabBarHomeImg drawInRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, kTabBarHeight)];
                 tabBarHomeImg = UIGraphicsGetImageFromCurrentImageContext();
                 UIGraphicsEndImageContext();
                 
                 self.tabBarController.tabBar.backgroundImage = tabBarHomeImg; // [UIImage imageNamed:@"bg_nav-on01.png"];
            
                 // プロフィールを最初の画面に戻す
                 [self.navigationController popToRootViewControllerAnimated:NO];
                 
            
             }];
            
            [SVProgressHUD showSuccessWithStatus: NSLocalizedString(@"MsgDidLogout", nil)];

        }else{
            // no error check
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ApiErrorLogout", nil) message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }

    }];

}


// アプリ内メーラーのデリゲートメソッド
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            // キャンセル
            break;
        case MFMailComposeResultSaved:
            // 保存
            break;
        case MFMailComposeResultSent:
            // 送信成功
            break;
        case MFMailComposeResultFailed:
            // 送信失敗
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

///バグ修正(#2894)お知らせを更新.
- (void)resetInfoIfExists {
    InfoViewController * infoView;
    for (UIViewController * v in ((NaviViewController * )self.tabBarController).childViewControllers) {
        if ([v isKindOfClass:[UINavigationController class]]) {
            for (UIViewController * iv in v.childViewControllers) {
                if ([iv isKindOfClass:[InfoViewController class]]) {
                    infoView = (InfoViewController * )iv;
                }
            }
        }
    }
    if (infoView) {
        [infoView viewWillAppear:NO];
        [infoView refreshInfos:YES];
    }
}


@end
