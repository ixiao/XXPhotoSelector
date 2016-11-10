//
//  XXAssetModel.m
//  XXPhotoSelector
//
//  Created by 闫潇 on 16/10/15.
//  Copyright © 2016年 闫潇. All rights reserved.
//

#import "XXAssetModel.h"
#import "XXImageManager.h"
@implementation XXAssetModel
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(XXAssetModelType)type
{
    XXAssetModel * model = [[XXAssetModel alloc]init];
    model.asset = asset;
    model.type = type;
    model.isSelector = NO;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(XXAssetModelType)type timeLength:(NSString *)timeLength
{
    XXAssetModel * model = [self modelWithAsset:asset type:type];
    model.timeLenght = timeLength;
    return  model;
}
@end

@implementation XXAlbumModel

- (void)setResult:(PHFetchResult *)result
{
    _result = result;
    
   //  BOOL allowPickingVideo = [[NSUserDefaults standardUserDefaults] boolForKey:@"allowPickingVideo"];
   // BOOL allowPickingImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"allowPickingImage"];
    
    [[XXImageManager manager] getAssetsFromFetchResult:result allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<XXAssetModel *> *models) {
        _modelsArr = models;
        
        if (_selectedModelsArr) {
            [self checkSelectModelsArr];
        }
    }];
}
- (void)setSelectedModelsArr:(NSArray *)selectedModelsArr
{
    _selectedModelsArr = selectedModelsArr;
    if (_modelsArr) {
        [self checkSelectModelsArr];
    }
}
- (void)checkSelectModelsArr
{
    self.selectedCount = 0;
    NSMutableArray * selectAssets = [NSMutableArray array];
    
    for (XXAssetModel * model in _selectedModelsArr) {
        [selectAssets addObject:model];
    }
    
}
@end
