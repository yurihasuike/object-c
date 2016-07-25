//
//  KZCameraView.h
//  VideoRecorder
//
//  Created by Kseniya Kalyuk Zito on 10/21/13.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import <UIKit/UIKit.h>

@class CaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@protocol SelectImagePickerDelegate
@optional
- (void)selectImagePicker;
@end

@interface KZCameraView : UIView <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) float maxDuration;
@property (nonatomic, assign) BOOL showCameraSwitch;
@property (nonatomic, strong) NSURL *outPutURL;
@property (nonatomic, assign) id <SelectImagePickerDelegate> delegate;

//Recording progress
@property (nonatomic,assign) float duration;
@property (nonatomic,strong) NSTimer *durationTimer;
@property (nonatomic,strong) UIProgressView *durationProgressBar;

//Exporting progress
@property (nonatomic,strong) UIView *progressView;
@property (nonatomic,strong) UIProgressView *progressBar;
@property (nonatomic,strong) UILabel *progressLabel;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;

//Delete last piece
@property (nonatomic,strong) UIButton *deleteLastBtn;

- (id)initWithFrame:(CGRect)frame withVideoPreviewFrame:(CGRect)videoFrame;
- (void)saveVideoWithCompletionBlock:(void(^)(BOOL success))completion;
-(void)cancell;

@end