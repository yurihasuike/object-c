// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MyFollow.h instead.

#import <CoreData/CoreData.h>


extern const struct MyFollowAttributes {
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *isFollow;
	__unsafe_unretained NSString *modified;
	__unsafe_unretained NSString *myUserPID;
	__unsafe_unretained NSString *userPID;
} MyFollowAttributes;

extern const struct MyFollowRelationships {
} MyFollowRelationships;

extern const struct MyFollowFetchedProperties {
} MyFollowFetchedProperties;








@interface MyFollowID : NSManagedObjectID {}
@end

@interface _MyFollow : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MyFollowID*)objectID;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isFollow;



@property BOOL isFollowValue;
- (BOOL)isFollowValue;
- (void)setIsFollowValue:(BOOL)value_;

//- (BOOL)validateIsFollow:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* modified;



//- (BOOL)validateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* myUserPID;



@property int64_t myUserPIDValue;
- (int64_t)myUserPIDValue;
- (void)setMyUserPIDValue:(int64_t)value_;

//- (BOOL)validateMyUserPID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userPID;



@property int64_t userPIDValue;
- (int64_t)userPIDValue;
- (void)setUserPIDValue:(int64_t)value_;

//- (BOOL)validateUserPID:(id*)value_ error:(NSError**)error_;






@end

@interface _MyFollow (CoreDataGeneratedAccessors)

@end

@interface _MyFollow (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSNumber*)primitiveIsFollow;
- (void)setPrimitiveIsFollow:(NSNumber*)value;

- (BOOL)primitiveIsFollowValue;
- (void)setPrimitiveIsFollowValue:(BOOL)value_;




- (NSDate*)primitiveModified;
- (void)setPrimitiveModified:(NSDate*)value;




- (NSNumber*)primitiveMyUserPID;
- (void)setPrimitiveMyUserPID:(NSNumber*)value;

- (int64_t)primitiveMyUserPIDValue;
- (void)setPrimitiveMyUserPIDValue:(int64_t)value_;




- (NSNumber*)primitiveUserPID;
- (void)setPrimitiveUserPID:(NSNumber*)value;

- (int64_t)primitiveUserPIDValue;
- (void)setPrimitiveUserPIDValue:(int64_t)value_;




@end
