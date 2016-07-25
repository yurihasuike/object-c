//
//  RecorderViewController.m
//  NewVideoRecorder
//
//  Created by Kseniya Kalyuk Zito on 10/23/13.

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

#import "RecorderViewController.h"
#import "KZCameraView.h"
#import "MovieEditViewController.h"
#import "TrackingManager.h"
#import "Defines.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface RecorderViewController ()

@property (nonatomic, strong) KZCameraView *cam;

@end

@implementation RecorderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f];
    
    if (IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //Create CameraView
	self.cam = [[KZCameraView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 64.0) withVideoPreviewFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 370.0)];
    self.cam.delegate = self;
    self.cam.maxDuration = 60.0;
    self.cam.durationProgressBar.transform = CGAffineTransformMakeScale(1.0f, 6.0f);
    self.cam.durationProgressBar.progressTintColor = HEADER_BG_COLOR;
    self.cam.durationProgressBar.trackTintColor = [UIColor whiteColor];
    self.cam.progressBar.progressTintColor = HEADER_BG_COLOR;
    self.cam.progressBar.trackTintColor = [UIColor whiteColor];
    [self.cam.deleteLastBtn setTitleColor:HEADER_BG_COLOR forState:UIControlStateNormal];
    self.cam.showCameraSwitch = YES; //Say YES to button to switch between front and back cameras
    //Create "save" button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveVideo:)];
    
    //キャンセルボタンの作成
    UIButton *leftbutton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [leftbutton setImage:[UIImage imageNamed:@"btn_cancel.png"] forState:UIControlStateNormal];
    [leftbutton addTarget:self action:@selector(dismiss)forControlEvents:UIControlEventTouchUpInside];
    [leftbutton setFrame:CGRectMake(0, 0, 53, 31)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView: leftbutton];
    self.navigationItem.leftBarButtonItem = barButton;
    
    [self.view addSubview:self.cam];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"ムービー";
    [title sizeToFit];
    self.navigationItem.titleView = title;
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.97 green:0.67 blue:0.49 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)dismiss{
    
    [self.cam cancell];
    self.cam = nil;
    [self dismissViewControllerAnimated:YES completion:nil];

}

-(IBAction)saveVideo:(id)sender
{
    [self.cam saveVideoWithCompletionBlock:^(BOOL success) {
        if (success)
        {
            // SEND REPRO EVENT
            [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[TOOKAMOVIE]
                                 properties:nil];
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Movie" bundle:nil];
            
            MovieEditViewController* meCon = [storyboard instantiateViewControllerWithIdentifier:@"MovieEditViewController"];
            meCon.fileURL = self.cam.outPutURL;
            NSLog(@"WILL PUSH NEW CONTROLLER HERE");
            [self.navigationController pushViewController:meCon animated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectImagePicker{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes =  @[(NSString*)kUTTypeMovie];
        picker.allowsEditing = NO;
        picker.delegate = self;
        
        [self presentViewController: picker animated:YES completion:nil];//selfはUIViewController
    }
    else {
        //エラー処理
    }

}

-(void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Movie" bundle:nil];
        
        MovieEditViewController* meCon = [storyboard instantiateViewControllerWithIdentifier:@"MovieEditViewController"];
        //動画のURLを取得
        NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL];
        meCon.fileURL = url;
        [self.navigationController pushViewController:meCon animated:YES];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
