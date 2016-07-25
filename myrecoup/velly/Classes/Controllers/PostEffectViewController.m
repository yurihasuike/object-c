//
//  PostEffectViewController.m
//  velly
//
//  Created by m_saruwatari on 2015/03/02.
//  Copyright (c) 2015年 mamoru.saruwatari. All rights reserved.
//

#import "PostEffectViewController.h"
#import "PostEditViewController.h"
#import "TOCropViewController.h"
#import "FLBrightnessViewController.h"
#import "CoreImageHelper.h"
#import "TrackingManager.h"
#import "UIImage+CropRotate.h"
#import "UIImage+Bright.h"
#import "PostEffectCollectionViewCell.h"
#import "Defines.h"
#import "CategoryManager.h"

// --------------------------------------
// master
// cropedimage		brightedimage
// fileterdimage
//
// クロップは、
// 画面上は、brightedimageを表示
// brightedimageから取得してきて、加工し、filterdimageへ
// masterから取得してきて、加工し、cropedimageへ
//　ブライトは、
//　画面上は、cropedimageを表示
// cropedimageから取得してきて、加工し、filterdimageへ
// masterから取得してきて、加工し、brightedimageへ
// --------------------------------------

@interface PostEffectViewController () <TOCropViewControllerDelegate, FLBrightnessViewControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) CGRect holdMasterBoxFrame;
@property (nonatomic) CGRect holdCropBoxFrame;
@property (nonatomic, assign) NSInteger holdAngle;
@property (nonatomic, assign) CGFloat sliderVal;

@end

@implementation PostEffectViewController

- (id) initWithPostImage:(UIImage *)t_postImage {
    
    if(!self) {
        self = [[PostEffectViewController alloc] init];
    }
    
    //遅い場合があるので非同期的にフィルター画像をセット
    [self doTaskAsynchronously:^{
        self.filteredImages = [self getFilteredImages:t_postImage];
        [self doTaskSynchronously:^{
            [self.filteredImageCollectionView reloadData];
        }];
    }];
    self.cameraImage   = t_postImage;     // master
    self.filteredImage = t_postImage;
    self.cropedimage   = t_postImage;
    self.brightedimage = t_postImage;
    
    //self.cameraImageView.image = t_postImage;
    
    return self;
}

//フィルター選択のための画像を配列に格納
/*
 フィルター追加方法
 1,filterNamesにフィルター名を追加
 2,filterNamesループの中でその名前に対応するフィルターのciFilterを作成
 
 削除方法
 1,filterNamesから名前を削除
 2,もう元に戻さないならループ内の処理も削除
 */
- (NSMutableArray *) getFilteredImages:(UIImage *)t_postImage {
    DLog("getFilteredImages");
    
    NSMutableArray *filteredImages = [[NSMutableArray alloc] init];
    
    if (!t_postImage) {
        return filteredImages;
    }
    //オリジナルを入れておく
    [filteredImages addObject:t_postImage];
    
    //フィルター名登録
    NSArray *filterNames = @[@"CISepiaTone",@"CIColorControls",@"CIToneCurve",@"Brighten",@"Saturated",@"CIFalseColor"];
    
    //この画像を元にフィルター後画像を作成
    CIImage *ciImage = [[CIImage alloc] initWithImage:t_postImage];
    
    //以下、フィルターされた画像の作成
    [filterNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        
        //フィルタ別に処理を記述
        if([name  isEqualToString: @"CISepiaTone"]){
            //sepia
            self.ciFilter = [CIFilter filterWithName:name
                                       keysAndValues:kCIInputImageKey, ciImage,
                                  @"inputIntensity", [NSNumber numberWithFloat:0.8],
                                  nil
                                  ];
            
        }
        else if([name isEqualToString:@"CIColorMonochrome"]){
            //グレースケール->未使用
            self.ciFilter = [CIFilter filterWithName:name
                                            keysAndValues:kCIInputImageKey, ciImage,
                                  @"inputColor", [CIColor colorWithRed:0.75 green:0.75 blue:0.75],
                                  @"inputIntensity", [NSNumber numberWithFloat:1.0],
                                  nil
                                  ];
        }
        else if([name isEqualToString:@"CIColorInvert"]){
            //反転->未使用
            self.ciFilter = [CIFilter filterWithName:name
                                       keysAndValues:kCIInputImageKey, ciImage,nil];
            
        }
        else if([name isEqualToString:@"CIFalseColor"]){
            //偽色
            self.ciFilter = [CIFilter filterWithName:name
                                       keysAndValues:kCIInputImageKey, ciImage,
                             @"inputColor0", [CIColor colorWithRed:0.44 green:0.5 blue:0.2 alpha:1],
                             @"inputColor1", [CIColor colorWithRed:1 green:0.92 blue:0.50 alpha:1],
                             nil
                             ];
        }
        else if([name isEqualToString:@"CIColorControls"]){
            //色調節フィルタ
            self.ciFilter = [CIFilter filterWithName:name
                                       keysAndValues:kCIInputImageKey, ciImage,
                             @"inputSaturation", [NSNumber numberWithFloat:1.0],
                             @"inputBrightness", [NSNumber numberWithFloat:0.5],
                             @"inputContrast", [NSNumber numberWithFloat:3.0],
                             nil
                             ];
        }
        else if([name isEqualToString:@"CIToneCurve"]){
            //トーンカーブ
            self.ciFilter = [CIFilter filterWithName:name
                                       keysAndValues:kCIInputImageKey, ciImage,
                             @"inputPoint0", [CIVector vectorWithX:0.0 Y:0.0],
                             @"inputPoint1", [CIVector vectorWithX:0.25 Y:0.1],
                             @"inputPoint2", [CIVector vectorWithX:0.5 Y:0.5],
                             @"inputPoint3", [CIVector vectorWithX:0.75 Y:0.9],
                             @"inputPoint4", [CIVector vectorWithX:1 Y:1],
                             nil
                             ];
        }
        else if([name isEqualToString:@"CIHueAdjust"]){
            //色相調整->未使用
            self.ciFilter = [CIFilter filterWithName:name
                                       keysAndValues:kCIInputImageKey, ciImage,
                             @"inputAngle",[NSNumber numberWithFloat:3.14],
                             nil
                             ];
        }
        else if ([name isEqualToString:@"Brighten"]){
            //明るさ下げ
            self.ciFilter = [CIFilter filterWithName:@"CIColorControls"
                                       keysAndValues:kCIInputImageKey, ciImage,
                             @"inputSaturation", [NSNumber numberWithFloat:1.0],
                             @"inputBrightness", [NSNumber numberWithFloat:-0.25],
                             @"inputContrast", [NSNumber numberWithFloat:1.0],
                             nil
                             ];
        }
        else if ([name isEqualToString:@"Saturated"]){
            //彩度下げ
            self.ciFilter = [CIFilter filterWithName:@"CIColorControls"
                                       keysAndValues:kCIInputImageKey, ciImage,
                             @"inputSaturation", [NSNumber numberWithFloat:0.3],
                             @"inputBrightness", [NSNumber numberWithFloat:0],
                             @"inputContrast", [NSNumber numberWithFloat:1.0],
                             nil
                             ];
        }
        
        //共通の処理
        CIContext *ciContext = [CIContext contextWithOptions:nil];
        CGImageRef cgimg = [ciContext createCGImage:[self.ciFilter outputImage] fromRect:[[self.ciFilter outputImage] extent]];
        
        //それぞれのフィルター後画像
        UIImage* tmpImage = [UIImage imageWithCGImage:cgimg
                                                scale:1.0f
                                          orientation:t_postImage.imageOrientation];
        
        //配列に追加
        [filteredImages addObject:tmpImage];
        //いらないので解放
        CGImageRelease(cgimg);
        
    }];
    
    return filteredImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    
    DLog(@"%f", self.cameraImage.size.width);
    DLog(@"%f", self.cameraImageView.image.size.width);
    DLog(@"hedear view : %f", self.headerView.frame.origin.y);
    
    // 画像のセット
    if(self.cameraImage != nil){
        
        DLog(@"self.cameraImage width : %f", self.cameraImage.size.width);
        DLog(@"self.cameraImage height : %f", self.cameraImage.size.height);
        //[self layoutImageView];
        
        //self.cameraImageView.image = self.cameraImage;
        //[self.cameraImageView setImage:self.cameraImage];
        
        //self.cameraImageView.frame = CGRectMake(cameraImageViewFrame.origin.x, cameraImageViewFrame.origin.y, resizedSize.width, resizedSize.height);
        //self.cameraImageView.frame = CGRectMake(cameraImageViewFrame.origin.x, cameraImageViewFrame.origin.y, cameraImageViewFrame.size.width, cameraImageViewFrame.size.height);
        
//        CGSize ciSize = CGSizeMake(self.cameraImageView.frame.size.width, self.cameraImageView.frame.size.height);
//        [CoreImageHelper centerCroppingImageWithImage:self.cameraImage atSize:ciSize completion:^(UIImage *resultImg){
//            self.cameraImageView.image = resultImg;
//            [self.cameraImageView setImage:resultImg];
//        }];
        
    }
    self.holdMasterBoxFrame = self.displayView.frame;
    
    // back btn
    [self.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.backBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    // crop btn
    self.cropBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    // bright btn
    self.brightBtn.tappableInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    
    //フィルターされた画像のコレクションを設置
    [self setFilteredImageCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DLog(@"hedear view : %f", self.headerView.frame.origin.y);
    
    //[self.navigationController setNavigationBarHidden:YES animated:NO];      // del
    
    
    [self layoutImageView];
    
    
    // ---------------------------------------
    // GA
    // ---------------------------------------
    [TrackingManager sendScreenTracking:@"PostEffect"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

///コレクションViewのレイアウト決定
- (void)setFilteredImageCollectionView
{
    DLog("setFilteredImageCollectionView");
    
    //Filterバーのサイズ-------------------------------
    CGFloat fBarWidth = self.view.bounds.size.width;
    CGFloat fBarHeight = self.PostEffectCollectionBaseView.bounds.size.height;
    //----------------------------------------------
    //cellのサイズ--------------------------------
    CGFloat cellWidth = fBarHeight - 5;
    CGFloat cellHeight = cellWidth;
    //-------------------------------------------
    
    //set flow layout.
    self.filteredImageCollectionLayout = [[UICollectionViewFlowLayout alloc] init];
    self.filteredImageCollectionLayout.itemSize = CGSizeMake(cellWidth, cellHeight);  //表示するアイテムのサイズ
    self.filteredImageCollectionLayout.minimumLineSpacing = 10.0f;  //セクションとアイテムの間隔
    [self.filteredImageCollectionLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.filteredImageCollectionLayout.minimumInteritemSpacing = 10.0f;
    
    //set collection view.
    self.filteredImageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, fBarWidth, fBarHeight) collectionViewLayout:self.filteredImageCollectionLayout];
    self.filteredImageCollectionView.delegate = self;
    self.filteredImageCollectionView.dataSource = self;
    [self.filteredImageCollectionView registerClass:[PostEffectCollectionViewCell class] forCellWithReuseIdentifier:@"PostEffectCollectionViewCell"];  //collectionViewにcellのクラスを登録。セルの表示に使う
    
    [self.PostEffectCollectionBaseView addSubview:self.filteredImageCollectionView];
}

#pragma mark -
#pragma mark UICollectionViewDelegate

/*セクションの数*/
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

/*セクションに応じたセルの数*/
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.filteredImages count];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

/*セルの内容を返す*/
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"PostEffectCollectionViewCell";
    PostEffectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
    //Preview画像を縦横比を維持し縮小->正方形で上から切り抜き,cellに貼り付け
    //フィルター後の元サイズ画像とその縦横比
    UIImage *OriginSizeImage = self.filteredImages[indexPath.row];
    CGFloat OriginHDevideByW = OriginSizeImage.size.height / OriginSizeImage.size.width;
    
    //Preview画像
    UIImage *img_resized;
    
    //最終的な画像サイズ
    CGFloat ResultSize = cell.bounds.size.width * 0.8;
    
    //比率を守って縮小したサイズ------------
    CGFloat ResizeWidth;
    CGFloat ResizeHeight;
    //--------------------------------------------
    
    if (OriginHDevideByW >= 1 ) {
    //縦長の場合
        ResizeWidth = ResultSize;
        ResizeHeight = ResizeWidth * OriginHDevideByW;
    }else {
    //横長の場合
        ResizeHeight = ResultSize;
        ResizeWidth = ResizeHeight / OriginHDevideByW;
    }
    
    //ここで縦横比維持したままリサイズ
    UIGraphicsBeginImageContext(CGSizeMake(ResizeWidth, ResizeHeight));
    [OriginSizeImage drawInRect:CGRectMake(0, 0, ResizeWidth, ResizeHeight)];
    img_resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //ここでトリミング x=stratX,y=startYから正方形で (中央切り抜き)。
    CGFloat startX = ( img_resized.size.width - ResultSize ) /2;
    CGFloat startY = ( img_resized.size.height - ResultSize ) /2;
    CGImageRef cg_img_cropped = CGImageCreateWithImageInRect(img_resized.CGImage, CGRectMake(startX,
                                                                                             startY,
                                                                                             ResultSize,
                                                                                             ResultSize));
    img_resized = [UIImage imageWithCGImage:cg_img_cropped];
    CGImageRelease(cg_img_cropped);
    
    //cellに貼り付けるためにuiimageviewに貼り付け
    cell.filteredImageView.image = img_resized;
    
    CGRect fimageviewf = CGRectMake(0, 0, img_resized.size.width, img_resized.size.height);
    cell.filteredImageView.frame = fimageviewf;
    CGPoint fimageviewp = CGPointMake(cell.bounds.size.width/2, cell.bounds.size.height/2);
    cell.filteredImageView.layer.position = fimageviewp;
    
    //imageviewをを角丸に
    cell.filteredImageView.layer.cornerRadius = 5;
    cell.filteredImageView.clipsToBounds = true;
    
    //アンダーバー
    UIImage *underBarImage = [UIImage imageNamed:@"prev_selected"];
    cell.underBar.image = underBarImage;
    [cell.underBar setFrame:CGRectMake(0, 0, img_resized.size.width * 1.2,2)];
    cell.underBar.layer.position = CGPointMake(fimageviewp.x,
                                               CGRectGetMaxY(cell.filteredImageView.frame) * 1.05);
    //cellが選択されていればつける処理
    if ((NSInteger *)indexPath.row == self.shouldBeBarRow) {
        cell.underBar.hidden = NO;
    }
    //外す処理
    else{
        cell.underBar.hidden = YES;
    }
    
    //タップアクション付加
    UITapGestureRecognizer *tapUserGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filteredImageTap:)];
    cell.userInteractionEnabled = YES;
    [cell addGestureRecognizer:tapUserGestureRecognizer];
    
    return cell;
}

//選ばれたのを記憶しリロードすることにより選択中の画像下にアンダーバーを。
- (void)memorizeSelected:(PostEffectCollectionViewCell *)cell{
    NSIndexPath *path = [self.filteredImageCollectionView indexPathForCell:cell];
    self.shouldBeBarRow = (NSInteger *)path.row;
    [self.filteredImageCollectionView reloadData];
}

//フィルターされた画像コレクションの中から画像がタップされた時
- (void)filteredImageTap:(UIGestureRecognizer *)recognizer
{
    //タップ画像を取得
    PostEffectCollectionViewCell *cell = (PostEffectCollectionViewCell *)[recognizer view];
    NSIndexPath *path = [self.filteredImageCollectionView indexPathForCell:cell];
    
    //セル選択位置を真ん中へ
    [self.filteredImageCollectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    //初期化
    self.cameraImage   = self.filteredImages[path.row];
    self.filteredImage = self.filteredImages[path.row];
    self.cropedimage   = self.filteredImages[path.row];
    self.brightedimage = self.filteredImages[path.row];
    
    //フィルター後画像をセット
    [self layoutImageView];
    
    //選択中のアンダーバーセット
    [self memorizeSelected:cell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        DLog(@"back");
    }
}

- (void)backAction:(id)sender
{
    DLog(@"PostEffectView backAction");
    
    if(self.cameraImage){
        // have a image
        
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.delegate = self;
        alert.title = @"";
        alert.message = NSLocalizedString(@"MsgResetComfAction", nil);
        [alert addButtonWithTitle:NSLocalizedString(@"NO", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"YES", nil)];
        [alert show];
        
    }else{
        // no have a image
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }

}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // cancel
            break;
        case 1:
            // OK
            if (self.wasPostSelectFromLibraryView) {
                [self.navigationController setNavigationBarHidden:NO];
                [self.navigationController popViewControllerAnimated:YES];
                [APP_DELEGATE_FUNC showTabBar:nil];
                break;
            }
            self.navigationController.navigationBarHidden = YES;
            self.postViewController.cameraImage = nil;
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}

- (IBAction)cropAction:(id)sender {
    DLog(@"PostEffectView cropAction");
    
    // cropedimage, filterdimage を加工
    TOCropViewController *cropController = nil;
    cropController = [[TOCropViewController alloc] initWithImage:self.brightedimage cropedimage:self.cameraImage brightedimage:self.cameraImage];
    cropController.delegate = self;
    [self presentViewController:cropController animated:YES completion:nil];
}

- (IBAction)brightAction:(id)sender {
    DLog(@"PostEffectView brightAction");
    
    
    DLog(@"self.filteredImage width : %f", self.filteredImage.size.width);
    DLog(@"self.filteredImage height : %f", self.filteredImage.size.height);
    
    DLog(@"self.cameraImage width : %f", self.cameraImage.size.width);
    DLog(@"self.cameraImage height : %f", self.cameraImage.size.height);
    
    DLog(@"self.cropedimage width : %f", self.cropedimage.size.width);
    DLog(@"self.cropedimage height : %f", self.cropedimage.size.height);
    
    
    // brightedimage, filterdimage を加工
    FLBrightnessViewController *brightnessController = nil;
    brightnessController = [[FLBrightnessViewController alloc] initWithImage:self.cropedimage cropedimage:self.cameraImage brightedimage:self.cameraImage];
    brightnessController.delegate = self;
    [self presentViewController:brightnessController animated:YES completion:nil];
}

- (IBAction)recSubmitAction:(id)sender {
    DLog(@"PostEffectView recSubmitAction");
    
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[EFFECTSUBMITTAP]
                         properties:nil];
    
    DLog(@"filteredImage width : %f", self.filteredImage.size.width);
    DLog(@"filteredImage height : %f", self.filteredImage.size.height);
    
    
    PostEditViewController *postEditViewController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"PostEditViewController"];
    //postEditViewController = [postEditViewController initWithPostImage: self.cameraImageView.image];
    postEditViewController = [postEditViewController initWithPostImage: self.filteredImage];
    postEditViewController.postEffectViewController = self;
    if([self.descrip length] > 0){
        postEditViewController.descripView.text = self.descrip;
        postEditViewController.descrip = self.descrip;
    }
    if(self.category){
        if (self.category.parent) {
            postEditViewController.parent = [[CategoryManager sharedManager] getParentByChild:self.category];
            postEditViewController.child = self.category;
        }else{
            postEditViewController.parent = self.category;
        }
        
    }
    
    self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"NavTabPost", nil);
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationController.navigationItem.backBarButtonItem = backItem;
    
    //[self.navigationController pushViewController:postEffectViewController animated:YES];
    [self.navigationController pushViewController: postEditViewController animated:YES];
    
}

- (void)layoutImageView
{
    if (self.filteredImage == nil)
        return;
    
    CGFloat cameraImageViewWidth = [[UIScreen mainScreen]bounds].size.width;
    CGFloat cameraImageViewHeight = [[UIScreen mainScreen]bounds].size.height - (64.0f + 120.0f);

    //CGRect mainFrame = [[UIScreen mainScreen]bounds];
    CGSize filteredImageSize = self.filteredImage.size;
    
    CGFloat scale = MIN(cameraImageViewWidth / filteredImageSize.width, cameraImageViewHeight / filteredImageSize.height);
    //CGPoint cropMidPoint = (CGPoint){0.0f, 64.0f};
    
    CGRect newImageFrame = CGRectZero;
    newImageFrame.size = (CGSize){floorf(filteredImageSize.width * scale), floorf(filteredImageSize.height * scale)};
    
    //newImageFrame.origin.x = floorf((cameraImageViewWidth * 0.5f) - (newImageFrame.size.width * 0.5f)) + cropMidPoint.x;
    //newImageFrame.origin.y = floorf((cameraImageViewHeight * 0.5f) - (newImageFrame.size.height * 0.5f)) + cropMidPoint.y;
    
    newImageFrame.origin.x = floorf((cameraImageViewWidth * 0.5f) - (newImageFrame.size.width * 0.5f));
    newImageFrame.origin.y = floorf((cameraImageViewHeight * 0.5f) - (newImageFrame.size.height * 0.5f));
    
    UIImage *image = self.filteredImage;
    //[self.cameraImageView setImage:image];
    
    UIGraphicsBeginImageContext(newImageFrame.size);
    [image drawInRect:CGRectMake(0, 0, newImageFrame.size.width, newImageFrame.size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.displayView.userInteractionEnabled = YES;
    self.cameraImageView.userInteractionEnabled = YES;
    self.cameraImageView.image = resizedImage;
    [self.cameraImageView setImage:resizedImage];
    self.cameraImageView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.cameraImageView setFrame:newImageFrame];

}

#pragma mark - Cropper Delegate -
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image cropedimage:(UIImage *)cropedimage withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.holdAngle = angle;
    self.holdCropBoxFrame = cropRect;
    
    // cropedimage, filterdimage を加工
    //self.cameraImageView.image = image;
    self.filteredImage = nil;
    self.filteredImage = image;
    self.cropedimage = nil;
    self.cropedimage = cropedimage;   // cropViewでcropedimage -> 加工したものをセット
    
    //configure filtered images collection view.
    [self doTaskAsynchronously:^{
        self.filteredImages = [self getFilteredImages:self.cropedimage];
       [self doTaskSynchronously:^{
           [self.filteredImageCollectionView reloadData];
       }];
    }];
    
    DLog(@"self.filteredImage width : %f", self.filteredImage.size.width);
    DLog(@"self.filteredImage height : %f", self.filteredImage.size.height);
    
    DLog(@"self.cropedimage width : %f", self.cropedimage.size.width);
    DLog(@"self.cropedimage height : %f", self.cropedimage.size.height);
    
    [self layoutImageView];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    CGRect viewFrame = [self.view convertRect:self.cameraImageView.bounds toView:self.navigationController.view];
    //CGRect viewFrame = [self.view convertRect:self.displayView.frame toView:self.navigationController.view];
    
    if(self.holdAngle != 0 && self.holdAngle != 360){
//        viewFrame = self.holdCropBoxFrame;
//        
//        
//        //Work out how much we'll need to scale everything to fit to the new rotation
//        //CGRect contentBounds = self.cameraImageView.bounds;
//        CGRect cropBoxFrame = self.holdCropBoxFrame;
//        //CGFloat scale = MIN(contentBounds.size.width / cropBoxFrame.size.height, contentBounds.size.height / cropBoxFrame.size.width);
//        
//        //Work out which section of the image we're currently focusing at
//        //CGPoint cropMidPoint = (CGPoint){CGRectGetMidX(cropBoxFrame), CGRectGetMidY(cropBoxFrame)};
//        //CGPoint cropTargetPoint = (CGPoint){cropMidPoint.x + self.cameraImageView.bounds.origin.x, cropMidPoint.y + self.cameraImageView.bounds.origin.y};
//        
//        //Work out the dimensions of the crop box when rotated
//        CGRect newCropFrame = CGRectZero;
//        newCropFrame.size = self.holdCropBoxFrame.size;
//        newCropFrame.origin.x = floorf((CGRectGetWidth(self.cameraImageView.bounds) - newCropFrame.size.width) * 0.5f);
//        newCropFrame.origin.y = floorf((CGRectGetHeight(self.cameraImageView.bounds) - newCropFrame.size.height) * 0.5f);
//        
//        //self.cameraImageView.userInteractionEnabled = YES;
//        [self.cameraImageView setFrame:newCropFrame];
//        
    }else{
//        //self.cameraImageView.userInteractionEnabled = YES;
        //[self.cameraImageView setFrame:self.holdMasterBoxFrame];
        //DLog(@" hold y : %f", self.holdMasterBoxFrame.origin.y);
        //DLog(@" cameraImageView y : %f", self.cameraImageView.frame.origin.y);
    }

    self.cameraImageView.hidden = NO;
    [cropViewController dismissAnimatedFromParentViewController:self withCroppedImage:image toFrame:viewFrame completion:^{
        //self.cameraImageView.hidden = NO;
    }];
}


#pragma mark - Brightness Delegate -
- (void)brightnessViewController:(FLBrightnessViewController *)brightnessViewController didBrightnessToImage:(UIImage *)image brightedimage:(UIImage *)brightedimage withRect:(CGRect)cropRect sliderVal:(CGFloat)sliderVal
{
    self.sliderVal = sliderVal;
    
    // brightedimage, filterdimage を加工
    //self.cameraImageView.image = image;
    self.filteredImage = nil;
    self.filteredImage = image;
    self.brightedimage = nil;
    self.brightedimage = brightedimage;     // brightViewでbrightimage -> 加工したものをセット

    //configure filtered images collection view.
    self.filteredImages = [self getFilteredImages:self.brightedimage];
    [self.filteredImageCollectionView reloadData];
    
    DLog(@"self.filteredImage width : %f", self.filteredImage.size.width);
    DLog(@"self.filteredImage height : %f", self.filteredImage.size.height);
    
    DLog(@"self.brightedimage width : %f", self.brightedimage.size.width);
    DLog(@"self.brightedimage height : %f", self.brightedimage.size.height);

    [self layoutImageView];

    self.navigationItem.rightBarButtonItem.enabled = YES;

    CGRect viewFrame = [self.view convertRect:self.cameraImageView.frame toView:self.navigationController.view];

    self.cameraImageView.hidden = NO;
    [brightnessViewController dismissAnimatedFromParentViewController:self withBrightnessImage:image toFrame:viewFrame completion:^{
        //self.cameraImageView.hidden = NO;
    }];

}

///非同期実行
- (void)doTaskAsynchronously:(void (^) ())block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        block();
    });
}

///同期実行
- (void)doTaskSynchronously:(void (^) ())block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}


@end
