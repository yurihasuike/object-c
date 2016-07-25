//
//  PostViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/02/19.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostViewController.h"
#import "PostEffectViewController.h"
#import "PostEditViewController.h"
#import "PostLibCollectionViewController.h"
#import "AVCaptureManager.h"
#import "SVProgressHUD.h"
#import "TrackingManager.h"
#import "ConfigLoader.h"
#import "CoreImageHelper.h"
#import "Defines.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#include <AVFoundation/AVFoundation.h>

@interface PostViewController () <UIImagePickerControllerDelegate>        // AVCaptureManagerDelegate
{
    NSTimeInterval startTime;
    BOOL isNeededToSave;
    BOOL isHelpOpen;
    //IBOutlet UIView *helpView;
}
@property (nonatomic, strong) AVCaptureManager *captureManager;

@end

@implementation PostViewController

@synthesize adjustingExposure, indicatorLayer;

#define INDICATOR_RECT_SIZE 50.0

#define CAPTURE_TYPE_CAMERA 0
#define CAPTURE_TYPE_VIDEO  1

+ (PostViewController *)sharedInstance {
    static PostViewController *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PostViewController alloc] init];
    });
    return _sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.navigationController.navigationBarHidden = YES;

    // close btn
    [self.closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    
    // grid btn
    [self.lineBtn setSelected:NO];
    [self.lineBtn setBackgroundImage:[UIImage imageNamed:@"btn_grid.png"] forState:UIControlStateNormal];
    [self.lineBtn addTarget:self action:@selector(lineGridAction:) forControlEvents:UIControlEventTouchUpInside];
    self.lineBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);

    // reverse btn
    [self.reverseBtn setSelected:NO];
    [self.reverseBtn addTarget:self action:@selector(reverseAction:) forControlEvents:UIControlEventTouchUpInside];
    self.reverseBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);

    // flash btn
    [self.flashBtn setSelected:NO];
    [self.flashBtn setBackgroundImage:[UIImage imageNamed:@"btn_flash.png"] forState:UIControlStateNormal];
    [self.flashBtn addTarget:self action:@selector(flashAction:) forControlEvents:UIControlEventTouchUpInside];
    self.flashBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);

    // library btn
    [self.libBtn addTarget:self action:@selector(librarySelectAction:) forControlEvents:UIControlEventTouchUpInside];

    // next btn
    //[self.nextBtn addTarget:self action:@selector(nextRecEffectAction:) forControlEvents:UIControlEventTouchUpInside];
    //self.nextBtn.hidden = YES;

    // rec btn
    [self.recBtn addTarget:self action:@selector(recAction:) forControlEvents:UIControlEventTouchUpInside];

    // グリッド表示 最前面
    [self.view bringSubviewToFront:self.gridView];
    self.gridView.alpha = 0.5f;
    self.gridView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.gridView.layer.borderWidth = 1.0;
    self.gridView.hidden = YES;
    [self.lineBtn setSelected:NO];

    // ヘルプ表示
//    isHelpOpen = NO;
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHelpButtonTapped:)];
//    [helpView addGestureRecognizer:tapGesture];
    // ヘルプボタンアクション
//    [self.helpBtn addTarget:self action:@selector(handleHelpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.isNoCameraDevice = NO;
    self.isNoCameraPermit = NO;
    self.isFirstCameraPermit = NO;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // do something
        DLog(@"no device TypeCamera");
        self.isNoCameraDevice = YES;
        
    }else if(![self checkPermissionOfCamera]) {
        
        self.isNoCameraPermit = YES;
        
    }else{
    
        // カメラプレビュー設定
        self.captureType = CAPTURE_TYPE_CAMERA; // 初期はカメラでキャプチャ
        self.cameraManager = AVCameraManager.new;         // カメラクラスを初期化
        self.cameraManager.delegate = self;
    
        CGRect displayFrame = self.displayView.frame;
        displayFrame.size.height = [[UIScreen mainScreen]bounds].size.height - 120.0f;
        [self.displayView setFrame:displayFrame];
    
        [self.cameraManager setPreview:self.displayView];   // プレビューレイヤを設定
    }
    
    // フォーカス位置を探す
    self.indicatorLayer = [CALayer layer];
    self.indicatorLayer.borderColor = [[UIColor whiteColor] CGColor];
    self.indicatorLayer.borderWidth = 1.0;
    self.indicatorLayer.frame = CGRectMake(self.view.bounds.size.width/2.0 - INDICATOR_RECT_SIZE/2.0,
                                           self.view.bounds.size.height/2.0 - INDICATOR_RECT_SIZE/2.0,
                                           INDICATOR_RECT_SIZE,
                                           INDICATOR_RECT_SIZE);
    
    //self.indicatorLayer.hidden = YES;
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //done 0.2 seconds after.
        self.indicatorLayer.hidden = YES;
    });
    
    [self.view.layer addSublayer:self.indicatorLayer];
    
    // ジェスチャ監視
    UIGestureRecognizer* gr = [[UITapGestureRecognizer alloc]
                               initWithTarget:self action:@selector(didTapGesture:)];
    [self.view addGestureRecognizer:gr];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"PostRegist"];
        
    //self.isNoCameraPermit = YES;
    if(self.isNoCameraDevice){
        
        self.recBtn.enabled     = NO;
        self.libBtn.enabled     = NO;
        self.lineBtn.enabled    = NO;
        self.reverseBtn.enabled = NO;
        self.flashBtn.enabled   = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.delegate = self;
        alert.title = @"";
        alert.message = NSLocalizedString(@"RegistUserPhotoNotCamera", nil);
        [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alert show];
        
    }else if(self.isNoCameraPermit || ![self checkPermissionOfCamera]) {
        
        self.recBtn.enabled     = NO;
        self.libBtn.enabled     = NO;
        self.lineBtn.enabled    = NO;
        self.reverseBtn.enabled = NO;
        self.flashBtn.enabled   = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.delegate = self;
        alert.title = @"";
        alert.message = NSLocalizedString(@"CameraPermitError", nil);
        [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alert show];
        
    }else{
    
        self.recBtn.enabled = YES;
        
        DLog(@"%@", self.cameraImageView.image);
    
        if(self.cameraImageView.image != nil){
            self.cameraImageView.image = nil;
        }
    
        if(self.cameraImage != nil){
            DLog(@"cameImage have a image");
            [self postEffectActionImage:(UIImage *)self.cameraImage];
        }
    
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //done 0.2 seconds after.
            if(self.cameraManager){
                [self.cameraManager useFrontCamera:NO];
            }
            [self.gridView setupSubviews];
        });
    
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) removeOverlay: (UIView *) overlayView
{
    [overlayView removeFromSuperview];
}


#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // no camera device
            [self dismissViewControllerAnimated:YES completion:^{
                // 動画投稿画面を閉じる際の処理
            }];
            break;
    }
}


// カメラ / 動画きりかえ
//- (IBAction)segment:(id)sender {
//    UISegmentedControl *segmentedControl = (UISegmentedControl*) sender;
//    switch (segmentedControl.selectedSegmentIndex) {
//        case 0: {
//            NSLog(@"Change Capture Type: Camera");
//            self.captureType = CAPTURE_TYPE_CAMERA;
//            self.statusLabel.hidden = YES;
//            break;
//        }
//        case 1: {
//            NSLog(@"Change Capture Type: Video");
//            self.captureType = CAPTURE_TYPE_VIDEO;
//            self.statusLabel.hidden = NO;
//            break;
//        }
//        default: {
//            break;
//        }
//    }
//}



// グリッド呼び出し
- (void) lineGridAction:(id)sender
{
    DLog(@"PostView lineGridAction");
    if(self.lineBtn.selected){
        // grid clear
        [UIView animateWithDuration:0.8f animations:^{
            self.gridView.alpha = 0.8f;
            self.gridView.alpha = 0.0f;
        }completion:^(BOOL finished) {
            self.gridView.hidden = YES;
        }];
        [self.lineBtn setBackgroundImage:[UIImage imageNamed:@"btn_grid.png"] forState:UIControlStateNormal];
        [self.lineBtn setSelected:NO];
        

    }else{
        // grid on
        self.gridView.hidden = NO;
        [UIView animateWithDuration:0.8f animations:^{
            self.gridView.alpha = 0.0f;
            self.gridView.alpha = 0.8f;
        }];
        [self.lineBtn setBackgroundImage:[UIImage imageNamed:@"btn_grid-on.png"] forState:UIControlStateNormal];
        [self.lineBtn setSelected:YES];
        
    }
}

// カメラ反転
- (void) reverseAction:(id)sender
{
    DLog(@"PostView reverseAction");
    
    //[self.captureManager cameraToggleButtonPressed];
    [self.cameraManager flipCamera];
}

// フラッシュ操作
- (void) flashAction:(id)sender
{
    DLog(@"PostView flashAction");
    if(self.flashBtn.selected){
        [self.flashBtn setBackgroundImage:[UIImage imageNamed:@"btn_flash.png"] forState:UIControlStateNormal];
        [self.flashBtn setSelected:NO];
        
        //[self.captureManager setFlashMode:BDYFlashModeOff];
        
    }else{
        [self.flashBtn setBackgroundImage:[UIImage imageNamed:@"btn_flash-on.png"] forState:UIControlStateNormal];
        [self.flashBtn setSelected:YES];
        
        //[self.captureManager setFlashMode:BDYFlashModeOn];
    }
    
    [self.cameraManager lightToggle];
}

- (void) recAction:(id)sender
{
    DLog(@"PostView recAction");
    
    // 二重タップ防止
    [self.recBtn setEnabled:NO];
    
    // 撮影
    //[self.captureManager takePhoto];

    // カメラ
    if (self.captureType == CAPTURE_TYPE_CAMERA) {
        [_cameraManager takePhoto:^(UIImage *image, NSError *error){
            
            // 480 640
            
            DLog(@"image width : %f", image.size.width);
            DLog(@"image height : %f", image.size.height);
            
            CGSize ciSize;
            
            if(image.size.width > image.size.height){
                // 横向き撮影時
                CGFloat ratio = [[UIScreen mainScreen]bounds].size.width / image.size.width;
                CGFloat targetHeight = image.size.height * ratio;
                ciSize = CGSizeMake([[UIScreen mainScreen]bounds].size.width,
                                       targetHeight);
                
            }else{
                // 縦向き撮影時
                ciSize = CGSizeMake([[UIScreen mainScreen]bounds].size.width,
                                       [[UIScreen mainScreen]bounds].size.height - (120.0f + 64.0f));
            }
            
            [CoreImageHelper centerCroppingImageWithImage:image atSize:ciSize completion:^(UIImage *resultImg){
                
                DLog(@"resultImge width : %f", resultImg.size.width);
                DLog(@"resultImge height : %f", resultImg.size.height);
                
                // SEND REPRO EVENT
                [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[TOOKAPHOTO]
                                     properties:nil];
                
                self.cameraImageView.image = resultImg;
                self.cameraImage = resultImg;
                //[self saveCaptureFile:image];
                [self postEffectActionImage:(UIImage *)resultImg];
            }];
            
        }];

    }
    // 動画
//    else if (self.captureType == CAPTURE_TYPE_VIDEO) {
//        // 撮影開始
//        if (!self.cameraManager.isRecording) {
//            startTime = [[NSDate date] timeIntervalSince1970];
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
//                                                          target:self
//                                                        selector:@selector(timerHandler:)
//                                                        userInfo:nil
//                                                         repeats:YES];
//            
//            [self.cameraManager startRecording];
//            [self.recBtn setImage:self.recStopImage
//                         forState:UIControlStateNormal];
//            AudioServicesPlaySystemSound(1117); // 録画の開始音
//        }
//        // 撮影終了
//        else {
//            isNeededToSave = YES;
//            
//            [self.timer invalidate];
//            self.timer = nil;
//            self.statusLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", 0, 0, 0];
//            self.title = [NSString stringWithFormat:@"%02d:%02d:%02d", 0, 0, 0];
//            
//            [self.cameraManager stopRecording];
//            [self.recBtn setImage:self.recStartImage
//                         forState:UIControlStateNormal];
//            AudioServicesPlaySystemSound(1118); // 録画の停止音
//        }
//    }
    
    
}

// ライブラリから呼び出し
- (void) librarySelectAction:(id)sender
{
    DLog(@"PostView librarySelectAction");
    
//    PostLibCollectionViewController *postLibCollectionViewController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"PostLibCollectionViewController"];
//    
//    postLibCollectionViewController.postViewController = self;
//    self.navigationController.navigationBarHidden = NO;
//    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @" ";
//    backItem.tintColor = [UIColor whiteColor];
//    self.navigationItem.backBarButtonItem = backItem;
//    self.navigationController.navigationItem.backBarButtonItem = backItem;
//    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.backgroundColor = HEADER_BG_COLOR;
//    
//    //[self.navigationController pushViewController: postLibCollectionViewController animated:YES];
//    CATransition* transition = [CATransition animation];
//    transition.duration = 0.4;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    transition.type = kCATransitionReveal;
//    transition.subtype = kCATransitionFromTop;  // kCATransitionFromLeft kCATransitionFromTop
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//    [self.navigationController pushViewController:postLibCollectionViewController animated:YES];
    
    
    // ライブラリ起動
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        //[imagePickerController setAllowsEditing:YES];
        imagePickerController.allowsEditing = NO;
        imagePickerController.delegate = self;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
    }
}

// ImagePicker 画像選択時
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // カメラライブラリ画面を閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //画像が選択されたとき。オリジナル画像をUIImageViewに突っ込む
    UIImage *origImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    //UIImage *origImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];

    if (origImage) {
        
        float imageW = origImage.size.width;
        float imageH = origImage.size.height;
        
        float imgRatioW = imageW / imageH;
        float imgRatioH = imageH / imageW;
        DLog(@"imgRatioW : %f", imgRatioW);
        DLog(@"imgRatioH : %f", imgRatioH);
        
        // 比率がおかしい画像の場合は、アラートを表示し、フィルタ画面への遷移不可とする
        if(imgRatioW < 0.5f || imgRatioH < 0.5f){
            // system error
            
            UIAlertView *alert = [[UIAlertView alloc]init];
            alert = [[UIAlertView alloc]
                     initWithTitle:NSLocalizedString(@"ValidateLoadingImgInvalid", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
        }else{
        
//            float scale = self.cameraImageView.frame.size.width / imageW;
//            CGSize resizedSize = CGSizeMake(imageW * scale, imageH * scale);
//            UIGraphicsBeginImageContext(resizedSize);
//            
//            // UIImagePickerControllerOriginalImageだと大きすぎるのでリサイズ
//            [origImage drawInRect:CGRectMake(0, self.cameraImageView.frame.origin.y, resizedSize.width, resizedSize.height)];
//            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            self.cameraImageView.image = resizedImage;
//
//            self.cameraImageView.frame = CGRectMake(0, self.cameraImageView.frame.origin.y, resizedSize.width, resizedSize.height);
            
            //[self.cameraImageView setImage:origImage];
            // 次の画面へ
            //self.nextBtn.hidden = NO;
        
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @" ";
            self.navigationItem.backBarButtonItem = backItem;
            self.navigationController.navigationItem.backBarButtonItem = backItem;
            [self.navigationController setNavigationBarHidden:YES animated:NO];
            
//            PostEffectViewController *postEffectViewController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"PostEffectViewController"];
////            postEffectViewController = [postEffectViewController initWithPostImage: origImage];
//            postEffectViewController = [postEffectViewController initWithPostImage: resizedImage];
//
//            postEffectViewController.postViewController = self;
//            self.navigationItem.backBarButtonItem.title = @"";
//            [self.navigationController pushViewController:postEffectViewController animated:YES];
        
            CGFloat ratio = [[UIScreen mainScreen]bounds].size.width / imageW;
            CGFloat targetHeight = imageH * ratio;
            CGSize ciSize = CGSizeMake([[UIScreen mainScreen]bounds].size.width,
                                targetHeight);
            
            [CoreImageHelper centerCroppingImageWithImage:origImage atSize:ciSize completion:^(UIImage *resizedImage){
                
                // SEND REPRO EVENT
                [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[SELECTEDFROMLIBRARY]
                                     properties:nil];
                
                self.cameraImageView.image = resizedImage;
                self.cameraImage = resizedImage;
                
                [self postEffectActionImage:(UIImage *)resizedImage];
                
            }];
            
            
        }
        
    }
    
}

- (void)postEffectActionImage:(UIImage *)image
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationController.navigationItem.backBarButtonItem = backItem;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    PostEffectViewController *postEffectViewController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"PostEffectViewController"];
    postEffectViewController = [postEffectViewController initWithPostImage: image];
    postEffectViewController.postViewController = self;
    self.navigationItem.backBarButtonItem.title = @"";
    //[self.navigationController pushViewController:postEffectViewController animated:YES];
    [self.navigationController pushViewController: postEffectViewController animated:YES];
}


// ImagePicker キャンセル時
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //cancelのとき。なにもしないで閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}


// 撮影画面閉じる
- (void)closeAction:(id)sender
{
    DLog(@"PostView closeAction");
    
    // flash状態を保持してしまうようなので、リセット
    if(self.flashBtn.selected){
        [self.cameraManager lightToggle];
    }
    
    // 撮影画像がある場合には、アラート確認 -> no action

    [self dismissViewControllerAnimated:YES completion:^{
        // 動画投稿画面を閉じる際の処理
    }];
    
}

// 撮影編集画面へ delete
//- (void) nextRecEffectAction:(id)sender
//{
//    DLog(@"PostView nextRecEffectAction");
//}


// 動画撮影機能をもっているかチェック
- (BOOL) videoRecordingAvailable
{
    // The source type must be available
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return NO;
    
    // And the media type must include the movie type
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    return  [mediaTypes containsObject:(NSString *)kUTTypeMovie];
}


// ヘルプアクション
- (void) handleHelpButtonTapped:(id)sender {
    if(isHelpOpen == YES){
        // ヘルプ閉じる
        [UIView animateWithDuration:1.0f
                         animations:^{
                             //helpView.alpha = 0.0f;
                         }
                         completion:^(BOOL done){
                             // 非表示後の処理
                         }];
        isHelpOpen = NO;
    }else{
        // ヘルプ開く
        [UIView animateWithDuration:1.0f
                         animations:^{
                             //helpView.alpha = 0.8f;
                         }
                         completion:^(BOOL done){
                             // 表示後の処理
                         }];
        
        isHelpOpen = YES;
    }
}

- (void)noVideoCancelButtonPushed {
    // 動画投稿画面自体を落とす
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

// =============================================================================
#pragma mark - AVCaptureManagerDeleagte

//- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error {
//    
//    if (error) {
//        DLog(@"error:%@", error);
//        return;
//    }
//    
//    if (!isNeededToSave) {
//        return;
//    }
//    
//    //[self saveRecordedFile:outputFileURL];
//}


#pragma -
#pragma mark - フォーカス位置指定など

- (void)setPoint:(CGPoint)p {
    CGSize viewSize = self.view.bounds.size;
    CGPoint pointOfInterest = CGPointMake(p.y / viewSize.height,
                                          1.0 - p.x / viewSize.width);
    
    AVCaptureDevice* videoCaptureDevice = self.cameraManager.backCameraDevice;
    NSError* error = nil;
    if ([videoCaptureDevice lockForConfiguration:&error]) {
        // フォーカスの場合は、この値を focusPointOfInterest へ渡し、focusMode を設定すれば良い
        if ([videoCaptureDevice isFocusPointOfInterestSupported] &&
            [videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            videoCaptureDevice.focusPointOfInterest = pointOfInterest;
            videoCaptureDevice.focusMode = AVCaptureFocusModeAutoFocus;
        }
        
        // 露出の方は、exposurePointOfInterest 渡すだけでは駄目で、もう少し手間が必要
        if ([videoCaptureDevice isExposurePointOfInterestSupported] &&
            [videoCaptureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
            self.adjustingExposure = YES;
            videoCaptureDevice.exposurePointOfInterest = pointOfInterest;
            videoCaptureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        [videoCaptureDevice unlockForConfiguration];
    }
    else {
        DLog(@"%s|[ERROR] %@", __PRETTY_FUNCTION__, error);
    }
}

// 監視を設定しておき値が変化したら処理をする
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if (!self.adjustingExposure) {
        return;
    }
    
    if ([keyPath isEqual:@"adjustingExposure"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == NO) {
            self.adjustingExposure = NO;
            AVCaptureDevice* videoCaptureDevice = _cameraManager.backCameraDevice;
            NSError *error = nil;
            if ([videoCaptureDevice lockForConfiguration:&error]) {
                DLog(@"%s|%@", __PRETTY_FUNCTION__, @"locked!");
                [videoCaptureDevice setExposureMode:AVCaptureExposureModeLocked];
                [videoCaptureDevice unlockForConfiguration];
            }
        }
    }
}

// タップを検知
- (void)didTapGesture:(UITapGestureRecognizer*)tgr {
    CGPoint p = [tgr locationInView:tgr.view];
    //NSLog(@"*** x:%f y:%f", p.x, p.y);
    
    // プレビュー画面の範囲内の場合のみ移動する処理をする
    //if (p.x > 320 || p.y < 60 || p.y > 410) {
    if (p.x > 320 || p.y < 60 || p.y > 355) {
        
        return;
    }
    self.indicatorLayer.hidden = NO;
    
    // フォーカスポイント移動
    self.indicatorLayer.frame = CGRectMake(p.x - INDICATOR_RECT_SIZE/2.0,
                                           p.y - INDICATOR_RECT_SIZE/2.0,
                                           INDICATOR_RECT_SIZE,
                                           INDICATOR_RECT_SIZE);
    double delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //done 0.4 seconds after.
        self.indicatorLayer.hidden = YES;
        [self setPoint:p];
    });
}


#pragma -
#pragma mark - Timer Handler

// 録画時間を表示
//- (void)timerHandler:(NSTimer *)timer {
//    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
//    int recorded = current - startTime;
//    int s = recorded % 60;
//    int m = (recorded - s) / 60 % 60;
//    int h = (recorded - s - m * 60) / 3600 % 3600;
//    self.statusLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
//    self.title = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s]; // TODO:
//}


#pragma -
#pragma mark - Save function

// 静止画を保存する
- (void)saveCaptureFile:(UIImage*)captureImage {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:self.cameraImageView.image.CGImage
                              orientation:(ALAssetOrientation)captureImage.imageOrientation // 明示的に
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              DLog(@"saved");
                          }];
}

// 動画を保存する
//- (void)saveRecordedFile:(NSURL *)recordedFile {
//    //    [SVProgressHUD showWithStatus:@"Saving..."
//    //                         maskType:SVProgressHUDMaskTypeGradient];
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
//        [assetLibrary writeVideoAtPathToSavedPhotosAlbum:recordedFile
//                                         completionBlock:
//         ^(NSURL *assetURL, NSError *error) {
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 //[SVProgressHUD dismiss];
//                 
//                 NSString *title;
//                 NSString *message;
//                 
//                 if (error != nil) {
//                     title = @"Failed to save video";
//                     message = [error localizedDescription];
//                 }
//                 else {
//                     title = @"Saved!";
//                     message = nil;
//                 }
//                 
//                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                                 message:message
//                                                                delegate:nil
//                                                       cancelButtonTitle:@"OK"
//                                                       otherButtonTitles:nil];
//                 [alert show];
//             });
//         }];
//    });
//}


#pragma -
#pragma mark - CameraManagerDelegate

//- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error {
//    NSLog(@"didFinishRecordingToOutputFileAtURL");
//    if (error) {
//        NSLog(@"error:%@", error);
//        return;
//    }
//    
//    if (!isNeededToSave) {
//        return;
//    }
//    
//    [self saveRecordedFile:outputFileURL];
//}


// リアルタイムにエフェクトかける場合に利用
//-(void)videoFrameUpdate:(CGImageRef)cgImage from:(CameraManager*)captureManager {
//UIImage* imageRotate = [CameraManager rotateImage:[UIImage imageWithCGImage:cgImage] angle:270];
//   if(captureManager.isUsingFrontCamera)
//       imageRotate = [self mirrorImage:imageRotate];
//_previewView.image = imageRotate;
//}

- (BOOL)checkPermissionOfCamera {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    //機能制限 or 拒否
    if((authStatus == AVAuthorizationStatusRestricted) || (authStatus == AVAuthorizationStatusDenied)) {
        // @"カメラへのアクセスが未許可です。\n設定 > プライバシー > でカメラを許可してください。";

//        UIAlertView *alert = [[UIAlertView alloc]init];
//        alert = [[UIAlertView alloc]
//                 initWithTitle:NSLocalizedString(@"CameraPermitError", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//        [alert show];
        
        return false;
        
    }
    //未選択
    else if(authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(!granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //許可されなかった
                    //@"カメラへのアクセスが未許可です。\n設定 > プライバシー > でカメラを許可してください。";
//                    UIAlertView *alert = [[UIAlertView alloc]init];
//                    alert = [[UIAlertView alloc]
//                             initWithTitle:NSLocalizedString(@"CameraPermitError", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
//                    [alert show];
                    
                    if(!self.isFirstCameraPermit){
                    
                        self.isFirstCameraPermit = YES;
                        self.recBtn.enabled     = NO;
                        self.libBtn.enabled     = NO;
                        self.lineBtn.enabled    = NO;
                        self.reverseBtn.enabled = NO;
                        self.flashBtn.enabled   = NO;
                    
                        UIAlertView *alert = [[UIAlertView alloc] init];
                        alert.delegate = self;
                        alert.title = @"";
                        alert.message = NSLocalizedString(@"CameraPermitError", nil);
                        [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
                        [alert show];

                        //self.isNoCameraPermit = YES;
                    }

                });
            }
            
        }];
    }
    return true;
}


@end
