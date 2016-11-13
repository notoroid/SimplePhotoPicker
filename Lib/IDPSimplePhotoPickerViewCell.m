//
//  IDPSimplePhotoPickerViewCell.m
//  SimpleLibraryPicker
//
//  Created by 能登 要 on 2016/11/13.
//  Copyright © 2016年 Kaname Noto. All rights reserved.
//

#import "IDPSimplePhotoPickerViewCell.h"
@import Photos;
//@import AVFoundation;

@interface IDPSimplePhotoPickerViewCell () 
{
    __weak IBOutlet UIView *_highlightedView;
    __weak IBOutlet UIImageView *_imageView;
    __weak PHFetchResult *_fetchResult;
    __weak NSCache *_cache;
    
    NSString *_qualityCacheID;
    UIImage *_fastImage;
    UIImage *_qualityImage;
    
    CGSize _contentSize;
    
    PHImageRequestOptions *_requestOptions;
}
@property (assign,nonatomic) PHImageRequestID fastRequestID;
@property (assign,nonatomic) PHImageRequestID qualityRequestID;
@end

@implementation IDPSimplePhotoPickerViewCell

- (void) setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    _highlightedView.hidden = highlighted ? NO : YES;
}

- (void) setSelected:(BOOL)selected
{
    if( selected == YES ){
        [_delegate selectedSimpleLibraryPickerViewCellDidSelect:self];
    }
}

- (void) updateThumbnailWithFetchResult:(PHFetchResult *)fetchResult cache:(NSCache *)cache index:(NSUInteger)index size:(CGSize)size
{
    _contentSize = size;
    _fetchResult = fetchResult;
    _cache = cache;
    
    _qualityCacheID = [NSString stringWithFormat:@"quality%@",@(index)];
    
    UIImage *image = [_cache objectForKey:_qualityCacheID];
    if( image == nil ){
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat imageSizeBudget = (4.0 / 3.0);
        CGSize imageSize = CGSizeMake(_contentSize.width * scale * imageSizeBudget, _contentSize.height * scale * imageSizeBudget);
        
        __weak IDPSimplePhotoPickerViewCell *weakSelf = self;
        [_fetchResult enumerateObjectsAtIndexes:indexSet options:0 usingBlock:^(PHAsset *  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            PHImageContentMode contentMode = PHImageContentModeAspectFill;
            
            PHImageManager *defaultManager = [PHImageManager defaultManager];
            
            weakSelf.fastRequestID = [defaultManager /*_imageManager*/ requestImageForAsset:asset
                   targetSize:imageSize /*retina*/
                  contentMode:contentMode
                      options:options
                resultHandler:^(UIImage *result, NSDictionary *info) {
                    weakSelf.fastRequestID = PHInvalidImageRequestID;

                    if (result) {
                        _fastImage = [UIImage imageWithCGImage:result.CGImage scale:scale orientation:result.imageOrientation];
                        _imageView.image = _fastImage;
                        
                        // 高画質読み込み開始
                        [self performSelector:@selector(updateQuality:) withObject:indexSet afterDelay:0.5];
                    }
                }];
        }];
    }else{
        _qualityImage = image;
        _imageView.image = _qualityImage;
    }
    

}

- (void) updateQuality:(id)obj
{
    NSIndexSet *indexSet = obj;
    
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat imageSizeBudget = (4.0 / 3.0);
    
    CGSize imageSize = CGSizeMake(_contentSize.width * scale * imageSizeBudget, _contentSize.height * scale * imageSizeBudget);
    
    __weak IDPSimplePhotoPickerViewCell *weakSelf = self;
    [_fetchResult enumerateObjectsAtIndexes:indexSet options:0 usingBlock:^(PHAsset *  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        
        PHImageContentMode contentMode = PHImageContentModeAspectFill;
        PHImageManager *defaultManager = [PHImageManager defaultManager];
        
        weakSelf.qualityRequestID = [defaultManager requestImageForAsset:asset
                                                           targetSize:imageSize /*retina*/
                                                          contentMode:contentMode
                                                              options:options
                                                        resultHandler:^(UIImage *result, NSDictionary *info) {
                                                            weakSelf.qualityRequestID = PHInvalidImageRequestID;
                                                            
                                                            if (result) {
                                                                _qualityImage = [UIImage imageWithCGImage:result.CGImage scale:scale orientation:result.imageOrientation];
                                                                _imageView.image = _qualityImage;
                                                                
                                                                [_cache setObject:_qualityImage forKey:_qualityCacheID];
                                                            }
                                                        }];
    }];
    
}

- (void) prepareForReuse
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if( _fastRequestID != PHInvalidImageRequestID ){
        PHImageManager *defaultManager = [PHImageManager defaultManager];
        [defaultManager cancelImageRequest:_fastRequestID];
        _fastRequestID = PHInvalidImageRequestID;
    }
    _fastImage = nil;
    
    if( _qualityRequestID != PHInvalidImageRequestID ){
        PHImageManager *defaultManager = [PHImageManager defaultManager];
        [defaultManager cancelImageRequest:_fastRequestID];
        _qualityRequestID = PHInvalidImageRequestID;
    }
    _qualityImage = nil;

    _qualityCacheID = nil;
    
    _imageView.image = nil;
    
    [super prepareForReuse];
}

@end
