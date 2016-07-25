// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Server.m instead.

#import "_Server.h"

const struct ServerAttributes ServerAttributes = {
	.serverID = @"serverID",
};

const struct ServerRelationships ServerRelationships = {
};

const struct ServerFetchedProperties ServerFetchedProperties = {
};

@implementation ServerID
@end

@implementation _Server

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Server" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Server";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Server" inManagedObjectContext:moc_];
}

- (ServerID*)objectID {
	return (ServerID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"serverIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"serverID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic serverID;



- (int64_t)serverIDValue {
	NSNumber *result = [self serverID];
	return [result longLongValue];
}

- (void)setServerIDValue:(int64_t)value_ {
	[self setServerID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveServerIDValue {
	NSNumber *result = [self primitiveServerID];
	return [result longLongValue];
}

- (void)setPrimitiveServerIDValue:(int64_t)value_ {
	[self setPrimitiveServerID:[NSNumber numberWithLongLong:value_]];
}










@end
