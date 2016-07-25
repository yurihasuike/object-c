// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.accessToken = @"accessToken",
	.area = @"area",
	.birth = @"birth",
	.cntFollow = @"cntFollow",
	.cntFollower = @"cntFollower",
	.cntPost = @"cntPost",
	.created = @"created",
	.email = @"email",
	.fbToken = @"fbToken",
	.iconPath = @"iconPath",
	.identifier = @"identifier",
	.introduction = @"introduction",
	.isFollow = @"isFollow",
	.isPushComment = @"isPushComment",
	.isPushFollow = @"isPushFollow",
	.isPushGood = @"isPushGood",
	.sex = @"sex",
	.twToken = @"twToken",
	.twTokenSecrect = @"twTokenSecrect",
	.userID = @"userID",
	.userPID = @"userPID",
	.username = @"username",
};

const struct UserRelationships UserRelationships = {
};

const struct UserFetchedProperties UserFetchedProperties = {
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"areaValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"area"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"cntFollowValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cntFollow"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"cntFollowerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cntFollower"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"cntPostValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cntPost"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isFollowValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isFollow"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isPushCommentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPushComment"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isPushFollowValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPushFollow"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isPushGoodValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPushGood"];
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




@dynamic accessToken;






@dynamic area;



- (int64_t)areaValue {
	NSNumber *result = [self area];
	return [result longLongValue];
}

- (void)setAreaValue:(int64_t)value_ {
	[self setArea:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveAreaValue {
	NSNumber *result = [self primitiveArea];
	return [result longLongValue];
}

- (void)setPrimitiveAreaValue:(int64_t)value_ {
	[self setPrimitiveArea:[NSNumber numberWithLongLong:value_]];
}





@dynamic birth;






@dynamic cntFollow;



- (int64_t)cntFollowValue {
	NSNumber *result = [self cntFollow];
	return [result longLongValue];
}

- (void)setCntFollowValue:(int64_t)value_ {
	[self setCntFollow:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveCntFollowValue {
	NSNumber *result = [self primitiveCntFollow];
	return [result longLongValue];
}

- (void)setPrimitiveCntFollowValue:(int64_t)value_ {
	[self setPrimitiveCntFollow:[NSNumber numberWithLongLong:value_]];
}





@dynamic cntFollower;



- (int64_t)cntFollowerValue {
	NSNumber *result = [self cntFollower];
	return [result longLongValue];
}

- (void)setCntFollowerValue:(int64_t)value_ {
	[self setCntFollower:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveCntFollowerValue {
	NSNumber *result = [self primitiveCntFollower];
	return [result longLongValue];
}

- (void)setPrimitiveCntFollowerValue:(int64_t)value_ {
	[self setPrimitiveCntFollower:[NSNumber numberWithLongLong:value_]];
}





@dynamic cntPost;



- (int64_t)cntPostValue {
	NSNumber *result = [self cntPost];
	return [result longLongValue];
}

- (void)setCntPostValue:(int64_t)value_ {
	[self setCntPost:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveCntPostValue {
	NSNumber *result = [self primitiveCntPost];
	return [result longLongValue];
}

- (void)setPrimitiveCntPostValue:(int64_t)value_ {
	[self setPrimitiveCntPost:[NSNumber numberWithLongLong:value_]];
}





@dynamic created;






@dynamic email;






@dynamic fbToken;






@dynamic iconPath;






@dynamic identifier;






@dynamic introduction;






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





@dynamic isPushComment;



- (BOOL)isPushCommentValue {
	NSNumber *result = [self isPushComment];
	return [result boolValue];
}

- (void)setIsPushCommentValue:(BOOL)value_ {
	[self setIsPushComment:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPushCommentValue {
	NSNumber *result = [self primitiveIsPushComment];
	return [result boolValue];
}

- (void)setPrimitiveIsPushCommentValue:(BOOL)value_ {
	[self setPrimitiveIsPushComment:[NSNumber numberWithBool:value_]];
}





@dynamic isPushFollow;



- (BOOL)isPushFollowValue {
	NSNumber *result = [self isPushFollow];
	return [result boolValue];
}

- (void)setIsPushFollowValue:(BOOL)value_ {
	[self setIsPushFollow:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPushFollowValue {
	NSNumber *result = [self primitiveIsPushFollow];
	return [result boolValue];
}

- (void)setPrimitiveIsPushFollowValue:(BOOL)value_ {
	[self setPrimitiveIsPushFollow:[NSNumber numberWithBool:value_]];
}





@dynamic isPushGood;



- (BOOL)isPushGoodValue {
	NSNumber *result = [self isPushGood];
	return [result boolValue];
}

- (void)setIsPushGoodValue:(BOOL)value_ {
	[self setIsPushGood:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPushGoodValue {
	NSNumber *result = [self primitiveIsPushGood];
	return [result boolValue];
}

- (void)setPrimitiveIsPushGoodValue:(BOOL)value_ {
	[self setPrimitiveIsPushGood:[NSNumber numberWithBool:value_]];
}





@dynamic sex;






@dynamic twToken;






@dynamic twTokenSecrect;






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
