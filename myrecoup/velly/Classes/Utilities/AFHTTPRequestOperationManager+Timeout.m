//
//  AFHTTPRequestOperationManager+Timeout.m
//  velly
//
//  Created by m_saruwatari on 2015/03/25.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "AFHTTPRequestOperationManager+Timeout.h"

@implementation AFHTTPRequestOperationManager (TimeoutCategory)

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                timeoutInterval:(NSTimeInterval)timeoutInterval
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                 timeoutInterval:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    DLog(@"%@", parameters);
    DLog(@"%@", URLString);
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                 timeoutInterval:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                timeoutInterval:(NSTimeInterval)timeoutInterval
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    DLog(@"%@", parameters);
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PATCH" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}


- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                 timeoutInterval:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    DLog(@"%@", parameters);
    DLog(@"%@", URLString);
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

/** send data(movie) **/

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                       imageData:(NSData *)imageData
                       imageName:(NSString *)imageName
                         mimType:(NSString *)mimeType
                       movieData:(NSData *)movieData
                       movieName:(NSString *)movieName
                         mimTypeMovie:(NSString *)mimeTypeMovie
                 timeoutInterval:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSString *sendMimeType_movie = @"video/quicktime";
    NSString *sendMimeType_img = @"img/png";
    
    NSString *video_data = @"video_data";
    NSString *thumnail_data = @"thumbnail_data";
    
    NSString *video_data_file = @"video_data2.mov";
    NSString *thumnail_data_file = @"thumbnail_data2.png";
    
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:thumnail_data fileName:thumnail_data_file mimeType:sendMimeType_img];
        [formData appendPartWithFileData:movieData name:video_data fileName:video_data_file mimeType:sendMimeType_movie];
        
        
    } error:NULL];
    [request setTimeoutInterval:timeoutInterval];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];
    return operation;
    
}


/** send data **/

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
                        imageData:(NSData *)imageData
                        imageName:(NSString *)imageName
                          mimType:(NSString *)mimeType
                  timeoutInterval:(NSTimeInterval)timeoutInterval
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSString *sendImage = nil;
    NSString *sendMimeType = nil;
    if(mimeType){
        if(imageName){
            sendImage = imageName;
        }
        NSRange range = [mimeType rangeOfString:@"jpeg"];
        if (range.location != NSNotFound) {
            sendMimeType = @"image/jpeg";
            imageName = [NSString stringWithFormat:@"%@%@",imageName,@".jpg"];
        }
        range = [mimeType rangeOfString:@"gif"];
        if (range.location != NSNotFound) {
            sendMimeType = @"image/gif";
            imageName = [NSString stringWithFormat:@"%@%@",imageName,@".gif"];
        }
        range = [mimeType rangeOfString:@"png"];
        if (range.location != NSNotFound) {
            sendMimeType = @"image/png";
            imageName = [NSString stringWithFormat:@"%@%@",imageName,@".png"];
        }
    }
    
    DLog(@"%@", parameters);
    DLog(@"%@", sendImage);
    DLog(@"%@", imageName);
    DLog(@"%@", sendMimeType);
    
    if(sendMimeType && [sendMimeType length] > 0){
        NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {  [formData appendPartWithFileData:imageData name:sendImage fileName:imageName mimeType:sendMimeType];  } error:NULL];
        [request setTimeoutInterval:timeoutInterval];
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
        [self.operationQueue addOperation:operation];
        return operation;
    }else{
        NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters];
        [request setTimeoutInterval:timeoutInterval];
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
        [self.operationQueue addOperation:operation];
        return operation;
    }
}

- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
                        imageData:(NSData *)imageData
                        imageName:(NSString *)imageName
                          mimType:(NSString *)mimeType
                  timeoutInterval:(NSTimeInterval)timeoutInterval
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSString *sendImage = nil;
    NSString *sendMimeType = nil;
    if(mimeType){
        if(imageName){
            sendImage = imageName;
        }
        NSDate *now = [NSDate date];
        int unixtime = floor([now timeIntervalSince1970]);
        NSString *nowStr = [NSString stringWithFormat:@"%d_", unixtime];
        imageName = [nowStr stringByAppendingString:imageName];
        
        DLog(@"imageName : %@", imageName);
        
        NSRange range = [mimeType rangeOfString:@"jpeg"];
        if (range.location != NSNotFound) {
            sendMimeType = @"image/jpeg";
            if(!imageName) imageName = [imageName stringByAppendingString:@".jpg"];
        }
        range = [mimeType rangeOfString:@"gif"];
        if (range.location != NSNotFound) {
            sendMimeType = @"image/gif";
            if(!imageName) imageName = [imageName stringByAppendingString:@".gif"];
        }
        range = [mimeType rangeOfString:@"png"];
        if (range.location != NSNotFound) {
            sendMimeType = @"image/png";
            if(!imageName) imageName = [imageName stringByAppendingString:@".png"];
        }
    }
    
    DLog(@"patch user : params : %@", parameters);
    DLog(@"patch user : sendImage : %@", sendImage);
    DLog(@"patch user : imageName : %@", imageName);
    DLog(@"patch user : sendMimeType : %@", sendMimeType);
    
    if(sendMimeType && [sendMimeType length] > 0){
        NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"PATCH" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {  [formData appendPartWithFileData:imageData name:sendImage fileName:imageName mimeType:sendMimeType];  } error:NULL];
        [request setTimeoutInterval:timeoutInterval];
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
        [self.operationQueue addOperation:operation];
        return operation;
    }else{
        NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PATCH" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters];
        [request setTimeoutInterval:timeoutInterval];
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
        [self.operationQueue addOperation:operation];
        return operation;
    }
}


@end
