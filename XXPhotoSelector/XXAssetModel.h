//
//  XXAssetModel.h
//  XXPhotoSelector
//
//  Created by 闫潇 on 16/10/15.
//  Copyright © 2016年 闫潇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger{
    XXAssetModelTypePhoto,
    XXAssetModelTypeLivePhoto,
    XXAssetModelTypeVideo,
    XXAssetModelTypeAudio,
}XXAssetModelType;

@interface XXAssetModel : NSObject
@property (nonatomic, strong) PHAsset * asset; ///< PHAsset or ALAsset
@property (nonatomic ) BOOL isSelector;
@property (nonatomic, assign) XXAssetModelType type;
@property (nonatomic, copy) NSString * timeLenght;

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(XXAssetModelType )type;
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(XXAssetModelType )type timeLength:(NSString *)timeLength;

@end

@interface XXAlbumModel : NSObject
@property (nonatomic, copy) NSString * name;
@property (nonatomic, assign) NSInteger albumCount;
@property (nonatomic, strong) PHFetchResult * result; ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>

@property (nonatomic, strong) NSArray *modelsArr;
@property (nonatomic, strong) NSArray *selectedModelsArr;
@property (nonatomic, assign) NSUInteger selectedCount;
@end
