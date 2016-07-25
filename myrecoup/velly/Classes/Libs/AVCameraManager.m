//
//  CameraManager.m
//  CameraApps
//
//  Created by Yuki ANAI on 5/1/14.
//  Copyright (c) 2014 Yuki ANAI. All rights reserved.
//
#import "AVCameraManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import <ImageIO/ImageIO.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, SCFlashMode) {
    SCFlashModeOff  = AVCaptureFlashModeOff,
    SCFlashModeOn   = AVCaptureFlashModeOn,
    SCFlashModeAuto = AVCaptureFlashModeAuto,
    SCFlashModeLight
};

@implementation AVCameraManager

#pragma -
#pragma mark - 初期化

// デフォルト初期化
-(id)init {
    if (super.init) {
        // AVCaptureSessionPresetHigh
        // AVCaptureSessionPresetPhoto
        // AVCaptureSessionPreset640x480
        // AVCaptureSessionPreset1280x720
        // AVCaptureSessionPresetInputPriority
        //[self setupAVCapture:AVCaptureSessionPreset1920x1080];        // 全面カメラが対応していない・・・
        [self setupAVCapture:AVCaptureSessionPreset640x480];
        
        return self;
    }
    return nil;
}

// 解像度指定して初期化
-(id)initWithPreset:(NSString*)preset {
    if (super.init) {
        [self setupAVCapture:preset];
        return self;
    }
    return nil;
}

// プレビューレイヤをビューに設定する
-(void)setPreview:(UIView*)view{
    //_previewLayer.frame = view.bounds;
    //[self.previewLayer setFrame:view.bounds];
    [self.previewLayer setFrame:CGRectMake(0,
                                             0.0f,
                                             [[UIScreen mainScreen]bounds].size.width,
                                             [[UIScreen mainScreen]bounds].size.height - (120.0f + 64.0f))];
    [view.layer addSublayer:_previewLayer];
}

// presetで解像度を指定，セッションの作成を行う
- (void)setupAVCapture:(NSString*)preset {
    // カメラの一覧を取得しカメラデバイスを保存
    self.backCameraDevice = nil;
    self.frontCameraDevice = nil;
    NSArray*    cameraArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *camera in cameraArray){
        if(camera.position == AVCaptureDevicePositionBack) {
            self.backCameraDevice = camera;
        }
        if(camera.position == AVCaptureDevicePositionFront) {
            self.frontCameraDevice = camera;
        }
    }
    // デフォルトはバックカメラ
    videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.backCameraDevice error:nil];
    
    // フォーマット設定
    self.defaultFormat = videoInput.device.activeFormat;
    defaultVideoMaxFrameDuration = videoInput.device.activeVideoMaxFrameDuration;
    
    // キャプチャセッションの作成
    captureSession = [[AVCaptureSession alloc] init];
    captureSession.sessionPreset = preset;
    [captureSession addInput:videoInput];
    
    // 出力設定
    self.fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [captureSession addOutput:self.fileOutput];
    
    // プレビュー設定
  	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
	[self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];    // AVLayerVideoGravityResizeAspectFill AVLayerVideoGravityResizeAspect
    
    DLog(@"preview frame x : %f", self.previewLayer.bounds.origin.x);
    DLog(@"preview frame y : %f", self.previewLayer.bounds.origin.y);
    DLog(@"preview frame width : %f", self.previewLayer.bounds.size.width);
    DLog(@"preview frame height : %f", self.previewLayer.bounds.size.height);
    
    // 各初期化を行う
    [self setupImageCapture];
    [self setupVideoCapture];
    
    // セッション開始
    [captureSession startRunning];
}

// 静止画キャプチャの初期化
// 設定後:captureOutputが呼ばれる
-(BOOL)setupImageCapture {
    imageOutput = AVCaptureStillImageOutput.new;
    if(imageOutput){
        if([captureSession canAddOutput:imageOutput]){
            [captureSession addOutput:imageOutput];
            return YES;
        }
    }
    return NO;
}

// ビデオキャプチャの初期化
// 設定後:captureOutputが呼ばれる
-(BOOL)setupVideoCapture {
    // ビデオ出力デバイスの設定
	NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)};
    videoOutput = AVCaptureVideoDataOutput.new;
	[videoOutput setVideoSettings:rgbOutputSettings];
	[videoOutput setAlwaysDiscardsLateVideoFrames:YES];     //  NOだとコマ落ちしないが重い処理には向かない
  	videoOutputQueue = dispatch_queue_create("VideoData Output Queue", DISPATCH_QUEUE_SERIAL);
	[videoOutput setSampleBufferDelegate:self queue:videoOutputQueue];
    
	if (videoOutput) {
        if ([captureSession canAddOutput:videoOutput]) {
            [captureSession addOutput:videoOutput];
            return YES;
        }
    }
    return NO;
}

// オーディオキャプチャの初期化
// 設定後:captureOutputが呼ばれる
-(BOOL)setupAudioCapture {
    audioOutput = AVCaptureAudioDataOutput.new;
    audioOutputQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
	[audioOutput setSampleBufferDelegate:self queue:audioOutputQueue];
    if (audioOutput) {
        if ([captureSession canAddOutput:audioOutput]) {
            [captureSession addOutput:audioOutput];
            return YES;
        }
    }
    return NO;
}

#pragma -
#pragma mark - カメラ切り替え

// カメラを選択: YESの場合フロントを利用，NOの場合はバックを利用
-(void)useFrontCamera:(BOOL)selectFront {
    if (selectFront == YES) {
        [self enableCamera:AVCaptureDevicePositionFront];
    }
    else {
        [self enableCamera:AVCaptureDevicePositionBack];
    }
    
}

// カメラをトグル
-(void)flipCamera {
    if(self.isUsingFrontCamera) {
        [self useFrontCamera:NO];
    }
    else {
        [self useFrontCamera:YES];
    }
}

// カメラを有効化する
-(void)enableCamera:(AVCaptureDevicePosition)desiredPosition {
    [captureSession stopRunning];
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [captureSession beginConfiguration];
            videoInput= [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in [[_previewLayer session] inputs]) {
                [captureSession removeInput:oldInput];
            }
            [captureSession addInput:videoInput];
            [captureSession commitConfiguration];
            break;
        }
    }
    [captureSession startRunning];
}

// フロントカメラを使っているか
-(BOOL)isUsingFrontCamera {
    if(videoInput.device.position == AVCaptureDevicePositionFront) {
        return YES;
    }
    return NO;
}

#pragma -
#pragma mark - ライト制御

// ライトを選択: YESの場合ON
-(void)light:(BOOL)yesno {
    if(![_backCameraDevice hasTorch]) {
        return;
    }
    
    // フロントカメラ使用中ならバックカメラに切り替え
    if(self.isUsingFrontCamera) {
        [self useFrontCamera:NO];
    }
    
    NSError* error;
    [_backCameraDevice lockForConfiguration:&error];
    
    // SCFlashModeLight
//    if(yesno == YES) {
//        _backCameraDevice.torchMode = AVCaptureTorchModeOn;
//    }
//    else {
//        _backCameraDevice.torchMode = AVCaptureTorchModeOff;
//    }
    
    if(yesno == YES) {
        //_backCameraDevice.torchMode = AVCaptureTorchModeOn;
        [_backCameraDevice setFlashMode:(AVCaptureFlashMode)SCFlashModeOn];
    }
    else {
        //_backCameraDevice.torchMode = AVCaptureTorchModeOff;
        //[_backCameraDevice setFlashMode:AVCaptureFlashModeOff];
        [_backCameraDevice setFlashMode:(AVCaptureFlashMode)SCFlashModeOff];
    }

    [_backCameraDevice unlockForConfiguration];
}

// ライトをトグル
-(void)lightToggle {
    if(self.isLightOn) {
        [self light:NO];
    }
    else {
        [self light:YES];
    }
}

// ライトがついてるか
-(BOOL)isLightOn {
//    if(![_backCameraDevice hasTorch]) {
//        return NO;
//    }
//    if(_backCameraDevice.isTorchActive) {
//        return YES;
//    }
    
    if(_backCameraDevice.isFlashActive){
        return YES;
    }else{
        return NO;
    }
    
    return NO;
}

#pragma -
#pragma mark - フォーカス制御

-(void)autoFocusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = videoInput.device;
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        }    }
}

-(void)continuousFocusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = videoInput.device;
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		}
	}
}

#pragma -
#pragma mark - 撮影

// 写真撮影
-(void)takePhoto:(takePhotoBlock) block {
    AVCaptureConnection* connection = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // 画像の向きを調整する
    if (connection.isVideoOrientationSupported) {
        // 明示的に
        connection.videoOrientation = (AVCaptureVideoOrientation)[[UIDevice currentDevice] orientation];
    }
    
    // UIImage化した画像を通知する
    [imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                 if(imageDataSampleBuffer == nil){
                                                     block(nil,error);
                                                     return;
                                                 }
                                                 
                                                 // jpg
                                                 NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                 UIImage *image = [UIImage imageWithData:data];
                                                 CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
                                                 
                                                 //メタ情報の取得
                                                 NSDictionary *meta = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
                                                 NSMutableDictionary *mutableMeta = [meta mutableCopy];

                                                 DLog(@"%@", mutableMeta);
                                                 DLog(@"Orientaiton %@", mutableMeta[@"Orientation"]);
                                                 
                                                 DLog(@"orietaiton : %@", [mutableMeta objectForKey:(NSString *)kCGImagePropertyOrientation]);
                                                 NSNumber *orientation = (NSNumber *)[mutableMeta objectForKey:(NSString *)kCGImagePropertyOrientation];
                                                 
                                                 if([orientation isEqualToNumber:[NSNumber numberWithInt:UIImageOrientationUp]]){
                                                     // そのまま    Orientation:1   ホームボタン右向きで撮影
                                                     [mutableMeta setObject:[NSNumber numberWithInt:kCGImagePropertyOrientationUp] forKey:(NSString *)kCGImagePropertyOrientation];
                                                     
                                                 }else if([orientation isEqualToNumber:[NSNumber numberWithInt:kCGImagePropertyOrientationDown]]){
                                                     // 180度回転  Orientation:3   ホームボタン左向きで撮影
                                                     [mutableMeta setObject:[NSNumber numberWithInt:kCGImagePropertyOrientationUp] forKey:(NSString *)kCGImagePropertyOrientation];
                                                 
                                                 }else if([orientation isEqualToNumber:[NSNumber numberWithInt:kCGImagePropertyOrientationRight]]){
                                                     // 時計回りに90度    Orientation:6   普通の向き（ホームボタン下）
                                                     [mutableMeta setObject:[NSNumber numberWithInt:kCGImagePropertyOrientationUp] forKey:(NSString *)kCGImagePropertyOrientation];
                                                     
                                                 }else if([orientation isEqualToNumber:[NSNumber numberWithInt:kCGImagePropertyOrientationLeft]]){
                                                     // 時計回りに270度   Orientation:8   反対（ホームボタン上）
                                                     [mutableMeta setObject:[NSNumber numberWithInt:kCGImagePropertyOrientationUp] forKey:(NSString *)kCGImagePropertyOrientation];
                                                     
                                                 }
                                                 
                                                 NSMutableData *dataDest = [NSMutableData data];
                                                 CGImageDestinationRef dest;
                                                 dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dataDest,
                                                                                         (__bridge CFStringRef)(NSString *)kUTTypeJPEG,
                                                                                         1,
                                                                                         NULL);
                                                 CGImageDestinationAddImage(dest, image.CGImage, (__bridge CFDictionaryRef)mutableMeta);
                                                 BOOL ret = CGImageDestinationFinalize(dest);
                                                 if(ret) {
//                                                     ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
//                                                     [lib writeImageDataToSavedPhotosAlbum:dataDest
//                                                                                  metadata:mutableMeta
//                                                                           completionBlock:^(NSURL *assetURL, NSError *error) {
//                                                                           }];
                                                 }else{
                                                     DLog(@"save error");
                                                 }
                                                 CFRelease(dest);
                                                 
                                                 
                                                 image = [[UIImage alloc] initWithData:dataDest];
                                                 image = [UIImage imageWithCGImage:image.CGImage
                                                                             scale:image.scale
                                                                       orientation:UIImageOrientationUp];
                                                 
                                                 if([orientation isEqualToNumber:[NSNumber numberWithInt:kCGImagePropertyOrientationUp]]){
                                                     // そのまま    Orientation:1   ホームボタン右向きで撮影
                                                     //image = [AVCameraManager rotateImage:image angle:270];
                                                     // 横を縦に自動にしたい時
                                                     // 何もしない
                                                     
                                                 }else if([orientation isEqualToNumber:[NSNumber numberWithInt:kCGImagePropertyOrientationDown]]){
                                                     // 180度回転  Orientation:3   ホームボタン左向きで撮影
                                                     //image = [AVCameraManager rotateImage:image angle:270];
                                                     // 横を縦に自動にしたい時
                                                     image = [AVCameraManager rotateImage:image angle:180];
                                                     
                                                 }else if([orientation isEqualToNumber:[NSNumber numberWithInt:kCGImagePropertyOrientationRight]]){
                                                     // 時計回りに90度    Orientation:6   普通の向き（ホームボタン下）
                                                     image = [AVCameraManager rotateImage:image angle:270];
                                                     
                                                 }else if([orientation isEqualToNumber:[NSNumber numberWithInt:kCGImagePropertyOrientationLeft]]){
                                                     // 時計回りに270度   Orientation:8   反対（ホームボタン上）
                                                     image = [AVCameraManager rotateImage:image angle:90];
                                                     
                                                 }

                                                 //NSDictionary *metadata = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
                                                 
                                                 //GPS Dictionary
                                                 //NSDictionary *GPSDictionary02 = [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
                                                 
                                                 
//                                                 CFStringRef UTI = CGImageSourceGetType(source);
//                                                 NSMutableData *dest_data = [NSMutableData data];
//                                                 CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
//                                                 if(!destination) {
//                                                     DLog(@"***Could not create image destination ***");
//                                                 }
//                                                 //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
//                                                 CGImageDestinationAddImageFromSource(destination,source,0, (CFDictionaryRef) mutableMeta);
//                                                 BOOL success = NO;
//                                                 success = CGImageDestinationFinalize(destination);
//                                                 if(!success) {
//                                                     NSLog(@"***Could not create data from image destination ***");
//                                                 }
//                                                 //[dest_data writeToFile:file atomically:YES];
//                                                 // cleanup
//                                                 CFRelease(destination);
                                                 
                                                 
                                                 CFRelease(source);
                                                 
                                                 
                                                 block(image,error);
                                             }
     ];
}

// 録画開始
- (void)startRecording {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString* dateTimePrefix = [formatter stringFromDate:[NSDate date]];
    
    int fileNamePostfix = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = nil;
    do {
        filePath =[NSString stringWithFormat:@"/%@/%@-%i.mp4", documentsDirectory, dateTimePrefix, fileNamePostfix++];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    
    NSURL *fileURL = [NSURL URLWithString:[@"file://" stringByAppendingString:filePath]];
    [self.fileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

// 録画終了
- (void)stopRecording {
    [self.fileOutput stopRecording];
}

// 静止画取得
// TODO: not working, didOutputSampleBufferのとこに処理が飛んでないのが原因
-(UIImage*)takeCapture {
    if(self.videoImage == nil) {
        return nil;
    }
    
    UIImage* image = nil;
    UIDeviceOrientation orientation = _videoOrientaion;
    if (orientation == UIDeviceOrientationPortrait) {
        image = [AVCameraManager rotateImage:self.videoImage angle:270];
    }
    else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        image = [AVCameraManager rotateImage:self.videoImage angle:90];
    }
    else if (orientation == UIDeviceOrientationLandscapeRight) {
        image = self.videoImage;
    }
    else {
        image = self.videoImage;
    }
    return image;
}

#pragma -
#pragma mark - Utility

- (NSUInteger) cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *) frontFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *) backFacingCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *) audioDevice {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0) {
        return [devices objectAtIndex:0];
    }
    return nil;
}

#pragma -
#pragma mark - Util Functions

// SampleBufferをCGImageRefに変換する
+ (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // バッファをロック
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);      // バッファをアンロック
    
    return newImage;
}

// 画像を回転
+ (UIImage*)rotateImage:(UIImage*)img angle:(int)angle {
    CGImageRef      imgRef = [img CGImage];
    CGContextRef    context;
    
    switch (angle) {
        case 90:
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.height, img.size.width), YES, img.scale);
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.height, img.size.width);
            CGContextScaleCTM(context, 1, -1);
            CGContextRotateCTM(context, M_PI_2);
            break;
        case 180:
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.width, img.size.height), YES, img.scale);
            context = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(context, img.size.width, 0);
            CGContextScaleCTM(context, 1, -1);
            CGContextRotateCTM(context, -M_PI);
            break;
        case 270:
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(img.size.height, img.size.width), YES, img.scale);
            context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, 1, -1);
            CGContextRotateCTM(context, -M_PI_2);
            break;
        default:
            return img;
            break;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), imgRef);
    UIImage*    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

#pragma -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

// TODO: ここまで処理が飛ばない原因探る，一旦動くから良いけど
// ビデオキャプチャ時、 新しいフレームが書き込まれた際に通知を受けるデリゲートメソッド
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"didOutputSampleBuffer");
    @autoreleasepool {
        // キャプチャ画像からUIImageを作成する
        CGImageRef cgImage = [AVCameraManager imageFromSampleBuffer:sampleBuffer];
        UIImage* captureImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        // メインスレッドでの処理
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.videoImage = captureImage;
            self.videoOrientaion = UIDevice.currentDevice.orientation;
            
            // デリゲートの存在確認後画面更新
            //if ([self.delegate respondsToSelector:@selector(videoFrameUpdate:from:)]) {
            //    [self.delegate videoFrameUpdate:self.videoImage.CGImage from:self];
            //}
        });
    }
}

#pragma -
#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void) captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
       fromConnections:(NSArray *)connections {
    _isRecording = YES;
}

- (void) captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
       fromConnections:(NSArray *)connections error:(NSError *)error {
    _isRecording = NO;
    
//    if ([self.delegate respondsToSelector:@selector(didFinishRecordingToOutputFileAtURL:error:)]) {
//        [self.delegate didFinishRecordingToOutputFileAtURL:outputFileURL error:error];
//    }
}

@end
