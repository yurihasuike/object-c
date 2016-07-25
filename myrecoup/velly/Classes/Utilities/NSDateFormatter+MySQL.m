//
//  NSDateFormatter+MySQL.m
//  BDYPico
//
//  Created by m_saruwatari on 2014/11/11.
//  Copyright (c) 2014年 mamoru.saruwatari. All rights reserved.
//

#import "NSDateFormatter+MySQL.h"

@implementation NSDateFormatter (MySQL)

+ (instancetype)MySQLDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return formatter;
}

+ (instancetype)UserBirthDateFormatter
{
    NSDateFormatter *strFormatter = [[NSDateFormatter alloc] init];
    strFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:NSLocalizedString(@"DateTimezone", nil)];
    [strFormatter setDateFormat:NSLocalizedString(@"DateFormatSrv", nil)];
    return strFormatter;
}

@end
