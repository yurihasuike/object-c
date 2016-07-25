// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Post.m instead.

#import "_Post.h"

const struct PostAttributes PostAttributes = {
	.categoryID = @"categoryID",
	.categoryName = @"categoryName",
	.cntComment = @"cntComment",
	.cntGood = @"cntGood",
	.created = @"created",
	.descrip = @"descrip",
	.iconPath = @"iconPath",
	.identifier = @"identifier",
	.isGood = @"isGood",
	.originalHeight = @"originalHeight",
	.originalPath = @"originalPath",
	.originalWidth = @"originalWidth",
	.postID = @"postID",
	.thumbnailHeight = @"thumbnailHeight",
	.thumbnailPath = @"thumbnailPath",
	.thumbnailWidth = @"thumbnailWidth",
	.transcodedHeight = @"transcodedHeight",
	.transcodedPath = @"transcodedPath",
	.transcodedWidth = @"transcodedWidth",
	.userID = @"userID",
	.userPID = @"userPID",
	.username = @"username",
};

const struct PostRelationships PostRelationships = {
};

const struct PostFetchedProperties PostFetchedProperties = {
};

@implementation PostID
@end

@implementation _Post

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Post";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Post" inManagedObjectContext:moc_];
}

- (PostID*)objectID {
	return (PostID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"categoryIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"categoryID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"cntCommentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"cntComment"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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
	if ([key isEqualToString:@"originalHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"originalWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalWidth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"postIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"postID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"thumbnailHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"thumbnailHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"thumbnailWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"thumbnailWidth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"transcodedHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"transcodedHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"transcodedWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"transcodedWidth"];
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






@dynamic cntComment;



- (int64_t)cntCommentValue {
	NSNumber *result = [self cntComment];
	return [result longLongValue];
}

- (void)setCntCommentValue:(int64_t)value_ {
	[self setCntComment:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveCntCommentValue {
	NSNumber *result = [self primitiveCntComment];
	return [result longLongValue];
}

- (void)setPrimitiveCntCommentValue:(int64_t)value_ {
	[self setPrimitiveCntComment:[NSNumber numberWithLongLong:value_]];
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





@dynamic created;






@dynamic descrip;






@dynamic iconPath;






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





@dynamic originalHeight;



- (int64_t)originalHeightValue {
	NSNumber *result = [self originalHeight];
	return [result longLongValue];
}

- (void)setOriginalHeightValue:(int64_t)value_ {
	[self setOriginalHeight:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveOriginalHeightValue {
	NSNumber *result = [self primitiveOriginalHeight];
	return [result longLongValue];
}

- (void)setPrimitiveOriginalHeightValue:(int64_t)value_ {
	[self setPrimitiveOriginalHeight:[NSNumber numberWithLongLong:value_]];
}





@dynamic originalPath;






@dynamic originalWidth;



- (int64_t)originalWidthValue {
	NSNumber *result = [self originalWidth];
	return [result longLongValue];
}

- (void)setOriginalWidthValue:(int64_t)value_ {
	[self setOriginalWidth:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveOriginalWidthValue {
	NSNumber *result = [self primitiveOriginalWidth];
	return [result longLongValue];
}

- (void)setPrimitiveOriginalWidthValue:(int64_t)value_ {
	[self setPrimitiveOriginalWidth:[NSNumber numberWithLongLong:value_]];
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





@dynamic thumbnailHeight;



- (int64_t)thumbnailHeightValue {
	NSNumber *result = [self thumbnailHeight];
	return [result longLongValue];
}

- (void)setThumbnailHeightValue:(int64_t)value_ {
	[self setThumbnailHeight:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveThumbnailHeightValue {
	NSNumber *result = [self primitiveThumbnailHeight];
	return [result longLongValue];
}

- (void)setPrimitiveThumbnailHeightValue:(int64_t)value_ {
	[self setPrimitiveThumbnailHeight:[NSNumber numberWithLongLong:value_]];
}





@dynamic thumbnailPath;






@dynamic thumbnailWidth;



- (int64_t)thumbnailWidthValue {
	NSNumber *result = [self thumbnailWidth];
	return [result longLongValue];
}

- (void)setThumbnailWidthValue:(int64_t)value_ {
	[self setThumbnailWidth:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveThumbnailWidthValue {
	NSNumber *result = [self primitiveThumbnailWidth];
	return [result longLongValue];
}

- (void)setPrimitiveThumbnailWidthValue:(int64_t)value_ {
	[self setPrimitiveThumbnailWidth:[NSNumber numberWithLongLong:value_]];
}





@dynamic transcodedHeight;



- (int64_t)transcodedHeightValue {
	NSNumber *result = [self transcodedHeight];
	return [result longLongValue];
}

- (void)setTranscodedHeightValue:(int64_t)value_ {
	[self setTranscodedHeight:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTranscodedHeightValue {
	NSNumber *result = [self primitiveTranscodedHeight];
	return [result longLongValue];
}

- (void)setPrimitiveTranscodedHeightValue:(int64_t)value_ {
	[self setPrimitiveTranscodedHeight:[NSNumber numberWithLongLong:value_]];
}





@dynamic transcodedPath;






@dynamic transcodedWidth;



- (int64_t)transcodedWidthValue {
	NSNumber *result = [self transcodedWidth];
	return [result longLongValue];
}

- (void)setTranscodedWidthValue:(int64_t)value_ {
	[self setTranscodedWidth:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTranscodedWidthValue {
	NSNumber *result = [self primitiveTranscodedWidth];
	return [result longLongValue];
}

- (void)setPrimitiveTranscodedWidthValue:(int64_t)value_ {
	[self setPrimitiveTranscodedWidth:[NSNumber numberWithLongLong:value_]];
}





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
