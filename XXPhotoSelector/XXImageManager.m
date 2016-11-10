//
//  XXImageManager.m
//  XXPhotoSelector
//
//  Created by 闫潇 on 16/10/14.
//  Copyright © 2016年 闫潇. All rights reserved.
//

#import "XXImageManager.h"

@implementation XXImageManager

+ (instancetype)manager
{
    static XXImageManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XXImageManager alloc]init];
        manager.cachingImageManager = [[PHCachingImageManager alloc]init];
        
    });
    return manager;
}
- (void)getCameraRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(XXAlbumModel * albumModel))completion{

    __block XXAlbumModel * model;
    
    PHFetchOptions * option = [PHFetchOptions new];
    if (!allowPickingVideo)  option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeImage];
    
    if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType ==%ld",PHAssetMediaTypeVideo];
    
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
    
    PHFetchResult * resultAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection * collection in resultAlbums) {
        
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        
        if ([self isCameraRollAlbum:collection.localizedTitle]) {
            PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            model = [self modelWithResult:result name:collection.localizedTitle];
            if (completion) completion(model);
        }
    }
}

- (void)getAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<XXAlbumModel *> *))completion
{
    NSMutableArray *albumArr = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    if (!allowPickingImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                                PHAssetMediaTypeVideo];
    
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    for (PHAssetCollection *collection in smartAlbums) {
        
        // 有可能是PHCollectionList类的的对象，过滤掉
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count < 1) continue;
        if ([collection.localizedTitle containsString:@"Deleted"] || [collection.localizedTitle isEqualToString:@"最近删除"]) continue;
        if ([self isCameraRollAlbum:collection.localizedTitle]) {
            
            [albumArr insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle] atIndex:0];
        } else {
            [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
        }
    }
    for (PHAssetCollection *collection in topLevelUserCollections) {
        // 有可能是PHCollectionList类的的对象，过滤掉
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count < 1) continue;
        [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle]];
    }
    if (completion && albumArr.count > 0) completion(albumArr);
}

- (void)getAssetsFromFetchResult:(PHFetchResult *)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void(^)(NSArray<XXAssetModel * > *models))comletion{
    NSMutableArray * photoArr = [NSMutableArray array];
    
    if ([result isKindOfClass:[PHFetchResult class]]) {
        
        [result enumerateObjectsUsingBlock:^(PHAsset * asset, NSUInteger idx, BOOL * _Nonnull stop) {
            XXAssetModelType type = XXAssetModelTypePhoto;
            if (asset.mediaType == PHAssetMediaTypeVideo) type = XXAssetModelTypeVideo;
            else if (asset.mediaType == PHAssetMediaTypeAudio) type = XXAssetModelTypeAudio;
            
            if (!allowPickingVideo && type == XXAssetModelTypeVideo) return;
            if (!allowPickingImage && type == XXAssetModelTypePhoto) return;
            
            NSString * timeLength = type == XXAssetModelTypeVideo ? [NSString stringWithFormat:@"%0.0f",asset.duration] : @"";
            
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
             [photoArr addObject:[XXAssetModel modelWithAsset:asset type:type timeLength:timeLength]];
        }];
    }
    if (comletion) {
        comletion(photoArr);
    }
    
}

- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset width:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion{

    PHImageRequestOptions * options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    CGSize  size = CGSizeMake(150, 150);
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL isDownload = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![[info objectForKey:PHImageErrorKey] boolValue]);
        
        if (isDownload && result) {
            
            if (completion) {
                completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
            
             // Download image from iCloud
            
            if ([info objectForKey:PHImageResultIsInCloudKey] && !result) {
                
                PHImageRequestOptions * options = [[PHImageRequestOptions alloc]init];
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                
                [[PHImageManager defaultManager]requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    resultImage = [self scaleImage:resultImage toSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)];
                    
                    if (resultImage) {
//                        resultImage = [self fixOrientation:resultImage];
                        if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    }
                }];
            }
        }
    }];
    
    return imageRequestID;
}

- (void)getOriginalPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            if (completion) completion(result,info);
        }
    }];
}


- (XXAlbumModel *)modelWithResult:(PHFetchResult *)result name:(NSString *)name {
    
    XXAlbumModel * model = [[XXAlbumModel alloc]init];
    model.result = result;
    model.name = name;
    model.albumCount = result.count;
    NSLog(@"album:%@",name);
    return model;
}
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}
- (BOOL)isCameraRollAlbum:(NSString *)albumName {
    NSString *versionStr = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (versionStr.length <= 1) {
        versionStr = [versionStr stringByAppendingString:@"00"];
    } else if (versionStr.length <= 2) {
        versionStr = [versionStr stringByAppendingString:@"0"];
    }
    CGFloat version = versionStr.floatValue;
    // 目前已知8.0.0 - 8.0.2系统，拍照后的图片会保存在最近添加中
    if (version >= 800 && version <= 802) {
        return [albumName isEqualToString:@"最近添加"] || [albumName isEqualToString:@"Recently Added"];
    } else {
        return [albumName isEqualToString:@"Camera Roll"] || [albumName isEqualToString:@"相机胶卷"] || [albumName isEqualToString:@"所有照片"] || [albumName isEqualToString:@"All Photos"];
    }
}
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}
@end
