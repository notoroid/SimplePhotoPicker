//
//  ViewController.m
//  SimplePhotoPicker
//
//  Created by 能登 要 on 2016/11/14.
//  Copyright © 2016年 Kaname Noto. All rights reserved.
//

#import "ViewController.h"
#import "SimplePhotoPicker.h"
@import Photos;

@interface ViewController () <IDPSimplePhotoPickerViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onPick:(id)sender
{
    IDPSimplePhotoPickerViewController *simplePhotoPickerViewController = [IDPSimplePhotoPickerViewController simplePhotoPickerViewController];
    simplePhotoPickerViewController.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:simplePhotoPickerViewController];
    [self presentViewController:navigationController animated:YES completion:^{
       
    }];
}

- (void) simpleLibraryPickerViewController:(IDPSimplePhotoPickerViewController *)simpleLibraryPickerViewController didSelectAsset:(PHAsset *)asset
{
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
}

- (void) simpleLibraryPickerViewControllerDidCancel:(IDPSimplePhotoPickerViewController *)simpleLibraryPickerViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
