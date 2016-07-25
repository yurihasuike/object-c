//
//  Configuration.m
//  velly
//
//  Created by m_saruwatari on 2015/07/24.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "Configuration.h"

@implementation Configuration

+ (NSNumber *)loadBadge
{
    NSString *badgeStr = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"badge"];
    return [NSNumber numberWithInt:[badgeStr intValue]];
}

+ (void)saveBadge:(NSNumber *)badge
{
    [[LUKeychainAccess standardKeychainAccess] setObject:[badge stringValue] forKey:@"badge"];
}

+ (NSNumber *)loadSendBirdBadge
{
    NSString *badgeStr = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"sendbirdBadge"];
    return [NSNumber numberWithInt:[badgeStr intValue]];
}

+ (void)saveSendBirdBadge:(NSNumber *)badge
{
    [[LUKeychainAccess standardKeychainAccess] setObject:[badge stringValue] forKey:@"sendbirdBadge"];
}

+ (NSNumber *)loadInfoBadge
{
    NSString *badgeStr = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"infoBadge"];
    return [NSNumber numberWithInt:[badgeStr intValue]];
}

+ (void)saveInfoBadge:(NSNumber *)badge
{
    [[LUKeychainAccess standardKeychainAccess] setObject:[badge stringValue] forKey:@"infoBadge"];
}


+ (NSString *)loadLoginCallback
{
    NSString *loginCallback = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"loginCallback"];
    return loginCallback;
}
+ (void)saveLoginCallback:(NSString *)loginCallback {
    [[LUKeychainAccess standardKeychainAccess] setObject:loginCallback forKey:@"loginCallback"];
}


+ (NSString *)loadEmail
{
    NSString *email = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"email"];
    return email;
}

+ (void)saveEmail:(NSString *)email
{
    [[LUKeychainAccess standardKeychainAccess] setObject:email forKey:@"email"];
}

+ (NSNumber *)loadUserPid
{
    NSString *userPID = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"userPID"];
    return [NSNumber numberWithInt:[userPID intValue]];
}

+ (void)saveUserPid:(NSNumber *)userPID
{
    [[LUKeychainAccess standardKeychainAccess] setObject:userPID forKey:@"userPID"];
}

+ (NSString *)loadUserId
{
    NSString *userId = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"userID"];
    return userId;
}

+ (void)saveUserId:(NSString *)userID
{
    [[LUKeychainAccess standardKeychainAccess] setObject:userID forKey:@"userID"];
}

+ (void)saveUserChatToken:(NSString *)chatToken
{
    
    [[LUKeychainAccess standardKeychainAccess] setObject:chatToken forKey:@"userChatToken"];
}

+ (NSString *)loadUserChatToken
{
    NSString *userChatToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"userChatToken"];
    return userChatToken;
}

+ (NSString *)loadPassword
{
    NSString *password = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"password"];
    return password;
}

+ (void)savePassword:(NSString *)password
{
    [[LUKeychainAccess standardKeychainAccess] setObject:password forKey:@"password"];
}

+ (NSString *)loadAccessToken
{
    NSString *accessToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyToken"];
    return accessToken;
}

+ (void)saveAccessToken:(NSString *)accessToken
{
    [[LUKeychainAccess standardKeychainAccess] setObject:accessToken forKey:@"vellyToken"];
}

+ (NSString *)loadTWAccessToken
{
    NSString *twAccessToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyTWToken"];
    return twAccessToken;
}

+ (void)saveTWAccessToken:(NSString *)twAccessToken
{
    [[LUKeychainAccess standardKeychainAccess] setObject:twAccessToken forKey:@"vellyTWToken"];
}

+ (NSString *)loadLoginTWAccessToken
{
    NSString *loginTwAccessToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyLoginTWToken"];
    return loginTwAccessToken;
}

+ (void)saveLoginTWAccessToken:(NSString *)loginTwAccessToken
{
    [[LUKeychainAccess standardKeychainAccess] setObject:loginTwAccessToken forKey:@"vellyLoginTWToken"];
}

+ (NSString *)loadTWAccessTokenSecret
{
    NSString *twAccessTokenSecret = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyTWTokenSecret"];
    return twAccessTokenSecret;
}

+ (void)saveTWAccessTokenSecret:(NSString *)twAccessTokenSecret
{
    [[LUKeychainAccess standardKeychainAccess] setObject:twAccessTokenSecret forKey:@"vellyTWTokenSecret"];
}


+ (NSString *)loadLoginTWAccessTokenSecret
{
    NSString *loginTwAccessTokenSecret = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyLoginTWTokenSecret"];
    return loginTwAccessTokenSecret;
}

+ (void)saveLoginTWAccessTokenSecret:(NSString *)loginTwAccessTokenSecret
{
    [[LUKeychainAccess standardKeychainAccess] setObject:loginTwAccessTokenSecret forKey:@"vellyLoginTWTokenSecret"];
}

+ (NSString *)loadFBAccessToken
{
    NSString *fbAccessToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyFBToken"];
    return fbAccessToken;
}

+ (void)saveFBAccessToken:(NSString *)fbAccessToken
{
    [[LUKeychainAccess standardKeychainAccess] setObject:fbAccessToken forKey:@"vellyFBToken"];
}

+ (NSString *)loadLoginFBAccessToken
{
    NSString *loginFbAccessToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"vellyLoginFBToken"];
    return loginFbAccessToken;
}

+ (void)saveLoginFBAccessToken:(NSString *)loginFbAccessToken
{
    [[LUKeychainAccess standardKeychainAccess] setObject:loginFbAccessToken forKey:@"vellyLoginFBToken"];
}


+ (NSString *)loadDevToken
{
    NSString *deviceToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"deviceToken"];
    return deviceToken;
}

+ (void)saveDevToken:(NSString *)devToken
{
    [[LUKeychainAccess standardKeychainAccess] setObject:devToken forKey:@"deviceToken"];
}

+ (NSInteger *)loadDiffDevToken
{
    NSString *diffDeviceToken = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"diffDeviceToken"];
    switch ([diffDeviceToken integerValue]) {
        case VLISACTIVEDOIT:
            return (NSInteger *)VLISACTIVEDOIT;
            break;
        case VLISACTIVENON:
            return (NSInteger *)VLISACTIVENON;
            break;
        default:
            return (NSInteger *)VLISACTIVENON;
            break;
    }
}

+ (void)saveDiffDevToken:(NSInteger *)diffDevToken
{
    NSString *str = [NSString stringWithFormat:@"%zd",diffDevToken];
    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"diffDeviceToken"];
}

+ (NSInteger *)loadSettingFollow
{
    NSString *settingFollow = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"settingFollow"];
    switch ([settingFollow integerValue]) {
        case VLISACTIVENON:
            return (NSInteger *)VLISACTIVENON;
            break;
        case VLISACTIVEDOIT:
            return (NSInteger *)VLISACTIVEDOIT;
            break;
        default:
            return (NSInteger *)VLISACTIVENON;
            break;
    }
}

+ (void)saveSettingFollow:(NSInteger *)settingFollow
{
    NSString *str = [NSString stringWithFormat:@"%zd",settingFollow];
    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"settingFollow"];
}

+ (NSInteger *)loadSettingGood{
    NSString *settingGood = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"settingGood"];
    switch ([settingGood integerValue]) {
        case VLISACTIVENON:
            return (NSInteger *)VLISACTIVENON;
            break;
        case VLISACTIVEDOIT:
            return (NSInteger *)VLISACTIVEDOIT;
            break;
        default:
            return (NSInteger *)VLISACTIVENON;
            break;
    }
}

+ (void)saveSettingGood:(NSInteger *)settingGood
{
    NSString *str = [NSString stringWithFormat:@"%zd",settingGood];
    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"settingGood"];
}

+ (NSInteger *)loadSettingComment
{
    NSString *settingComment = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"settingComment"];
    switch ([settingComment integerValue]) {
        case VLISACTIVENON:
            return (NSInteger *)VLISACTIVENON;
            break;
        case VLISACTIVEDOIT:
            return (NSInteger *)VLISACTIVEDOIT;
            break;
        default:
            return (NSInteger *)VLISACTIVENON;
            break;
    }
}

+ (void)saveSettingComment:(NSInteger *)settingComment
{
    NSString *str = [NSString stringWithFormat:@"%zd",settingComment];
    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"settingComment"];
}

+ (NSInteger *)loadSettingRanking
{
    NSString *settingRanking = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"settingRanking"];
    switch ([settingRanking integerValue]) {
        case VLISACTIVENON:
            return (NSInteger *)VLISACTIVENON;
            break;
        case VLISACTIVEDOIT:
            return (NSInteger *)VLISACTIVEDOIT;
            break;
        default:
            return (NSInteger *)VLISACTIVENON;
            break;
    }
}

+ (void)saveSettingRanking:(NSInteger *)settingRanking
{
    NSString *str = [NSString stringWithFormat:@"%zd",settingRanking];
    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"settingRanking"];
}

+ (NSInteger *)loadSettingPostSave
{
    NSString *settingPostSave = [[LUKeychainAccess standardKeychainAccess] objectForKey:@"settingPostSave"];
    switch ([settingPostSave integerValue]) {
        case VLISACTIVENON:
            return (NSInteger *)VLISACTIVENON;
            break;
        case VLISACTIVEDOIT:
            return (NSInteger *)VLISACTIVEDOIT;
            break;
        default:
            return (NSInteger *)VLISACTIVENON;
            break;
    }
}

+ (void)saveSettingPostSave:(NSInteger *)settingPostSave
{
    NSString *str = [NSString stringWithFormat:@"%zd",settingPostSave];
    [[LUKeychainAccess standardKeychainAccess] setObject:str forKey:@"settingPostSave"];
}


+ (NSString *)checkLogined
{
    // access_token取得
    NSString *vellyToken = [Configuration loadAccessToken];
    if([vellyToken length]) {
        return vellyToken;
    }
    return nil;
}

#pragma mark - Synchronize
+ (void)synchronize
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)checkModel
{
    NSString *modelname = [ [ UIDevice currentDevice] model];
    if ( ![modelname hasPrefix:@"iPad"] ) {
        CGRect r = [[UIScreen mainScreen] bounds];
        if(r.size.height == 480){
            // iPhone4
            return VLModelNameIPhone4;
        } else if(r.size.height == 667){
            // iPhone6
            return VLModelNameIPhone6;
        } else if(r.size.height == 736){
            // iPhone6 Plus
            return VLModelNameIPhone6p;
        } else {
            // iPhone5
            return VLModelNameIPhone5;
        }
    } else {
        // iPad
        return VLModelNameIPad;
    }
}


@end
