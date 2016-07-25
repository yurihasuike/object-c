#import "_MyGood.h"

@interface MyGood : _MyGood {}

+ (MyGood *)getMyGood:(NSNumber *)myUserPID postID:(NSNumber *)postID;
+ (void)updateMyGood:(NSNumber *)myUserPID postID:(NSNumber *)postID isGood:(BOOL)isGood cntGood:(NSNumber *)cntGood;

@end
