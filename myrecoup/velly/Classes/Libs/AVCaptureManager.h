//
//  AVCaptureManager.h
//  BDYPico
//
//  Created by m_saruwatari on 2014/11/18.
//  Copyright (c) 2014年 mamoru.saruwatari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#import <AssetsLibrary/AssetsLibrary.h>    

typedef NS_ENUM(NSInteger, BDYFlashMode) {
    BDYFlashModeOff  = AVCaptureFlashModeOff,
    BDYFlashModeOn   = AVCaptureFlashModeOn,
    BDYFlashModeAuto = AVCaptureFlashModeAuto,
    BDYFlashModeLight
};

@protocol AVCaptureManagerDelegate <NSObject>
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                                      error:(NSError *)error;
@end


@interface AVCaptureManager : NSObject {

    dispatch_queue_t queue;

}

@property (nonatomic, assign) id<AVCaptureManagerDelegate> delegate;
@property (nonatomic, assign) AVCaptureDevicePosition position;
@property (assign, nonatomic) BDYFlashMode flashMode;

@property (nonatomic, readonly) BOOL isRecording;

- (id)initWithPreviewView:(UIView *)previewView;
- (void)toggleContentsGravity;
- (void)resetFormat;
- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS;
- (void)startRecording;
- (void)stopRecording;
- (void)takePhoto;
- (void)cameraToggleButtonPressed;
- (void)cameraFlashModeButtonPressed;

- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position;

@end
