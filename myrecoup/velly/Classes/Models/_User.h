// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "Server.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *accessToken;
	__unsafe_unretained NSString *area;
	__unsafe_unretained NSString *birth;
	__unsafe_unretained NSString *cntFollow;
	__unsafe_unretained NSString *cntFollower;
	__unsafe_unretained NSString *cntPost;
	__unsafe_unretained NSString *created;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *fbToken;
	__unsafe_unretained NSString *iconPath;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *introduction;
	__unsafe_unretained NSString *isFollow;
	__unsafe_unretained NSString *isPushComment;
	__unsafe_unretained NSString *isPushFollow;
	__unsafe_unretained NSString *isPushGood;
	__unsafe_unretained NSString *sex;
	__unsafe_unretained NSString *twToken;
	__unsafe_unretained NSString *twTokenSecrect;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *userPID;
	__unsafe_unretained NSString *username;
} UserAttributes;

extern const struct UserRelationships {
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;

























@interface UserID : NSManagedObjectID {}
@end

@interface _User : Server {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;





@property (nonatomic, strong) NSString* accessToken;



//- (BOOL)validateAccessToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* area;



@property int64_t areaValue;
- (int64_t)areaValue;
- (void)setAreaValue:(int64_t)value_;

//- (BOOL)validateArea:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* birth;



//- (BOOL)validateBirth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* cntFollow;



@property int64_t cntFollowValue;
- (int64_t)cntFollowValue;
- (void)setCntFollowValue:(int64_t)value_;

//- (BOOL)validateCntFollow:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* cntFollower;



@property int64_t cntFollowerValue;
- (int64_t)cntFollowerValue;
- (void)setCntFollowerValue:(int64_t)value_;

//- (BOOL)validateCntFollower:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* cntPost;



@property int64_t cntPostValue;
- (int64_t)cntPostValue;
- (void)setCntPostValue:(int64_t)value_;

//- (BOOL)validateCntPost:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* created;



//- (BOOL)validateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* fbToken;



//- (BOOL)validateFbToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iconPath;



//- (BOOL)validateIconPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* introduction;



//- (BOOL)validateIntroduction:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isFollow;



@property BOOL isFollowValue;
- (BOOL)isFollowValue;
- (void)setIsFollowValue:(BOOL)value_;

//- (BOOL)validateIsFollow:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isPushComment;



@property BOOL isPushCommentValue;
- (BOOL)isPushCommentValue;
- (void)setIsPushCommentValue:(BOOL)value_;

//- (BOOL)validateIsPushComment:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isPushFollow;



@property BOOL isPushFollowValue;
- (BOOL)isPushFollowValue;
- (void)setIsPushFollowValue:(BOOL)value_;

//- (BOOL)validateIsPushFollow:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isPushGood;



@property BOOL isPushGoodValue;
- (BOOL)isPushGoodValue;
- (void)setIsPushGoodValue:(BOOL)value_;

//- (BOOL)validateIsPushGood:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sex;



//- (BOOL)validateSex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* twToken;



//- (BOOL)validateTwToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* twTokenSecrect;



//- (BOOL)validateTwTokenSecrect:(id*)value_ error:(NSError**)error_;





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

@interface _User (CoreDataGeneratedAccessors)

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAccessToken;
- (void)setPrimitiveAccessToken:(NSString*)value;




- (NSNumber*)primitiveArea;
- (void)setPrimitiveArea:(NSNumber*)value;

- (int64_t)primitiveAreaValue;
- (void)setPrimitiveAreaValue:(int64_t)value_;




- (NSDate*)primitiveBirth;
- (void)setPrimitiveBirth:(NSDate*)value;




- (NSNumber*)primitiveCntFollow;
- (void)setPrimitiveCntFollow:(NSNumber*)value;

- (int64_t)primitiveCntFollowValue;
- (void)setPrimitiveCntFollowValue:(int64_t)value_;




- (NSNumber*)primitiveCntFollower;
- (void)setPrimitiveCntFollower:(NSNumber*)value;

- (int64_t)primitiveCntFollowerValue;
- (void)setPrimitiveCntFollowerValue:(int64_t)value_;




- (NSNumber*)primitiveCntPost;
- (void)setPrimitiveCntPost:(NSNumber*)value;

- (int64_t)primitiveCntPostValue;
- (void)setPrimitiveCntPostValue:(int64_t)value_;




- (NSDate*)primitiveCreated;
- (void)setPrimitiveCreated:(NSDate*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFbToken;
- (void)setPrimitiveFbToken:(NSString*)value;




- (NSString*)primitiveIconPath;
- (void)setPrimitiveIconPath:(NSString*)value;




- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSString*)primitiveIntroduction;
- (void)setPrimitiveIntroduction:(NSString*)value;




- (NSNumber*)primitiveIsFollow;
- (void)setPrimitiveIsFollow:(NSNumber*)value;

- (BOOL)primitiveIsFollowValue;
- (void)setPrimitiveIsFollowValue:(BOOL)value_;




- (NSNumber*)primitiveIsPushComment;
- (void)setPrimitiveIsPushComment:(NSNumber*)value;

- (BOOL)primitiveIsPushCommentValue;
- (void)setPrimitiveIsPushCommentValue:(BOOL)value_;




- (NSNumber*)primitiveIsPushFollow;
- (void)setPrimitiveIsPushFollow:(NSNumber*)value;

- (BOOL)primitiveIsPushFollowValue;
- (void)setPrimitiveIsPushFollowValue:(BOOL)value_;




- (NSNumber*)primitiveIsPushGood;
- (void)setPrimitiveIsPushGood:(NSNumber*)value;

- (BOOL)primitiveIsPushGoodValue;
- (void)setPrimitiveIsPushGoodValue:(BOOL)value_;




- (NSString*)primitiveSex;
- (void)setPrimitiveSex:(NSString*)value;




- (NSString*)primitiveTwToken;
- (void)setPrimitiveTwToken:(NSString*)value;




- (NSString*)primitiveTwTokenSecrect;
- (void)setPrimitiveTwTokenSecrect:(NSString*)value;




- (NSString*)primitiveUserID;
- (void)setPrimitiveUserID:(NSString*)value;




- (NSNumber*)primitiveUserPID;
- (void)setPrimitiveUserPID:(NSNumber*)value;

- (int64_t)primitiveUserPIDValue;
- (void)setPrimitiveUserPIDValue:(int64_t)value_;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;




@end
