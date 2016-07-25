//
//  AVCaptureManager.m
//  BDYPico
//
//  Created by m_saruwatari on 2014/11/18.
//  Copyright (c) 2014年 mamoru.saruwatari. All rights reserved.
//

#import "AVCaptureManager.h"


@interface AVCaptureManager ()
<AVCaptureFileOutputRecordingDelegate>
{
    CMTime defaultVideoMaxFrameDuration;
    AVCaptureDeviceInput *videoIn;
}
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureMovieFileOutput *fileOutput;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic, strong) AVCaptureDeviceFormat *defaultFormat;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end


@implementation AVCaptureManager

- (id)initWithPreviewView:(UIView *)previewView {
    
    self = [super init];
    
    if (self) {
        
        NSError *error;
        
        self.captureSession = [[AVCaptureSession alloc] init];
        //self.captureSession.sessionPreset = AVCaptureSessionPresetInputPriority;
        //self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;           // 480x360
        //self.captureSession.sessionPreset = AVCaptureSessionPresetLow;            // 192x144 out x

        AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error) {
            DLog(@"Video input creation failed");
            return nil;
        }
        
        if (![self.captureSession canAddInput:videoIn]) {
            DLog(@"Video input add-to-session failed");
            return nil;
        }
        [self.captureSession addInput:videoIn];
        
        
        // save the default format
        self.defaultFormat = videoDevice.activeFormat;
        defaultVideoMaxFrameDuration = videoDevice.activeVideoMaxFrameDuration;
        
        
        AVCaptureDevice *audioDevice= [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioIn = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        [self.captureSession addInput:audioIn];
        
        self.fileOutput = [[AVCaptureMovieFileOutput alloc] init];
        // 動画の長さ
        Float64 totalSeconds = 60;
        // 一秒あたりのFrame数
        int32_t preferredTimeScale = 15;
        // 動画の最大長さ
        CMTime maxDuration = CMTimeMakeWithSeconds(totalSeconds, preferredTimeScale);
        
        self.fileOutput.maxRecordedDuration = maxDuration;
        
        //self.videoOutput = [[AVCaptureVideoDataOutput alloc]init];
        // これがあやしい　size
        //self.videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        //self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
        
        [self.captureSession addOutput:self.fileOutput];
        
        
        //output
        self.videoOutput = [[AVCaptureVideoDataOutput alloc]init];
        self.videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
        [self.captureSession addOutput:self.videoOutput];
        dispatch_queue_t videoQueue = dispatch_queue_create("com.coma-tech.myQueue", NULL);
        [self.videoOutput setSampleBufferDelegate:(id)self queue:videoQueue];
        
        
        
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        self.previewLayer.frame = previewView.bounds;
        self.previewLayer.contentsGravity = kCAGravityResizeAspectFill;
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [previewView.layer insertSublayer:self.previewLayer atIndex:0];
        
        [self.captureSession startRunning];
    }
    return self;
}


// =============================================================================
#pragma mark - Public

- (void)toggleContentsGravity {
    
    if ([self.previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    else {
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

- (void)resetFormat {
    
    BOOL isRunning = self.captureSession.isRunning;
    
    if (isRunning) {
        [self.captureSession stopRunning];
    }
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [videoDevice lockForConfiguration:nil];
    videoDevice.activeFormat = self.defaultFormat;
    videoDevice.activeVideoMaxFrameDuration = defaultVideoMaxFrameDuration;
    [videoDevice unlockForConfiguration];
    
    if (isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS
{
    BOOL isRunning = self.captureSession.isRunning;
    
    if (isRunning)  [self.captureSession stopRunning];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    
    if (selectedFormat) {
        
        if ([videoDevice lockForConfiguration:nil]) {
            
            NSLog(@"selected format:%@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            // 1秒あたりX回画像をキャプチャ
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [videoDevice unlockForConfiguration];
        }
    }
    
    if (isRunning) [self.captureSession startRunning];
}

- (void)startRecording {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString* dateTimePrefix = [formatter stringFromDate:[NSDate date]];
    
    int fileNamePostfix = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = nil;
    do
        filePath =[NSString stringWithFormat:@"/%@/%@-%i.mp4", documentsDirectory, dateTimePrefix, fileNamePostfix++];
    while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    
    NSURL *fileURL = [NSURL URLWithString:[@"file://" stringByAppendingString:filePath]];
    [self.fileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

- (void)stopRecording {
    
    [self.fileOutput stopRecording];
}



// =============================================================================
#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)                 captureOutput:(AVCaptureFileOutput *)captureOutput
    didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                       fromConnections:(NSArray *)connections
{
    _isRecording = YES;
}

- (void)                 captureOutput:(AVCaptureFileOutput *)captureOutput
   didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                       fromConnections:(NSArray *)connections error:(NSError *)error
{
    //    [self saveRecordedFile:outputFileURL];
    _isRecording = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFinishRecordingToOutputFileAtURL:error:)]) {
        [self.delegate didFinishRecordingToOutputFileAtURL:outputFileURL error:error];
    }
}


// カメラ切り替えの時に必要
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position
{
    NSArray *Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *Device in Devices)
    {
        if ([Device position] == Position)
        {
            return Device;
        }
    }
    return nil;
}

// Camera切り替えアクション
- (void)cameraToggleButtonPressed
{
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1)        //Only do if device has multiple cameras
    {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[videoIn device] position];
        if (position == AVCaptureDevicePositionBack) {
            
            self.position = AVCaptureDevicePositionFront;
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionFront] error:&error];
            
        } else {
            
            self.position = AVCaptureDevicePositionBack;
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionBack] error:&error];
            
        }

        if (newVideoInput != nil)
        {
            BOOL isRunning = self.captureSession.isRunning;
            
            if (isRunning) {
                [self.captureSession stopRunning];
            }

            // TODO movie 撮影中に前後切替ができない問題
            
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:videoIn];

            if ([self.captureSession canAddInput:newVideoInput])
            {
                [self.captureSession addInput:newVideoInput];
                videoIn = newVideoInput;
            }
            else
            {
                [self.captureSession addInput:videoIn];
            }
            [self.captureSession commitConfiguration];
            
            if (isRunning) {
                [self.captureSession startRunning];
            }

        }
    }
}



- (void)setFlashMode:(BDYFlashMode)flashMode {
    AVCaptureDevice *currentDevice = [videoIn device];
    NSError *error = nil;
    
    if (currentDevice.hasFlash) {
        if ([currentDevice lockForConfiguration:&error]) {
            if (flashMode == BDYFlashModeLight) {
                if ([currentDevice isTorchModeSupported:AVCaptureTorchModeOn]) {
                    [currentDevice setTorchMode:AVCaptureTorchModeOn];
                }
                if ([currentDevice isFlashModeSupported:AVCaptureFlashModeOff]) {
                    [currentDevice setFlashMode:AVCaptureFlashModeOff];
                }
            } else {
                if ([currentDevice isTorchModeSupported:AVCaptureTorchModeOff]) {
                    [currentDevice setTorchMode:AVCaptureTorchModeOff];
                }
                if ([currentDevice isFlashModeSupported:(AVCaptureFlashMode)flashMode]) {
                    [currentDevice setFlashMode:(AVCaptureFlashMode)flashMode];
                }
            }
            [currentDevice unlockForConfiguration];
        }
    } else {
        error = [AVCaptureManager createError:@"Current device does not support flash"];
    }
    
//    id<SCRecorderDelegate> delegate = self.delegate;
//    if ([delegate respondsToSelector:@selector(recorder:didChangeFlashMode:error:)]) {
//        [delegate recorder:self didChangeFlashMode:flashMode error:error];
//    }
    
    if (error == nil) {
        _flashMode = flashMode;
    }
}

// Camera flashモード切り替えアクション
- (void)cameraFlashModeButtonPressed {

}

- (void)takePhoto {
    
    //AVCaptureDevice *currentDevice = [videoIn device];
    
//    dispatch_sync(queue, ^{
//        Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
//        if (captureDeviceClass != nil) {
//            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//            if ([device hasTorch] && [device hasFlash]){
//                [device lockForConfiguration:nil];
//                if ([currentDevice isTorchModeSupported:AVCaptureTorchModeOn]) {
//                    [device setTorchMode:AVCaptureTorchModeOn];
//                    [device setFlashMode:AVCaptureFlashModeOn];
//                } else {
//                    [device setTorchMode:AVCaptureTorchModeOff];
//                    [device setFlashMode:AVCaptureFlashModeOff];
//                }
//                [device unlockForConfiguration];
//            }
//        }
//        sleep(1);
//    });
    
}


+ (NSError*)createError:(NSString*)errorDescription {
    return [NSError errorWithDomain:@"AVCaptureManager" code:200 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
}


@end
