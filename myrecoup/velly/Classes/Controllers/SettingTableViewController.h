//
//  SettingTableViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/03/07.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
-(id)initWithUserPid:(NSNumber*)userPid;
@end
