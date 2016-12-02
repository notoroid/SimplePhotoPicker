//
//  IDPSimplePhotoPickerViewController.h
//  SimpleLibraryPicker
//
//  Created by 能登 要 on 2016/11/13.
//  Copyright © 2016年 Kaname Noto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@protocol IDPSimplePhotoPickerViewControllerDelegate;

@interface IDPSimplePhotoPickerViewController : UICollectionViewController

+ (IDPSimplePhotoPickerViewController *)simplePhotoPickerViewController;

@property (weak,nonatomic) id<IDPSimplePhotoPickerViewControllerDelegate> delegate;
@property (weak,nonatomic) id<UIScrollViewDelegate> scrollViewDelegate;

@end


@protocol IDPSimplePhotoPickerViewControllerDelegate <NSObject>

- (void) simpleLibraryPickerViewController:(IDPSimplePhotoPickerViewController *)simpleLibraryPickerViewController didSelectAsset:(PHAsset *)asset;
- (void) simpleLibraryPickerViewControllerDidCancel:(IDPSimplePhotoPickerViewController *)simpleLibraryPickerViewController;

@end
