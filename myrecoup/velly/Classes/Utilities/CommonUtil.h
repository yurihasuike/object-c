//
//  CommonUtil.h
//  velly
//
//  Created by m_saruwatari on 2015/03/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NaviViewController.h"

@interface CommonUtil : NSObject

+ (CommonUtil *)sharedInstance;

+ (NSAttributedString *)uiLabelHeight:(CGFloat)height label:(NSString *)label;
+ (NSAttributedString *)uiLabelNoBreakHeight:(CGFloat)height label:(NSString *)label;
+ (NSString *)dateToExchangeString:(NSDate *)targetDate;

- (NSString *)dateToString:(NSDate *)baseDate formatString:(NSString *)formatString;
- (NSString *)createStringAddedCommaFromInt:(NSNumber *)number;

- (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size radiusSize:(CGSize)radiusSize;

- (NSString *)contentTypeForImageData:(NSData *)data;
- (NSString *)mimeTypeByGuessingFromData:(NSData *)data;

+ (NSString *)clearLineBreak:(NSString *)line;
+ (void)delay:(float)time block:(void (^)())block;
+ (void)doTaskAsynchronously:(void(^)())block;
+ (void)doTaskSynchronously:(void(^)())block;
+ (NaviViewController * )getNaviViewController;
+ (NSString *)getMaxDoubleDigitsStr:(NSNumber *)num;
+ (NSString *)getImgPath:(Post *)post;
+ (NSString *)getURLFormattedParams:(NSDictionary *)params;
+ (NSIndexPath *)indexPathForTableViewAtRecognizer:(UITableView *)tblView r:(UIGestureRecognizer *)r;
+ (NSIndexPath *)indexPathForTableViewAtEvent:(UITableView *)tblView e:(UIEvent *)e;
+ (NSMutableDictionary *)errorJson:(NSString *)response;
+ (UIImage *)getCachedImg:(NSString *)url;
+ (void)cacheImg:(UIImage *)img URL:(NSString *)URL;
+ (UILabel *)getNaviTitle:(NSString *)str;
+ (UIBarButtonItem *)getBackNaviBtn;

@end


