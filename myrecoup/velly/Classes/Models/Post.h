//
//  Post.h
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "_Post.h"


@interface Post : NSObject  //_Post {}


/* id : コメントID */
@property (nonatomic) NSNumber *postID;
@property (nonatomic) NSNumber *userPID;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *iconPath;
@property (nonatomic) NSString *originalPath;
@property (nonatomic) NSNumber *originalWidth;
@property (nonatomic) NSNumber *originalHeight;

@property (nonatomic) NSString *transcodedPath;
@property (nonatomic) NSNumber *transcodedWidth;
@property (nonatomic) NSNumber *transcodedHeight;
@property (nonatomic) NSString *thumbnailPath;
@property (nonatomic) NSNumber *thumbnailWidth;
@property (nonatomic) NSNumber *thumbnailHeight;

@property (nonatomic) NSString *descrip;

@property (nonatomic) NSNumber *cntGood;
@property (nonatomic) NSNumber *cntComment;
@property (nonatomic) NSString *categoryID;
@property (nonatomic) NSString *categoryName;

@property (nonatomic) NSNumber *isGood;
@property (nonatomic) NSDate *created;

@property (nonatomic) NSDate *loadingDate;



+ (instancetype)initFromDictionary:(NSDictionary *)aDictionary;


/** `JSON` 辞書から `Post` を初期化する
 @param json.
 @return Post.
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)json;



/** Post 初期化
 @param postID id.
 @param userPID userPID,
 @param userID user_id.
 @param username username.
 @param iconPath icon_path.
 @param originalPath originalPath
 @param originalWidth originalWidth
 @param originalHeight originalHeight
 @param transcodedPath transcodedPath
 @param transcodedWidth transcodedWidth
 @param transcodedHeight transcodedHeight
 @param thumbnailPath thumbnailPath
 @param thumbnailWidth thumbnailWidth
 @param thumbnailHeight thumbnailHeight
 @param descrip descrip,
 @param cntGood cnt_good,
 @param cntComment cnt_comment,
 @param categoryID category_id,
 @param categoryName categoryName,
 @param isGood is_good,
 @param created created,
 @return Post.
 */
- (instancetype)initWithPostID:(NSNumber *)postID
                       userPID:(NSNumber *)userPID
                        userID:(NSString *)userID
                      username:(NSString *)username
                      iconPath:(NSString *)iconPath
                  originalPath:(NSString *)originalPath
                 originalWidth:(NSNumber *)originalWidth
                originalHeight:(NSNumber *)originalHeight
                transcodedPath:(NSString *)transcodedPath
               transcodedWidth:(NSNumber *)transcodedWidth
              transcodedHeight:(NSNumber *)transcodedHeight
                 thumbnailPath:(NSString *)thumbnailPath
                thumbnailWidth:(NSNumber *)thumbnailWidth
               thumbnailHeight:(NSNumber *)thumbnailHeight
                       descrip:(NSString *)descrip
                       cntGood:(NSNumber *)cntGood
                    cntComment:(NSNumber *)cntComment
                    categoryID:(NSNumber *)categoryID
                  categoryName:(NSString *)categoryName
                        isGood:(NSNumber *)isGood
                       created:(NSDate *)created;

-(instancetype)replacePost:(Post *)tPost;

/**
 * 動画カテゴリなら YESを返す
 * @return BOOL
 */
- (BOOL)isMovie;

@end
