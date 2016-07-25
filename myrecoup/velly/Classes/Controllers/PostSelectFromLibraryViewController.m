//
//  PostSelectFromLibraryViewController.m
//  myrecoup
//
//  Created by aoponaopon on 2016/03/19.
//  Copyright (c) 2016年 mamoru.saruwatari. All rights reserved.
//

#import "PostSelectFromLibraryViewController.h"
#import "PostEffectViewController.h"
#import "TrackingManager.h"
#import "Defines.h"

@interface PostSelectFromLibraryViewController ()

@end

@implementation PostSelectFromLibraryViewController

- (id)initWithPreviousTab:(UIViewController *)previousTab {
    
    if (self = [super init]) {
        self.previousTab = previousTab;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark CustromAction

- (void)postEffectActionImage:(UIImage *)image
{
    //postEffectViewに画像とフラグをセット
    PostEffectViewController *postEffectViewController = [[UIStoryboard storyboardWithName:@"Post" bundle:nil] instantiateViewControllerWithIdentifier:@"PostEffectViewController"];
    postEffectViewController = [postEffectViewController initWithPostImage: image];
    postEffectViewController.wasPostSelectFromLibraryView = YES;
    
    //先にナビゲーションで移動させてからモーダルを消す
    [self.previousTab.navigationController pushViewController:postEffectViewController animated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UIImagePickerControllerDelegate

//写真を選択した時に呼ばれる
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // SEND REPRO EVENT
    [TrackingManager sendReproEvent:DEFINES_REPROEVENTNAME[SELECTEDFROMLIBRARY]
                         properties:nil];
    
    [self postEffectActionImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
}

//キャンセルした時に呼ばれる関数
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [APP_DELEGATE_FUNC showTabBar:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
