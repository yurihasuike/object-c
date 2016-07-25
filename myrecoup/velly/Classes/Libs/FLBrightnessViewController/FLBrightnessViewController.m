//
//  FLBrightnessViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/11.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "FLBrightnessViewController.h"
#import "FLBrightnessView.h"
#import "FLBrightnessToolbar.h"
#import "FLBrightnessViewControllerTransitioning.h"

#import "FLActivityBrightnessImageProvider.h"
#import "FLBrightnessImageAttributes.h"

@interface FLBrightnessViewController () <UIActionSheetDelegate, UIViewControllerTransitioningDelegate, FLBrightnessViewDelegate>

//@property (nonatomic, readwrite) UIImage *image;
@property (nonatomic, strong) FLBrightnessToolbar *toolbar;
@property (nonatomic, strong) FLBrightnessView *brightnessView;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) FLBrightnessViewControllerTransitioning *transitionController;
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
@property (nonatomic, assign) BOOL inTransition;

- (void)cancelButtonTapped;
- (void)doneButtonTapped;
//- (void)showAspectRatioDialog;
//- (void)resetCropViewLayout;
//- (void)rotateCropView;

//- (void)sliderChange;

/* View layout */
- (CGRect)frameForToolBarWithVerticalLayout:(BOOL)verticalLayout;

@end

@implementation FLBrightnessViewController

- (instancetype)initWithImage:(UIImage *)image cropedimage:(UIImage *)cropedimage brightedimage:(UIImage *)brightedimage
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        
        _image = nil;
        _cropedimage = nil;
        _brightedimage = nil;
        
        _transitionController = [[FLBrightnessViewControllerTransitioning alloc] init];
        _image = image;
        _cropedimage = cropedimage;
        _brightedimage = brightedimage;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    DLog(@"self.image width : %f", self.image.size.width);                      // croppedimage
    DLog(@"self.image height : %f", self.image.size.height);
    
    DLog(@"self.cropedimage width : %f", self.cropedimage.size.width);          // cameraimage
    DLog(@"self.cropedimage height : %f", self.cropedimage.size.height);
    
    BOOL landscapeLayout = CGRectGetWidth(self.view.frame) > CGRectGetHeight(self.view.frame);
    self.brightnessView = [[FLBrightnessView alloc] initWithImage:self.image];
    //self.brightnessView = [[FLBrightnessView alloc] initWithImage:self.cropedimage];
    
    self.brightnessView.frame = (CGRect){(landscapeLayout ? 44.0f : 0.0f),0,(CGRectGetWidth(self.view.bounds) - (landscapeLayout ? 44.0f : 0.0f)), (CGRectGetHeight(self.view.bounds)-(landscapeLayout ? 0.0f : 44.0f)) };
    self.brightnessView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.brightnessView.delegate = self;
    [self.view addSubview:self.brightnessView];
    
    self.toolbar = [[FLBrightnessToolbar alloc] initWithFrame:CGRectZero];
    self.toolbar.frame = [self frameForToolBarWithVerticalLayout:CGRectGetWidth(self.view.bounds) < CGRectGetHeight(self.view.bounds)];
    [self.view addSubview:self.toolbar];
    
    __block typeof(self) blockSelf = self;
    self.toolbar.doneButtonTapped =     ^{ [blockSelf doneButtonTapped]; };
    self.toolbar.cancelButtonTapped =   ^{ [blockSelf cancelButtonTapped]; };
    //self.toolbar.resetButtonTapped =    ^{ [blockSelf resetCropViewLayout]; };
    //self.toolbar.clampButtonTapped =    ^{ [blockSelf showAspectRatioDialog]; };
    //self.toolbar.rotateButtonTapped =   ^{ [blockSelf rotateCropView]; };
    
    self.toolbar.sliderChange = ^{ [blockSelf sliderChangeView]; };
    
    //self.transitioningDelegate = self;
    
    //self.view.backgroundColor = self.brightnessView.backgroundColor;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([UIApplication sharedApplication].statusBarHidden == NO) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (animated && [UIApplication sharedApplication].statusBarHidden == NO) {
        [UIView animateWithDuration:0.3f animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];
        //[self.cropView setGridOverlayHidden:NO animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.5f animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Status Bar -
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

//- (BOOL)prefersStatusBarHidden
//{
//    return !self.inTransition;
//}

- (CGRect)frameForToolBarWithVerticalLayout:(BOOL)verticalLayout
{
    CGRect frame = self.toolbar.frame;
    if (verticalLayout ) {
        frame = self.toolbar.frame;
        frame.origin.x = 0.0f;
        frame.origin.y = 0.0f;
        frame.size.width = 44.0f;
        frame.size.height = CGRectGetHeight(self.view.frame);
    }
    else {
        frame.origin.x = 0.0f;
        //frame.origin.y = CGRectGetHeight(self.view.bounds) - 44.0f;
        frame.origin.y = CGRectGetHeight(self.view.bounds) - 88.0f;
        frame.size.width = CGRectGetWidth(self.view.bounds);
        frame.size.height = 44.0f;
    }
    
    return frame;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    BOOL verticalLayout = CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds);
    if (verticalLayout ) {
        CGRect frame = self.brightnessView.frame;
        frame.origin.x = 44.0f;
        frame.size.width = CGRectGetWidth(self.view.bounds) - 44.0f;
        frame.size.height = CGRectGetHeight(self.view.bounds);
        self.brightnessView.frame = frame;
    }
    else {
        CGRect frame = self.brightnessView.frame;
        frame.origin.x = 0.0f;
        frame.size.width = CGRectGetWidth(self.view.bounds);
        frame.size.height = CGRectGetHeight(self.view.bounds) - 44.0f;
        self.brightnessView.frame = frame;
    }
    
    [UIView setAnimationsEnabled:NO];
    self.toolbar.frame = [self frameForToolBarWithVerticalLayout:verticalLayout];
    self.toolbar.backgroundColor = [UIColor blackColor];
    [self.toolbar setNeedsLayout];
    [UIView setAnimationsEnabled:YES];
}


#pragma mark - Reset -
//- (void)resetCropViewLayout
//{
//    [self.brightnessView resetLayoutToDefaultAnimated:YES];
//    self.brightnessView.aspectLockEnabled = NO;
//    //self.brightnessView.clampButtonGlowing = NO;
//}

#pragma mark - Crop View Delegates -
- (void)cropViewDidBecomeResettable:(FLBrightnessView *)brightnessView
{
    self.toolbar.resetButtonEnabled = YES;
}

- (void)cropViewDidBecomeNonResettable:(FLBrightnessView *)brightnessView
{
    self.toolbar.resetButtonEnabled = NO;
}

#pragma mark - Presentation Handling -

- (void)presentAnimatedFromParentViewController:(UIViewController *)viewController fromFrame:(CGRect)frame completion:(void (^)(void))completion
{
    self.transitionController.image = self.image;
    self.transitionController.fromFrame = frame;
    
    __block typeof (self) blockSelf = self;
    [viewController presentViewController:self animated:YES completion:^ {
        if (completion) {
            completion();
        }
        
        [blockSelf.brightnessView setCroppingViewsHidden:NO animated:YES];
        if (!CGRectIsEmpty(frame)) {
            //[blockSelf.brightnessView setGridOverlayHidden:NO animated:YES];
        }
    }];
}

- (void)dismissAnimatedFromParentViewController:(UIViewController *)viewController withBrightnessImage:(UIImage *)image toFrame:(CGRect)frame completion:(void (^)(void))completion
{
    self.transitionController.image = image;
    self.transitionController.fromFrame = [self.brightnessView convertRect:self.brightnessView.cropBoxFrame toView:self.view];
    self.transitionController.toFrame = frame;
    
    [viewController dismissViewControllerAnimated:YES completion:^ {
        if (completion) {
            completion();
        }
    }];
}

- (void)dismissAnimatedFromParentViewController:(UIViewController *)viewController toFrame:(CGRect)frame completion:(void (^)(void))completion
{
    self.transitionController.image = self.image;
    self.transitionController.fromFrame = [self.brightnessView convertRect:self.brightnessView.imageViewFrame toView:self.view];
    self.transitionController.toFrame = frame;
   
    [viewController dismissViewControllerAnimated:YES completion:^ {
        if (completion) {
            completion();
        }
    }];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    __block typeof (self) blockSelf = self;
    self.transitionController.prepareForTransitionHandler = ^{
        blockSelf.transitionController.toFrame = [blockSelf.brightnessView convertRect:blockSelf.brightnessView.cropBoxFrame toView:blockSelf.view];
        if (!CGRectIsEmpty(blockSelf.transitionController.fromFrame))
            blockSelf.brightnessView.croppingViewsHidden = YES;
        
        if (blockSelf.prepareForTransitionHandler)
            blockSelf.prepareForTransitionHandler();
        
        blockSelf.prepareForTransitionHandler = nil;
    };
    
    self.transitionController.isDismissing = NO;
    return self.transitionController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    __block typeof (self) blockSelf = self;
    self.transitionController.prepareForTransitionHandler = ^{
        if (!CGRectIsEmpty(blockSelf.transitionController.toFrame))
            blockSelf.brightnessView.croppingViewsHidden = YES;
        else
            blockSelf.brightnessView.simpleMode = YES;
        
        if (blockSelf.prepareForTransitionHandler)
            blockSelf.prepareForTransitionHandler();
    };
    
    self.transitionController.isDismissing = YES;
    return self.transitionController;
}

#pragma mark - Button Feedback -
- (void)cancelButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(brightnessViewController:didFinishCancelled:)]) {
        [self.delegate brightnessViewController:self didFinishCancelled:YES];
        return;
    }
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve; // UIModalTransitionStyleCoverVertical;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)doneButtonTapped
{
    CGRect brightnessFrame = self.brightnessView.croppedImageFrame;
    NSInteger angle = self.brightnessView.angle;
    
    //If desired, when the user taps done, show an activity sheet
    if (self.showActivitySheetOnDone) {
        FLActivityBrightnessImageProvider *imageItem = [[FLActivityBrightnessImageProvider alloc] initWithImage:self.image brightnessFrame:brightnessFrame angle:angle];
        FLBrightnessImageAttributes *attributes = [[FLBrightnessImageAttributes alloc] initWithBrightnessFrame:brightnessFrame angle:angle originalImageSize:self.image.size];
        
        NSMutableArray *activityItems = [@[imageItem, attributes] mutableCopy];
        if (self.activityItems)
            [activityItems addObjectsFromArray:self.activityItems];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:self.applicationActivities];
        activityController.excludedActivityTypes = self.excludedActivityTypes;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:activityController animated:YES completion:nil];
        }
        else {
            [self.activityPopoverController dismissPopoverAnimated:NO];
            self.activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
            [self.activityPopoverController presentPopoverFromRect:self.toolbar.doneButtonFrame inView:self.toolbar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        
        __block typeof(activityController) blockController = activityController;
        activityController.completionHandler = ^(NSString *activityType, BOOL completed) {
            if (!completed)
                return;
            
            if ([self.delegate respondsToSelector:@selector(brightnessViewController:didFinishCancelled:)]) {
                [self.delegate brightnessViewController:self didFinishCancelled:NO];
            }
            else {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                blockController.completionHandler = nil;
            }
        };
        
        return;
    }
    
    DLog(@"brightnessFrame : x %f", brightnessFrame.origin.x);
    DLog(@"brightnessFrame : y %f", brightnessFrame.origin.y);
    DLog(@"brightnessFrame : width %f", brightnessFrame.size.width);
    DLog(@"brightnessFrame : height %f", brightnessFrame.size.height);
    
    //If the delegate that only supplies crop data is provided, call it
    if ([self.delegate respondsToSelector:@selector(brightnessViewController:didBrightnessImageToRect:sliderVal:)]) {
        [self.delegate brightnessViewController:self didBrightnessImageToRect:brightnessFrame sliderVal:self.toolbar.brightnessSlider.value];
    }
    //If the delegate that requires the specific cropped image is provided, call it
    else if ([self.delegate respondsToSelector:@selector(brightnessViewController:didBrightnessToImage:brightedimage:withRect:sliderVal:)]) {
        UIImage *image = nil;
        UIImage *brightedimage = nil;
        if (angle == 0 && CGRectEqualToRect(brightnessFrame, (CGRect){CGPointZero, self.image.size})) {

            image = [self.image brightImageWithFrame:brightnessFrame sliderVal:self.toolbar.brightnessSlider.value];
            brightedimage = [self.brightedimage brightImageWithFrame:brightnessFrame sliderVal:self.toolbar.brightnessSlider.value];

            DLog(@"image : x %f", image.size.width);
            DLog(@"image : y %f", image.size.height);
            DLog(@"brightedimage : width %f", brightedimage.size.width);
            DLog(@"brightedimage : height %f", brightedimage.size.height);
            
        }
        else {
            
            image = [self.image brightImageWithFrame:brightnessFrame sliderVal:self.toolbar.brightnessSlider.value];
            brightedimage = [self.brightedimage brightImageWithFrame:brightnessFrame sliderVal:self.toolbar.brightnessSlider.value];

        }
        //dispatch on the next run-loop so the animation isn't interuppted by the crop operation
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate brightnessViewController:self didBrightnessToImage:image brightedimage:(UIImage *)brightedimage withRect:brightnessFrame sliderVal:self.toolbar.brightnessSlider.value];
        });
    }
    else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}


- (void)sliderChangeView
{

    static BOOL inProgress = NO;

    if(inProgress){ return; }
    inProgress = YES;
    
    UIImage *image = nil;
    image = [self.image brightImage:self.toolbar.brightnessSlider.value];
    [self.brightnessView brightnessImageNinetyDegreesAnimated:YES image:image sliderVal:self.toolbar.brightnessSlider.value];
    inProgress = NO;
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        UIImage *image = nil;
//        image = [self.image brightImage:self.toolbar.brightnessSlider.value];
//        [self.brightnessView brightnessImageNinetyDegreesAnimated:YES image:image sliderVal:self.toolbar.brightnessSlider.value];
//        
//        inProgress = NO;
//        
//    });


}


@end
