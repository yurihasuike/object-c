// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MyGood.m instead.

#import "_MyGood.h"

const struct MyGoodAttributes MyGoodAttributes = {
	.cntGood = @"cntGood",
	.identifier = @"identifier",
	.isGood = @"isGood",
	.modified = @"modified",
	.myUserPID = @"myUserPID",
	.postID = @"postID",
};

const struct MyGoodRelationships MyGoodRelationships = {
};

const struct MyGoodFetchedProperties MyGoodFetchedProperties = {
};

@implementation MyGoodID
@end

@implementation _MyGood

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MyGood" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MyGood";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MyGood" inManagedObjectContext:moc_];
}

- (MyGoodID*)objectID {
	return (MyGoodID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"cntGoodValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cntGood"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isGoodValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isGood"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"myUserPIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"myUserPID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"postIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"postID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic cntGood;



- (int64_t)cntGoodValue {
	NSNumber *result = [self cntGood];
	return [result longLongValue];
}

- (void)setCntGoodValue:(int64_t)value_ {
	[self setCntGood:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveCntGoodValue {
	NSNumber *result = [self primitiveCntGood];
	return [result longLongValue];
}

- (void)setPrimitiveCntGoodValue:(int64_t)value_ {
	[self setPrimitiveCntGood:[NSNumber numberWithLongLong:value_]];
}





@dynamic identifier;






@dynamic isGood;



- (BOOL)isGoodValue {
	NSNumber *result = [self isGood];
	return [result boolValue];
}

- (void)setIsGoodValue:(BOOL)value_ {
	[self setIsGood:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsGoodValue {
	NSNumber *result = [self primitiveIsGood];
	return [result boolValue];
}

- (void)setPrimitiveIsGoodValue:(BOOL)value_ {
	[self setPrimitiveIsGood:[NSNumber numberWithBool:value_]];
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





@dynamic postID;



- (int64_t)postIDValue {
	NSNumber *result = [self postID];
	return [result longLongValue];
}

- (void)setPostIDValue:(int64_t)value_ {
	[self setPostID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitivePostIDValue {
	NSNumber *result = [self primitivePostID];
	return [result longLongValue];
}

- (void)setPrimitivePostIDValue:(int64_t)value_ {
	[self setPrimitivePostID:[NSNumber numberWithLongLong:value_]];
}










@end
