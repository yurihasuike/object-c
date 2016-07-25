//
//  FLBrightnessView.h
//  velly
//
//  Created by m_saruwatari on 2015/07/12.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLBrightnessView;

@protocol FLBrightnessViewDelegate <NSObject>

- (void)cropViewDidBecomeResettable:(FLBrightnessView *)cropView;
- (void)cropViewDidBecomeNonResettable:(FLBrightnessView *)cropView;

@end

@interface FLBrightnessView : UIView

/**
 The image that the crop view is displaying. This cannot be changed once the crop view is instantiated.
 */
//@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong) UIImage *image;

/**
 A delegate object that receives notifications from the crop view
 */
@property (nonatomic, weak) id<FLBrightnessViewDelegate> delegate;

/**
 Whether the user has manipulated the crop view to the point where it can be reset
 */
@property (nonatomic, readonly) BOOL canReset;

/**
 The frame of the cropping box on the crop view
 */
@property (nonatomic, readonly) CGRect cropBoxFrame;

/**
 The frame of the entire image in the backing scroll view
 */
@property (nonatomic, readonly) CGRect imageViewFrame;

/**
 Inset the workable region of the crop view in case in order to make space for accessory views
 */
@property (nonatomic, assign) UIEdgeInsets cropRegionInsets;

/**
 Disable the dynamic translucency in order to smoothly relayout the view
 */
@property (nonatomic, assign) BOOL simpleMode;

/**
 When the cropping box is locked to its current size
 */
@property (nonatomic, assign) BOOL aspectLockEnabled;

/**
 True when the height of the crop box is bigger than the width
 */
@property (nonatomic, readonly) BOOL cropBoxAspectRatioIsPortrait;

/**
 The rotation angle of the crop view (Will always be negative as it rotates in a counter-clockwise direction)
 */
@property (nonatomic, assign, readonly) NSInteger angle;

/**
 Hide all of the crop elements for transition animations
 */
@property (nonatomic, assign) BOOL croppingViewsHidden;

/**
 In relation to the coordinate space of the image, the frame that the crop view is focussing on
 */
@property (nonatomic, readonly) CGRect croppedImageFrame;

/**
 Set the grid overlay graphic to be hidden
 */
@property (nonatomic, assign) BOOL gridOverlayHidden;

/**
 Create a new instance of the crop view with the supplied image
 */
- (instancetype)initWithImage:(UIImage *)image;

/**
 When performing large size transitions (eg, orientation rotation),
 set simple mode to YES to temporarily graphically heavy effects like translucency.
 
 @param simpleMode Whether simple mode is enabled or not
 
 */
- (void)setSimpleMode:(BOOL)simpleMode animated:(BOOL)animated;

/**
 When performing a screen rotation that will change the size of the scroll view, this takes
 a snapshot of all of the scroll view data before it gets manipulated by iOS.
 Please call this in your view controller, before the rotation animation block is committed.
 */
- (void)prepareforRotation;

/**
 Performs the realignment of the crop view while the screen is rotating.
 Please call this inside your view controller's screen rotation animation block.
 */
- (void)performRelayoutForRotation;

/**
 Reset the crop box and zoom scale back to the initial layout
 
 @param animated The reset is animated
 */
- (void)resetLayoutToDefaultAnimated:(BOOL)animated;

/**
 Enables an aspect ratio lock where the crop box will always scale at a specific ratio.
 
 @param aspectRatio The aspect ratio (For example 16:9 is 16.0f/9.0f). Specify 0.0f to lock to the image's original aspect ratio
 @param animated Whether the locking effect is animated
 */
//- (void)setAspectLockEnabledWithAspectRatio:(CGSize)aspectRatio animated:(BOOL)animated;

/**
 Rotates the entire canvas to a 90-degree angle
 
 @param angle The angle in which to rotate (May be 0, 90, 180, 270)
 @param animated Whether the transition is animated
 */
//- (void)rotateImageNinetyDegreesAnimated:(BOOL)animated;

- (void)brightnessImageNinetyDegreesAnimated:(BOOL)animated image:(UIImage *)image sliderVal:(CGFloat)sliderVal;

/**
 Animate the grid overlay graphic to be visible
 */
//- (void)setGridOverlayHidden:(BOOL)gridOverlayHidden animated:(BOOL)animated;

/**
 Animate the cropping component views to become visible
 */
- (void)setCroppingViewsHidden:(BOOL)hidden animated:(BOOL)animated;



@end
