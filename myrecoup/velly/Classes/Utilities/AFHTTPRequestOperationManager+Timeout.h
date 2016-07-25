//
//  AFHTTPRequestOperationManager+Timeout.h
//  velly
//
//  Created by m_saruwatari on 2015/03/25.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"


@interface AFHTTPRequestOperationManager (TimeoutCategory)

/**
 *  Add timeout interval parameter to AFHTTPRequestOperationManager#GET
 *
 *  @param timeoutInterval
 *  Other parameters See AFHTTPRequestOperationManager#GET
 *
 *  @return See AFHTTPRequestOperationManager#GET
 */
- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                timeoutInterval:(NSTimeInterval)timeoutInterval
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  Add timeout interval parameter to AFHTTPRequestOperationManager#POST
 *
 *  @param timeoutInterval
 *  Other parameters See AFHTTPRequestOperationManager#POST
 *
 *  @return See AFHTTPRequestOperationManager#POST
 */
- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                 timeoutInterval:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  Add timeout interval parameter to AFHTTPRequestOperationManager#PUT
 *
 *  @param timeoutInterval
 *  Other parameters See AFHTTPRequestOperationManager#PUT
 *
 *  @return See AFHTTPRequestOperationManager#PUT
 */
- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                 timeoutInterval:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  Add timeout interval parameter to AFHTTPRequestOperationManager#PATCH
 *
 *  @param timeoutInterval
 *  Other parameters See AFHTTPRequestOperationManager#PATCH
 *
 *  @return See AFHTTPRequestOperationManager#PATCH
 */
- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                timeoutInterval:(NSTimeInterval)timeoutInterval
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                        parameters:(NSDictionary *)parameters
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/** include multipart data **/

- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
                        imageData:(NSData *)imageData
                        imageName:(NSString *)imageName
                          mimType:(NSString *)mimeType
                  timeoutInterval:(NSTimeInterval)timeoutInterval
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
                        imageData:(NSData *)imageData
                        imageName:(NSString *)imageName
                          mimType:(NSString *)mimeType
                  timeoutInterval:(NSTimeInterval)timeoutInterval
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

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
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
