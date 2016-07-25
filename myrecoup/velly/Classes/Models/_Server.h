// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Server.h instead.

#import <CoreData/CoreData.h>


extern const struct ServerAttributes {
	__unsafe_unretained NSString *serverID;
} ServerAttributes;

extern const struct ServerRelationships {
} ServerRelationships;

extern const struct ServerFetchedProperties {
} ServerFetchedProperties;




@interface ServerID : NSManagedObjectID {}
@end

@interface _Server : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ServerID*)objectID;





@property (nonatomic, strong) NSNumber* serverID;



@property int64_t serverIDValue;
- (int64_t)serverIDValue;
- (void)setServerIDValue:(int64_t)value_;

//- (BOOL)validateServerID:(id*)value_ error:(NSError**)error_;






@end

@interface _Server (CoreDataGeneratedAccessors)

@end

@interface _Server (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveServerID;
- (void)setPrimitiveServerID:(NSNumber*)value;

- (int64_t)primitiveServerIDValue;
- (void)setPrimitiveServerIDValue:(int64_t)value_;




@end
