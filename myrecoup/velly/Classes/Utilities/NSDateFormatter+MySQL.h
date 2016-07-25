//
//  NSDateFormatter+MySQL.h
//  BDYPico
//
//  Created by m_saruwatari on 2014/11/11.
//  Copyright (c) 2014年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>

/** MySQL から出力されるフォーマットの日時を取り扱うためのカテゴリ */
@interface NSDateFormatter (MySQL)

/** MySQL から出力されるフォーマットの日時を取り扱うためのフォーマッターを作る
 @return `NSDateFormatter`.
 */
+ (instancetype)MySQLDateFormatter;

+ (instancetype)UserBirthDateFormatter;


@end
