//
//  IDPSimplePhotoPickerViewCell.h
//  SimpleLibraryPicker
//
//  Created by 能登 要 on 2016/11/13.
//  Copyright © 2016年 Kaname Noto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHFetchResult;
@class PHCachingImageManager;

@protocol IDPSimplePhotoPickerViewCellDelegate;

@interface IDPSimplePhotoPickerViewCell : UICollectionViewCell

- (void) updateThumbnailWithFetchResult:(PHFetchResult *)fetchResult cache:(NSCache *)cache index:(NSUInteger)index size:(CGSize)size;

@property (weak,nonatomic) id<IDPSimplePhotoPickerViewCellDelegate> delegate;

@end

@protocol IDPSimplePhotoPickerViewCellDelegate <NSObject>

- (void) selectedSimpleLibraryPickerViewCellDidSelect:(IDPSimplePhotoPickerViewCell *)simpleLibraryPickerViewCell;

@end
