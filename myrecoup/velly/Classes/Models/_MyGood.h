// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MyGood.h instead.

#import <CoreData/CoreData.h>


extern const struct MyGoodAttributes {
	__unsafe_unretained NSString *cntGood;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *isGood;
	__unsafe_unretained NSString *modified;
	__unsafe_unretained NSString *myUserPID;
	__unsafe_unretained NSString *postID;
} MyGoodAttributes;

extern const struct MyGoodRelationships {
} MyGoodRelationships;

extern const struct MyGoodFetchedProperties {
} MyGoodFetchedProperties;









@interface MyGoodID : NSManagedObjectID {}
@end

@interface _MyGood : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MyGoodID*)objectID;





@property (nonatomic, strong) NSNumber* cntGood;



@property int64_t cntGoodValue;
- (int64_t)cntGoodValue;
- (void)setCntGoodValue:(int64_t)value_;

//- (BOOL)validateCntGood:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* identifier;



//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isGood;



@property BOOL isGoodValue;
- (BOOL)isGoodValue;
- (void)setIsGoodValue:(BOOL)value_;

//- (BOOL)validateIsGood:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* modified;



//- (BOOL)validateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* myUserPID;



@property int64_t myUserPIDValue;
- (int64_t)myUserPIDValue;
- (void)setMyUserPIDValue:(int64_t)value_;

//- (BOOL)validateMyUserPID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* postID;



@property int64_t postIDValue;
- (int64_t)postIDValue;
- (void)setPostIDValue:(int64_t)value_;

//- (BOOL)validatePostID:(id*)value_ error:(NSError**)error_;






@end

@interface _MyGood (CoreDataGeneratedAccessors)

@end

@interface _MyGood (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCntGood;
- (void)setPrimitiveCntGood:(NSNumber*)value;

- (int64_t)primitiveCntGoodValue;
- (void)setPrimitiveCntGoodValue:(int64_t)value_;




- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;




- (NSNumber*)primitiveIsGood;
- (void)setPrimitiveIsGood:(NSNumber*)value;

- (BOOL)primitiveIsGoodValue;
- (void)setPrimitiveIsGoodValue:(BOOL)value_;




- (NSDate*)primitiveModified;
- (void)setPrimitiveModified:(NSDate*)value;




- (NSNumber*)primitiveMyUserPID;
- (void)setPrimitiveMyUserPID:(NSNumber*)value;

- (int64_t)primitiveMyUserPIDValue;
- (void)setPrimitiveMyUserPIDValue:(int64_t)value_;




- (NSNumber*)primitivePostID;
- (void)setPrimitivePostID:(NSNumber*)value;

- (int64_t)primitivePostIDValue;
- (void)setPrimitivePostIDValue:(int64_t)value_;




@end
