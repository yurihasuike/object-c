// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Info.h instead.

#import <CoreData/CoreData.h>
#import "Server.h"

extern const struct InfoAttributes {
	__unsafe_unretained NSString *categoryID;
	__unsafe_unretained NSString *categoryName;
	__unsafe_unretained NSString *created;
	__unsafe_unretained NSString *iconPath;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *imgPath;
	__unsafe_unretained NSString *infoID;
	__unsafe_unretained NSString *infoType;
	__unsafe_unretained NSString *isFollow;
	__unsafe_unretained NSString *postID;
	__unsafe_unretained NSString *rankNew;
	__unsafe_unretained NSString *rankOld;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *userPID;
	__unsafe_unretained NSString *username;
} InfoAttributes;

extern const struct InfoRelationships {
} InfoRelationships;

extern const struct InfoFetchedProperties {
} InfoFetchedProperties;



















@interface InfoID : NSManagedObjectID {}
@end

@interface _Info : Server {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (InfoID*)objectID;





@property (nonatomic, strong) NSNumber* categoryID;



@property int64_t categoryIDValue;
- (int64_t)categoryIDValue;
- (void)setCategoryIDValue:(int64_t)value_;

//- (BOOL)validateCategoryID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* categoryName;



//- (BOOL)validateCategoryName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* created;



//- (BOOL)validateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iconPath;



//- (BOOL)validateIconPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* imgPath;



//- (BOOL)validateImgPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* infoID;



@property int64_t infoIDValue;
- (int64_t)infoIDValue;
- (void)setInfoIDValue:(int64_t)value_;

//- (BOOL)validateInfoID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* infoType;



@property int64_t infoTypeValue;
- (int64_t)infoTypeValue;
- (void)setInfoTypeValue:(int64_t)value_;

//- (BOOL)validateInfoType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isFollow;



@property BOOL isFollowValue;
- (BOOL)isFollowValue;
- (void)setIsFollowValue:(BOOL)value_;

//- (BOOL)validateIsFollow:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* postID;



@property int64_t postIDValue;
- (int64_t)postIDValue;
- (void)setPostIDValue:(int64_t)value_;

//- (BOOL)validatePostID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rankNew;



@property int64_t rankNewValue;
- (int64_t)rankNewValue;
- (void)setRankNewValue:(int64_t)value_;

//- (BOOL)validateRankNew:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rankOld;



@property int64_t rankOldValue;
- (int64_t)rankOldValue;
- (void)setRankOldValue:(int64_t)value_;

//- (BOOL)validateRankOld:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





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

@interface _Info (CoreDataGeneratedAccessors)

@end

@interface _Info (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCategoryID;
- (void)setPrimitiveCategoryID:(NSNumber*)value;

- (int64_t)primitiveCategoryIDValue;
- (void)setPrimitiveCategoryIDValue:(int64_t)value_;




- (NSString*)primitiveCategoryName;
- (void)setPrimitiveCategoryName:(NSString*)value;




- (NSDate*)primitiveCreated;
- (void)setPrimitiveCreated:(NSDate*)value;




- (NSString*)primitiveIconPath;
- (void)setPrimitiveIconPath:(NSString*)value;




- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSString*)primitiveImgPath;
- (void)setPrimitiveImgPath:(NSString*)value;




- (NSNumber*)primitiveInfoID;
- (void)setPrimitiveInfoID:(NSNumber*)value;

- (int64_t)primitiveInfoIDValue;
- (void)setPrimitiveInfoIDValue:(int64_t)value_;




- (NSNumber*)primitiveInfoType;
- (void)setPrimitiveInfoType:(NSNumber*)value;

- (int64_t)primitiveInfoTypeValue;
- (void)setPrimitiveInfoTypeValue:(int64_t)value_;




- (NSNumber*)primitiveIsFollow;
- (void)setPrimitiveIsFollow:(NSNumber*)value;

- (BOOL)primitiveIsFollowValue;
- (void)setPrimitiveIsFollowValue:(BOOL)value_;




- (NSNumber*)primitivePostID;
- (void)setPrimitivePostID:(NSNumber*)value;

- (int64_t)primitivePostIDValue;
- (void)setPrimitivePostIDValue:(int64_t)value_;




- (NSNumber*)primitiveRankNew;
- (void)setPrimitiveRankNew:(NSNumber*)value;

- (int64_t)primitiveRankNewValue;
- (void)setPrimitiveRankNewValue:(int64_t)value_;




- (NSNumber*)primitiveRankOld;
- (void)setPrimitiveRankOld:(NSNumber*)value;

- (int64_t)primitiveRankOldValue;
- (void)setPrimitiveRankOldValue:(int64_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveUserID;
- (void)setPrimitiveUserID:(NSString*)value;




- (NSNumber*)primitiveUserPID;
- (void)setPrimitiveUserPID:(NSNumber*)value;

- (int64_t)primitiveUserPIDValue;
- (void)setPrimitiveUserPIDValue:(int64_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;




@end
