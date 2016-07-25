//
//  Post.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "Post.h"

#import "NSDateFormatter+MySQL.h"

@interface Post ()

@end

@implementation Post

//@synthesize postID = _postID;
//@synthesize userPID = _userPID;
//@synthesize userID = _userID;
//@synthesize username = _username;
//@synthesize iconPath = _iconPath;
//@synthesize categoryID = _categoryID;
//@synthesize categoryName = _categoryName;
//@synthesize descrip = _descrip;
//
//@synthesize originalPath = _originalPath;
//@synthesize originalWidth = _originalWidth;
//@synthesize originalHeight = _originalHeight;
//@synthesize transcodedPath = _transcodedPath;
//@synthesize transcodedWidth = _transcodedWidth;
//@synthesize transcodedHeight = _transcodedHeight;
//@synthesize thumbnailPath = _thumbnailPath;
//@synthesize thumbnailWidth = _thumbnailWidth;
//@synthesize thumbnailHeight = _thumbnailHeight;
//
//@synthesize cntComment = _cntComment;
//@synthesize cntGood = _cntGood;
//@synthesize isGood = _isGood;
//
//@synthesize created = _created;


//-(void)awakeFromInsert {
//    [super awakeFromInsert];
//    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
//    NSString *uuidStr = (__bridge_transfer NSString *) CFUUIDCreateString(kCFAllocatorDefault, uuid);
//    CFRelease(uuid);
//    self.identifier = uuidStr;
//}

+ (instancetype)initFromDictionary:(NSDictionary *)aDictionary
{
    Post *instance = [[Post alloc] init];
    instance = [instance initWithJSONDictionary:aDictionary];
    return instance;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
{
    // postID
    NSNumber *postID, *postID_;
    if( [json[@"id"] isKindOfClass:[NSNumber class]] ){
        postID_ = json[@"id"];
    }else{
        postID_ = [NSNumber numberWithInteger:(NSInteger)json[@"id"]];
    }
    if ([postID_ isKindOfClass:[NSNumber class]]) {
        postID = postID_;
    }
    
//    DLog(@"JSON userPID : %@", json[@"author"][@"id"]);
//    DLog(@"JSON userID : %@", json[@"author"][@"username"]);
//    DLog(@"JSON nickname : %@", json[@"author"][@"nickname"]);

    // userPID
    NSNumber *userPID, *userPID_;
    if( ![json[@"author"] isKindOfClass:[NSNull class]] && [json[@"author"][@"id"] isKindOfClass:[NSNumber class]] ){
        userPID_ = json[@"author"][@"id"];
    }else{
        userPID_ = [NSNumber numberWithInt:0];
    }
    if ([userPID_ isKindOfClass:[NSNumber class]]) {
        userPID = userPID_;
    }

    // user_id
    NSString *userID, *userID_;
    if( ![json[@"author"] isKindOfClass:[NSNull class]] && [json[@"author"][@"username"] isKindOfClass:[NSString class]] ){
        userID_ = json[@"author"][@"username"];
    }
    if ([userID_ isKindOfClass:[NSString class]]) {
        userID = userID_;
    }
    
    // username
    NSString *username, *username_;
    if( ![json[@"author"] isKindOfClass:[NSNull class]] && [json[@"author"][@"nickname"] isKindOfClass:[NSString class]] ){
        username_ = json[@"author"][@"nickname"];
    }
    if ([username_ isKindOfClass:[NSString class]]) {
        username = username_;
    }
    
    DLog(@"DATA userPID : %@", userPID);
    DLog(@"DATA userID : %@", userID);
    DLog(@"DATA nickname : %@", username);

    
    // icon_path
    NSString *iconPath = nil, *iconPath_;
    if( ![json[@"author"] isKindOfClass:[NSNull class]] && [json[@"author"][@"icon"] isKindOfClass:[NSString class]] ){
        iconPath_ = json[@"author"][@"icon"];
    }
    if ([iconPath_ isKindOfClass:[NSString class]]) {
        iconPath = iconPath_;
    }

    // original_file
    NSString *originalPath, *originalPath_;
    if( ![json[@"medium"] isKindOfClass:[NSNull class]] && [json[@"medium"][@"original_file"] isKindOfClass:[NSString class]] ){
        originalPath_ = json[@"medium"][@"original_file"];
        
//        DLog(@"%@", json[@"medium"][@"original_file"]);
//        DLog(@"%@", json[@"medium"][@"original_width"]);
//        NSNumber *width = json[@"medium"][@"original_width"];
//        DLog(@"%@", width);
//        DLog(@"%@", json[@"medium"][@"original_height"]);
//        NSNumber *height = json[@"medium"][@"original_height"];
//        DLog(@"%@", height);
        
    }
    if ([originalPath_ isKindOfClass:[NSString class]]) {
        originalPath = originalPath_;
    }
    
    DLog(@"%@", originalPath);
    
    // original_width
    NSNumber *originalWidth, *originalWidth_;
    if( ![json[@"medium"] isKindOfClass:[NSNull class]] && [json[@"medium"][@"original_width"] isKindOfClass:[NSNumber class]] ){
        originalWidth_ = json[@"medium"][@"original_width"];
    }else{
        originalWidth_ = [NSNumber numberWithInt:0];
    }
    if ([originalWidth_ isKindOfClass:[NSNumber class]]) {
        originalWidth = originalWidth_;
    }
    DLog(@"%@", originalWidth);
    
    // original_height
    NSNumber *originalHeight, *originalHeight_;
    if( ![json[@"medium"] isKindOfClass:[NSNull class]] && [json[@"medium"][@"original_height"] isKindOfClass:[NSNumber class]] ){
        originalHeight_ = json[@"medium"][@"original_height"];
    }else{
        originalHeight_ = [NSNumber numberWithInt:0];
    }
    if ([originalHeight_ isKindOfClass:[NSNumber class]]) {
        originalHeight = originalHeight_;
    }

    // transcoded_file
    NSString *transcodedPath, *transcodedPath_;
    if( ![json[@"medium"] isKindOfClass:[NSNull class]] && [json[@"medium"] count] > 0 && [json[@"medium"][@"transcoded_file"] isKindOfClass:[NSString class]] ){
        transcodedPath_ = json[@"medium"][@"transcoded_file"];
    }
    if ([transcodedPath_ isKindOfClass:[NSString class]]) {
        transcodedPath = transcodedPath_;
    }
    
    // transcoded_width
    NSNumber *transcodedWidth, *transcodedWidth_;
    if( ![json[@"medium"] isKindOfClass:[NSNull class]] && [json[@"medium"][@"transcoded_width"] isKindOfClass:[NSNumber class]] ){
        transcodedWidth_ = json[@"medium"][@"transcoded_width"];
    }else{
        transcodedWidth_ = [NSNumber numberWithInt:0];
    }
    if ([transcodedWidth_ isKindOfClass:[NSNumber class]]) {
        transcodedWidth = transcodedWidth_;
    }
    
    // transcoded_height
    NSNumber *transcodedHeight, *transcodedHeight_;
    if( ![json[@"medium"] isKindOfClass:[NSNull class]] && [json[@"medium"][@"transcoded_height"] isKindOfClass:[NSNumber class]] ){
        transcodedHeight_ = json[@"medium"][@"transcoded_height"];
    }else{
        transcodedHeight_ = [NSNumber numberWithInt:0];
    }
    if ([transcodedHeight_ isKindOfClass:[NSNumber class]]) {
        transcodedHeight = transcodedHeight_;
    }
    
    // thumbnail
    NSString *thumbnailPath, *thumbnailPath_;
    if( ![json[@"medium"] isKindOfClass:[NSNull class]] && [json[@"medium"] count] > 0 && [json[@"medium"][@"thumbnail"] isKindOfClass:[NSString class]] ){
        thumbnailPath_ = json[@"medium"][@"thumbnail"];
    }
    if ([thumbnailPath_ isKindOfClass:[NSString class]]) {
        thumbnailPath = thumbnailPath_;
    }
    
    // thumbnail_width
    NSNumber *thumbnailWidth, *thumbnailWidth_;
    if( ![json[@"medium"] isKindOfClass:[NSNull class]] && [json[@"medium"][@"thumbnail_width"] isKindOfClass:[NSNumber class]] ){
        thumbnailWidth_ = json[@"medium"][@"thumbnail_width"];
    }else{
        thumbnailWidth_ = [NSNumber numberWithInt:0];
    }
    if ([thumbnailWidth_ isKindOfClass:[NSNumber class]]) {
        thumbnailWidth = thumbnailWidth_;
    }
    
    // thumbnail_height
    NSNumber *thumbnailHeight, *thumbnailHeight_;
    if( ![json[@"medium"] isKindOfClass:[NSNull class]] && [json[@"medium"][@"thumbnail_height"] isKindOfClass:[NSNumber class]] ){
        thumbnailHeight_ = json[@"medium"][@"thumbnail_height"];
    }else{
        thumbnailHeight_ = [NSNumber numberWithInt:0];
    }
    if ([thumbnailHeight_ isKindOfClass:[NSNumber class]]) {
        thumbnailHeight = thumbnailHeight_;
    }
    
    // descrip
    NSString *descrip, *descrip_;
    if( [json[@"body"] isKindOfClass:[NSString class]] ){
        descrip_ = json[@"body"];
    }
    if ([descrip_ isKindOfClass:[NSString class]]) {
        descrip = descrip_;
    }

    // cntGood
    NSNumber *cntGood, *cntGood_;
    if( [json[@"cnt_likes"] isKindOfClass:[NSNumber class]] ){
        cntGood_ = json[@"cnt_likes"];
    }else{
        cntGood_ = [NSNumber numberWithInteger:(NSInteger)json[@"cnt_likes"]];
    }
    if ([cntGood_ isKindOfClass:[NSNumber class]]) {
        cntGood = cntGood_;
    }
    
    // cntComment
    NSNumber *cntComment, *cntComment_;
    if( [json[@"cnt_comments"] isKindOfClass:[NSNumber class]] ){
        cntComment_ = json[@"cnt_comments"];
    }else{
        cntComment_ = [NSNumber numberWithInt:0];
    }
    if ([cntComment_ isKindOfClass:[NSNumber class]]) {
        cntComment = cntComment_;
    }
    
    // categoryID
    NSNumber *categoryID, *categoryID_;
    if(![json[@"category"] isKindOfClass:[NSNull class]] && ![json[@"category"] isKindOfClass:[NSNumber class]] && [json[@"category"][@"id"] isKindOfClass:[NSNumber class]] ){
        categoryID_ = json[@"category"][@"id"];
    }else{
        categoryID_ = [NSNumber numberWithInt:0];
    }
    if ([categoryID_ isKindOfClass:[NSNumber class]]) {
        categoryID = categoryID_;
    }

    // categoryName
    NSString *categoryName, *categoryName_;
    if( ![json[@"category"] isKindOfClass:[NSNull class]] && ![json[@"category"] isKindOfClass:[NSNumber class]] && ![json[@"category"][@"label"] isKindOfClass:[NSNull class]] ){
        categoryName_ = json[@"category"][@"label"];
    }
    if ([categoryName_ isKindOfClass:[NSString class]]) {
        categoryName = categoryName_;
    }

    // isGood
    NSNumber *isGood, *isGood_;
    if(![json[@"is_liked"] isKindOfClass:[NSNull class]]){
        if( [(NSNumber *)json[@"is_liked"] boolValue] == false ){
            isGood_ = [NSNumber numberWithInt:VLISBOOLFALSE];
        }else{
            isGood_ = [NSNumber numberWithInt:VLISBOOLTRUE];
        }
        isGood = isGood_;
    }else{
        // nil
        isGood_ = [NSNumber numberWithInt:VLISBOOLFALSE];
        isGood = isGood_;
    }
    
    DLog(@"%@",json[@"is_liked"]);
    
    NSDateFormatter *dateFormatter = [NSDateFormatter MySQLDateFormatter];

    // created
    NSDate *created;
    NSString *createdString = json[@"create_at"];
    if ([createdString isKindOfClass:[NSString class]]) {
        created = [dateFormatter dateFromString:createdString];
    }
    
    DLog(@"DATA userPID : %@", userPID);
    DLog(@"DATA userID : %@", userID);
    DLog(@"DATA nickname : %@", username);
    
    return [self initWithPostID:postID userPID:userPID userID:userID username:username iconPath:iconPath originalPath:originalPath originalWidth:originalWidth originalHeight:originalHeight transcodedPath:transcodedPath transcodedWidth:transcodedWidth transcodedHeight:transcodedHeight thumbnailPath:thumbnailPath thumbnailWidth:thumbnailWidth thumbnailHeight:thumbnailHeight descrip:descrip cntGood:cntGood cntComment:cntComment categoryID:categoryID categoryName:categoryName isGood:isGood created:created];
}

- (instancetype)initWithPostID:(NSNumber *)postID userPID:(NSNumber *)userPID userID:(NSString *)userID username:(NSString *)username iconPath:(NSString *)iconPath originalPath:(NSString *)originalPath originalWidth:(NSNumber *)originalWidth originalHeight:(NSNumber *)originalHeight transcodedPath:(NSString *)transcodedPath transcodedWidth:(NSNumber *)transcodedWidth transcodedHeight:(NSNumber *)transcodedHeight thumbnailPath:(NSString *)thumbnailPath thumbnailWidth:(NSNumber *)thumbnailWidth thumbnailHeight:(NSNumber *)thumbnailHeight descrip:(NSString *)descrip cntGood:(NSNumber *)cntGood cntComment:(NSNumber *)cntComment categoryID:(NSNumber *)categoryID categoryName:(NSString *)categoryName isGood:(NSNumber *)isGood created:(NSDate *)created
{
    self = [super init];
    if (self) {
        
        DLog(@"DATA userPID : %@", userPID);
        DLog(@"DATA userID : %@", userID);
        DLog(@"DATA nickname : %@", username);
        
        if(postID)                                        self.postID = postID;
        if(userPID)                                       self.userPID = userPID;
        if(userID)                                        self.userID = userID;
        if(username)                                      self.username = username;
        if(iconPath && [iconPath length] > 0) {
            self.iconPath = iconPath;
        }else{
            self.iconPath = nil;
        }
        if(originalPath && [originalPath length] > 0)     self.originalPath  = originalPath;
        if(originalWidth)                                 self.originalWidth = originalWidth;
        if(originalHeight)                                self.originalHeight = originalHeight;
        if(transcodedPath && [transcodedPath length] > 0) self.transcodedPath = transcodedPath;
        if(transcodedWidth)                               self.transcodedWidth = transcodedWidth;
        if(transcodedHeight)                              self.transcodedHeight = transcodedHeight;
        if(thumbnailPath && [thumbnailPath length] > 0)   self.thumbnailPath = thumbnailPath;
        if(thumbnailWidth)                                self.thumbnailWidth = thumbnailWidth;
        if(thumbnailHeight)                               self.thumbnailHeight = thumbnailHeight;
        if(descrip)      self.descrip = descrip;
        if(cntGood)      self.cntGood = cntGood;
        if(cntComment)   self.cntComment = cntComment;
        if(categoryID)   self.categoryID = [categoryID stringValue];
        if(categoryName) self.categoryName = categoryName;
        if( isGood && isGood == [NSNumber numberWithInt:VLISBOOLTRUE] ){
            self.isGood = [NSNumber numberWithInt:VLISBOOLTRUE];
        }else{
            self.isGood = [NSNumber numberWithInt:VLISBOOLFALSE];
        }
        if(created) self.created = created;
        
        self.loadingDate = [NSDate date];
    }
    return self;
}

-(instancetype)replacePost:(Post *)tPost
{
    if (self && ![tPost isKindOfClass:[NSNull class]]) {
        if(![tPost.postID isKindOfClass:[NSNull class]])   self.postID = tPost.postID;
        if(![tPost.userPID isKindOfClass:[NSNull class]])  self.userPID = tPost.userPID;
        if(![tPost.userID isKindOfClass:[NSNull class]])   self.userID = tPost.userID;
        if(![tPost.username isKindOfClass:[NSNull class]]) self.username = tPost.username;
        if(![tPost.iconPath isKindOfClass:[NSNull class]] && [tPost.iconPath length] > 0) self.iconPath = tPost.iconPath;
        if(![tPost.originalPath isKindOfClass:[NSNull class]] && [tPost.originalPath length] > 0)     self.originalPath  = tPost.originalPath;
        if(![tPost.originalWidth isKindOfClass:[NSNull class]])  self.originalWidth = tPost.originalWidth;
        if(![tPost.originalHeight isKindOfClass:[NSNull class]])  self.originalHeight = tPost.originalHeight;
        if(![tPost.transcodedPath isKindOfClass:[NSNull class]] && [tPost.transcodedPath length] > 0) self.transcodedPath = tPost.transcodedPath;
        if(![tPost.transcodedWidth isKindOfClass:[NSNull class]])  self.transcodedWidth = tPost.transcodedWidth;
        if(![tPost.transcodedHeight isKindOfClass:[NSNull class]])  self.transcodedHeight = tPost.transcodedHeight;
        if(![tPost.thumbnailPath isKindOfClass:[NSNull class]] && [tPost.thumbnailPath length] > 0)   self.thumbnailPath = tPost.thumbnailPath;
        if(![tPost.thumbnailWidth isKindOfClass:[NSNull class]])  self.thumbnailWidth = tPost.thumbnailWidth;
        if(![tPost.thumbnailHeight isKindOfClass:[NSNull class]])  self.thumbnailHeight = tPost.thumbnailHeight;
        if(![tPost.descrip isKindOfClass:[NSNull class]])      self.descrip = tPost.descrip;
        if(![tPost.cntGood isKindOfClass:[NSNull class]])      self.cntGood = tPost.cntGood;
        if(![tPost.cntComment isKindOfClass:[NSNull class]])   self.cntComment = tPost.cntComment;
        if(![tPost.categoryID isKindOfClass:[NSNull class]])   self.categoryID = tPost.categoryID;
        if(![tPost.categoryName isKindOfClass:[NSNull class]]) self.categoryName = tPost.categoryName;
        if( ![tPost.isGood isKindOfClass:[NSNull class]] && tPost.isGood == [NSNumber numberWithInt:VLISBOOLTRUE] ){
            self.isGood = [NSNumber numberWithInt:VLISBOOLTRUE];
        }else{
            self.isGood = [NSNumber numberWithInt:VLISBOOLFALSE];
        }
        if(![tPost.created isKindOfClass:[NSNull class]]) self.created = tPost.created;
    }
    return self;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.poset=%@", self.postID];
    [description appendFormat:@"self.userPID=%@", self.userPID];
    [description appendFormat:@", self.user_id=%@", self.userID];
    [description appendFormat:@", self.username=%@", self.username];
    [description appendFormat:@", self.icon=%@", self.iconPath];
    [description appendFormat:@", self.originalPath=%@", self.originalPath];
    [description appendFormat:@", self.originalWidth=%@", self.originalWidth];
    [description appendFormat:@", self.originalHeight=%@", self.originalHeight];
    [description appendFormat:@", self.transcodedPath=%@", self.transcodedPath];
    [description appendFormat:@", self.transcodedWidth=%@", self.transcodedWidth];
    [description appendFormat:@", self.transcodedHeight=%@", self.transcodedHeight];
    [description appendFormat:@", self.thumbnailPath=%@", self.thumbnailPath];
    [description appendFormat:@", self.thumbnailWidth=%@", self.thumbnailWidth];
    [description appendFormat:@", self.thumbnailHeight=%@", self.thumbnailHeight];
    [description appendFormat:@", self.descrip=%@", self.descrip];
    [description appendFormat:@", self.cntGood=%@", self.cntGood];
    [description appendFormat:@", self.cntComment=%@", self.cntComment];
    [description appendFormat:@", self.categoryID=%@", self.categoryID];
    [description appendFormat:@", self.categoryName=%@", self.categoryName];
    //[description appendFormat:@", self.isGood=%@", self.isGood];
    [description appendFormat:@", self.created=%@", self.created];
    [description appendString:@">"];
    return description;
}

/**
 * 動画カテゴリなら YESを返す
 * @return BOOL
 */
- (BOOL)isMovie {
    return ([self.originalPath hasSuffix:@".mov"] || [self.originalPath hasSuffix:@".mp4"]);
}

@end
