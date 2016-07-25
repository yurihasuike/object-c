#import "MyFollow.h"


@interface MyFollow ()

// Private interface goes here.

@end


@implementation MyFollow

+ (MyFollow *)getMyFollow:(NSNumber *)myUserPID userPID:(NSNumber *)userPID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"myUserPID == %d && userPID == %d", [myUserPID intValue], [userPID intValue]];
    MyFollow *myFollow = [MyFollow MR_findFirstWithPredicate:predicate];
    return myFollow;
}

+ (void)updateMyFollow:(NSNumber *)myUserPID userPID:(NSNumber *)userPID isFollow:(BOOL)isFollow
{

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"myUserPID == %d && userPID == %d", [myUserPID intValue], [userPID intValue]];
        //            NSFetchRequest *myGoodRequest = [MyGood MR_requestAllWithPredicate:predicate inContext:localContext];
        //        [myGoodRequest setPredicate:predicate];
        //        NSArray *myGoods = [MyGood MR_executeFetchRequest:myGoodRequest];
        
        MyFollow *myFollow = [MyFollow MR_findFirstWithPredicate:predicate inContext:localContext];
        if(myFollow == nil){
            myFollow = [MyFollow MR_createEntityInContext:localContext];
            myFollow.myUserPID = myUserPID;
            myFollow.userPID   = userPID;
        }
        myFollow.modified  = [NSDate date];
        if(isFollow){
            myFollow.isFollow = [NSNumber numberWithInt:VLPOSTLIKEYES];
        }else{
            myFollow.isFollow = [NSNumber numberWithInt:VLPOSTLIKENO];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
    } completion:^(BOOL success, NSError *error) {
    }];
    
}

@end
