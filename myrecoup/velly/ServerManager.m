//
//  ServerManger.m
//  SBRCalendar
//
//  Created by VCJPCM013 on 2015/01/22.
//  Copyright (c) 2015年 HidekiYokozeki. All rights reserved.
//

#import "ServerManager.h"
#import "ConfigLoader.h"
#import <Foundation/NSJSONSerialization.h>
#import "Configuration.h"

#define CONST_STRING_APPLIID @"102" //app名

@implementation ServerManager

static ServerManager *sharedData_ = nil;

//ログ取得する場合
//[[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
//[[AFNetworkActivityLogger sharedLogger] startLogging];

+(NSString*)baseURL{
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    return [NSString stringWithFormat:@"%@/api/1/",vConfig[@"BaseApiURI"]];
}


//今後CDNサーバが用意された時用
+(NSString*)ResourceURL{
    
    NSDictionary *vConfig   = [ConfigLoader mixIn];
    return [NSString stringWithFormat:@"%@/api/1/",vConfig[@"BaseApiURI"]];
    
}

+(NSString* )getCSRFFromCookie:(NSString*)APIURL{
    
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:APIURL]];
    NSLog(@"cookie csrf %@",    [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]);
    
    NSString* strCookieValue=@"";
    for(NSHTTPCookie* cookie in cookies) {
        if([cookie.name isEqualToString:@"csrftoken"])
            return cookie.value;
    }
    return strCookieValue;
}


//ログイン処理---------------------------------------------------------------------------------------
-(void)login:(JsonData)SuccessJson Fail:(JsonData)failJson Error:(JsonData)errorJson
{
    
    
}

//token取得メソッド
+(NSString*)getToken
{
    return @"";
}


- (void)getJson:(NSString*)API Parameters:(NSDictionary*)parameters Success:(JsonData)SuccessJson fail:(JsonData)failJson Error:(JsonData)errorJson{
    
    //独自エラー返す場合用
    __block JsonData actFailJson = failJson;
    
    __block JsonData actSuccessJson = SuccessJson;
    __block JsonData actErrorJson = errorJson;
    
    //リクエスト情報の生成
    NSMutableDictionary* resultParameters = [parameters mutableCopy];
    
    //json形式で返却を依頼
    [resultParameters setObject:@"json" forKey:@"format"];
  
    NSString * urlStrings = [NSString stringWithFormat:@"%@%@",[ServerManager baseURL],API];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    //今後ヘッダー周りでの実装時に使う
    [manager.requestSerializer setValue:[ServerManager getCSRFFromCookie:urlStrings] forHTTPHeaderField:@"csrftoken"];
//    [manager.requestSerializer setValue:CONST_STRING_APPLIID forHTTPHeaderField:@"X-APPLI-ID"];
    manager.requestSerializer.timeoutInterval = 10.0;
    
    [manager GET:urlStrings
      parameters:[resultParameters copy]
         success:^(NSURLSessionDataTask *task, id responseObject)
     {
         

//         NSError* error;
//         if ([NSJSONSerialization isValidJSONObject:responseObject]){
//             NSLog(@"Good JSON \n");
//         }
         
         NSDictionary* jsonDic = [NSDictionary dictionaryWithDictionary:responseObject];
         
         //NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
         
         if(actSuccessJson){
             
             actSuccessJson(jsonDic);
             actSuccessJson = nil;
             
         }
         
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
         
         NSData* data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
         NSString* errorstring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         NSLog(@"error=%@",errorstring);
         
         if(actErrorJson){
             NSHTTPURLResponse* response = (NSHTTPURLResponse*)task.response;
             NSNumber* statusCode = [NSNumber numberWithInteger:response.statusCode];
             actErrorJson([NSDictionary dictionaryWithObject:statusCode forKey:@"ErrorCode"]);
             actErrorJson = nil;
         }
         
     }];
    
}

- (void)FileUpload:(NSString*)bodyData Category:(NSString*)category VideoData:(NSData*)videoData ThumnailData:(NSData*)thumbailData{
    
    //トークン読み込み
    NSString* aToken = [Configuration loadAccessToken];
    NSString *sendAToken = [@"Token " stringByAppendingString:aToken];
    
    //送信先URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[ServerManager baseURL],@"posts/"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    //multipart/form-dataのバウンダリ文字列生成
    CFUUIDRef uuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, uuid);
    CFRelease(uuid);
    NSString *boundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    
    //アップロードする際のパラメーター名
    NSString *parameter = @"video_data";
    
    //アップロードするファイルの名前
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm:ss"];// フォーマット指定
    NSString* today = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@-%@.mov",today,aToken];
    
    //アップロードするファイルの種類
    NSString *contentType = @"video/mp4";
    NSMutableData *postBody = [NSMutableData data];
    
    //HTTPBody(動画部)
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",parameter,fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:videoData];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    fileName = [NSString stringWithFormat:@"%@-%@.png",today,aToken];
    //HTTPBody(サムネイル部)
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"thumbnail_data\"; filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:thumbailData];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //HTTPBody(Body部)
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"body\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"testだよ"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //HTTPBody(カテゴリ部)
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"category\""] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"1"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    //リクエストヘッダー
    NSString *header = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request addValue:header forHTTPHeaderField:@"Content-Type"];
    [request addValue:sendAToken forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:postBody];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        NSString* datastring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (error) {
            // エラー処理を行う。
            if (error.code == -1003) {
                NSLog(@"not found hostname. targetURL=%@", url);
            } else if (error.code == -1019) {
                NSLog(@"auth error. reason=%@", error);
            } else {
                NSLog(@"unknown error occurred. reason = %@", error);
            }
            
        } else {
            
            
        }
    
    }];
    
    //[NSURLConnection connectionWithRequest:request delegate:self];
}




+ (ServerManager *)sharedManager{
    
    @synchronized(self){
    
        if (!sharedData_) {
            sharedData_ = [ServerManager new];
        }
        
    }
    return sharedData_;
}

@end
