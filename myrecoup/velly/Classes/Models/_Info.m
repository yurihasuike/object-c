// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Info.m instead.

#import "_Info.h"

const struct InfoAttributes InfoAttributes = {
	.categoryID = @"categoryID",
	.categoryName = @"categoryName",
	.created = @"created",
	.iconPath = @"iconPath",
	.identifier = @"identifier",
	.imgPath = @"imgPath",
	.infoID = @"infoID",
	.infoType = @"infoType",
	.isFollow = @"isFollow",
	.postID = @"postID",
	.rankNew = @"rankNew",
	.rankOld = @"rankOld",
	.title = @"title",
	.userID = @"userID",
	.userPID = @"userPID",
	.username = @"username",
};

const struct InfoRelationships InfoRelationships = {
};

const struct InfoFetchedProperties InfoFetchedProperties = {
};

@implementation InfoID
@end

@implementation _Info

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Info" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Info";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Info" inManagedObjectContext:moc_];
}

- (InfoID*)objectID {
	return (InfoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"categoryIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"categoryID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"infoIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"infoID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"infoTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"infoType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isFollowValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isFollow"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"postIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"postID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rankNewValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rankNew"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rankOldValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rankOld"];
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




@dynamic categoryID;



- (int64_t)categoryIDValue {
	NSNumber *result = [self categoryID];
	return [result longLongValue];
}

- (void)setCategoryIDValue:(int64_t)value_ {
	[self setCategoryID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveCategoryIDValue {
	NSNumber *result = [self primitiveCategoryID];
	return [result longLongValue];
}

- (void)setPrimitiveCategoryIDValue:(int64_t)value_ {
	[self setPrimitiveCategoryID:[NSNumber numberWithLongLong:value_]];
}





@dynamic categoryName;






@dynamic created;






@dynamic iconPath;






@dynamic identifier;






@dynamic imgPath;






@dynamic infoID;



- (int64_t)infoIDValue {
	NSNumber *result = [self infoID];
	return [result longLongValue];
}

- (void)setInfoIDValue:(int64_t)value_ {
	[self setInfoID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveInfoIDValue {
	NSNumber *result = [self primitiveInfoID];
	return [result longLongValue];
}

- (void)setPrimitiveInfoIDValue:(int64_t)value_ {
	[self setPrimitiveInfoID:[NSNumber numberWithLongLong:value_]];
}





@dynamic infoType;



- (int64_t)infoTypeValue {
	NSNumber *result = [self infoType];
	return [result longLongValue];
}

- (void)setInfoTypeValue:(int64_t)value_ {
	[self setInfoType:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveInfoTypeValue {
	NSNumber *result = [self primitiveInfoType];
	return [result longLongValue];
}

- (void)setPrimitiveInfoTypeValue:(int64_t)value_ {
	[self setPrimitiveInfoType:[NSNumber numberWithLongLong:value_]];
}





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





@dynamic rankNew;



- (int64_t)rankNewValue {
	NSNumber *result = [self rankNew];
	return [result longLongValue];
}

- (void)setRankNewValue:(int64_t)value_ {
	[self setRankNew:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRankNewValue {
	NSNumber *result = [self primitiveRankNew];
	return [result longLongValue];
}

- (void)setPrimitiveRankNewValue:(int64_t)value_ {
	[self setPrimitiveRankNew:[NSNumber numberWithLongLong:value_]];
}





@dynamic rankOld;



- (int64_t)rankOldValue {
	NSNumber *result = [self rankOld];
	return [result longLongValue];
}

- (void)setRankOldValue:(int64_t)value_ {
	[self setRankOld:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRankOldValue {
	NSNumber *result = [self primitiveRankOld];
	return [result longLongValue];
}

- (void)setPrimitiveRankOldValue:(int64_t)value_ {
	[self setPrimitiveRankOld:[NSNumber numberWithLongLong:value_]];
}





@dynamic title;






@dynamic userID;






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





@dynamic username;











@end
