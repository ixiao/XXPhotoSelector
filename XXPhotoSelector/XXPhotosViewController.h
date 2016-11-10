//
//  XXPhotosViewController.h
//  XXPhotoSelector
//
//  Created by 闫潇 on 16/10/14.
//  Copyright © 2016年 闫潇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXAlbumModel;
@class XXAssetModel;

@interface XXPhotosViewController : UIViewController
@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) XXAlbumModel * albumModel;

@property (nonatomic, strong) NSMutableArray<XXAssetModel *> * selectedModels;
@property (nonatomic, strong) NSMutableArray<XXAlbumModel *> * albumArray;
@end


@interface XXCollectionView : UICollectionView
@end

@interface XXNavgationController : UINavigationController
@end


