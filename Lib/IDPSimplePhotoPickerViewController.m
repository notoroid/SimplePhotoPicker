//
//  IDPSimplePhotoPickerViewController.m
//  SimpleLibraryPicker
//
//  Created by 能登 要 on 2016/11/13.
//  Copyright © 2016年 Kaname Noto. All rights reserved.
//

#import "IDPSimplePhotoPickerViewController.h"
#import "IDPSimplePhotoPickerViewCell.h"
@import Photos;

@interface IDPSimplePhotoPickerViewController () <IDPSimplePhotoPickerViewCellDelegate,PHPhotoLibraryChangeObserver>
{
    PHFetchResult *_assets;
    NSCache *_cache;
}
@property(readonly,nonatomic) NSCache *cache;
@end

@implementation IDPSimplePhotoPickerViewController

static NSString * const reuseIdentifier = @"simpleLibraryPickerViewCell";

+ (IDPSimplePhotoPickerViewController *)simplePhotoPickerViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IDPSimplePhotoPicker" bundle:nil];
    id viewController = [storyboard instantiateInitialViewController];
    return viewController;
}

- (NSCache *)cache
{
    if( _cache == nil ){
        _cache = [[NSCache alloc] init];
        _cache.countLimit = 44;
    }
    return _cache;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
    
    // 登録
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self updateAssets];
}

- (void) updateAssets
{
    // サイズを変更
    UICollectionViewLayout *collectionViewLayout = self.collectionViewLayout;
    if( [collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]] ){
        UICollectionViewFlowLayout *collectionViewFlowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        
        CGFloat cellEdge = [self cellEdge];
        
        CGRect bounds = [UIScreen mainScreen].bounds;
        collectionViewFlowLayout.minimumLineSpacing = [self minimumLineSpacingWithSize:bounds.size];
        
        collectionViewFlowLayout.minimumInteritemSpacing = 0.25;
        collectionViewFlowLayout.itemSize = CGSizeMake(cellEdge, cellEdge);
        collectionViewFlowLayout.estimatedItemSize = CGSizeMake(cellEdge, cellEdge);
    }
    
    // PHAssetCollectionを取得
    PHFetchResult *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    __block PHFetchResult *assets = nil;
    
    [assetCollections enumerateObjectsUsingBlock:^(PHAssetCollection *smartFolderAssetCollection, NSUInteger idx, BOOL *stop) {
        //        NSLog(@"momentAssetCollection:%@", smartFolderAssetCollection);
        
        //        NSLog(@"smartFolderAssetCollection.localizedLocationNames=%@", smartFolderAssetCollection.localizedLocationNames );
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %@",@(PHAssetMediaTypeImage)];
        // PHAssetを取得
        _assets = [PHAsset fetchAssetsInAssetCollection:smartFolderAssetCollection options:options];
        //        NSLog(@"assets.count=%@",@(assets.count) );
        *stop = YES;
    }];
    
    if( assets != nil ){
        _assets = assets;
    }
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
//    PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:_assets];

//    NSArray<NSIndexPath *> *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
//    __block NSUInteger row = -1;
//    [visibleIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        row = MAX(row,obj.row);
//    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _cache = nil;
        // キャッシュをリセット
        // アセットを更新
        [self updateAssets];

        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished) {
            
        }];

    });
    
}

- (void) onCancel:(id)sender
{
    [_delegate simpleLibraryPickerViewControllerDidCancel:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    UICollectionViewLayout *collectionViewLayout = self.collectionViewLayout;
    if( [collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]] ){
        UICollectionViewFlowLayout *collectionViewFlowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            collectionViewFlowLayout.minimumLineSpacing = [self minimumLineSpacingWithSize:size];
        }];
    }
    
}

- (CGFloat) minimumLineSpacingWithSize:(CGSize)size
{
    CGFloat minimumLineSpacingWithSize = 0;
    if( size.height > size.width ){
        if( [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad ){
            minimumLineSpacingWithSize = 1;
        }else{
            minimumLineSpacingWithSize = 1;
        }
    }else{
        if( [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad ){
            minimumLineSpacingWithSize = 2;
        }else{
            CGRect bounds = [UIScreen mainScreen].bounds;
            CGFloat maximumEdge = MAX(CGRectGetWidth(bounds),CGRectGetHeight(bounds));
//            CGFloat minimumEdge = MIN(CGRectGetWidth(bounds),CGRectGetHeight(bounds));
            
            NSInteger numberOfItem = (NSInteger)maximumEdge / (NSInteger)[self cellEdge];
            CGFloat itemSpace = (NSInteger)maximumEdge % (NSInteger)[self cellEdge];
            itemSpace = itemSpace / (numberOfItem -1);
            itemSpace = round(itemSpace);
            
            minimumLineSpacingWithSize = itemSpace;
        }
    }
    return minimumLineSpacingWithSize;
}

- (CGFloat) cellEdge
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat height = MIN(CGRectGetWidth(bounds),CGRectGetHeight(bounds));
    
    CGFloat ratio = [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad ? 0.25 : 0.2;
    return height * ratio - 0.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
//    cell.backgroundColor = [UIColor redColor];
    
    [self configureCell:cell withIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(UICollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    IDPSimplePhotoPickerViewCell *simpleLibraryPickerViewCell = [cell isKindOfClass:[IDPSimplePhotoPickerViewCell class]] ? (IDPSimplePhotoPickerViewCell *)cell : nil;
    simpleLibraryPickerViewCell.delegate = self;
    
    CGFloat cellEdge = [self cellEdge];
    CGSize size = CGSizeMake(cellEdge,cellEdge);

    [simpleLibraryPickerViewCell updateThumbnailWithFetchResult:_assets cache:self.cache index:indexPath.row size:size];
}

- (void) selectedSimpleLibraryPickerViewCellDidSelect:(IDPSimplePhotoPickerViewCell *)simpleLibraryPickerViewCell
{
    if( self.collectionView.dragging != YES && self.collectionView.decelerating != YES ){
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:simpleLibraryPickerViewCell];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.row];
        
        [_assets enumerateObjectsAtIndexes:indexSet options:0 usingBlock:^(PHAsset *  _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            [_delegate simpleLibraryPickerViewController:self didSelectAsset:asset];
            *stop = YES;
        }];
    }
    
}

@end
