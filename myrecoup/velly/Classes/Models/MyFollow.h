#import "_MyFollow.h"

@interface MyFollow : _MyFollow {}

+ (MyFollow *)getMyFollow:(NSNumber *)myUserPID userPID:(NSNumber *)userPID;
+ (void)updateMyFollow:(NSNumber *)myUserPID userPID:(NSNumber *)userPID isFollow:(BOOL)isFollow;

@end
