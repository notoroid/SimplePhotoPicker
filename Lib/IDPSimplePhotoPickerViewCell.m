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

//- (PHImageRequestOptions *)requestOptions
//{
//    if( _requestOptions == nil ){
//        _requestOptions = [[PHImageRequestOptions alloc] init];
//        _requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
//        _requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
//    }
//    return _requestOptions;
//}

//- (void) setSelected:(BOOL)selected;

- (void) updateThumbnailWithFetchResult:(PHFetchResult *)fetchResult cache:(NSCache *)cache index:(NSUInteger)index size:(CGSize)size
{
    _contentSize = size;
    _fetchResult = fetchResult;
    _cache = cache;
    
//    _imageManager = [[PHImageManager alloc] init];
    
//    _fastCacheID = [NSString stringWithFormat:@"fast%@",@(index)];
//    NSDictionary<NSString *,id> *dict = [_cache objectForKey:_fastCacheID];
//    if( dict == nil ){
//        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
//        
////        CGFloat scale = [UIScreen mainScreen].scale;
////        CGFloat imageSizeBudget = (4.0 / 3.0);
////        CGSize imageSize = CGSizeMake(_contentSize.width * scale * imageSizeBudget, _contentSize.height * scale * imageSizeBudget);
//    
//        __weak IDPSimplePhotoPickerViewCell *weakSelf = self;
//        [_fetchResult enumerateObjectsAtIndexes:indexSet options:0 usingBlock:^(PHAsset *  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
//            PHImageRequestOptions *options = self.requestOptions;
////            PHImageContentMode contentMode = PHImageContentModeAspectFill;
//            PHImageManager *defaultManager = [PHImageManager defaultManager];
//            
//            weakSelf.fastRequestID = [defaultManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//
//                weakSelf.fastRequestID = PHInvalidImageRequestID;
//                
//                if( imageData != nil ){
//#define IDP_IMAGE_DATA_KEY_NAME @"imageData"
//#define IDP_ORIENTATION_KEY_NAME @"orientation"
//                    NSMutableDictionary<NSString *,id> *mutableDict = [NSMutableDictionary<NSString *,id> dictionaryWithDictionary:@{IDP_IMAGE_DATA_KEY_NAME:imageData,IDP_ORIENTATION_KEY_NAME:@(orientation)}];
//                    
//                    if( dataUTI != nil ){
//#define IDP_DATA_UTI_KEY_NAME @"dataUTI"
//                        mutableDict[IDP_DATA_UTI_KEY_NAME] = dataUTI;
//                    }
//                    
//                    if( info != nil ){
//#define IDP_INFO_KEY_NAME @"info"
//                        mutableDict[IDP_INFO_KEY_NAME] = info;
//                    }
//                    
//                    if( _fastCacheID.length ){
//                        [_cache setObject:[NSDictionary<NSString *,id> dictionaryWithDictionary:mutableDict] forKey:_fastCacheID];
//                        
//                        NSDictionary<NSString *,id> *dict = [_cache objectForKey:_fastCacheID];
//                        
//                        [weakSelf setNeedsDisplay];
//                    }
//                }
//            }];
//        }];
//    }else{
//        [self setNeedsDisplay];
//    }

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
                        [weakSelf setNeedsDisplay];
                        
                        // 高画質読み込み開始
                        [self performSelector:@selector(updateQuality:) withObject:indexSet afterDelay:0.5];
                    }
                }];
        }];
    }else{
        _qualityImage = image;
        [self setNeedsDisplay];
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
                                                                [weakSelf setNeedsDisplay];
                                                                
                                                                [_cache setObject:_qualityImage forKey:_qualityCacheID];
                                                            }
                                                        }];
    }];
    
}

- (void) drawRect:(CGRect)rect
{
//    if( _fastCacheID.length ){
//        NSDictionary<NSString *,id> *dict = [_cache objectForKey:_fastCacheID];
//        
//        if( dict != nil ){
//            NSData *imageData = dict[IDP_IMAGE_DATA_KEY_NAME];
//            NSNumber *orientation = dict[IDP_ORIENTATION_KEY_NAME];
//            CGFloat scale = [UIScreen mainScreen].scale;
//            
//            @autoreleasepool {
//                UIImage *image = [UIImage imageWithData:imageData];
//                /*UIImage **/image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:[orientation integerValue]];
//                
//                CGFloat minimumEdge = MIN(image.size.width,image.size.height);
//                if( minimumEdge > 0 ){
//                    /*CGFloat*/ minimumEdge = MIN(image.size.width,image.size.height);
//                    if( minimumEdge > 0 ){
//                        CGFloat ratio = _contentSize.height / minimumEdge;
//                        // 倍率を算出
//                        CGRect imageArea = {CGPointZero,CGSizeMake(image.size.width * ratio ,image.size.height * ratio)};
//                        CGRect contentArea = AVMakeRectWithAspectRatioInsideRect(_contentSize,imageArea);
//                        
//                        CGRect renderArea = (CGRect){ CGPointMake( - CGRectGetMinX(contentArea) , - CGRectGetMinY(contentArea)),imageArea.size};
//                        [image drawInRect:renderArea];
//                    }
//                }
//            }
//        }
//        
//    }
    
    if( _qualityImage != nil ){
//        CGFloat minimumEdge = MIN(_qualityImage.size.width,_qualityImage.size.height);
//        if( minimumEdge > 0 ){
//            /*CGFloat*/ minimumEdge = MIN(_qualityImage.size.width,_qualityImage.size.height);
//            if( minimumEdge > 0 ){
//                CGFloat ratio = _contentSize.height / minimumEdge;
//                // 倍率を算出
//                CGRect imageArea = {CGPointZero,CGSizeMake(_qualityImage.size.width * ratio ,_qualityImage.size.height * ratio)};
//                CGRect contentArea = AVMakeRectWithAspectRatioInsideRect(_contentSize,imageArea);
//                
//                CGRect renderArea = (CGRect){ CGPointMake( - CGRectGetMinX(contentArea) , - CGRectGetMinY(contentArea)),imageArea.size};
//                [_qualityImage drawInRect:renderArea];
//            }
//        }
        
        _imageView.image = _qualityImage;
    }else if( _fastImage != nil ){
//        CGFloat minimumEdge = MIN(_fastImage.size.width,_fastImage.size.height);
//        if( minimumEdge > 0 ){
//            CGFloat ratio = _contentSize.height / minimumEdge;
//            // 倍率を算出
//            CGRect imageArea = {CGPointZero,CGSizeMake(_fastImage.size.width * ratio ,_fastImage.size.height * ratio)};
//            CGRect contentArea = AVMakeRectWithAspectRatioInsideRect(_contentSize,imageArea);
//            
//            CGRect renderArea = (CGRect){ CGPointMake( - CGRectGetMinX(contentArea) , - CGRectGetMinY(contentArea)),imageArea.size};
//            [_fastImage drawInRect:renderArea];
//        }
        _imageView.image = _fastImage;
        
    }else{
        [[UIColor whiteColor] setFill];

        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, rect);
    }
    
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
    
//    _imageManager = nil;
    
    [super prepareForReuse];
}

@end
