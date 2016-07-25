#import "MyGood.h"


@interface MyGood ()

// Private interface goes here.

@end


@implementation MyGood

+ (MyGood *)getMyGood:(NSNumber *)myUserPID postID:(NSNumber *)postID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"myUserPID == %d && postID == %d", [myUserPID intValue], [postID intValue]];
    MyGood *myGood = [MyGood MR_findFirstWithPredicate:predicate];
    return myGood;
}

+ (void)updateMyGood:(NSNumber *)myUserPID postID:(NSNumber *)postID isGood:(BOOL)isGood cntGood:(NSNumber *)cntGood
{

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"myUserPID == %d && postID == %d", [myUserPID intValue], [postID intValue]];
//            NSFetchRequest *myGoodRequest = [MyGood MR_requestAllWithPredicate:predicate inContext:localContext];
//        [myGoodRequest setPredicate:predicate];
//        NSArray *myGoods = [MyGood MR_executeFetchRequest:myGoodRequest];

        MyGood *myGood = [MyGood MR_findFirstWithPredicate:predicate inContext:localContext];
        
        if(myGood == nil){
            myGood = [MyGood MR_createEntityInContext:localContext];
            myGood.myUserPID = myUserPID;
            myGood.postID    = postID;
        }
        myGood.modified  = [NSDate date];
        if(isGood){
            myGood.isGood = [NSNumber numberWithInt:VLPOSTLIKEYES];
        }else{
            myGood.isGood = [NSNumber numberWithInt:VLPOSTLIKENO];
        }
        myGood.cntGood = cntGood;
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    } completion:^(BOOL success, NSError *error) {
    }];

}


@end
