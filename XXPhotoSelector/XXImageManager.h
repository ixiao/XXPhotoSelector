//
//  XXImageManager.h
//  XXPhotoSelector
//
//  Created by 闫潇 on 16/10/14.
//  Copyright © 2016年 闫潇. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XXAssetModel.h"
@interface XXImageManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

+ (instancetype )manager;

- (void)getCameraRollAlbum:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(XXAlbumModel *albumModel))completion;

- (void)getAllAlbums:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void (^)(NSArray<XXAlbumModel *> *models))completion;

- (void)getAssetsFromFetchResult:(PHFetchResult *)result allowPickingVideo:(BOOL)allowPickingVideo allowPickingImage:(BOOL)allowPickingImage completion:(void(^)(NSArray<XXAssetModel * > *models))comletion;

- (PHImageRequestID)getPhotoWithAsset:(PHAsset *)asset width:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

- (void)getOriginalPhotoWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

@end
