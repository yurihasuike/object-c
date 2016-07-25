//
//  MoviewEditViewController.m
//  NewVideoRecorder
//
//  Created by VCJPCM012 on 2015/07/22.
//  Copyright (c) 2015年 KZito. All rights reserved.
//

#import "Defines.h"
#import "ThumnailEditViewController.h"
#import "TrackingManager.h"
#import "Defines.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PostEditViewController.h"



@implementation ThumnailEditViewController{
    
    UIImageView* photoView;
    CostumDraggingView* cuttingView;
    NSArray* thumnailArray;
    
    UIScrollView* mainView;
    CGSize thumnailSize;
    
    //アセット設定類
    AVURLAsset* assetMaster;
    AVAssetImageGenerator *imageGenMaster;
    
    //動画の長さ取得
    Float64 durationSecondsMaster;
    CMTime pointMaster;
    
}

static const int FRAME_HEIGHT = 100;
static const int CUTTINGVIEW_HEIGHT = 100;
static const int kVideoFPS = 30;
static const Float64 MaxTime = 30;
static const int thumnailCount = 10;

-(void)initialize{
    
    //スクロールビューの準備
    mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - FRAME_HEIGHT- self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, FRAME_HEIGHT)];
    mainView.delegate = self;
    mainView.bounces  = NO;
    thumnailSize = CGSizeMake(self.view.frame.size.width/thumnailCount, FRAME_HEIGHT);
    mainView.backgroundColor = [UIColor redColor];
    [self.view addSubview:mainView];
    
    //フレーム画像表示部の準備
    photoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-FRAME_HEIGHT-CUTTINGVIEW_HEIGHT-self.navigationController.navigationBar.frame.size.height)];
    [photoView setContentMode:UIViewContentModeScaleAspectFit];
    [photoView setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    [self.view addSubview:photoView];
    
    //サムネイル選択View
    cuttingView = [[CostumDraggingView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height -FRAME_HEIGHT - CUTTINGVIEW_HEIGHT-self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, CUTTINGVIEW_HEIGHT)];
    cuttingView.delegate = self;
    //cuttingView.parent = self;
    cuttingView.backgroundColor = [UIColor blackColor];
    [cuttingView cuttingMode];
    [self.view addSubview:cuttingView];
    
    //ナビゲーションコントローラのスワイプBackを無効化
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    //ナビゲーションコントローラに保存ボタンを追加
    UIBarButtonItem* right1 = [[UIBarButtonItem alloc]
                               initWithTitle:@"確認画面へ"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(goForm)];
    self.navigationItem.rightBarButtonItems = @[right1];
    
}

-(void)setContents:(NSArray*)imageArray{
    
    int counter = 0;
    for (UIImage* image in imageArray) {
        
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(counter*thumnailSize.width, 0, thumnailSize.width, thumnailSize.height)];
        counter++;
        //imageView.contentMode = UIViewContentModeRedraw;
        imageView.image = image;
        imageView.backgroundColor = [UIColor redColor];
        [mainView addSubview:imageView];
        
        if(counter == 1){
            photoView.image = image;
        }
        
    }
    CGSize size = CGSizeMake(thumnailSize.width*counter, thumnailSize.height);
    mainView.contentSize = size;
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //if (floor(NSFoundationVersionNumber) &gt; NSFoundationVersionNumber_iOS_6_1){
        // ①下から表示
        self.edgesForExtendedLayout = UIRectEdgeNone;
        // ②不透明バーがレイアウトに含まれない
        self.extendedLayoutIncludesOpaqueBars = NO;
        // ③ScrollViewのインセット自動調整をしない
        self.automaticallyAdjustsScrollViewInsets = NO;
    //}
    
    [self initialize];
    
    AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:self.fileURL options:nil];
    thumnailArray = [self createThumbnailImage:asset];
    [self setContents:thumnailArray];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"カバー画像";
    [title sizeToFit];
    self.navigationItem.titleView = title;
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.97 green:0.67 blue:0.49 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (NSArray*)createThumbnailImage:(AVURLAsset*)asset {
    
    NSMutableArray* result = [NSMutableArray array];
    
    if ([asset tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
        AVAssetImageGenerator *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        [imageGen setAppliesPreferredTrackTransform:YES];
        
        //動画の長さ取得
        Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
        
        //動画の取得感覚
        Float64 interval;
        
        if(durationSeconds < MaxTime){
            interval = MaxTime / durationSeconds;
        }else{
            interval = 1;
        }
        
        
        for(Float64 i = 0; i <= thumnailCount ;i++){
            CMTime point =   CMTimeMakeWithSeconds((i*(MaxTime/thumnailCount))/interval, 600);
            NSError* error = nil;
            CMTime actualTime;
            CGImageRef halfWayImageRef = [imageGen copyCGImageAtTime:point actualTime:&actualTime error:&error];
            if (halfWayImageRef != NULL) {
                UIImage* myImage = [[UIImage alloc]initWithCGImage:halfWayImageRef];
                [result addObject:myImage];
                CGImageRelease(halfWayImageRef);
            }
            
        }
        
    }
    return result;
}


//プロトコル
-(void)changeThumnail:(int)leftViewPosition{
    
//    int oneFrameSize = self.view.frame.size.width/MaxTime;
//    int frame = leftViewPosition / oneFrameSize;
//    
//    //撮影数が下回っていた場合
//    if(frame >= (thumnailArray.count - 1)){
//        frame = thumnailArray.count - 1;
//    }
    
    Float64 postion = (Float64)leftViewPosition / (Float64)self.view.frame.size.width;
    
    
    if(!assetMaster){
        assetMaster = [[AVURLAsset alloc]initWithURL:self.fileURL options:nil];
        imageGenMaster = [[AVAssetImageGenerator alloc] initWithAsset:assetMaster];
        [imageGenMaster setAppliesPreferredTrackTransform:YES];
        //動画の長さ取得
    }
    CMTime actualTime;
    NSError *error = nil;
    
    //AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:self.fileURL options:nil];
    
    if ([assetMaster tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
        
        durationSecondsMaster = CMTimeGetSeconds([assetMaster duration]);
        durationSecondsMaster = durationSecondsMaster * postion;
        pointMaster =   CMTimeMakeWithSeconds(durationSecondsMaster, 600);
        CGImageRef halfWayImageRef = [imageGenMaster copyCGImageAtTime:pointMaster actualTime:&actualTime error:&error];
        if (halfWayImageRef != NULL) {
            UIImage* myImage = [[UIImage alloc]initWithCGImage:halfWayImageRef];
            
            int width = myImage.size.width;
            int height = myImage.size.height;
            NSLog(@"画像サイズ:%d x %d", width, height);
            CGImageRelease(halfWayImageRef);
            photoView.image = myImage;
        }
    }
}

-(void)goForm{
    
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[THUMBNAILEDITED]
                         properties:nil];

    if(!assetMaster){
        assetMaster = [[AVURLAsset alloc]initWithURL:self.fileURL options:nil];
    }
    
    PostEditViewController *postEditViewController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"PostEditViewController"];
    postEditViewController = [postEditViewController initWithPostImage: photoView.image];
    postEditViewController.assetMaster = assetMaster;
    postEditViewController.isMovie = YES;
    
    [self.navigationController pushViewController:postEditViewController animated:YES];
    

}

@end
