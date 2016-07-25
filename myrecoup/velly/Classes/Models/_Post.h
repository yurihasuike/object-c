// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.h instead.

#import <CoreData/CoreData.h>
#import "Server.h"

extern const struct PostAttributes {
	__unsafe_unretained NSString *categoryID;
	__unsafe_unretained NSString *categoryName;
	__unsafe_unretained NSString *cntComment;
	__unsafe_unretained NSString *cntGood;
	__unsafe_unretained NSString *created;
	__unsafe_unretained NSString *descrip;
	__unsafe_unretained NSString *iconPath;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *isGood;
	__unsafe_unretained NSString *originalHeight;
	__unsafe_unretained NSString *originalPath;
	__unsafe_unretained NSString *originalWidth;
	__unsafe_unretained NSString *postID;
	__unsafe_unretained NSString *thumbnailHeight;
	__unsafe_unretained NSString *thumbnailPath;
	__unsafe_unretained NSString *thumbnailWidth;
	__unsafe_unretained NSString *transcodedHeight;
	__unsafe_unretained NSString *transcodedPath;
	__unsafe_unretained NSString *transcodedWidth;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *userPID;
	__unsafe_unretained NSString *username;
} PostAttributes;

extern const struct PostRelationships {
} PostRelationships;

extern const struct PostFetchedProperties {
} PostFetchedProperties;

























@interface PostID : NSManagedObjectID {}
@end

@interface _Post : Server {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PostID*)objectID;





@property (nonatomic, strong) NSNumber* categoryID;



@property int64_t categoryIDValue;
- (int64_t)categoryIDValue;
- (void)setCategoryIDValue:(int64_t)value_;

//- (BOOL)validateCategoryID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* categoryName;



//- (BOOL)validateCategoryName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* cntComment;



@property int64_t cntCommentValue;
- (int64_t)cntCommentValue;
- (void)setCntCommentValue:(int64_t)value_;

//- (BOOL)validateCntComment:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* cntGood;



@property int64_t cntGoodValue;
- (int64_t)cntGoodValue;
- (void)setCntGoodValue:(int64_t)value_;

//- (BOOL)validateCntGood:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* created;



//- (BOOL)validateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* descrip;



//- (BOOL)validateDescrip:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iconPath;



//- (BOOL)validateIconPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isGood;



@property BOOL isGoodValue;
- (BOOL)isGoodValue;
- (void)setIsGoodValue:(BOOL)value_;

//- (BOOL)validateIsGood:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* originalHeight;



@property int64_t originalHeightValue;
- (int64_t)originalHeightValue;
- (void)setOriginalHeightValue:(int64_t)value_;

//- (BOOL)validateOriginalHeight:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* originalPath;



//- (BOOL)validateOriginalPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* originalWidth;



@property int64_t originalWidthValue;
- (int64_t)originalWidthValue;
- (void)setOriginalWidthValue:(int64_t)value_;

//- (BOOL)validateOriginalWidth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* postID;



@property int64_t postIDValue;
- (int64_t)postIDValue;
- (void)setPostIDValue:(int64_t)value_;

//- (BOOL)validatePostID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* thumbnailHeight;



@property int64_t thumbnailHeightValue;
- (int64_t)thumbnailHeightValue;
- (void)setThumbnailHeightValue:(int64_t)value_;

//- (BOOL)validateThumbnailHeight:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailPath;



//- (BOOL)validateThumbnailPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* thumbnailWidth;



@property int64_t thumbnailWidthValue;
- (int64_t)thumbnailWidthValue;
- (void)setThumbnailWidthValue:(int64_t)value_;

//- (BOOL)validateThumbnailWidth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* transcodedHeight;



@property int64_t transcodedHeightValue;
- (int64_t)transcodedHeightValue;
- (void)setTranscodedHeightValue:(int64_t)value_;

//- (BOOL)validateTranscodedHeight:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* transcodedPath;



//- (BOOL)validateTranscodedPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* transcodedWidth;



@property int64_t transcodedWidthValue;
- (int64_t)transcodedWidthValue;
- (void)setTranscodedWidthValue:(int64_t)value_;

//- (BOOL)validateTranscodedWidth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userID;



//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userPID;



@property int64_t userPIDValue;
- (int64_t)userPIDValue;
- (void)setUserPIDValue:(int64_t)value_;

//- (BOOL)validateUserPID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;






@end

@interface _Post (CoreDataGeneratedAccessors)

@end

@interface _Post (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCategoryID;
- (void)setPrimitiveCategoryID:(NSNumber*)value;

- (int64_t)primitiveCategoryIDValue;
- (void)setPrimitiveCategoryIDValue:(int64_t)value_;




- (NSString*)primitiveCategoryName;
- (void)setPrimitiveCategoryName:(NSString*)value;




- (NSNumber*)primitiveCntComment;
- (void)setPrimitiveCntComment:(NSNumber*)value;

- (int64_t)primitiveCntCommentValue;
- (void)setPrimitiveCntCommentValue:(int64_t)value_;




- (NSNumber*)primitiveCntGood;
- (void)setPrimitiveCntGood:(NSNumber*)value;

- (int64_t)primitiveCntGoodValue;
- (void)setPrimitiveCntGoodValue:(int64_t)value_;




- (NSDate*)primitiveCreated;
- (void)setPrimitiveCreated:(NSDate*)value;




- (NSString*)primitiveDescrip;
- (void)setPrimitiveDescrip:(NSString*)value;




- (NSString*)primitiveIconPath;
- (void)setPrimitiveIconPath:(NSString*)value;




- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSNumber*)primitiveIsGood;
- (void)setPrimitiveIsGood:(NSNumber*)value;

- (BOOL)primitiveIsGoodValue;
- (void)setPrimitiveIsGoodValue:(BOOL)value_;




- (NSNumber*)primitiveOriginalHeight;
- (void)setPrimitiveOriginalHeight:(NSNumber*)value;

- (int64_t)primitiveOriginalHeightValue;
- (void)setPrimitiveOriginalHeightValue:(int64_t)value_;




- (NSString*)primitiveOriginalPath;
- (void)setPrimitiveOriginalPath:(NSString*)value;




- (NSNumber*)primitiveOriginalWidth;
- (void)setPrimitiveOriginalWidth:(NSNumber*)value;

- (int64_t)primitiveOriginalWidthValue;
- (void)setPrimitiveOriginalWidthValue:(int64_t)value_;




- (NSNumber*)primitivePostID;
- (void)setPrimitivePostID:(NSNumber*)value;

- (int64_t)primitivePostIDValue;
- (void)setPrimitivePostIDValue:(int64_t)value_;




- (NSNumber*)primitiveThumbnailHeight;
- (void)setPrimitiveThumbnailHeight:(NSNumber*)value;

- (int64_t)primitiveThumbnailHeightValue;
- (void)setPrimitiveThumbnailHeightValue:(int64_t)value_;




- (NSString*)primitiveThumbnailPath;
- (void)setPrimitiveThumbnailPath:(NSString*)value;




- (NSNumber*)primitiveThumbnailWidth;
- (void)setPrimitiveThumbnailWidth:(NSNumber*)value;

- (int64_t)primitiveThumbnailWidthValue;
- (void)setPrimitiveThumbnailWidthValue:(int64_t)value_;




- (NSNumber*)primitiveTranscodedHeight;
- (void)setPrimitiveTranscodedHeight:(NSNumber*)value;

- (int64_t)primitiveTranscodedHeightValue;
- (void)setPrimitiveTranscodedHeightValue:(int64_t)value_;




- (NSString*)primitiveTranscodedPath;
- (void)setPrimitiveTranscodedPath:(NSString*)value;




- (NSNumber*)primitiveTranscodedWidth;
- (void)setPrimitiveTranscodedWidth:(NSNumber*)value;

- (int64_t)primitiveTranscodedWidthValue;
- (void)setPrimitiveTranscodedWidthValue:(int64_t)value_;




- (NSString*)primitiveUserID;
- (void)setPrimitiveUserID:(NSString*)value;




- (NSNumber*)primitiveUserPID;
- (void)setPrimitiveUserPID:(NSNumber*)value;

- (int64_t)primitiveUserPIDValue;
- (void)setPrimitiveUserPIDValue:(int64_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;




@end
