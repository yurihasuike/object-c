//
//  PostViewController.h
//  velly
//
//  Created by m_saruwatari on 2015/02/19.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AVCameraManager.h"
#import "CSFlexibleTapAreaButton.h"
#import "GridView.h"

@interface PostViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCameraManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *displayView;
@property (weak, nonatomic) IBOutlet GridView *gridView;
//@property (weak, nonatomic) GridView *gridView;
//@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *closeBtn;
@property (strong, nonatomic) UIImage *cameraImage;

@property (nonatomic) BOOL isNoCameraDevice;
@property (nonatomic) BOOL isNoCameraPermit;
@property (nonatomic) BOOL isFirstCameraPermit;

@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *lineBtn;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *reverseBtn;
@property (weak, nonatomic) IBOutlet CSFlexibleTapAreaButton *flashBtn;
@property (weak, nonatomic) IBOutlet UIButton *libBtn;
@property (weak, nonatomic) IBOutlet UIImageView *recBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *recBtn;

+ (PostViewController *) sharedInstance;

@property AVCameraManager* cameraManager;  // 動画マネージャクラス
@property uint8_t captureType;               // キャプチャの方法(0:カメラ, 1:動画)
@property (nonatomic, assign) NSTimer *timer;
//@property (nonatomic, strong) UIImage *recStartImage;
//@property (nonatomic, strong) UIImage *recStopImage;

@property (nonatomic, strong) CALayer* indicatorLayer;  // ピント合わせる用のレイヤ
@property (nonatomic) BOOL adjustingExposure;           // 露出補正用のだっけ?

//@property IBOutlet UIImageView* previewView; // 動画プレビューを配置するビュー
//@property IBOutlet UIImageView* captureview; // キャプチャ後のイメージ
//@property IBOutlet UILabel *statusLabel;     // 時間表示用ラベル
//@property IBOutlet UIButton *recBtn;         // 撮影ボタン
//@property IBOutlet UIButton *albumBtn;       //

- (void)setPoint:(CGPoint)p;

- (void)postEffectActionImage:(UIImage *)image;

@end
