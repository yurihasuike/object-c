//
//  CommonUtil.m
//  velly
//
//  Created by m_saruwatari on 2015/03/03.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "CommonUtil.h"
#import "ConfigLoader.h"
#import "UIImageView+WebCache.h"

@implementation CommonUtil

+ (CommonUtil *)sharedInstance {
    static CommonUtil *sharedInstance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[CommonUtil alloc] init];
    });
    return sharedInstance;
}

+ (NSAttributedString *)uiLabelHeight:(CGFloat)height label:(NSString *)label
{
    CGFloat lineHeight = height;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [paragraphStyle setMinimumLineHeight:lineHeight] ;
    [paragraphStyle setMaximumLineHeight:lineHeight] ;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:label attributes:attributes] ;
    return attributedText;
}

+ (NSAttributedString *)uiLabelNoBreakHeight:(CGFloat)height label:(NSString *)label
{
    CGFloat lineHeight = height;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [paragraphStyle setMinimumLineHeight:lineHeight] ;
    [paragraphStyle setMaximumLineHeight:lineHeight] ;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:paragraphStyle,NSParagraphStyleAttributeName,nil] ;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:label attributes:attributes] ;
    return attributedText;
}

+ (NSString *)dateToExchangeString:(NSDate *)targetDate
{
    NSTimeInterval since = [[NSDate date] timeIntervalSinceDate:targetDate];
    //NSLog(@"%f時",round(since/(60*60)));
    //NSLog(@"%f日",round(since/(24*60*60)));
    NSNumber *days   = [NSNumber numberWithFloat:round(since/(24*60*60))];
    NSNumber *hours  = [NSNumber numberWithFloat:round(since/(60*60))];
    NSNumber *min    = [NSNumber numberWithFloat:round(since/(60))];
    NSNumber *target = [NSNumber numberWithInt:0.9];
    NSComparisonResult result;
    result = [days compare:target];
    switch(result) {
        case NSOrderedSame: // 一致したとき
        case NSOrderedAscending: // daysが小さいとき
            if([hours floatValue] < 1){
                if([min floatValue] <= 1){
                    return @"たった今";
                }else {
                    return [NSString stringWithFormat:@"%@分前", [min stringValue]];
                }
            }else{
                DLog(@"%f時",round(since/(60*60)));
                return [NSString stringWithFormat:@"%@時間前", [hours stringValue]];
            }
            break;
        case NSOrderedDescending: // daysが大きいとき
            DLog(@"%f日",round(since/(24*60*60)));
            //self.infoDateLabel.text =  [NSString stringWithFormat:@"%@日前", [days stringValue]];
            return [[self sharedInstance] dateToString:targetDate formatString:@"yyyy年M月d日"];
            break;
    }
    return @"";
}

/* 日付を文字列に変換
 */
- (NSString*)dateToString:(NSDate *)baseDate formatString:(NSString *)formatString
{
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    //24時間表示 & iPhoneの現在の設定に合わせる
    [inputDateFormatter setLocale:[NSLocale currentLocale]];
    [inputDateFormatter setDateFormat:formatString];
    NSString *str = [inputDateFormatter stringFromDate:baseDate];
    return str;
}

/*
 * 数字を３桁ずつカンマ区切りで出力
 */
- (NSString *)createStringAddedCommaFromInt:(NSNumber *)number
{
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    [format setNumberStyle:NSNumberFormatterDecimalStyle];
    [format setGroupingSeparator:@","];
    [format setGroupingSize:3];
    
    return [format stringForObjectValue:number];
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size radiusSize:(CGSize)radiusSize
{
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    int ra_w = radiusSize.width;
    int ra_h = radiusSize.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    //addRoundedRectToPath(context, rect, 23, 23);
    addRoundedRectToPath(context, rect, ra_w, ra_h);

    
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
}

- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

- (NSString *)mimeTypeByGuessingFromData:(NSData *)data {
    
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];
    
    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    const char swf[3] = {'F', 'W', 'S'};
    const char swc[3] = {'C', 'W', 'S'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char psd[4] = {'8', 'B', 'P', 'S'};
    const char iff[4] = {'F', 'O', 'R', 'M'};
    const char webp[4] = {'R', 'I', 'F', 'F'};
    const char ico[4] = {0x00, 0x00, 0x01, 0x00};
    const char tif_ii[4] = {'I','I', 0x2A, 0x00};
    const char tif_mm[4] = {'M','M', 0x00, 0x2A};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    const char jp2[12] = {0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, 0x87, 0x0a};

    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return @"image/gif";
    } else if (!memcmp(bytes, jpg, 3)) {
        return @"image/jpeg";
    } else if (!memcmp(bytes, psd, 4)) {
        return @"image/psd";
    } else if (!memcmp(bytes, iff, 4)) {
        return @"image/iff";
    } else if (!memcmp(bytes, webp, 4)) {
        return @"image/webp";
    } else if (!memcmp(bytes, ico, 4)) {
        return @"image/vnd.microsoft.icon";
    } else if (!memcmp(bytes, tif_ii, 4) || !memcmp(bytes, tif_mm, 4)) {
        return @"image/tiff";
    } else if (!memcmp(bytes, png, 8)) {
        return @"image/png";
    } else if (!memcmp(bytes, jp2, 12)) {
        return @"image/jp2";
    }
    return @"application/octet-stream"; // default type
}


+ (NSString *)clearLineBreak:(NSString *)line
{
    // 改行除去
    NSMutableArray *lines = [NSMutableArray array];
    [line enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [lines addObject:line];
    }];
    NSMutableString *descripStr = [[NSMutableString alloc] init];
    for (int i = 0; i < [lines count]; i++) {
        if (![lines[i] isEqualToString:@""]) {
            [descripStr appendString:lines[i]];
        }
    }
    return descripStr;
}

///遅延実行
+ (void)delay:(float)time block:(void (^)())block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        block();
    });
}
///非同期実行
+ (void)doTaskAsynchronously:(void(^)())block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}
///同期実行
+ (void)doTaskSynchronously:(void(^)())block {
    dispatch_sync(dispatch_get_main_queue(), ^{
        block();
    });
}
///一番上の階層のNaviViewを返す
+ (NaviViewController * )getNaviViewController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    if ([topController isKindOfClass:[NaviViewController class]]){
        return (NaviViewController * )topController;
    }
    return nil;
}

///2桁以上の数字には99+を返す
+ (NSString *)getMaxDoubleDigitsStr:(NSNumber *)num {
    NSString *ret = [num stringValue];
    if ([num intValue] >= 100) {
        ret = @"99+";
    }
    return ret;
}

///使用する投稿画像パスを返す
+ (NSString *)getImgPath:(Post *)post {
    NSString *path = post.originalPath;
    if (post.thumbnailPath) {
        path = post.thumbnailPath;
    }else if (post.transcodedPath){
        path = post.transcodedPath;
    }
    return path;
}

///Memoryにキャッシュされた画像を取得
+ (UIImage *)getCachedImg:(NSString *)url {
    
    NSString *cacheKey = [[SDWebImageManager sharedManager]
                          cacheKeyForURL:[NSURL URLWithString:url]];
    return [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
}

///Memoryにキャッシュする
+ (void)cacheImg:(UIImage *)img URL:(NSString *)URL {
    SDImageCache *imageCache = [[SDWebImageManager sharedManager] imageCache];
    [imageCache storeImage:img forKey:URL toDisk:NO];
}

/**
 *NSDictionaryのparametersからURL形式のparametersを作成
 * NSDictionaryのparamsの値にはNSString,NSNumber,NSArrayが格納可能
 **/
+ (NSString *)getURLFormattedParams:(NSDictionary *)params {
    __block NSMutableString *ret = [NSMutableString  stringWithString:@""];
    for (id key in [params keyEnumerator]) {
        __block NSString *val;
        if ([[params objectForKey:key] isKindOfClass:[NSArray class]]) {
            [(NSArray *)[params objectForKey:key]
             enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
                 if ([value isKindOfClass:[NSNumber class]]) {
                     val = [value stringValue];
                 }else{
                     val = value;
                 }
                 [ret appendString:[NSString stringWithFormat:@"&%@=%@",key, val]];
             }];
        }else if([[params objectForKey:key] isKindOfClass:[NSNumber class]]){
            val = [[params objectForKey:key] stringValue];
            [ret appendString:[NSString stringWithFormat:@"&%@=%@",key, val]];
        }else{
            val = [params objectForKey:key];
            [ret appendString:[NSString stringWithFormat:@"&%@=%@",key, val]];
        }
    }
    return ret;
}

/*UIGestureRecognizerで発火したイベントで取得できるrecognizerから
 *UITableViewのindexPathを取得する.
*/
+ (NSIndexPath *)indexPathForTableViewAtRecognizer:(UITableView *)tblView r:(UIGestureRecognizer *)r {
    CGPoint p =  [r locationInView:tblView];
    NSIndexPath *indexPath = [tblView indexPathForRowAtPoint:p];
    return indexPath;
}

/*UIEventから
 *UITableViewのindexPathを取得する.
 */
+ (NSIndexPath *)indexPathForTableViewAtEvent:(UITableView *)tblView e:(UIEvent *)e {
    UITouch *touch = [[e allTouches] anyObject];
    CGPoint p = [touch locationInView:tblView];
    NSIndexPath *indexPath = [tblView indexPathForRowAtPoint:p];
    return indexPath;
}

///エラーの形式をJsonへ整える
+ (NSMutableDictionary *)errorJson:(NSString *)response{
    NSData *resposeData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *failJson = [NSMutableDictionary dictionary];
    if(resposeData != nil){
        failJson = [NSJSONSerialization JSONObjectWithData:resposeData options:NSJSONReadingAllowFragments error:nil];
    }
    return failJson;
}

///ナビゲーションバーのタイトルを返す
+ (UILabel *)getNaviTitle:(NSString *)str {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = JPBFONT(17);
    title.textColor = [UIColor whiteColor];
    title.text = str;
    [title sizeToFit];
    return title;
}

///戻るボタンを返す
+ (UIBarButtonItem *)getBackNaviBtn {
    UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [b setAdjustsImageWhenHighlighted:NO];
    [b setBackgroundImage:[UIImage imageNamed:@"btn_back.png"]
                 forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:b];
}

@end
