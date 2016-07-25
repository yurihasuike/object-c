// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MyFollow.m instead.

#import "_MyFollow.h"

const struct MyFollowAttributes MyFollowAttributes = {
	.identifier = @"identifier",
	.isFollow = @"isFollow",
	.modified = @"modified",
	.myUserPID = @"myUserPID",
	.userPID = @"userPID",
};

const struct MyFollowRelationships MyFollowRelationships = {
};

const struct MyFollowFetchedProperties MyFollowFetchedProperties = {
};

@implementation MyFollowID
@end

@implementation _MyFollow

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MyFollow" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MyFollow";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MyFollow" inManagedObjectContext:moc_];
}

- (MyFollowID*)objectID {
	return (MyFollowID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isFollowValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isFollow"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"myUserPIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"myUserPID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"userPIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userPID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic identifier;






@dynamic isFollow;



- (BOOL)isFollowValue {
	NSNumber *result = [self isFollow];
	return [result boolValue];
}

- (void)setIsFollowValue:(BOOL)value_ {
	[self setIsFollow:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsFollowValue {
	NSNumber *result = [self primitiveIsFollow];
	return [result boolValue];
}

- (void)setPrimitiveIsFollowValue:(BOOL)value_ {
	[self setPrimitiveIsFollow:[NSNumber numberWithBool:value_]];
}





@dynamic modified;






@dynamic myUserPID;



- (int64_t)myUserPIDValue {
	NSNumber *result = [self myUserPID];
	return [result longLongValue];
}

- (void)setMyUserPIDValue:(int64_t)value_ {
	[self setMyUserPID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveMyUserPIDValue {
	NSNumber *result = [self primitiveMyUserPID];
	return [result longLongValue];
}

- (void)setPrimitiveMyUserPIDValue:(int64_t)value_ {
	[self setPrimitiveMyUserPID:[NSNumber numberWithLongLong:value_]];
}





@dynamic userPID;



- (int64_t)userPIDValue {
	NSNumber *result = [self userPID];
	return [result longLongValue];
}

- (void)setUserPIDValue:(int64_t)value_ {
	[self setUserPID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveUserPIDValue {
	NSNumber *result = [self primitiveUserPID];
	return [result longLongValue];
}

- (void)setPrimitiveUserPIDValue:(int64_t)value_ {
	[self setPrimitiveUserPID:[NSNumber numberWithLongLong:value_]];
}










@end
