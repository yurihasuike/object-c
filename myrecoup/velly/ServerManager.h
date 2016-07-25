//
//  ServerManger.h
//  SBRCalendar
//
//  Created by VCJPCM013 on 2015/01/22.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

typedef void (^JsonData)(NSDictionary *JsonList);
typedef void (^TokenStr)(NSString *tokenstring);
typedef void (^BinaryData)(NSData* binarydata);
typedef void (^MD5Str)(NSString* MD5ResourceStr);
typedef void (^FinishFlag)(BOOL flag);


@interface ServerManager : NSObject

//排他制御が必要なメソッド群
-(void)login:(JsonData)SuccessJson/*(TokenStr)SuccessString*/ Fail:(JsonData)failJson Error:(JsonData)errorJson;
//- (void)getJson:(NSString*)API Parameters:(NSDictionary*)parameters callback:(JsonData)callback;
- (void)getJson:(NSString*)API Parameters:(NSDictionary*)parameters Success:(JsonData)SuccessJson fail:(JsonData)failJson Error:(JsonData)errorJson;
- (void)FileUpload:(NSString*)bodyData Category:(NSString*)category VideoData:(NSData*)videoData ThumnailData:(NSData*)thumbailData;

+(NSString*)baseURL;
+(NSString*)ResourceURL;
+ (ServerManager *)sharedManager;

@end
