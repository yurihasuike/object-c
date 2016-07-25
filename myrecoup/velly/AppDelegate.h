//
//  AppDelegate.h
//  velly
//
//  Created by m_saruwatari on 2015/02/05.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Appirater.h"
#import "HomeTabPagerViewController.h"
#import "EAIntroView.h"

@class RegistViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,UIActionSheetDelegate, EAIntroDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UITabBarController *naviViewController;
@property (strong, nonatomic) UINavigationController *registNavi;
@property (strong, nonatomic) UINavigationController *postNavi;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) EAIntroView * introView;
@property (nonatomic) UIViewController *lastActiveTab;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)hideTabBar;
- (void)showTabBar:(void(^)())completion;

@end

